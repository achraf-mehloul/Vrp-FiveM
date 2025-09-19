-- [file name]: client/shop_interaction.lua
local ShopInteraction = {
    currentShop = nil,
    isInShopZone = false,
    shopCheckInterval = 1000
}

-- تهيئة التفاعل
function ShopInteraction:init()
    self:startInteractionCheck()
    self:registerKeyEvents()
    DebugPrint('تم تهيئة نظام التفاعل بنجاح', 'info')
end

-- التحقق من وجود اللاعب near المتاجر
function ShopInteraction:startInteractionCheck()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(self.shopCheckInterval)
            self:checkNearbyShops()
        end
    end)
end

-- التحقق من المتاجر القريبة
function ShopInteraction:checkNearbyShops()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local foundShop = nil
    
    for _, shop in pairs(ShopService:getAllShops()) do
        local distance = #(playerCoords - shop.location)
        
        if distance < Config.Settings.InteractionDistance then
            foundShop = shop
            break
        end
    end
    
    if foundShop then
        if not self.isInShopZone or self.currentShop ~= foundShop.id then
            self:enterShopZone(foundShop)
        end
    else
        if self.isInShopZone then
            self:exitShopZone()
        end
    end
end

-- دخول منطقة المتجر
function ShopInteraction:enterShopZone(shop)
    self.currentShop = shop.id
    self.isInShopZone = true
    
    -- عرض المساعدة
    self:showHelpNotification('اضغط ~INPUT_PICKUP~ لفتح المتجر')
    
    DebugPrint('دخول منطقة المتجر: ' .. shop.name, 'debug')
end

-- خروج من منطقة المتجر
function ShopInteraction:exitShopZone()
    self.isInShopZone = false
    self.currentShop = nil
    
    -- إغلاق الواجهة إذا كانت مفتوحة
    if IsNuiOpen() then
        self:closeShopInterface()
    end
    
    DebugPrint('خروج من منطقة المتجر', 'debug')
end

-- تسجيل أحداث المفاتيح
function ShopInteraction:registerKeyEvents()
    -- فتح المتجر
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if self.isInShopZone and IsControlJustReleased(0, Config.Settings.OpenKey) then
                self:openShopInterface()
            end
            
            if IsNuiOpen() and IsControlJustReleased(0, Config.Settings.CloseKey) then
                self:closeShopInterface()
            end
        end
    end)
end

-- فتح واجهة المتجر
function ShopInteraction:openShopInterface()
    if IsNuiOpen() then return end
    
    local shop = ShopService:getShop(self.currentShop)
    if not shop or not shop.isOpen then
        self:showNotification('المتجر مغلق حالياً', 'error')
        return
    end
    
    -- طلب بيانات المتجر
    TriggerServerEvent('shops:getShopData', self.currentShop)
    
    -- تشغيل الصوت
    self:playSound('OpenMenu')
    
    -- فتح الواجهة
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openShop',
        shopId = self.currentShop
    })
    
    DebugPrint('فتح واجهة المتجر: ' .. shop.name, 'info')
end

-- إغلاق واجهة المتجر
function ShopInteraction:closeShopInterface()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeShop'
    })
    
    -- تشغيل الصوت
    self:playSound('CloseMenu')
    
    DebugPrint('إغلاق واجهة المتجر', 'info')
end

-- معالجة رسائل NUI
RegisterNUICallback('closeShop', function(data, cb)
    ShopInteraction:closeShopInterface()
    cb('ok')
end)

RegisterNUICallback('purchaseItem', function(data, cb)
    TriggerServerEvent('shops:purchaseItem', data.shopId, data.itemName, data.quantity)
    cb('ok')
end)

RegisterNUICallback('saveCart', function(data, cb)
    TriggerServerEvent('shops:saveCart', data.shopId, data.items, data.totalAmount)
    cb('ok')
end)

-- استقبال بيانات المتجر
RegisterNetEvent('shops:receiveShopData')
AddEventHandler('shops:receiveShopData', function(shopData)
    if shopData then
        SendNUIMessage({
            action = 'loadShopData',
            data = shopData
        })
    else
        ShopInteraction:showNotification('فشل في تحميل بيانات المتجر', 'error')
        ShopInteraction:closeShopInterface()
    end
end)

-- استقبال نتيجة الشراء
RegisterNetEvent('shops:purchaseResult')
AddEventHandler('shops:purchaseResult', function(result)
    if result.success then
        ShopInteraction:playSound('PurchaseSuccess')
        ShopInteraction:showNotification(result.message, 'success')
    else
        ShopInteraction:playSound('PurchaseError')
        ShopInteraction:showNotification(result.message, 'error')
    end
end)

-- استقبال تحديث الرصيد
RegisterNetEvent('shops:updateBalance')
AddEventHandler('shops:updateBalance', function(balance)
    SendNUIMessage({
        action = 'updateBalance',
        balance = balance
    })
end)

-- عرض الإشعار
function ShopInteraction:showNotification(message, type)
    if not Config.Settings.EnableNotifications then return end
    
    SendNUIMessage({
        action = 'showNotification',
        message = message,
        type = type or 'info'
    })
end

-- عرض مساعدة التحكم
function ShopInteraction:showHelpNotification(message)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- تشغيل الصوت
function ShopInteraction:playSound(soundType)
    if not Config.Settings.EnableSounds then return end
    
    local sound = Config.Sounds[soundType]
    if sound then
        PlaySoundFrontend(-1, sound.name, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end

-- التحقق إذا كانت واجهة NUI مفتوحة
function IsNuiOpen()
    return IsNuiFocused()
end

-- تهيئة النظام
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.Wait(1000) -- انتظار تحميل البيانات
        ShopInteraction:init()
    end
end)

return ShopInteraction
