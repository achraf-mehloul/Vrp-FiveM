-- [file name]: server/shop_repository.lua
local ShopRepository = {}

-- تهيئة المستودع
function ShopRepository:init()
    self.cache = {}
    self.cacheTimeout = Config.Performance.CacheTimeout
    DebugPrint('تم تهيئة مستودع المتاجر', 'info')
end

-- الحصول على جميع المتاجر (مع التخزين المؤقت)
function ShopRepository:getAllShops()
    local cachedShops = GetCache('all_shops')
    if cachedShops then
        DebugPrint('تم تحميل المتاجر من الذاكرة المؤقتة', 'debug')
        return cachedShops
    end

    local shops = Database:getAllShops()
    
    -- معالجة البيانات
    local processedShops = {}
    for _, shop in ipairs(shops) do
        local shopData = {
            id = shop.id,
            name = shop.name,
            type = shop.type,
            location = JsonToTable(shop.location),
            blip = shop.blip_enabled == 1,
            marker = shop.marker_enabled == 1,
            hours = {
                open = shop.open_hour,
                close = shop.close_hour
            },
            itemCount = shop.item_count,
            totalRevenue = shop.total_revenue,
            isOpen = IsShopOpen(shop.open_hour, shop.close_hour)
        }
        table.insert(processedShops, shopData)
    end

    SetCache('all_shops', processedShops, self.cacheTimeout)
    return processedShops
end

-- الحصول على متجر معين
function ShopRepository:getShop(shopId)
    local cacheKey = 'shop_' .. shopId
    local cachedShop = GetCache(cacheKey)
    if cachedShop then
        return cachedShop
    end

    local allShops = self:getAllShops()
    for _, shop in ipairs(allShops) do
        if shop.id == shopId then
            SetCache(cacheKey, shop, self.cacheTimeout)
            return shop
        end
    end

    return nil
end

-- الحصول على عناصر المتجر
function ShopRepository:getShopItems(shopId)
    local cacheKey = 'shop_items_' .. shopId
    local cachedItems = GetCache(cacheKey)
    if cachedItems then
        DebugPrint('تم تحميل عناصر المتجر من الذاكرة المؤقتة: ' .. shopId, 'debug')
        return cachedItems
    end

    local items = Database:getShopItems(shopId)
    local processedItems = {}

    for _, item in ipairs(items) do
        local itemInfo = GetItemInfo(item.item_name)
        local itemData = {
            name = item.item_name,
            label = item.label,
            price = item.price,
            stock = item.stock,
            maxStock = item.max_stock,
            category = item.category,
            weight = item.weight,
            type = itemInfo.type,
            description = itemInfo.description,
            image = itemInfo.image,
            rarity = itemInfo.rarity,
            icon = GetItemIcon(item.item_name)
        }
        table.insert(processedItems, itemData)
    end

    SetCache(cacheKey, processedItems, self.cacheTimeout)
    return processedItems
end

-- تحديث مخزون العنصر
function ShopRepository:updateItemStock(shopId, itemName, newStock)
    ClearCache('shop_items_' .. shopId) -- مسح الذاكرة المؤقتة
    
    local success = Database:updateItemStock(shopId, itemName, newStock)
    if success then
        DebugPrint(string.format('تم تحديث مخزون %s في المتجر %d إلى %d', itemName, shopId, newStock), 'info')
        return true
    end
    return false
end

-- تحديث سعر العنصر
function ShopRepository:updateItemPrice(shopId, itemName, newPrice)
    ClearCache('shop_items_' .. shopId) -- مسح الذاكرة المؤقتة
    
    local success = Database:updateItemPrice(shopId, itemName, newPrice)
    if success then
        DebugPrint(string.format('تم تحديث سعر %s في المتجر %d إلى %s', itemName, shopId, newPrice), 'info')
        return true
    end
    return false
end

-- إضافة معاملة جديدة
function ShopRepository:addTransaction(transactionData)
    local transactionId = Database:addTransaction(transactionData)
    
    if transactionId then
        -- تحديث الإحصائيات
        local isNewCustomer = self:isNewCustomer(transactionData.shopId, transactionData.playerIdentifier)
        Database:updateStatistics(transactionData.shopId, transactionData.finalPrice, isNewCustomer)
        
        DebugPrint(string.format('تم تسجيل معاملة جديدة: %s اشترى %d من %s', 
            transactionData.playerName, transactionData.quantity, transactionData.itemName), 'info')
        return true
    end
    return false
end

-- التحقق إذا كان العميل جديداً
function ShopRepository:isNewCustomer(shopId, playerIdentifier)
    local result = MySQL.query.await([[
        SELECT COUNT(*) as count 
        FROM shop_transactions 
        WHERE shop_id = ? AND player_identifier = ?
    ]], {shopId, playerIdentifier})
    
    return result and result[1] and result[1].count == 0
end

-- الحصول على سجل المعاملات
function ShopRepository:getTransactionHistory(playerIdentifier, shopId, limit, offset)
    return Database:getTransactions(playerIdentifier, shopId, limit, offset)
end

-- حفظ سلة التسوق
function ShopRepository:saveCart(playerIdentifier, shopId, items, totalAmount)
    Database:saveCart(playerIdentifier, shopId, items, totalAmount)
    DebugPrint('تم حفظ سلة التسوق للاعب: ' .. playerIdentifier, 'debug')
end

-- تحميل سلة التسوق
function ShopRepository:loadCart(playerIdentifier, shopId)
    return Database:loadCart(playerIdentifier, shopId)
end

-- الحصول على الإحصائيات
function ShopRepository:getStatistics(shopId)
    return Database:getStatistics(shopId)
end

-- إضافة عنصر جديد للمتجر
function ShopRepository:addItemToShop(shopId, itemData)
    ClearCache('shop_items_' .. shopId) -- مسح الذاكرة المؤقتة
    
    local success = MySQL.insert.await([[
        INSERT INTO shop_items (shop_id, item_name, label, price, stock, max_stock, category, weight)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        shopId, itemData.name, itemData.label, itemData.price, 
        itemData.stock or 0, itemData.maxStock or 100, 
        itemData.category or 'عام', itemData.weight or 0.1
    })
    
    return success
end

-- حذف عنصر من المتجر
function ShopRepository:removeItemFromShop(shopId, itemName)
    ClearCache('shop_items_' .. shopId) -- مسح الذاكرة المؤقتة
    
    local success = MySQL.update.await([[
        DELETE FROM shop_items 
        WHERE shop_id = ? AND item_name = ?
    ]], {shopId, itemName})
    
    return success
end

-- إعادة تعيين المخزون
function ShopRepository:restockShop(shopId)
    ClearCache('shop_items_' .. shopId) -- مسح الذاكرة المؤقتة
    
    local success = MySQL.update.await([[
        UPDATE shop_items 
        SET stock = max_stock 
        WHERE shop_id = ?
    ]], {shopId})
    
    return success
end

-- مسح الذاكرة المؤقتة للمتجر
function ShopRepository:clearShopCache(shopId)
    ClearCache('shop_' .. shopId)
    ClearCache('shop_items_' .. shopId)
    DebugPrint('تم مسح الذاكرة المؤقتة للمتجر: ' .. shopId, 'debug')
end

-- مسح كل الذاكرة المؤقتة
function ShopRepository:clearAllCache()
    for key in pairs(cache) do
        ClearCache(key)
    end
    DebugPrint('تم مسح كل الذاكرة المؤقتة', 'info')
end

-- تهيئة المستودع
ShopRepository:init()

return ShopRepository
