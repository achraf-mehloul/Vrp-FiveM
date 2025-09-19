local isLoaded = false
local playerData = {
    health = 100,
    armor = 0,
    hunger = 100,
    thirst = 100,
    cash = 0,
    bank = 0,
    job = {name = "Unemployed", grade = "None", label = "Unemployed"},
    rank = "Civilian",
    wanted = 0,
    inCombat = false
}

-- Initialize HUD
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(100)
    end
    
    -- Wait for framework to load
    if Config.Framework == 'esx' then
        while not ESX do
            Citizen.Wait(100)
        end
        while not ESX.IsPlayerLoaded() do
            Citizen.Wait(100)
        end
    elseif Config.Framework == 'qb-core' then
        while not QBCore do
            Citizen.Wait(100)
        end
        while not QBCore.Functions.GetPlayerData().job do
            Citizen.Wait(100)
        end
    end
    
    -- Initialize HUD
    isLoaded = true
    Utils.Debug("HUD client initialized")
    
    -- Set initial HUD visibility
    SendNUIMessage({
        type = 'setVisibility',
        visible = Config.HUD.DefaultVisibility
    })
    
    -- Start update loop
    StartUpdateLoop()
end)

-- Main update loop
function StartUpdateLoop()
    Citizen.CreateThread(function()
        while isLoaded do
            UpdatePlayerData()
            Citizen.Wait(Config.HUD.UpdateInterval)
        end
    end)
end

-- Update player data from game state
function UpdatePlayerData()
    -- Get basic player stats
    local ped = PlayerPedId()
    
    -- Health (0-100 to 0-100)
    playerData.health = GetEntityHealth(ped) - 100
    if playerData.health < 0 then playerData.health = 0 end
    
    -- Armor (0-100 to 0-100)
    playerData.armor = GetPedArmour(ped)
    
    -- Get framework-specific data
    if Config.Framework == 'esx' then
        UpdateESXData()
    elseif Config.Framework == 'qb-core' then
        UpdateQBData()
    else
        -- Standalone fallback
        playerData.cash = 1000
        playerData.bank = 5000
    end
    
    -- Check combat state
    playerData.inCombat = IsPedInMeleeCombat(ped) or IsPedShooting(ped)
    
    -- Wanted level
    playerData.wanted = GetPlayerWantedLevel(PlayerId())
    
    -- Send update to NUI
    SendNUIMessage({
        type = 'updateHUD',
        data = playerData
    })
end

-- Update ESX-specific data
function UpdateESXData()
    local player = ESX.GetPlayerData()
    if player then
        playerData.cash = player.money or 0
        playerData.bank = player.accounts and player.accounts.bank or 0
        playerData.job = player.job or {name = "unemployed", grade = 0, label = "Unemployed"}
        playerData.rank = playerData.job.grade_label or "Civilian"
        
        -- Handle hunger/thirst if using esx_status
        if exports['esx_status'] then
            playerData.hunger = exports['esx_status']:getStatus('hunger') or 100
            playerData.thirst = exports['esx_status']:getStatus('thirst') or 100
        end
    end
end

-- Update QB-core specific data
function UpdateQBData()
    local player = QBCore.Functions.GetPlayerData()
    if player then
        playerData.cash = player.money.cash or 0
        playerData.bank = player.money.bank or 0
        playerData.job = player.job or {name = "unemployed", grade = {level = 0, name = "None"}, label = "Unemployed"}
        playerData.rank = playerData.job.grade.name or "Civilian"
        
        -- Handle hunger/thirst if using qb-core metadata
        if player.metadata then
            playerData.hunger = player.metadata.hunger or 100
            playerData.thirst = player.metadata.thirst or 100
        end
    end
end

-- Toggle HUD visibility
RegisterCommand('togglehud', function()
    SendNUIMessage({
        type = 'toggleHUD'
    })
end, false)

-- Force update HUD
RegisterCommand('updatehud', function()
    UpdatePlayerData()
end, false)

-- Key mapping for HUD toggle
RegisterKeyMapping('togglehud', 'Toggle HUD Visibility', 'keyboard', 'h')

-- Event handlers
RegisterNetEvent('hud:client:updateData')
AddEventHandler('hud:client:updateData', function(data)
    if data then
        for k, v in pairs(data) do
            playerData[k] = v
        end
        
        SendNUIMessage({
            type = 'updateHUD',
            data = playerData
        })
    end
end)

RegisterNetEvent('hud:client:showNotification')
AddEventHandler('hud:client:showNotification', function(message, type, duration)
    SendNUIMessage({
        type = 'showNotification',
        message = message,
        notificationType = type or 'info',
        duration = duration or 3000
    })
end)

-- Export functions for other resources
exports('GetHUDData', function()
    return playerData
end)

exports('SetHUDVisibility', function(visible)
    SendNUIMessage({
        type = 'setVisibility',
        visible = visible
    })
end)

exports('ShowNotification', function(message, type, duration)
    SendNUIMessage({
        type = 'showNotification',
        message = message,
        notificationType = type or 'info',
        duration = duration or 3000
    })
end)
