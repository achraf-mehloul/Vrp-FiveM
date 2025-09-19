-- Event handlers for player state changes

-- Update health when it changes
Citizen.CreateThread(function()
    local lastHealth = 0
    while true do
        Citizen.Wait(500)
        local currentHealth = GetEntityHealth(PlayerPedId()) - 100
        if currentHealth ~= lastHealth then
            lastHealth = currentHealth
            SendNUIMessage({
                type = 'updateHealth',
                value = currentHealth
            })
        end
    end
end)

-- Update armor when it changes
Citizen.CreateThread(function()
    local lastArmor = 0
    while true do
        Citizen.Wait(500)
        local currentArmor = GetPedArmour(PlayerPedId())
        if currentArmor ~= lastArmor then
            lastArmor = currentArmor
            SendNUIMessage({
                type = 'updateArmor',
                value = currentArmor
            })
        end
    end
end)

-- Handle vehicle entering/exiting
local inVehicle = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local currentInVehicle = IsPedInAnyVehicle(PlayerPedId(), false)
        if currentInVehicle ~= inVehicle then
            inVehicle = currentInVehicle
            SendNUIMessage({
                type = 'inVehicle',
                value = inVehicle
            })
        end
    end
end)

-- Handle combat state changes
Citizen.CreateThread(function()
    local inCombat = false
    while true do
        Citizen.Wait(500)
        local currentInCombat = IsPedInMeleeCombat(PlayerPedId()) or IsPedShooting(PlayerPedId())
        if currentInCombat ~= inCombat then
            inCombat = currentInCombat
            SendNUIMessage({
                type = 'inCombat',
                value = inCombat
            })
        end
    end
end)

-- Handle money changes (ESX)
if Config.Framework == 'esx' then
    RegisterNetEvent('esx:setAccountMoney')
    AddEventHandler('esx:setAccountMoney', function(account)
        if account.name == 'bank' then
            SendNUIMessage({
                type = 'updateBank',
                value = account.money
            })
        end
    end)

    RegisterNetEvent('esx:addInventoryItem')
    AddEventHandler('esx:addInventoryItem', function(item, count)
        if item == 'money' then
            SendNUIMessage({
                type = 'updateCash',
                value = count
            })
        end
    end)
end

-- Handle job changes
AddEventHandler('esx:setJob', function(job)
    SendNUIMessage({
        type = 'updateJob',
        value = job
    })
end)

-- Listen for NUI callbacks
RegisterNUICallback('getInitialData', function(data, cb)
    cb(playerData)
end)

RegisterNUICallback('savePosition', function(data, cb)
    -- Save HUD position to local storage
    SetResourceKvp('hud_position', json.encode(data))
    cb({success = true})
end)

RegisterNUICallback('playSound', function(data, cb)
    if data.sound == 'warning' then
        PlaySoundFrontend(-1, "CHECKPOINT_NORMAL", "HUD_MINI_GAME_SOUNDSET", true)
    end
    cb({success = true})
end)
