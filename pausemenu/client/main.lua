local isMenuOpen = false
local playerJoinTime = 0
local playerData = {
    playerId = 0,
    playerName = "",
    serverName = "Melix Files V1",
    serverLogo = "assets/logo.png",
    wantedLevel = 0,
    playTime = "0:00:00",
    onlinePlayers = 0
}

-- دالة فتح/إغلاق القائمة
function TogglePauseMenu()
    isMenuOpen = not isMenuOpen
    
    if isMenuOpen then
        -- تسجيل وقت دخول اللاعب إذا كان أول مرة
        if playerJoinTime == 0 then
            playerJoinTime = GetGameTimer()
        end
        
        -- تحديث البيانات قبل فتح القائمة
        UpdatePlayerData()
        
        -- إظهار واجهة NUI
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
        SendNUIMessage({
            action = 'showMenu',
            data = playerData
        })
        
        -- إيقاف حركة اللاعب
        DisableControls()
    else
        -- إخفاء واجهة NUI
        SetNuiFocus(false, false)
        SendNUIMessage({action = 'hideMenu'})
        
        -- تمكين حركة اللاعب
        EnableControls()
    end
end

-- تحديث بيانات اللاعب (وقت حقيقي)
function UpdatePlayerData()
    playerData.playerId = GetPlayerServerId(PlayerId())
    playerData.playerName = GetPlayerName(PlayerId())
    playerData.wantedLevel = GetPlayerWantedLevel(PlayerId())
    playerData.onlinePlayers = #GetActivePlayers()
    
    -- الحصول على اسم السيرفر من الموارد
    local resourceMetadata = GetResourceMetadata(GetCurrentResourceName(), "server_name", 0)
    if resourceMetadata then
        playerData.serverName = resourceMetadata
    end
    
    -- الحصول على لوجو السيرفر من الموارد
    local resourceLogo = GetResourceMetadata(GetCurrentResourceName(), "server_logo", 0)
    if resourceLogo then
        playerData.serverLogo = resourceLogo
    end
    
    -- حساب وقت اللعب الحقيقي من لحظة الدخول
    if playerJoinTime > 0 then
        local currentTime = GetGameTimer()
        local playTimeMs = currentTime - playerJoinTime
        local playTimeMinutes = math.floor(playTimeMs / 60000)
        local hours = math.floor(playTimeMinutes / 60)
        local minutes = playTimeMinutes % 60
        local seconds = math.floor((playTimeMs % 60000) / 1000)
        playerData.playTime = string.format("%d:%02d:%02d", hours, minutes, seconds)
    end
end

-- تحديث البيانات كل ثانية
CreateThread(function()
    while true do
        Wait(1000)
        if isMenuOpen then
            UpdatePlayerData()
            SendNUIMessage({
                action = 'updateData',
                data = playerData
            })
        end
    end
end)

-- تعطيل التحكم أثناء فتح القائمة
function DisableControls()
    CreateThread(function()
        while isMenuOpen do
            DisableAllControlActions(0)
            EnableControlAction(0, 249, true)
            Wait(0)
        end
    end)
end

-- أحداث فتح الخريطة والإعدادات
RegisterNetEvent('pausemenu:openMap')
AddEventHandler('pausemenu:openMap', function()
    TogglePauseMenu()
    SetNuiFocus(false, false)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'), true, -1)
end)

RegisterNetEvent('pausemenu:openSettings')
AddEventHandler('pausemenu:openSettings', function()
    TogglePauseMenu()
    SetNuiFocus(false, false)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'), true, -1)
end)

RegisterNetEvent('pausemenu:openShortcuts')
AddEventHandler('pausemenu:openShortcuts', function()
    SendNUIMessage({action = 'showShortcuts'})
end)

RegisterNetEvent('pausemenu:openFrameworks')
AddEventHandler('pausemenu:openFrameworks', function()
    SendNUIMessage({action = 'showFrameworks'})
end)

-- تغيير الإطارات (FPS) بشكل حقيقي
RegisterNetEvent('pausemenu:changeFramerate')
AddEventHandler('pausemenu:changeFramerate', function(level)
    if level == "high" then
        SetTimeCycleModifier("rply_saturation")
        SetTimeCycleModifierStrength(1.0)
    elseif level == "medium" then
        SetTimeCycleModifier("CAMERA_secuirity")
        SetTimeCycleModifierStrength(0.5)
    elseif level == "low" then
        SetTimeCycleModifier("player_transition")
        SetTimeCycleModifierStrength(0.2)
    else
        ClearTimeCycleModifier()
    end
end)

-- الأحداث المستلمة من NUI
RegisterNUICallback('closeMenu', function(data, cb)
    TogglePauseMenu()
    cb('ok')
end)

RegisterNUICallback('buttonAction', function(data, cb)
    local button = data.button
    
    if button == 'resume' then
        TogglePauseMenu()
    elseif button == 'map' then
        TriggerEvent('pausemenu:openMap')
    elseif button == 'settings' then
        TriggerEvent('pausemenu:openSettings')
    elseif button == 'shortcuts' then
        TriggerEvent('pausemenu:openShortcuts')
    elseif button == 'frameworks' then
        TriggerEvent('pausemenu:openFrameworks')
    elseif button == 'exit' then
        TriggerServerEvent('pausemenu:disconnect')
    end
    
    cb('ok')
end)

RegisterNUICallback('changeFramerate', function(data, cb)
    TriggerEvent('pausemenu:changeFramerate', data.level)
    cb('ok')
end)

-- أمر لفتح/إغلاق القائمة
RegisterCommand('pausemenu', function()
    TogglePauseMenu()
end, false)

RegisterKeyMapping('pausemenu', 'Open/Close Pause Menu', 'keyboard', 'F1')

-- حدث عند ضغط ESC
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, 200) then
            TogglePauseMenu()
        end
    end
end)

-- حدث عند بدء اللعبة
AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        -- الحصول على إعدادات السيرفر
        TriggerServerEvent('pausemenu:getServerSettings')
    end
end)

-- استقبال إعدادات السيرفر
RegisterNetEvent('pausemenu:setServerSettings')
AddEventHandler('pausemenu:setServerSettings', function(settings)
    if settings.serverName then
        playerData.serverName = settings.serverName
    end
    if settings.serverLogo then
        playerData.serverLogo = settings.serverLogo
    end
end)
