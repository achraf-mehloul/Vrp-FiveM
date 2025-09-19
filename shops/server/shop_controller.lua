-- [file name]: server/shop_controller.lua
local ShopController = {}

-- تهيئة الكونترولر
function ShopController:init()
    self:registerEvents()
    DebugPrint('تم تهيئة متحكم المتاجر بنجاح', 'info')
end

-- تسجيل الأحداث
function ShopController:registerEvents()
    -- طلب قائمة المتاجر
    RegisterNetEvent('shops:getShopsList', function()
        local src = source
        self:getShopsList(src)
    end)

    -- طلب بيانات متجر معين
    RegisterNetEvent('shops:getShopData', function(shopId)
        local src = source
        self:getShopData(src, shopId)
    end)

    -- شراء عنصر
    RegisterNetEvent('shops:purchaseItem', function(shopId, itemName, quantity)
        local src = source
        self:purchaseItem(src, shopId, itemName, quantity)
    end)

    -- الحصول على سجل المعاملات
    RegisterNetEvent('shops:getTransactionHistory', function(shopId, limit, offset)
        local src = source
        self:getTransactionHistory(src, shopId, limit or 10, offset or 0)
    end)

    -- حفظ سلة التسوق
    RegisterNetEvent('shops:saveCart', function(shopId, items, totalAmount)
        local src = source
        self:saveCart(src, shopId, items, totalAmount)
    end)

    -- تحميل سلة التسوق
    RegisterNetEvent('shops:loadCart', function(shopId)
        local src = source
        self:loadCart(src, shopId)
    end)

    -- تحديث سعر عنصر (للمسؤولين)
    RegisterNetEvent('shops:updateItemPrice', function(shopId, itemName, newPrice)
        local src = source
        self:updateItemPrice(src, shopId, itemName, newPrice)
    end)

    -- تحديث مخزون عنصر (للمسؤولين)
    RegisterNetEvent('shops:updateItemStock', function(shopId, itemName, newStock)
        local src = source
        self:updateItemStock(src, shopId, itemName, newStock)
    end)

    -- إضافة عنصر جديد (للمسؤولين)
    RegisterNetEvent('shops:addItemToShop', function(shopId, itemData)
        local src = source
        self:addItemToShop(src, shopId, itemData)
    end)

    -- حذف عنصر (للمسؤولين)
    RegisterNetEvent('shops:removeItemFromShop', function(shopId, itemName)
        local src = source
        self:removeItemFromShop(src, shopId, itemName)
    end)

    -- إعادة تعيين المخزون (للمسؤولين)
    RegisterNetEvent('shops:restockShop', function(shopId)
        local src = source
        self:restockShop(src, shopId)
    end)

    DebugPrint('تم تسجيل أحداث المتاجر بنجاح', 'info')
end

-- معالجة طلب قائمة المتاجر
function ShopController:getShopsList(source)
    local playerIdentifier = GetPlayerIdentifier(source)
    if not playerIdentifier then
        DebugPrint('تعذر الحصول على معرف اللاعب: ' .. source, 'error')
        return
    end

    local shopsList = ShopService:getShopsList()
    local playerMoney = ShopService:getPlayerMoney(source)

    TriggerClientEvent('shops:receiveShopsList', source, {
        shops = shopsList,
        playerMoney = playerMoney,
        currency = Config.Currency
    })

    DebugPrint(string.format('تم إرسال قائمة المتاجر إلى اللاعب %s', GetPlayerName(source)), 'debug')
end

-- معالجة طلب بيانات المتجر
function ShopController:getShopData(source, shopId)
    local playerIdentifier = GetPlayerIdentifier(source)
    if not playerIdentifier then
        DebugPrint('تعذر الحصول على معرف اللاعب: ' .. source, 'error')
        return
    end

    local shop = ShopService:getShop(shopId)
    if not shop then
        TriggerClientEvent('shops:receiveShopData', source, nil)
        DebugPrint('المتجر غير موجود: ' .. shopId, 'warn')
        return
    end

    -- التحقق من صلاحية الوصول للمتجر
    if not self:canAccessShop(source, shop) then
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = Config.Locales['no_permission']
        })
        return
    end

    local shopData = {
        id = shop.id,
        name = shop.name,
        type = shop.type,
        location = shop.location,
        hours = shop.hours,
        isOpen = shop.isOpen,
        items = {},
        statistics = shop.statistics,
        playerMoney = ShopService:getPlayerMoney(source)
    }

    -- إضافة العناصر
    for itemName, item in pairs(shop.items) do
        local itemInfo = GetItemInfo(itemName)
        table.insert(shopData.items, {
            name = itemName,
            label = itemInfo.label,
            price = item.price,
            stock = item.stock,
            maxStock = item.maxStock,
            category = item.category,
            weight = item.weight,
            type = itemInfo.type,
            description = itemInfo.description,
            image = itemInfo.image,
            rarity = itemInfo.rarity,
            icon = itemInfo.icon or GetItemIcon(itemName)
        })
    end

    -- تحميل سلة التسوق إذا كانت موجودة
    local cart = ShopService:loadCart(playerIdentifier, shopId)
    if cart then
        shopData.cart = cart
    end

    TriggerClientEvent('shops:receiveShopData', source, shopData)
    DebugPrint(string.format('تم إرسال بيانات المتجر %d إلى اللاعب %s', shopId, GetPlayerName(source)), 'debug')
end

-- معالجة عملية الشراء
function ShopController:purchaseItem(source, shopId, itemName, quantity)
    local playerIdentifier = GetPlayerIdentifier(source)
    if not playerIdentifier then
        DebugPrint('تعذر الحصول على معرف اللاعب: ' .. source, 'error')
        return
    end

    local success, message, totalPrice = ShopService:purchaseItem(shopId, itemName, quantity, source)

    TriggerClientEvent('shops:purchaseResult', source, {
        success = success,
        message = message,
        totalPrice = totalPrice,
        currency = Config.Currency
    })

    -- إرسال تحديث الرصيد
    if success then
        local playerMoney = ShopService:getPlayerMoney(source)
        TriggerClientEvent('shops:updateBalance', source, playerMoney)
    end

    DebugPrint(string.format('نتيجة الشراء: %s - %s (%s)', 
        GetPlayerName(source), message, totalPrice or 0), success and 'info' or 'warn')
end

-- معالجة طلب سجل المعاملات
function ShopController:getTransactionHistory(source, shopId, limit, offset)
    local playerIdentifier = GetPlayerIdentifier(source)
    if not playerIdentifier then
        DebugPrint('تعذر الحصول على معرف اللاعب: ' .. source, 'error')
        return
    end

    local transactions = ShopService:getTransactionHistory(playerIdentifier, shopId, limit, offset)
    
    TriggerClientEvent('shops:receiveTransactionHistory', source, {
        transactions = transactions,
        totalCount = #transactions
    })

    DebugPrint(string.format('تم إرسال سجل المعاملات إلى اللاعب %s', GetPlayerName(source)), 'debug')
end

-- حفظ سلة التسوق
function ShopController:saveCart(source, shopId, items, totalAmount)
    local playerIdentifier = GetPlayerIdentifier(source)
    if not playerIdentifier then
        DebugPrint('تعذر الحصول على معرف اللاعب: ' .. source, 'error')
        return
    end

    ShopService:saveCart(playerIdentifier, shopId, items, totalAmount)
    DebugPrint('تم حفظ سلة التسوق للاعب: ' .. GetPlayerName(source), 'debug')
end

-- تحميل سلة التسوق
function ShopController:loadCart(source, shopId)
    local playerIdentifier = GetPlayerIdentifier(source)
    if not playerIdentifier then
        DebugPrint('تعذر الحصول على معرف اللاعب: ' .. source, 'error')
        return
    end

    local cart = ShopService:loadCart(playerIdentifier, shopId)
    TriggerClientEvent('shops:receiveCart', source, cart)
    DebugPrint('تم تحميل سلة التسوق للاعب: ' .. GetPlayerName(source), 'debug')
end

-- تحديث سعر العنصر (للمسؤولين)
function ShopController:updateItemPrice(source, shopId, itemName, newPrice)
    if not self:hasAdminPermission(source) then
        self:sendNoPermissionResponse(source)
        return
    end

    newPrice = tonumber(newPrice)
    if not newPrice or newPrice < 0 then
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = 'السعر غير صالح'
        })
        return
    end

    local success = ShopRepository:updateItemPrice(shopId, itemName, newPrice)
    if success then
        ShopService:clearCache(shopId)
        TriggerClientEvent('shops:notification', source, {
            type = 'success',
            message = 'تم تحديث السعر بنجاح'
        })
        DebugPrint(string.format('تم تحديث سعر %s في المتجر %d إلى %s', itemName, shopId, newPrice), 'info')
    else
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = 'فشل في تحديث السعر'
        })
    end
end

-- تحديث مخزون العنصر (للمسؤولين)
function ShopController:updateItemStock(source, shopId, itemName, newStock)
    if not self:hasAdminPermission(source) then
        self:sendNoPermissionResponse(source)
        return
    end

    newStock = tonumber(newStock)
    if not newStock or newStock < 0 then
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = 'المخزون غير صالح'
        })
        return
    end

    local success = ShopRepository:updateItemStock(shopId, itemName, newStock)
    if success then
        ShopService:clearCache(shopId)
        TriggerClientEvent('shops:notification', source, {
            type = 'success',
            message = 'تم تحديث المخزون بنجاح'
        })
        DebugPrint(string.format('تم تحديث مخزون %s في المتجر %d إلى %d', itemName, shopId, newStock), 'info')
    else
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = 'فشل في تحديث المخزون'
        })
    end
end

-- إضافة عنصر جديد (للمسؤولين)
function ShopController:addItemToShop(source, shopId, itemData)
    if not self:hasAdminPermission(source) then
        self:sendNoPermissionResponse(source)
        return
    end

    -- التحقق من صحة البيانات
    if not itemData.name or not itemData.label or not itemData.price then
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = 'بيانات العنصر غير مكتملة'
        })
        return
    end

    local success = ShopRepository:addItemToShop(shopId, itemData)
    if success then
        ShopService:clearCache(shopId)
        TriggerClientEvent('shops:notification', source, {
            type = 'success',
            message = 'تم إضافة العنصر بنجاح'
        })
        DebugPrint(string.format('تم إضافة العنصر %s إلى المتجر %d', itemData.name, shopId), 'info')
    else
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = 'فشل في إضافة العنصر'
        })
    end
end

-- حذف عنصر (للمسؤولين)
function ShopController:removeItemFromShop(source, shopId, itemName)
    if not self:hasAdminPermission(source) then
        self:sendNoPermissionResponse(source)
        return
    end

    local success = ShopRepository:removeItemFromShop(shopId, itemName)
    if success then
        ShopService:clearCache(shopId)
        TriggerClientEvent('shops:notification', source, {
            type = 'success',
            message = 'تم حذف العنصر بنجاح'
        })
        DebugPrint(string.format('تم حذف العنصر %s من المتجر %d', itemName, shopId), 'info')
    else
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = 'فشل في حذف العنصر'
        })
    end
end

-- إعادة تعيين المخزون (للمسؤولين)
function ShopController:restockShop(source, shopId)
    if not self:hasAdminPermission(source) then
        self:sendNoPermissionResponse(source)
        return
    end

    local success = ShopRepository:restockShop(shopId)
    if success then
        ShopService:clearCache(shopId)
        TriggerClientEvent('shops:notification', source, {
            type = 'success',
            message = 'تم إعادة التعيين بنجاح'
        })
        DebugPrint(string.format('تم إعادة تعيين مخزون المتجر %d', shopId), 'info')
    else
        TriggerClientEvent('shops:notification', source, {
            type = 'error',
            message = 'فشل في إعادة التعيين'
        })
    end
end

-- التحقق من صلاحية الوصول للمتجر
function ShopController:canAccessShop(source, shop)
    local shopTypeConfig = Config.ShopTypes[shop.type]
    if not shopTypeConfig then return true end

    -- التحقق من الوظائف المسموحة
    if shopTypeConfig.allowedJobs and #shopTypeConfig.allowedJobs > 0 then
        if Config.UseESX then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                local playerJob = xPlayer.getJob().name
                for _, allowedJob in ipairs(shopTypeConfig.allowedJobs) do
                    if playerJob == allowedJob then
                        return true
                    end
                end
            end
        end
        return false
    end

    return true
end

-- التحقق من صلاحيات الأدمن
function ShopController:hasAdminPermission(source)
    return IsPlayerAceAllowed(source, Config.Settings.AdminPermission)
end

-- إرسال رد عدم الصلاحية
function ShopController:sendNoPermissionResponse(source)
    TriggerClientEvent('shops:notification', source, {
        type = 'error',
        message = Config.Locales['no_permission']
    })
end

-- تهيئة الكونترولر
ShopController:init()

return ShopController
