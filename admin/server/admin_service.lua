[file name]: admin/server/admin_service.lua
[file content begin]
AdminService = {}

function AdminService:new()
    local instance = {}
    setmetatable(instance, { __index = AdminService })
    return instance
end

-- Get all online players
function AdminService:GetOnlinePlayers()
    local players = {}
    local playerCount = 0
    
    for _, playerId in ipairs(GetPlayers()) do
        playerCount = playerCount + 1
        local player = {
            id = tonumber(playerId),
            name = GetPlayerName(playerId),
            ping = GetPlayerPing(playerId),
            identifiers = self:GetPlayerIdentifiers(playerId)
        }
        
        -- Add ESX player data if available
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                player.steam = xPlayer.identifier
                player.license = self:GetIdentifier(xPlayer.identifier, 'license')
                player.discord = self:GetIdentifier(xPlayer.identifier, 'discord')
                player.license2 = self:GetIdentifier(xPlayer.identifier, 'license2')
                player.xbl = self:GetIdentifier(xPlayer.identifier, 'xbl')
                player.live = self:GetIdentifier(xPlayer.identifier, 'live')
                player.fivem = self:GetIdentifier(xPlayer.identifier, 'fivem')
                
                -- Get job information
                player.job = xPlayer.job
                
                -- Get money
                player.money = {
                    cash = xPlayer.getMoney(),
                    bank = xPlayer.getAccount('bank').money,
                    black_money = xPlayer.getAccount('black_money').money
                }
            end
        end
        
        table.insert(players, player)
    end
    
    return players, playerCount
end

-- Get player identifiers
function AdminService:GetPlayerIdentifiers(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    local result = {}
    
    for _, identifier in ipairs(identifiers) do
        local type, value = identifier:match('([^:]+):([^:]+)')
        if type and value then
            result[type] = value
        end
    end
    
    return result
end

-- Get specific identifier
function AdminService:GetIdentifier(identifiers, type)
    if type(identifiers) == 'table' then
        return identifiers[type]
    else
        local allIdentifiers = self:GetPlayerIdentifiers(identifiers)
        return allIdentifiers[type]
    end
end

-- Check if player is admin
function AdminService:IsPlayerAdmin(playerId)
    if not playerId then return false end
    
    local identifier = self:GetPlayerIdentifier(playerId)
    if not identifier then return false end
    
    return Permissions:IsAdmin(identifier)
end

-- Get player admin level
function AdminService:GetPlayerAdminLevel(playerId)
    if not playerId then return nil end
    
    local identifier = self:GetPlayerIdentifier(playerId)
    if not identifier then return nil end
    
    return Permissions:GetPlayerGroup(playerId)
end

-- Get player identifier
function AdminService:GetPlayerIdentifier(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, identifier in ipairs(identifiers) do
        if identifier:sub(1, 5) == 'steam' then
            return identifier
        end
    end
    return identifiers[1] -- fallback to first identifier
end

-- Kick player
function AdminService:KickPlayer(source, targetId, reason)
    if not self:IsPlayerAdmin(source) then
        return false, 'No permission'
    end
    
    local targetName = GetPlayerName(targetId)
    DropPlayer(targetId, reason or 'Kicked by admin')
    
    -- Log action
    Permissions:LogAction(source, 'kick', targetId, {
        reason = reason,
        target_name = targetName
    })
    
    return true, 'Player kicked'
end

-- Ban player
function AdminService:BanPlayer(source, targetId, duration, reason)
    if not self:IsPlayerAdmin(source) then
        return false, 'No permission'
    end
    
    local targetIdentifier = self:GetPlayerIdentifier(targetId)
    if not targetIdentifier then
        return false, 'Could not get player identifier'
    end
    
    local targetName = GetPlayerName(targetId)
    local expiresAt = os.time() + (duration * 24 * 60 * 60) -- Convert days to seconds
    
    -- Insert ban into database
    local success = AdminRepository:BanPlayer({
        identifier = targetIdentifier,
        reason = reason,
        banned_by = self:GetPlayerIdentifier(source),
        expires_at = os.date('%Y-%m-%d %H:%M:%S', expiresAt)
    })
    
    if success then
        DropPlayer(targetId, 'Banned: ' .. reason)
        
        -- Log action
        Permissions:LogAction(source, 'ban', targetId, {
            reason = reason,
            duration = duration,
            target_name = targetName
        })
        
        return true, 'Player banned'
    else
        return false, 'Failed to ban player'
    end
end

-- Warn player
function AdminService:WarnPlayer(source, targetId, reason, severity)
    if not self:IsPlayerAdmin(source) then
        return false, 'No permission'
    end
    
    local targetIdentifier = self:GetPlayerIdentifier(targetId)
    if not targetIdentifier then
        return false, 'Could not get player identifier'
    end
    
    local targetName = GetPlayerName(targetId)
    
    -- Add warning to database
    local success = AdminRepository:AddWarning({
        player_identifier = targetIdentifier,
        admin_identifier = self:GetPlayerIdentifier(source),
        reason = reason,
        severity = severity
    })
    
    if success then
        -- Log action
        Permissions:LogAction(source, 'warn', targetId, {
            reason = reason,
            severity = severity,
            target_name = targetName
        })
        
        -- Notify target player
        TriggerClientEvent('admin:client:showNotification', targetId, 
            'You have been warned by an admin: ' .. reason, 'warning')
        
        return true, 'Player warned'
    else
        return false, 'Failed to warn player'
    end
end

-- Teleport to player
function AdminService:TeleportToPlayer(source, targetId)
    if not self:IsPlayerAdmin(source) then
        return false, 'No permission'
    end
    
    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
    SetEntityCoords(GetPlayerPed(source), targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, false)
    
    -- Log action
    Permissions:LogAction(source, 'teleport_to', targetId, {
        target_name = GetPlayerName(targetId)
    })
    
    return true, 'Teleported to player'
end

-- Teleport player to me
function AdminService:TeleportPlayerToMe(source, targetId)
    if not self:IsPlayerAdmin(source) then
        return false, 'No permission'
    end
    
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    SetEntityCoords(GetPlayerPed(targetId), sourceCoords.x, sourceCoords.y, sourceCoords.z, false, false, false, false)
    
    -- Log action
    Permissions:LogAction(source, 'teleport_bring', targetId, {
        target_name = GetPlayerName(targetId)
    })
    
    return true, 'Player teleported to you'
end

-- Revive player
function AdminService:RevivePlayer(source, targetId)
    if not self:IsPlayerAdmin(source) then
        return false, 'No permission'
    end
    
    TriggerClientEvent('esx_ambulancejob:revive', targetId)
    
    -- Log action
    Permissions:LogAction(source, 'revive', targetId, {
        target_name = GetPlayerName(targetId)
    })
    
    return true, 'Player revived'
end

-- Get player information
function AdminService:GetPlayerInfo(playerId)
    if not playerId then return nil end
    
    local playerInfo = {
        id = playerId,
        name = GetPlayerName(playerId),
        ping = GetPlayerPing(playerId),
        identifiers = self:GetPlayerIdentifiers(playerId)
    }
    
    -- Add ESX data if available
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            playerInfo.steam = xPlayer.identifier
            playerInfo.job = xPlayer.job
            playerInfo.money = {
                cash = xPlayer.getMoney(),
                bank = xPlayer.getAccount('bank').money
            }
            
            -- Get inventory
            playerInfo.inventory = {}
            for _, item in ipairs(xPlayer.inventory) do
                if item.count > 0 then
                    table.insert(playerInfo.inventory, {
                        name = item.name,
                        count = item.count,
                        label = item.label
                    })
                end
            end
            
            -- Get loadout (weapons)
            playerInfo.loadout = xPlayer.loadout
        end
    end
    
    return playerInfo
end

-- Get server statistics
function AdminService:GetServerStats()
    return AdminRepository:GetServerStats()
end

-- Get admin log
function AdminService:GetAdminLog(limit, offset)
    return AdminRepository:GetAdminLog(limit, offset)
end

-- Get player warnings
function AdminService:GetPlayerWarnings(playerIdentifier)
    return AdminRepository:GetPlayerWarnings(playerIdentifier)
end

-- Clear player warnings
function AdminService:ClearPlayerWarnings(playerIdentifier)
    return AdminRepository:ClearWarnings(playerIdentifier)
end

-- Check if player is banned
function AdminService:IsPlayerBanned(playerIdentifier)
    return AdminRepository:IsPlayerBanned(playerIdentifier)
end

-- Get all admins
function AdminService:GetAllAdmins()
    return AdminRepository:GetAdminUsers()
end

-- Add admin
function AdminService:AddAdmin(identifier, group, addedBy)
    if not self:IsPlayerAdmin(addedBy) then
        return false, 'No permission'
    end
    
    return AdminRepository:AddAdminUser({
        identifier = identifier,
        group = group,
        added_by = self:GetPlayerIdentifier(addedBy)
    })
end

-- Remove admin
function AdminService:RemoveAdmin(identifier, removedBy)
    if not self:IsPlayerAdmin(removedBy) then
        return false, 'No permission'
    end
    
    return AdminRepository:RemoveAdminUser(identifier, self:GetPlayerIdentifier(removedBy))
end

-- Export data
function AdminService:ExportData(dataType, format, requestedBy)
    if not self:IsPlayerAdmin(requestedBy) then
        return false, 'No permission'
    end
    
    return AdminRepository:ExportData(dataType, format)
end

-- Send notification to player
function AdminService:SendNotification(playerId, message, type)
    TriggerClientEvent('admin:client:showNotification', playerId, message, type or 'info')
end

-- Broadcast message to all players
function AdminService:BroadcastMessage(message, type)
    TriggerClientEvent('admin:client:showNotification', -1, message, type or 'info')
end

-- Update player list for all admins
function AdminService:UpdatePlayerListForAdmins()
    local players = self:GetOnlinePlayers()
    
    for _, playerId in ipairs(GetPlayers()) do
        if self:IsPlayerAdmin(playerId) then
            TriggerClientEvent('admin:client:updatePlayerList', playerId, players)
        end
    end
end

-- Initialize service
function AdminService:Initialize()
    -- Update player list every 30 seconds
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000)
            self:UpdatePlayerListForAdmins()
        end
    end)
    
    print('[AdminService] Initialized')
end

-- Create global instance
AdminServiceInstance = AdminService:new()
[file content end]
