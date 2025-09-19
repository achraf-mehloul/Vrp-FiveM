-- Kick player
RegisterNetEvent('admin:kickPlayer')
AddEventHandler('admin:kickPlayer', function(target, reason)
    local source = source
    
    if not HasPermission(source, 'kick') then
        LogAction(source, 'attempted_kick', 'No permission')
        return
    end
    
    DropPlayer(target, 'Kicked by admin: ' .. (reason or 'No reason provided'))
    LogAction(source, 'kick', 'Kicked player ' .. target .. ' for: ' .. reason)
end)

-- Ban player
RegisterNetEvent('admin:banPlayer')
AddEventHandler('admin:banPlayer', function(target, duration, reason)
    local source = source
    
    if not HasPermission(source, 'ban') then
        LogAction(source, 'attempted_ban', 'No permission')
        return
    end
    
    local identifier = GetPlayerIdentifier(target)
    MySQL.Async.execute('INSERT INTO bans (identifier, reason, duration, banned_by) VALUES (@identifier, @reason, @duration, @banned_by)', {
        ['@identifier'] = identifier,
        ['@reason'] = reason,
        ['@duration'] = duration,
        ['@banned_by'] = GetPlayerIdentifier(source)
    })
    
    DropPlayer(target, 'Banned: ' .. reason)
    LogAction(source, 'ban', 'Banned player ' .. target .. ' for ' .. duration .. ' days: ' .. reason)
end)

-- Teleport to player
RegisterNetEvent('admin:teleportToPlayer')
AddEventHandler('admin:teleportToPlayer', function(target)
    local source = source
    
    if not HasPermission(source, 'teleport') then
        LogAction(source, 'attempted_teleport', 'No permission')
        return
    end
    
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    SetEntityCoords(GetPlayerPed(source), targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, false)
    LogAction(source, 'teleport', 'Teleported to player ' .. target)
end)