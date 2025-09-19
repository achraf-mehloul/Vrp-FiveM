-- [file name]: client/main.lua
local ClientShops = {
    currentShop = nil,
    isShopOpen = false,
    playerData = {},
    nearbyShops = {},
    blips = {},
    markers = {}
}

-- تهيئة الكلينت
function ClientShops:init()
    self:setupEventHandlers()
    self:createBlips()
    self:startInteractionThread()
    self:startUpdateThread()
    
    DebugPrint('تم تهيئة جانب العميل بنجاح', 'info')
    
    -- طلب بيانات اللاعب
    self:requestPlayerData()
end

-- إعداد معالجات الأحداث
function ClientShops:setupEventHandlers()
    -- استقبال قائمة المتاجر
    RegisterNetEvent('shops:receiveShopsList', function(data)
        self:handleShopsList(data)
    end)

    -- استقبال بيانات المتجر
    RegisterNetEvent('shops:receiveShopData', function(data)
        self:handleShopData(data)
    end)

    -- استقبال نتيجة الشراء
    RegisterNetEvent('shops:purchaseResult', function(data)
        self:handlePurchaseResult(data)
    end)

    -- استقبال تحديث الرصيد
    RegisterNetEvent('shops:updateBalance', function(balance)
        self:handleBalanceUpdate(balance)
    end)

    -- استقبال الإشعارات
    RegisterNetEvent('shops:notification', function(data)
        self:showNotification(data)
    end)

    -- استقبال سجل المعاملات
    RegisterNetEvent('shops:receiveTransactionHistory', function(data)
        self:handleTransactionHistory(data)
    end)

    -- استقبال سلة التسوق
    RegisterNetEvent('shops:receiveCart', function(data)
        self:handleCartData(data)
    end)

    -- استقبال حالة النظام
    RegisterNetEvent('shops:systemStatus', function(data)
        self:handleSystemStatus(data)
    end)

    -- استقبال الصوت
    RegisterNetEvent('shops:playSound', function(soundName, volume)
        self:playSound(soundName, volume)
    end)

    DebugPrint('تم إعداد معالجات الأحداث بنجاح', 'info')
end

-- إنشاء البليبس
function ClientShops:createBlips()
    if not Config.Settings.EnableBlips then return end

    for _, shop in ipairs(Config.Shops) do
        if shop.blip then
            local blip = AddBlipForCoord(shop.location.x, shop.location.y, shop.location.z)
            
            local blipConfig = Config.ShopTypes[shop.type]
            if blipConfig then
                SetBlipSprite(blip, blipConfig.blip)
                SetBlipColour(blip, blipConfig.color)
                SetBlipScale(blip, blipConfig.scale)
                SetBlipAsShortRange(blip, true)
                
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(blipConfig.name)
                EndTextCommandSetBlipName(blip)
                
                self.blips[shop.id] = blip
            end
        end
    end

    DebugPrint('تم إنشاء البليبس بنجاح', 'info')
end

-- خيط التفاعل مع المتاجر
function ClientShops:startInteractionThread()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            self:checkNearbyShops()
        end
    end)
end

-- خيط التحديث
function ClientShops:startUpdateThread()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000) -- كل 30 ثانية
            self:updatePlayerData()
            self:checkShopStatus()
        end
    end)
end

-- التحقق من المتاجر القريبة
function ClientShops:checkNearbyShops()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    self.nearbyShops = {}

    for _, shop in ipairs(Config.Shops) do
        local distance = #(playerCoords - shop.location)
        
        if distance < Config.Settings.InteractionDistance then
            table.insert(self.nearbyShops, {
                id = shop.id,
                name = shop.name,
                type = shop.type,
                distance = distance,
                isOpen = IsShopOpen(shop.hours.open, shop.hours.close)
            })

            -- عرض المساعدة إذا كان المتجر مفتوحاً
            if shop.marker then
                self:drawMarker(shop.location, shop.type)
            end

            if distance < 2.0 and shop.isOpen then
                self:showInteractionHelp(shop)
            end
        end
    end
end

-- رسم ماركر المتجر
function ClientShops:drawMarker(coords, shopType)
    local markerConfig = Config.ShopTypes[shopType]
    if not markerConfig then return end

    DrawMarker(
        1, -- النوع
        coords.x, coords.y, coords.z - 1.0, -- الموقع
        0.0, 0.0, 0.0, -- الاتجاه
        0.0, 0.0, 0.0, -- الدوران
        1.5, 1.5, 1.0, -- الحجم
        markerConfig.color.r or 255, -- اللون الأحمر
        markerConfig.color.g or 255, -- اللون الأخضر
        markerConfig.color.b or 255, -- اللون الأزرق
        100, -- الشفافية
        false, -- Bob up and down
        true, -- Face camera
        2, -- Rotation order
        false, -- Rotate
        nil, -- Texture dict
        nil, -- Texture name
        false -- Draw on entities
    )
end

-- عرض مساعدة التفاعل
function ClientShops:showInteractionHelp(shop)
    ESX.ShowHelpNotification(string.format('اضغط ~INPUT_CONTEXT~ لفتح ~y~%s~s~', shop.name))
    
    if IsControlJustReleased(0, Config.Settings.OpenKey) then -- E key
        self:openShop(shop.id)
    end
end

-- فتح المتجر
function ClientShops:openShop(shopId)
    if self.isShopOpen then return end
    
    self.isShopOpen = true
    self.currentShop = shopId
    
    -- فتح واجهة المستخدم
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openShop',
        shopId = shopId
    })
    
    -- طلب بيانات المتجر
    TriggerServerEvent('shops:getShopData', shopId)
    
    -- تشغيل صوت فتح القائمة
    self:playSound('OpenMenu')
    
    DebugPrint('تم فتح المتجر: ' .. shopId, 'info')
end

-- إغلاق المتجر
function ClientShops:closeShop()
    if not self.isShopOpen then return end
    
    self.isShopOpen = false
    self.currentShop = nil
    
    -- إغلاق واجهة المستخدم
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeShop'
    })
    
    -- تشغيل صوت إغلاق القائمة
    self:playSound('CloseMenu')
    
    DebugPrint('تم إغلاق المتجر', 'info')
end

-- معالجة قائمة المتاجر
function ClientShops:handleShopsList(data)
    SendNUIMessage({
        action = 'loadShopsList',
        data = data
    })
end

-- معالجة بيانات المتجر
function ClientShops:handleShopData(data)
    if not data then
        self:closeShop()
        self:showNotification({
            type = 'error',
            message = 'فشل في تحميل بيانات المتجر'
        })
        return
    end

    SendNUIMessage({
        action = 'loadShopData',
        data = data
    })
end

-- معالجة نتيجة الشراء
function ClientShops:handlePurchaseResult(data)
    self:showNotification({
        type = data.success and 'success' or 'error',
        message = data.message,
        duration = 5000
    })

    if data.success then
        self:playSound('PurchaseSuccess')
    else
        self:playSound('PurchaseError')
    end
end

-- معالجة تحديث الرصيد
function ClientShops:handleBalanceUpdate(balance)
    self.playerData.money = balance
    
    SendNUIMessage({
        action = 'updateBalance',
        balance = balance
    })
end

-- معالجة سجل المعاملات
function ClientShops:handleTransactionHistory(data)
    SendNUIMessage({
        action = 'loadTransactionHistory',
        data = data
    })
end

-- معالجة سلة التسوق
function ClientShops:handleCartData(data)
    SendNUIMessage({
        action = 'loadCart',
        data = data
    })
end

-- معالجة حالة النظام
function ClientShops:handleSystemStatus(data)
    DebugPrint('حالة النظام: ' .. json.encode(data), 'debug')
end

-- طلب بيانات اللاعب
function ClientShops:requestPlayerData()
    if Config.UseESX then
        ESX.TriggerServerCallback('shops:getPlayerData', function(data)
            self.playerData = data
        end)
    else
        self.playerData = {
            money = 0,
            identifier = GetPlayerServerId(PlayerId()),
            name = GetPlayerName(PlayerId())
        }
    end
end

-- تحديث بيانات اللاعب
function ClientShops:updatePlayerData()
    if Config.UseESX then
        local playerMoney = ESX.GetPlayerData().money or 0
        if playerMoney ~= self.playerData.money then
            self.playerData.money = playerMoney
            TriggerEvent('shops:updateBalance', playerMoney)
        end
    end
end

-- التحقق من حالة المتاجر
function ClientShops:checkShopStatus()
    for _, shop in ipairs(Config.Shops) do
        local isOpen = IsShopOpen(shop.hours.open, shop.hours.close)
        
        if self.blips[shop.id] then
            local blipConfig = Config.ShopTypes[shop.type]
            if blipConfig then
                if isOpen then
                    SetBlipColour(self.blips[shop.id], blipConfig.color)
                else
                    SetBlipColour(self.blips[shop.id], 1) -- لون أحمر للمغلق
                end
            end
        end
    end
end

-- عرض الإشعار
function ClientShops:showNotification(data)
    if not Config.Settings.EnableNotifications then return end

    ESX.ShowNotification(data.message)
    
    SendNUIMessage({
        action = 'showNotification',
        data = data
    })
end

-- تشغيل الصوت
function ClientShops:playSound(soundName, volume)
    if not Config.Settings.EnableSounds then return end

    local soundFile = Config.Sounds[soundName]
    if soundFile then
        SendNUIMessage({
            action = 'playSound',
            sound = soundFile.sound,
            volume = volume or soundFile.volume
        })
    end
end

-- إدارة أحداث NUI
RegisterNUICallback('getShopsData', function(data, cb)
    TriggerServerEvent('shops:getShopsList')
    cb('ok')
end)

RegisterNUICallback('selectShop', function(data, cb)
    TriggerServerEvent('shops:getShopData', data.shopId)
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

RegisterNUICallback('loadCart', function(data, cb)
    TriggerServerEvent('shops:loadCart', data.shopId)
    cb('ok')
end)

RegisterNUICallback('closeShop', function(data, cb)
    ClientShops:closeShop()
    cb('ok')
end)

RegisterNUICallback('getTransactionHistory', function(data, cb)
    TriggerServerEvent('shops:getTransactionHistory', data.shopId, data.limit, data.offset)
    cb('ok')
end)

-- إغلاق المتجر عند الضغط على ESC
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if ClientShops.isShopOpen then
            if IsControlJustReleased(0, Config.Settings.CloseKey) then
                ClientShops:closeShop()
            end
            
            -- تعطيل حركة اللاعب
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 24, true) -- Attack
            DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
        end
    end
end)

-- تهيئة الكلينت
Citizen.CreateThread(function()
    while not ESX do
        Citizen.Wait(100)
    end
    
    ClientShops:init()
    DebugPrint('تم تحميل جانب العميل بنجاح', 'success')
end)

-- تصدير الدوال
function OpenShop(shopId)
    ClientShops:openShop(shopId)
end

function CloseShop()
    ClientShops:closeShop()
end

-- أوامر التطوير
RegisterCommand('devshop', function(source, args)
    if #args < 1 then
        print('استخدام: /devshop [shopId]')
        return
    end
    
    local shopId = tonumber(args[1])
    OpenShop(shopId)
end, false)
