-- [file name]: server/transaction_manager.lua
local TransactionManager = {}

-- تهيئة مدير المعاملات
function TransactionManager:init()
    self.transactions = {}
    self:startCleanupTask()
    DebugPrint('تم تهيئة مدير المعاملات بنجاح', 'info')
end

-- تسجيل معاملة جديدة
function TransactionManager:addTransaction(transactionData)
    local transactionId = #self.transactions + 1
    
    local transaction = {
        id = transactionId,
        shopId = transactionData.shopId,
        playerIdentifier = transactionData.playerIdentifier,
        playerName = transactionData.playerName,
        itemName = transactionData.itemName,
        itemLabel = transactionData.itemLabel,
        quantity = transactionData.quantity,
        unitPrice = transactionData.unitPrice,
        totalPrice = transactionData.totalPrice,
        discountAmount = transactionData.discountAmount or 0,
        taxAmount = transactionData.taxAmount or 0,
        finalPrice = transactionData.finalPrice,
        transactionType = transactionData.transactionType or 'purchase',
        timestamp = os.time(),
        metadata = transactionData.metadata or {}
    }
    
    table.insert(self.transactions, transaction)
    
    -- حفظ في قاعدة البيانات إذا كان مفعل
    if Config.Settings.SaveTransactions then
        ShopRepository:addTransaction(transaction)
    end
    
    DebugPrint(string.format('تم تسجيل معاملة جديدة: %s - %s', 
        transaction.playerName, transaction.itemLabel), 'info')
    
    return transactionId
end

-- الحصول على معاملة بواسطة المعرف
function TransactionManager:getTransaction(transactionId)
    for _, transaction in ipairs(self.transactions) do
        if transaction.id == transactionId then
            return transaction
        end
    end
    return nil
end

-- الحصول على معاملات اللاعب
function TransactionManager:getPlayerTransactions(playerIdentifier, limit)
    local playerTransactions = {}
    local count = 0
    
    for _, transaction in ipairs(self.transactions) do
        if transaction.playerIdentifier == playerIdentifier then
            table.insert(playerTransactions, transaction)
            count = count + 1
            
            if limit and count >= limit then
                break
            end
        end
    end
    
    return playerTransactions
end

-- الحصول على معاملات المتجر
function TransactionManager:getShopTransactions(shopId, limit)
    local shopTransactions = {}
    local count = 0
    
    for _, transaction in ipairs(self.transactions) do
        if transaction.shopId == shopId then
            table.insert(shopTransactions, transaction)
            count = count + 1
            
            if limit and count >= limit then
                break
            end
        end
    end
    
    return shopTransactions
end

-- الحصول على إحصائيات المعاملات
function TransactionManager:getStatistics(shopId, startDate, endDate)
    local stats = {
        totalSales = 0,
        totalTransactions = 0,
        uniqueCustomers = {},
        popularItems = {},
        dailyRevenue = {}
    }
    
    for _, transaction in ipairs(self.transactions) do
        if shopId and transaction.shopId ~= shopId then
            goto continue
        end
        
        if startDate and transaction.timestamp < startDate then
            goto continue
        end
        
        if endDate and transaction.timestamp > endDate then
            goto continue
        end
        
        -- إجمالي المبيعات
        stats.totalSales = stats.totalSales + transaction.finalPrice
        stats.totalTransactions = stats.totalTransactions + 1
        
        -- العملاء الفريدون
        stats.uniqueCustomers[transaction.playerIdentifier] = true
        
        -- العناصر الشائعة
        stats.popularItems[transaction.itemName] = (stats.popularItems[transaction.itemName] or 0) + transaction.quantity
        
        -- الإيرادات اليومية
        local date = os.date('%Y-%m-%d', transaction.timestamp)
        stats.dailyRevenue[date] = (stats.dailyRevenue[date] or 0) + transaction.finalPrice
        
        ::continue::
    end
    
    stats.uniqueCustomersCount = countTable(stats.uniqueCustomers)
    
    return stats
end

-- استرجاع معاملة (refund)
function TransactionManager:refundTransaction(transactionId, adminSource)
    local transaction = self:getTransaction(transactionId)
    if not transaction then
        return false, 'المعاملة غير موجودة'
    end
    
    if transaction.transactionType == 'refund' then
        return false, 'تم استرجاع هذه المعاملة مسبقاً'
    end
    
    -- إعادة المال للاعب
    local playerId = self:getPlayerIdByIdentifier(transaction.playerIdentifier)
    if playerId then
        ShopService:addPlayerMoney(playerId, transaction.finalPrice)
    end
    
    -- تحديث المخزون
    ShopRepository:updateItemStock(
        transaction.shopId,
        transaction.itemName,
        (ShopService:getShop(transaction.shopId).items[transaction.itemName].stock or 0) + transaction.quantity
    )
    
    -- تسجيل معاملة الاسترجاع
    local refundTransaction = {
        shopId = transaction.shopId,
        playerIdentifier = transaction.playerIdentifier,
        playerName = transaction.playerName,
        itemName = transaction.itemName,
        itemLabel = transaction.itemLabel,
        quantity = transaction.quantity,
        unitPrice = transaction.unitPrice,
        totalPrice = transaction.totalPrice,
        discountAmount = transaction.discountAmount,
        taxAmount = transaction.taxAmount,
        finalPrice = transaction.finalPrice,
        transactionType = 'refund',
        metadata = {
            originalTransactionId = transactionId,
            refundedBy = adminSource and GetPlayerName(adminSource) or 'System',
            refundReason = 'Admin refund'
        }
    }
    
    self:addTransaction(refundTransaction)
    
    DebugPrint(string.format('تم استرجاع معاملة %d للاعب %s', 
        transactionId, transaction.playerName), 'info')
    
    return true, 'تم الاسترجاع بنجاح'
end

-- مهمة تنظيف المعاملات القديمة
function TransactionManager:startCleanupTask()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30 * 60 * 1000) -- كل 30 دقيقة
            
            local currentTime = os.time()
            local maxAge = 24 * 60 * 60 -- 24 ساعة
            
            for i = #self.transactions, 1, -1 do
                local transaction = self.transactions[i]
                if currentTime - transaction.timestamp > maxAge then
                    table.remove(self.transactions, i)
                end
            end
            
            DebugPrint('تم تنظيف المعاملات القديمة', 'debug')
        end
    end)
end

-- الحصول على معرف اللاعب بواسطة المعرف الفريد
function TransactionManager:getPlayerIdByIdentifier(identifier)
    for _, playerId in ipairs(GetPlayers()) do
        local playerIdentifier = GetPlayerIdentifier(playerId)
        if playerIdentifier == identifier then
            return playerId
        end
    end
    return nil
end

-- تصدير المعاملات إلى ملف
function TransactionManager:exportTransactions(filename, shopId, startDate, endDate)
    local transactions = shopId and self:getShopTransactions(shopId) or self.transactions
    local filteredTransactions = {}
    
    for _, transaction in ipairs(transactions) do
        if startDate and transaction.timestamp < startDate then
            goto continue
        end
        
        if endDate and transaction.timestamp > endDate then
            goto continue
        end
        
        table.insert(filteredTransactions, transaction)
        ::continue::
    end
    
    local data = json.encode(filteredTransactions, {indent = true})
    local filePath = GetResourcePath(GetCurrentResourceName()) .. '/exports/' .. (filename or 'transactions.json')
    
    -- حفظ الملف
    local file = io.open(filePath, 'w')
    if file then
        file:write(data)
        file:close()
        return true, filePath
    end
    
    return false, 'فشل في حفظ الملف'
end

-- تهيئة المدير
TransactionManager:init()

return TransactionManager
