-- [file name]: server/shop_service.lua
local ShopService = {}
ShopService.shops = {}

-- تهيئة الخدمة
function ShopService:init()
    self.shops = {}
    self.players = {}
    self.transactions = {}
    
    self:loadShops()
    self:startRestockTask()
    self:startCacheCleanupTask()
    
    DebugPrint('تم تهيئة خدمة المتاجر بنجاح', 'success')
end

-- تحميل المتاجر
function ShopService:loadShops()
    local shopsData = ShopRepository:getAllShops()
    
    for _, shopData in ipairs(shopsData) do
        local shop = {
            id = shopData.id,
            name = shopData.name,
            type = shopData.type,
            location = shopData.location,
            blip = shopData.blip,
            marker = shopData.marker,
            hours = shopData.hours,
            isOpen = shopData.isOpen,
            items = {},
            statistics = ShopRepository:getStatistics(shopData.id)
        }
        
        -- تحميل العناصر
        local itemsData = ShopRepository:getShopItems(shopData.id)
        for _, itemData in ipairs(itemsData) do
            shop.items[itemData.name] = {
                price = itemData.price,
                stock = itemData.stock,
                maxStock = itemData.maxStock,
                category = itemData.category,
                weight = itemData.weight,
                metadata = {
                    type = itemData.type,
                    description = itemData.description,
                    image = itemData.image,
                    rarity = itemData.rarity,
                    icon = itemData.icon
                }
            }
        end
        
        self.shops[shop.id] = shop
    end
    
    DebugPrint(string.format('تم تحميل %d متجر بنجاح', #shopsData), 'info')
end

-- الحصول على متجر
function ShopService:getShop(shopId)
    return self.shops[shopId]
end

-- الحصول على جميع المتاجر
function ShopService:getAllShops()
    return self.shops
end

-- الحصول على قائمة المتاجر
function ShopService:getShopsList()
    local shopsList = {}
    
    for shopId, shop in pairs(self.shops) do
        local itemCount = 0
        for _ in pairs(shop.items) do itemCount = itemCount + 1 end
        
        table.insert(shopsList, {
            id = shopId,
            name = shop.name,
            type = shop.type,
            itemCount = itemCount,
            isOpen = shop.isOpen,
            icon = GetShopTypeIcon(shop.type),
            totalRevenue = shop.statistics and shop.statistics.total_sales or 0
        })
    end
    
    return shopsList
end

-- معالجة عملية الشراء
function ShopService:purchaseItem(shopId, itemName, quantity, source)
    local shop = self:getShop(shopId)
    if not shop then
        return false, Config.Locales['shop_not_found'], 0
    end
    
    -- التحقق إذا كان المتجر مفتوحاً
    if not shop.isOpen then
        return false, Config.Locales['shop_closed'], 0
    end
    
    local item = shop.items[itemName]
    if not item then
        return false, Config.Locales['item_not_found'], 0
    end
    
    quantity = tonumber(quantity) or 1
    if quantity <= 0 or quantity > Config.Settings.MaxPurchaseQuantity then
        return false, Config.Locales['invalid_quantity'], 0
    end
    
    if item.stock < quantity then
        return false, Config.Locales['no_stock'], 0
    end
    
    local totalPrice = item.price * quantity
    local discount, tax, finalPrice = CalculateFinalPrice(totalPrice)
    
    -- التحقق من رصيد اللاعب
    local playerMoney = self:getPlayerMoney(source)
    if playerMoney < finalPrice then
        return false, Config.Locales['not_enough_money'], 0
    end
    
    -- خصم المال
    local moneyDeducted = self:removePlayerMoney(source, finalPrice)
    if not moneyDeducted then
        return false, Config.Locales['system_error'], 0
    end
    
    -- تحديث المخزون
    item.stock = item.stock - quantity
    local stockUpdated = ShopRepository:updateItemStock(shopId, itemName, item.stock)
    if not stockUpdated then
        -- استرجاع المال إذا فشل تحديث المخزون
        self:addPlayerMoney(source, finalPrice)
        return false, Config.Locales['system_error'], 0
    end
    
    -- إعطاء العنصر للاعب
    local itemGiven = self:givePlayerItem(source, itemName, quantity)
    if not itemGiven then
        -- استرجاع المال والعكس إذا فشل إعطاء العنصر
        self:addPlayerMoney(source, finalPrice)
        item.stock = item.stock + quantity
        ShopRepository:updateItemStock(shopId, itemName, item.stock)
        return false, Config.Locales['system_error'], 0
    end
    
    -- تسجيل المعاملة
    local playerIdentifier = GetPlayerIdentifier(source)
    local playerName = GetPlayerName(source)
    local itemInfo = GetItemInfo(itemName)
    
    local transactionData = {
        shopId = shopId,
        playerIdentifier = playerIdentifier,
        playerName = playerName,
        itemName = itemName,
        itemLabel = itemInfo.label,
        quantity = quantity,
        unitPrice = item.price,
        totalPrice = totalPrice,
        discountAmount = totalPrice * discount,
        taxAmount = tax,
        finalPrice = finalPrice,
        transactionType = 'purchase',
        metadata = {
            shopName = shop.name,
            itemCategory = item.category,
            itemRarity = itemInfo.rarity
        }
    }
    
    local transactionLogged = ShopRepository:addTransaction(transactionData)
    if not transactionLogged then
        DebugPrint('فشل في تسجيل المعاملة', 'error')
    end
    
    -- تحديث الإحصائيات
    self:updateShopStatistics(shopId, finalPrice, playerIdentifier)
    
    -- تشغيل صوت النجاح
    self:playSound(source, 'PurchaseSuccess')
    
    DebugPrint(string.format('تم البيع: %s اشترى %d من %s بسعر %s', 
        playerName, quantity, itemName, finalPrice), 'success')
    
    return true, Config.Locales['buy_success'], finalPrice
end

-- الحصول على رصيد اللاعب
function ShopService:getPlayerMoney(source)
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getMoney()
        end
    end
    return 0
end

-- خصم المال من اللاعب
function ShopService:removePlayerMoney(source, amount)
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeMoney(amount)
            return true
        end
    end
    return false
end

-- إضافة مال للاعب
function ShopService:addPlayerMoney(source, amount)
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(amount)
            return true
        end
    end
    return false
end

-- إعطاء عنصر للاعب
function ShopService:givePlayerItem(source, itemName, quantity)
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addInventoryItem(itemName, quantity)
            return true
        end
    end
    return false
end

-- تحديث إحصائيات المتجر
function ShopService:updateShopStatistics(shopId, amount, playerIdentifier)
    local shop = self:getShop(shopId)
    if shop and shop.statistics then
        shop.statistics.total_sales = (shop.statistics.total_sales or 0) + amount
        shop.statistics.total_transactions = (shop.statistics.total_transactions or 0) + 1
        
        -- يمكن إضافة المزيد من تحديثات الإحصائيات هنا
    end
end

-- مهمة إعادة التخزين التلقائي
function ShopService:startRestockTask()
    if not Config.Settings.AutoRestock then return end
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.Settings.RestockInterval * 1000)
            
            for shopId, shop in pairs(self.shops) do
                for itemName, item in pairs(shop.items) do
                    if item.stock < item.maxStock then
                        item.stock = item.maxStock
                        ShopRepository:updateItemStock(shopId, itemName, item.stock)
                    end
                end
            end
            
            DebugPrint('تم إعادة تخزين جميع المتاجر تلقائياً', 'info')
        end
    end)
end

-- مهمة تنظيف الذاكرة المؤقتة
function ShopService:startCacheCleanupTask()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(300000) -- كل 5 دقائق
            
            for shopId, shop in pairs(self.shops) do
                shop.isOpen = IsShopOpen(shop.hours.open, shop.hours.close)
            end
            
            ShopRepository:clearAllCache()
        end
    end)
end

-- تشغيل الصوت
function ShopService:playSound(source, soundType)
    if not Config.Settings.EnableSounds then return end
    
    local sound = Config.Sounds[soundType]
    if sound then
        TriggerClientEvent('shops:playSound', source, sound.name, sound.volume)
    end
end

-- الحصول على سجل المعاملات
function ShopService:getTransactionHistory(playerIdentifier, shopId, limit, offset)
    return ShopRepository:getTransactionHistory(playerIdentifier, shopId, limit, offset)
end

-- حفظ سلة التسوق
function ShopService:saveCart(playerIdentifier, shopId, items, totalAmount)
    ShopRepository:saveCart(playerIdentifier, shopId, items, totalAmount)
end

-- تحميل سلة التسوق
function ShopService:loadCart(playerIdentifier, shopId)
    return ShopRepository:loadCart(playerIdentifier, shopId)
end

-- إدارة الذاكرة المؤقتة
function ShopService:clearCache(shopId)
    if shopId then
        ShopRepository:clearShopCache(shopId)
    else
        ShopRepository:clearAllCache()
    end
    self:loadShops() -- إعادة تحميل المتاجر
end

-- تهيئة الخدمة
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ShopService:init()
    end
end)

-- إعادة تحميل المتاجر
RegisterNetEvent('shops:reloadShops')
AddEventHandler('shops:reloadShops', function()
    ShopService:clearCache()
    DebugPrint('تم إعادة تحميل المتاجر', 'info')
end)

return ShopService
