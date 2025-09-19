-- [file name]: client/blip_manager.lua
local BlipManager = {
    blips = {},
    markers = {}
}

-- تهيئة مدير البليبس
function BlipManager:init()
    self:createBlips()
    self:startUpdateTask()
    DebugPrint('تم تهيئة مدير البليبس بنجاح', 'info')
end

-- إنشاء البليبس
function BlipManager:createBlips()
    if not Config.Settings.EnableBlips then return end
    
    for _, shop in pairs(ShopService:getAllShops()) do
        if shop.blip then
            self:createShopBlip(shop)
        end
    end
end

-- إنشاء بليب للمتجر
function BlipManager:createShopBlip(shop)
    local shopType = Config.ShopTypes[shop.type]
    if not shopType then return end
    
    local blip = AddBlipForCoord(shop.location.x, shop.location.y, shop.location.z)
    
    SetBlipSprite(blip, shopType.blip)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, shopType.scale)
    SetBlipColour(blip, shopType.color)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(shop.name)
    EndTextCommandSetBlipName(blip)
    
    self.blips[shop.id] = blip
    DebugPrint('تم إنشاء بليب للمتجر: ' .. shop.name, 'debug')
end

-- تحديث حالة البليبس
function BlipManager:updateBlips()
    for shopId, blip in pairs(self.blips) do
        local shop = ShopService:getShop(shopId)
        if shop then
            if shop.isOpen then
                SetBlipColour(blip, Config.ShopTypes[shop.type].color)
                SetBlipAlpha(blip, 255)
            else
                SetBlipColour(blip, 1) -- اللون الأحمر للإغلاق
                SetBlipAlpha(blip, 128)
            end
        end
    end
end

-- رسم الماركرات
function BlipManager:drawMarkers()
    if not Config.Settings.EnableMarkers then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, shop in pairs(ShopService:getAllShops()) do
        if shop.marker then
            local distance = #(playerCoords - shop.location)
            
            if distance < 20.0 then
                self:drawShopMarker(shop, distance)
            end
        end
    end
end

-- رسم ماركر المتجر
function BlipManager:drawShopMarker(shop, distance)
    local markerConfig = shop.marker
    local alpha = math.max(100, 255 - (distance * 10))
    
    DrawMarker(
        markerConfig.type or 1,
        shop.location.x, shop.location.y, shop.location.z - 0.98,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        markerConfig.scale.x, markerConfig.scale.y, markerConfig.scale.z,
        markerConfig.color.r, markerConfig.color.g, markerConfig.color.b, alpha,
        markerConfig.rotate or false,
        false, 2, false, nil, nil, false
    )
    
    -- عرض النص فوق الماركر
    if distance < 3.0 then
        local text = shop.isOpen and '~g~' .. shop.name .. '~s~\n~INPUT_PICKUP~ للفتح' 
                               or '~r~' .. shop.name .. '~s~\n~r~مغلق حالياً'
        
        AddTextEntry('SHOP_MARKER', text)
        BeginTextCommandDisplayHelp('SHOP_MARKER')
        EndTextCommandDisplayHelp(0, false, false, -1)
    end
end

-- مهمة التحديث المستمر
function BlipManager:startUpdateTask()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            self:drawMarkers()
        end
    end)
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000) -- كل 30 ثانية
            self:updateBlips()
        end
    end)
end

-- حذف جميع البليبس
function BlipManager:cleanup()
    for _, blip in pairs(self.blips) do
        RemoveBlip(blip)
    end
    self.blips = {}
end

-- إعادة تحميل البليبس
function BlipManager:reload()
    self:cleanup()
    self:createBlips()
end

-- حدث إعادة تحميل البليبس
RegisterNetEvent('shops:reloadBlips')
AddEventHandler('shops:reloadBlips', function()
    BlipManager:reload()
end)

-- تهيئة المدير
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.Wait(1000) -- انتظار تحميل المتاجر
        BlipManager:init()
    end
end)

-- تنظيف عند إيقاف المورد
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        BlipManager:cleanup()
    end
end)

return BlipManager
