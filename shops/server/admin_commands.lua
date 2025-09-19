-- [file name]: server/admin_commands.lua
local AdminCommands = {}

-- تهيئة الأوامر الإدارية
function AdminCommands:init()
    self:registerCommands()
    DebugPrint('تم تهيئة أوامر الأدمن بنجاح', 'info')
end

-- تسجيل الأوامر
function AdminCommands:registerCommands()
    -- أمر إعادة تحميل المتاجر
    RegisterCommand('shops_reload', function(source, args, rawCommand)
        self:reloadShops(source)
    end, false)

    -- أمر عرض إحصائيات المتجر
    RegisterCommand('shops_stats', function(source, args, rawCommand)
        self:showShopStats(source, tonumber(args[1]))
    end, false)

    -- أمر إضافة عنصر
    RegisterCommand('shops_additem', function(source, args, rawCommand)
        if #args < 3 then
            self:sendUsage(source, 'shops_additem <shop_id> <item_name> <price> [stock] [category]')
            return
        end
        
        local shopId = tonumber(args[1])
        local itemName = args[2]
        local price = tonumber(args[3])
        local stock = tonumber(args[4]) or 10
        local category = args[5] or 'عام'
        
        self:addItemToShop(source, shopId, itemName, price, stock, category)
    end, false)

    -- أمر تحديث السعر
    RegisterCommand('shops_setprice', function(source, args, rawCommand)
        if #args < 3 then
            self:sendUsage(source, 'shops_setprice <shop_id> <item_name> <new_price>')
            return
        end
        
        local shopId = tonumber(args[1])
        local itemName = args[2]
        local newPrice = tonumber(args[3])
        
        self:setItemPrice(source, shopId, itemName, newPrice)
    end, false)

    -- أمر تحديث المخزون
    RegisterCommand('shops_setstock', function(source, args, rawCommand)
        if #args < 3 then
            self:sendUsage(source, 'shops_setstock <shop_id> <item_name> <new_stock>')
            return
        end
        
        local shopId = tonumber(args[1])
        local itemName = args[2]
        local newStock = tonumber(args[3])
        
        self:setItemStock(source, shopId, itemName, newStock)
    end, false)

    -- أمر إعادة تعيين المخزون
    RegisterCommand('shops_restock', function(source, args, rawCommand)
        local shopId = args[1] and tonumber(args[1]) or nil
        self:restockShop(source, shopId)
    end, false)

    -- أمر عرض سجل المعاملات
    RegisterCommand('shops_transactions', function(source, args, rawCommand)
        local shopId = args[1] and tonumber(args[1]) or nil
        local limit = args[2] and tonumber(args[2]) or 10
        self:showTransactions(source, shopId, limit)
    end, false)

    DebugPrint('تم تسجيل أوامر الأدمن بنجاح', 'info')
end

-- إعادة تحميل المتاجر
function AdminCommands:reloadShops(source)
    if not self:hasPermission(source) then
        self:sendNoPermission(source)
        return
    end

    ShopService:clearCache()
    TriggerClientEvent('shops:notification', source, {
        type = 'success',
        message = 'تم إعادة تحميل المتاجر بنجاح'
    })
    
    DebugPrint('تم إعادة تحميل المتاجر بواسطة: ' .. GetPlayerName(source), 'info')
end

-- عرض إحصائيات المتجر
function AdminCommands:showShopStats(source, shopId)
    if not self:hasPermission(source) then
        self:sendNoPermission(source)
        return
    end

    local stats
    if shopId then
        stats = ShopRepository:getStatistics(shopId)
    else
        stats = self:getAllStatistics()
    end

    TriggerClientEvent('chat:addMessage', source, {
        args = {'^2[Shops]', 'الإحصائيات:'}
    })
    
    if shopId then
        self:sendShopStats(source, stats, shopId)
    else
        for _, shopStats in ipairs(stats) do
            self:sendShopStats(source, shopStats, shopStats.shop_id)
        end
    end
end

-- إضافة عنصر للمتجر
function AdminCommands:addItemToShop(source, shopId, itemName, price, stock, category)
    if not self:hasPermission(source) then
        self:sendNoPermission(source)
        return
    end

    local itemInfo = GetItemInfo(itemName)
    if not itemInfo then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^1[Shops]', 'العنصر غير موجود: ' .. itemName}
        })
        return
    end

    local itemData = {
        name = itemName,
        label = itemInfo.label,
        price = price,
        stock = stock,
        maxStock = stock * 2,
        category = category,
        weight = itemInfo.weight or 0.1
    }

    local success = ShopRepository:addItemToShop(shopId, itemData)
    if success then
        ShopService:clearCache(shopId)
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^2[Shops]', 'تم إضافة العنصر بنجاح'}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^1[Shops]', 'فشل في إضافة العنصر'}
        })
    end
end

-- تحديث سعر العنصر
function AdminCommands:setItemPrice(source, shopId, itemName, newPrice)
    if not self:hasPermission(source) then
        self:sendNoPermission(source)
        return
    end

    local success = ShopRepository:updateItemPrice(shopId, itemName, newPrice)
    if success then
        ShopService:clearCache(shopId)
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^2[Shops]', 'تم تحديث السعر بنجاح'}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^1[Shops]', 'فشل في تحديث السعر'}
        })
    end
end

-- تحديث مخزون العنصر
function AdminCommands:setItemStock(source, shopId, itemName, newStock)
    if not self:hasPermission(source) then
        self:sendNoPermission(source)
        return
    end

    local success = ShopRepository:updateItemStock(shopId, itemName, newStock)
    if success then
        ShopService:clearCache(shopId)
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^2[Shops]', 'تم تحديث المخزون بنجاح'}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^1[Shops]', 'فشل في تحديث المخزون'}
        })
    end
end

-- إعادة تعيين المخزون
function AdminCommands:restockShop(source, shopId)
    if not self:hasPermission(source) then
        self:sendNoPermission(source)
        return
    end

    if shopId then
        local success = ShopRepository:restockShop(shopId)
        if success then
            ShopService:clearCache(shopId)
            TriggerClientEvent('chat:addMessage', source, {
                args = {'^2[Shops]', 'تم إعادة تعيين مخزون المتجر ' .. shopId}
            })
        end
    else
        for id, _ in pairs(ShopService:getAllShops()) do
            ShopRepository:restockShop(id)
        end
        ShopService:clearCache()
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^2[Shops]', 'تم إعادة تعيين جميع المتاجر'}
        })
    end
end

-- عرض سجل المعاملات
function AdminCommands:showTransactions(source, shopId, limit)
    if not self:hasPermission(source) then
        self:sendNoPermission(source)
        return
    end

    local transactions = ShopRepository:getTransactionHistory(nil, shopId, limit)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {'^2[Shops]', 'سجل المعاملات:'}
    })
    
    for _, transaction in ipairs(transactions) do
        local message = string.format('^3%s^0 - %s اشترى %d من %s بسعر %s%s',
            os.date('%Y-%m-%d %H:%M', transaction.transaction_date),
            transaction.player_name,
            transaction.quantity,
            transaction.item_label,
            Config.Currency,
            FormatNumber(transaction.final_price)
        )
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {'^2[Shops]', message}
        })
    end
end

-- التحقق من الصلاحيات
function AdminCommands:hasPermission(source)
    return IsPlayerAceAllowed(source, Config.Settings.AdminPermission)
end

-- إرسال رسالة عدم الصلاحية
function AdminCommands:sendNoPermission(source)
    TriggerClientEvent('chat:addMessage', source, {
        args = {'^1[Shops]', 'ليس لديك الصلاحية لاستخدام هذا الأمر'}
    })
end

-- إرسال طريقة الاستخدام
function AdminCommands:sendUsage(source, usage)
    TriggerClientEvent('chat:addMessage', source, {
        args = {'^3[Shops]', 'طريقة الاستخدام: /' .. usage}
    })
end

-- الحصول على جميع الإحصائيات
function AdminCommands:getAllStatistics()
    local allStats = {}
    for shopId, _ in pairs(ShopService:getAllShops()) do
        local stats = ShopRepository:getStatistics(shopId)
        if stats then
            table.insert(allStats, stats)
        end
    end
    return allStats
end

-- إرسال إحصائيات المتجر
function AdminCommands:sendShopStats(source, stats, shopId)
    if not stats then return end

    local shop = ShopService:getShop(shopId)
    local shopName = shop and shop.name or 'المتجر ' .. shopId
    
    local message = string.format('^2%s^0 - الإيرادات: %s%s - المعاملات: %d - العملاء: %d',
        shopName,
        Config.Currency,
        FormatNumber(stats.total_sales or 0),
        stats.total_transactions or 0,
        stats.unique_customers or 0
    )
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {'^2[Shops]', message}
    })
end

-- تهيئة الأوامر
AdminCommands:init()

return AdminCommands
