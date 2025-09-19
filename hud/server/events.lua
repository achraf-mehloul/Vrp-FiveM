-- Server-side event handlers for framework integration

-- ESX integration
if Config.Framework == 'esx' then
    ESX = nil
    
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(100)
        end
        
        Utils.Debug("ESX integration initialized")
    end)

    -- Update player data when job changes
    AddEventHandler('esx:setJob', function(playerId, job, lastJob)
        if players[playerId] then
            players[playerId].job = job
            
            -- Notify player's client about job change
            TriggerClientEvent('hud:client:updateData', playerId, {job = job})
        end
    end)

    -- Update player data when money changes
    AddEventHandler('esx:addMoney', function(playerId, amount)
        if players[playerId] then
            players[playerId].cash = (players[playerId].cash or 0) + amount
            
            -- Notify player's client about money change
            TriggerClientEvent('hud:client:updateData', playerId, {cash = players[playerId].cash})
        end
    end)
end

-- QB-core integration
if Config.Framework == 'qb-core' then
    QBCore = nil
    
    Citizen.CreateThread(function()
        while QBCore == nil do
            QBCore = exports['qb-core']:GetCoreObject()
            Citizen.Wait(100)
        end
        
        Utils.Debug("QB-core integration initialized")
    end)

    -- Update player data when job changes
    RegisterNetEvent('QBCore:Server:OnJobUpdate')
    AddEventHandler('QBCore:Server:OnJobUpdate', function(playerId, job)
        if players[playerId] then
            players[playerId].job = job
            
            -- Notify player's client about job change
            TriggerClientEvent('hud:client:updateData', playerId, {job = job})
        end
    end)

    -- Update player data when money changes
    RegisterNetEvent('QBCore:Server:OnMoneyChange')
    AddEventHandler('QBCore:Server:OnMoneyChange', function(playerId, moneyType, amount)
        if players[playerId] then
            if moneyType == 'cash' then
                players[playerId].cash = amount
                TriggerClientEvent('hud:client:updateData', playerId, {cash = amount})
            elseif moneyType == 'bank' then
                players[playerId].bank = amount
                TriggerClientEvent('hud:client:updateData', playerId, {bank = amount})
            end
        end
    end)
end

-- Handle player death/respawn
AddEventHandler('esx:onPlayerDeath', function(data)
    local playerId = source
    TriggerClientEvent('hud:client:showNotification', playerId, 'You are injured. Seek medical help!', 'warning')
end)

AddEventHandler('esx:onPlayerSpawn', function()
    local playerId = source
    TriggerClientEvent('hud:client:showNotification', playerId, 'You have respawned.', 'info')
end)

-- Handle player entering/leaving vehicle
RegisterNetEvent('hud:server:vehicleEnterExit')
AddEventHandler('hud:server:vehicleEnterExit', function(entered, vehicleData)
    local playerId = source
    if players[playerId] then
        players[playerId].inVehicle = entered
        players[playerId].vehicle = entered and vehicleData or nil
    end
end)
