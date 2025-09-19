local players = {}

-- Initialize server side
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    Utils.Debug("HUD server started")
    
    -- Initialize players already connected
    for _, playerId in ipairs(GetPlayers()) do
        players[playerId] = {
            source = playerId,
            identifier = Utils.GetPlayerIdentifier(playerId),
            connected = true
        }
    end
end)

-- Player connected
AddEventHandler('playerConnected', function()
    local playerId = source
    players[playerId] = {
        source = playerId,
        identifier = Utils.GetPlayerIdentifier(playerId),
        connected = true
    }
    
    Utils.Debug("Player connected: " .. playerId)
end)

-- Player disconnected
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    players[playerId] = nil
    
    Utils.Debug("Player disconnected: " .. playerId .. " Reason: " .. reason)
end)

-- Update player data from client
RegisterNetEvent('hud:server:updatePlayerData')
AddEventHandler('hud:server:updatePlayerData', function(data)
    local playerId = source
    if players[playerId] then
        players[playerId].data = data
    end
end)

-- Get player data (admin function)
RegisterNetEvent('hud:server:getPlayerData')
AddEventHandler('hud:server:getPlayerData', function(targetId)
    local playerId = source
    
    -- Check admin permissions
    if not Utils.HasPermission(playerId, 'admin') then
        Utils.Debug("Non-admin attempted to get player data: " .. playerId)
        return
    end
    
    local targetData = players[targetId]
    if targetData then
        TriggerClientEvent('hud:client:receivePlayerData', playerId, targetData)
    else
        TriggerClientEvent('hud:client:showNotification', playerId, 'Player not found', 'error')
    end
end)

-- Send notification to player (admin function)
RegisterNetEvent('hud:server:sendNotification')
AddEventHandler('hud:server:sendNotification', function(targetId, message, notifType)
    local playerId = source
    
    -- Check admin permissions
    if not Utils.HasPermission(playerId, 'admin') then
        Utils.Debug("Non-admin attempted to send notification: " .. playerId)
        return
    end
    
    TriggerClientEvent('hud:client:showNotification', targetId, message, notifType or 'info')
    Utils.Debug("Admin " .. playerId .. " sent notification to " .. targetId)
end)

-- Toggle HUD for player (admin function)
RegisterNetEvent('hud:server:toggleHUD')
AddEventHandler('hud:server:toggleHUD', function(targetId, toggle)
    local playerId = source
    
    -- Check admin permissions
    if not Utils.HasPermission(playerId, 'admin') then
        Utils.Debug("Non-admin attempted to toggle HUD: " .. playerId)
        return
    end
    
    TriggerClientEvent('hud:client:setHUDVisibility', targetId, toggle)
    Utils.Debug("Admin " .. playerId .. " toggled HUD for " .. targetId .. " to " .. tostring(toggle))
end)

-- Get all players data (admin function)
RegisterNetEvent('hud:server:getAllPlayersData')
AddEventHandler('hud:server:getAllPlayersData', function()
    local playerId = source
    
    -- Check admin permissions
    if not Utils.HasPermission(playerId, 'admin') then
        Utils.Debug("Non-admin attempted to get all players data: " .. playerId)
        return
    end
    
    local allPlayersData = {}
    for id, data in pairs(players) do
        allPlayersData[id] = {
            identifier = data.identifier,
            source = data.source,
            data = data.data
        }
    end
    
    TriggerClientEvent('hud:client:receiveAllPlayersData', playerId, allPlayersData)
end)

-- Export function for other resources
exports('GetPlayerHUDData', function(playerId)
    return players[playerId] and players[playerId].data or nil
end)

exports('SendNotification', function(playerId, message, notifType)
    if players[playerId] then
        TriggerClientEvent('hud:client:showNotification', playerId, message, notifType or 'info')
        return true
    end
    return false
end)
