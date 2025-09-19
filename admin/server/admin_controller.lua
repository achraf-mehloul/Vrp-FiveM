[file name]: admin/server/admin_controller.lua
[file content begin]
AdminController = {}

function AdminController:new()
    local instance = {}
    setmetatable(instance, { __index = AdminController })
    return instance
end

-- Check if player is admin
ESX.RegisterServerCallback('admin:checkAdmin', function(source, callback)
    local isAdmin = AdminServiceInstance:IsPlayerAdmin(source)
    local level = AdminServiceInstance:GetPlayerAdminLevel(source)
    callback(isAdmin, level)
end)

-- Get online players
ESX.RegisterServerCallback('admin:getPlayers', function(source, callback)
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        callback({})
        return
    end
    
    local players = AdminServiceInstance:GetOnlinePlayers()
    callback(players)
end)

-- Get player information
ESX.RegisterServerCallback('admin:getPlayerInfo', function(source, callback, playerId)
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        callback(nil)
        return
    end
    
    local playerInfo = AdminServiceInstance:GetPlayerInfo(playerId)
    callback(playerInfo)
end)

-- Get server statistics
ESX.RegisterServerCallback('admin:getServerStats', function(source, callback)
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        callback({})
        return
    end
    
    local stats = AdminServiceInstance:GetServerStats()
    callback(stats)
end)

-- Kick player
RegisterNetEvent('admin:kickPlayer')
AddEventHandler('admin:kickPlayer', function(targetId, reason)
    local source = source
    local success, message = AdminServiceInstance:KickPlayer(source, targetId, reason)
    
    if not success then
        TriggerClientEvent('admin:client:showNotification', source, message, 'error')
    else
        TriggerClientEvent('admin:client:showNotification', source, message, 'success')
    end
end)

-- Ban player
RegisterNetEvent('admin:banPlayer')
AddEventHandler('admin:banPlayer', function(targetId, duration, reason)
    local source = source
    local success, message = AdminServiceInstance:BanPlayer(source, targetId, duration, reason)
    
    if not success then
        TriggerClientEvent('admin:client:showNotification', source, message, 'error')
    else
        TriggerClientEvent('admin:client:showNotification', source, message, 'success')
    end
end)

-- Warn player
RegisterNetEvent('admin:warnPlayer')
AddEventHandler('admin:warnPlayer', function(targetId, reason, severity)
    local source = source
    local success, message = AdminServiceInstance:WarnPlayer(source, targetId, reason, severity)
    
    if not success then
        TriggerClientEvent('admin:client:showNotification', source, message, 'error')
    else
        TriggerClientEvent('admin:client:showNotification', source, message, 'success')
    end
end)

-- Teleport to player
RegisterNetEvent('admin:teleportToPlayer')
AddEventHandler('admin:teleportToPlayer', function(targetId)
    local source = source
    local success, message = AdminServiceInstance:TeleportToPlayer(source, targetId)
    
    if not success then
        TriggerClientEvent('admin:client:showNotification', source, message, 'error')
    else
        TriggerClientEvent('admin:client:showNotification', source, message, 'success')
    end
end)

-- Teleport player to me
RegisterNetEvent('admin:teleportPlayerToMe')
AddEventHandler('admin:teleportPlayerToMe', function(targetId)
    local source = source
    local success, message = AdminServiceInstance:TeleportPlayerToMe(source, targetId)
    
    if not success then
        TriggerClientEvent('admin:client:showNotification', source, message, 'error')
    else
        TriggerClientEvent('admin:client:showNotification', source, message, 'success')
    end
end)

-- Revive player
RegisterNetEvent('admin:revivePlayer')
AddEventHandler('admin:revivePlayer', function(targetId)
    local source = source
    local success, message = AdminServiceInstance:RevivePlayer(source, targetId or source)
    
    if not success then
        TriggerClientEvent('admin:client:showNotification', source, message, 'error')
    else
        TriggerClientEvent('admin:client:showNotification', source, message, 'success')
    end
end)

-- Spectate player
RegisterNetEvent('admin:spectatePlayer')
AddEventHandler('admin:spectatePlayer', function(targetId)
    local source = source
    
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        TriggerClientEvent('admin:client:showNotification', source, 'No permission', 'error')
        return
    end
    
    TriggerClientEvent('admin:client:startSpectate', source, targetId)
    
    -- Log action
    Permissions:LogAction(source, 'spectate', targetId, {
        target_name = GetPlayerName(targetId)
    })
end)

-- Give item to player
RegisterNetEvent('admin:giveItem')
AddEventHandler('admin:giveItem', function(targetId, itemName, amount)
    local source = source
    
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        TriggerClientEvent('admin:client:showNotification', source, 'No permission', 'error')
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(targetId)
    if xPlayer then
        xPlayer.addInventoryItem(itemName, amount or 1)
        
        -- Log action
        Permissions:LogAction(source, 'give_item', targetId, {
            item = itemName,
            amount = amount,
            target_name = GetPlayerName(targetId)
        })
        
        TriggerClientEvent('admin:client:showNotification', source, 'Item given', 'success')
    else
        TriggerClientEvent('admin:client:showNotification', source, 'Player not found', 'error')
    end
end)

-- Give weapon to player
RegisterNetEvent('admin:giveWeapon')
AddEventHandler('admin:giveWeapon', function(targetId, weaponName, ammo)
    local source = source
    
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        TriggerClientEvent('admin:client:showNotification', source, 'No permission', 'error')
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(targetId)
    if xPlayer then
        xPlayer.addWeapon(weaponName, ammo or 100)
        
        -- Log action
        Permissions:LogAction(source, 'give_weapon', targetId, {
            weapon = weaponName,
            ammo = ammo,
            target_name = GetPlayerName(targetId)
        })
        
        TriggerClientEvent('admin:client:showNotification', source, 'Weapon given', 'success')
    else
        TriggerClientEvent('admin:client:showNotification', source, 'Player not found', 'error')
    end
end)

-- Set player job
RegisterNetEvent('admin:setJob')
AddEventHandler('admin:setJob', function(targetId, jobName, grade)
    local source = source
    
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        TriggerClientEvent('admin:client:showNotification', source, 'No permission', 'error')
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(targetId)
    if xPlayer then
        xPlayer.setJob(jobName, grade or 0)
        
        -- Log action
        Permissions:LogAction(source, 'set_job', targetId, {
            job = jobName,
            grade = grade,
            target_name = GetPlayerName(targetId)
        })
        
        TriggerClientEvent('admin:client:showNotification', source, 'Job updated', 'success')
    else
        TriggerClientEvent('admin:client:showNotification', source, 'Player not found', 'error')
    end
end)

-- Set player money
RegisterNetEvent('admin:setMoney')
AddEventHandler('admin:setMoney', function(targetId, moneyType, amount)
    local source = source
    
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        TriggerClientEvent('admin:client:showNotification', source, 'No permission', 'error')
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(targetId)
    if xPlayer then
        if moneyType == 'cash' then
            xPlayer.setMoney(amount)
        elseif moneyType == 'bank' then
            xPlayer.setAccountMoney('bank', amount)
        elseif moneyType == 'black_money' then
            xPlayer.setAccountMoney('black_money', amount)
        end
        
        -- Log action
        Permissions:LogAction(source, 'set_money', targetId, {
            type = moneyType,
            amount = amount,
            target_name = GetPlayerName(targetId)
        })
        
        TriggerClientEvent('admin:client:showNotification', source, 'Money updated', 'success')
    else
        TriggerClientEvent('admin:client:showNotification', source, 'Player not found', 'error')
    end
end)

-- Open player inventory (UI)
RegisterNetEvent('admin:openPlayerInventory')
AddEventHandler('admin:openPlayerInventory', function(targetId)
    local source = source
    
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        return
    end
    
    local targetXPlayer = ESX.GetPlayerFromId(targetId)
    if targetXPlayer then
        TriggerClientEvent('esx_inventoryhud:openPlayerInventory', source, targetXPlayer.source, targetXPlayer.name)
    end
end)

-- NUI callbacks
RegisterNUICallback('getPlayerInfo', function(data, cb)
    local source = source
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        cb({})
        return
    end
    
    local playerInfo = AdminServiceInstance:GetPlayerInfo(data.playerId)
    cb(playerInfo or {})
end)

RegisterNUICallback('getServerStats', function(data, cb)
    local source = source
    if not AdminServiceInstance:IsPlayerAdmin(source) then
        cb({})
        return
    end
    
    local stats = AdminServiceInstance:GetServerStats()
    cb(stats or {})
end)

RegisterNUICallback('kickPlayer', function(data, cb)
    local source = source
    TriggerEvent('admin:kickPlayer', data.playerId, data.reason)
    cb('ok')
end)

RegisterNUICallback('banPlayer', function(data, cb)
    local source = source
    TriggerEvent('admin:banPlayer', data.playerId, data.duration, data.reason)
    cb('ok')
end)

RegisterNUICallback('warnPlayer', function(data, cb)
    local source = source
    TriggerEvent('admin:warnPlayer', data.playerId, data.reason, data.severity)
    cb('ok')
end)

RegisterNUICallback('teleportToPlayer', function(data, cb)
    local source = source
    TriggerEvent('admin:teleportToPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('teleportPlayerToMe', function(data, cb)
    local source = source
    TriggerEvent('admin:teleportPlayerToMe', data.playerId)
    cb('ok')
end)

RegisterNUICallback('revivePlayer', function(data, cb)
    local source = source
    TriggerEvent('admin:revivePlayer', data.playerId)
    cb('ok')
end)

-- Initialize controller
function AdminController:Initialize()
    -- Start the service
    AdminServiceInstance:Initialize()
    
    print('[AdminController] Initialized')
end

-- Create global instance
AdminControllerInstance = AdminController:new()

-- Start the controller when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        AdminControllerInstance:Initialize()
    end
end)
[file content end]
