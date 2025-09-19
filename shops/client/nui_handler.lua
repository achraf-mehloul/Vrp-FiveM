-- [file name]: client/nui_handler.lua
local NuiHandler = {
    isInterfaceOpen = false,
    currentShopData = nil,
    playerBalance = 0
}

-- تهيئة معالج NUI
function NuiHandler:init()
    self:registerNuiCallbacks()
    self:loadPlayerData()
    DebugPrint('تم تهيئة معالج NUI بنجاح', 'info')
end

-- تسجيل استدعاءات NUI
function NuiHandler:registerNuiCallbacks()
    -- استدعاء الشراء
    RegisterNUICallback('purchaseItems', function(data, cb)
        self:handlePurchase(data)
        cb('ok')
    end)

    -- استدعاء البحث
    RegisterNUICallback('searchItems', function(data, cb)
        self:handleSearch(data)
        cb('ok')
    end)

    -- استدعاء الفرز
    RegisterNUICallback('sortItems', function(data, cb)
        self:handleSort(data)
        cb('ok')
    end)

    -- استدعاء إدارة السلة
    RegisterNUICallback('manageCart', function(data, cb)
        self:handleCartManagement(data)
        cb('ok')
    end)

    -- استدعاء الإغلاق
    RegisterNUICallback('closeInterface', function(data, cb)
        self:closeInterface()
        cb('ok')
    end)

    -- استدعاء التحديث
    RegisterNUICallback('refreshData', function(data, cb)
        self:refreshShopData()
        cb('ok')
    end)
end

-- تحميل بيانات اللاعب
function NuiHandler:loadPlayerData()
    if Config.UseESX then
        ESX.TriggerServerCallback('shops:getPlayerData', function(data)
            self.playerBalance = data.money
            self:updateUI()
        end)
    end
end

-- معالجة عملية الشراء
function NuiHandler:handlePurchase(data)
    if not self.currentShopData then return end

    local totalPrice = 0
    local itemsToPurchase = {}

    -- حساب السعر الإجمالي
    for itemName, itemData in pairs(data.items) do
        local shopItem = self:findShopItem(itemName)
        if shopItem and shopItem.stock >= itemData.quantity then
            totalPrice = totalPrice + (shopItem.price * itemData.quantity)
            table.insert(itemsToPurchase, {
                name = itemName,
                quantity = itemData.quantity,
                price = shopItem.price
            })
        end
    end

    -- التحقق من الرصيد
    if self.playerBalance < totalPrice then
        self:showNotification(Config.Locales['not_enough_money'], 'error')
        return
    end

    -- إتمام الشراء
    TriggerServerEvent('shops:processPurchase', {
        shopId = self.currentShopData.id,
        items = itemsToPurchase,
        totalPrice = totalPrice
    })
end

-- معالجة البحث
function NuiHandler:handleSearch(data)
    if not self.currentShopData then return end

    local searchTerm = string.lower(data.searchTerm)
    local filteredItems = {}

    for _, item in ipairs(self.currentShopData.items) do
        if string.find(string.lower(item.label), searchTerm) or
           string.find(string.lower(item.category), searchTerm) then
            table.insert(filteredItems, item)
        end
    end

    self:updateItemsList(filteredItems)
end

-- معالجة الفرز
function NuiHandler:handleSort(data)
    if not self.currentShopData then return end

    local sortedItems = table.copy(self.currentShopData.items)

    table.sort(sortedItems, function(a, b)
        if data.sortBy == 'price' then
            return data.sortOrder == 'asc' and a.price < b.price or a.price > b.price
        elseif data.sortBy == 'name' then
            return data.sortOrder == 'asc' and a.label < b.label or a.label > b.label
        elseif data.sortBy == 'stock' then
            return data.sortOrder == 'asc' and a.stock < b.stock or a.stock > b.stock
        end
        return false
    end)

    self:updateItemsList(sortedItems)
end

-- معالجة إدارة السلة
function NuiHandler:handleCartManagement(data)
    if data.action == 'add' then
        self:addToCart(data.item)
    elseif data.action == 'remove' then
        self:removeFromCart(data.itemName)
    elseif data.action == 'clear' then
        self:clearCart()
    end
end

-- إضافة إلى السلة
function NuiHandler:addToCart(itemData)
    SendNUIMessage({
        action = 'addToCart',
        item = itemData
    })
end

-- إزالة من السلة
function NuiHandler:removeFromCart(itemName)
    SendNUIMessage({
        action = 'removeFromCart',
        itemName = itemName
    })
end

-- تفريغ السلة
function NuiHandler:clearCart()
    SendNUIMessage({
        action = 'clearCart'
    })
end

-- تحديث واجهة المستخدم
function NuiHandler:updateUI()
    SendNUIMessage({
        action = 'updateUI',
        data = {
            balance = self.playerBalance,
            shop = self.currentShopData,
            locale = Config.Locales
        }
    })
end

-- تحديث قائمة العناصر
function NuiHandler:updateItemsList(items)
    SendNUIMessage({
        action = 'updateItemsList',
        items = items
    })
end

-- إغلاق الواجهة
function NuiHandler:closeInterface()
    SetNuiFocus(false, false)
    self.isInterfaceOpen = false
    self.currentShopData = nil
    
    SendNUIMessage({
        action = 'closeInterface'
    })
end

-- تحديث بيانات المتجر
function NuiHandler:refreshShopData()
    if self.currentShopData then
        TriggerServerEvent('shops:getShopData', self.currentShopData.id)
    end
end

-- البحث عن عنصر في المتجر
function NuiHandler:findShopItem(itemName)
    if not self.currentShopData then return nil end
    
    for _, item in ipairs(self.currentShopData.items) do
        if item.name == itemName then
            return item
        end
    end
    return nil
end

-- عرض الإشعار
function NuiHandler:showNotification(message, type)
    SendNUIMessage({
        action = 'showNotification',
        message = message,
        type = type
    })
end

-- استقبال بيانات المتجر
RegisterNetEvent('shops:receiveShopData')
AddEventHandler('shops:receiveShopData', function(shopData)
    NuiHandler.currentShopData = shopData
    NuiHandler.isInterfaceOpen = true
    
    NuiHandler:updateUI()
end)

-- استقبال تحديث الرصيد
RegisterNetEvent('shops:updateBalance')
AddEventHandler('shops:updateBalance', function(balance)
    NuiHandler.playerBalance = balance
    NuiHandler:updateUI()
end)

-- استقبال نتيجة الشراء
RegisterNetEvent('shops:purchaseResult')
AddEventHandler('shops:purchaseResult', function(result)
    if result.success then
        NuiHandler:showNotification(result.message, 'success')
        NuiHandler:refreshShopData()
    else
        NuiHandler:showNotification(result.message, 'error')
    end
end)

-- تهيئة المعالج
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        NuiHandler:init()
    end
end)

return NuiHandler
