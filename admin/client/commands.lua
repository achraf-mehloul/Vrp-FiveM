-- Admin commands system
local adminCommands = {}

-- Register admin command
function RegisterAdminCommand(command, callback, restricted)
    RegisterCommand(Config.Admin.CommandPrefix .. command, function(source, args, rawCommand)
        if not isAdmin then
            ESX.ShowNotification('~r~You do not have permission to use this command!')
            return
        end

        if restricted and not Permissions:HasPermission(source, restricted) then
            ESX.ShowNotification('~r~Insufficient permissions!')
            return
        end

        callback(source, args, rawCommand)
    end, false)
end

-- Kick command
RegisterAdminCommand('kick', function(source, args)
    local target = tonumber(args[1])
    local reason = table.concat(args, ' ', 2) or 'No reason provided'
    
    if not target then
        ESX.ShowNotification('~r~Usage: /akick [playerId] [reason]')
        return
    end

    TriggerServerEvent('admin:kickPlayer', target, reason)
end, 'kick')

-- Ban command
RegisterAdminCommand('ban', function(source, args)
    local target = tonumber(args[1])
    local duration = tonumber(args[2])
    local reason = table.concat(args, ' ', 3) or 'No reason provided'
    
    if not target or not duration then
        ESX.ShowNotification('~r~Usage: /aban [playerId] [duration] [reason]')
        return
    end

    TriggerServerEvent('admin:banPlayer', target, duration, reason)
end, 'ban')

-- Teleport to player
RegisterAdminCommand('tp', function(source, args)
    local target = tonumber(args[1])
    
    if not target then
        ESX.ShowNotification('~r~Usage: /atp [playerId]')
        return
    end

    TriggerServerEvent('admin:teleportToPlayer', target)
end, 'teleport')

-- Teleport player to me
RegisterAdminCommand('bring', function(source, args)
    local target = tonumber(args[1])
    
    if not target then
        ESX.ShowNotification('~r~Usage: /abring [playerId]')
        return
    end

    TriggerServerEvent('admin:teleportPlayerToMe', target)
end, 'teleport')

-- Revive player
RegisterAdminCommand('revive', function(source, args)
    local target = tonumber(args[1]) or source
    
    TriggerServerEvent('admin:revivePlayer', target)
end, 'revive')

-- Spectate player
RegisterAdminCommand('spectate', function(source, args)
    local target = tonumber(args[1])
    
    if not target then
        ESX.ShowNotification('~r~Usage: /aspectate [playerId]')
        return
    end

    TriggerServerEvent('admin:spectatePlayer', target)
end, 'spectate')

-- Noclip
RegisterAdminCommand('noclip', function(source, args)
    TriggerEvent('admin:client:toggleNoclip')
end, 'teleport')

-- Give item
RegisterAdminCommand('giveitem', function(source, args)
    local target = tonumber(args[1])
    local item = args[2]
    local amount = tonumber(args[3]) or 1
    
    if not target or not item then
        ESX.ShowNotification('~r~Usage: /agiveitem [playerId] [item] [amount]')
        return
    end

    TriggerServerEvent('admin:giveItem', target, item, amount)
end, 'spawn_item')

-- Give weapon
RegisterAdminCommand('giveweapon', function(source, args)
    local target = tonumber(args[1])
    local weapon = args[2]
    local ammo = tonumber(args[3]) or 100
    
    if not target or not weapon then
        ESX.ShowNotification('~r~Usage: /agiveweapon [playerId] [weapon] [ammo]')
        return
    end

    TriggerServerEvent('admin:giveWeapon', target, weapon, ammo)
end, 'spawn_item')

-- Set job
RegisterAdminCommand('setjob', function(source, args)
    local target = tonumber(args[1])
    local job = args[2]
    local grade = tonumber(args[3]) or 0
    
    if not target or not job then
        ESX.ShowNotification('~r~Usage: /asetjob [playerId] [job] [grade]')
        return
    end

    TriggerServerEvent('admin:setJob', target, job, grade)
end, 'manage_player')

-- Set money
RegisterAdminCommand('setmoney', function(source, args)
    local target = tonumber(args[1])
    local moneyType = args[2]
    local amount = tonumber(args[3])
    
    if not target or not moneyType or not amount then
        ESX.ShowNotification('~r~Usage: /asetmoney [playerId] [cash/bank] [amount]')
        return
    end

    TriggerServerEvent('admin:setMoney', target, moneyType, amount)
end, 'manage_player')

-- Warn player
RegisterAdminCommand('warn', function(source, args)
    local target = tonumber(args[1])
    local reason = table.concat(args, ' ', 2) or 'No reason provided'
    
    if not target then
        ESX.ShowNotification('~r~Usage: /awarn [playerId] [reason]')
        return
    end

    TriggerServerEvent('admin:warnPlayer', target, reason, 'medium')
end, 'manage_player')

-- Car spawn
RegisterAdminCommand('car', function(source, args)
    local vehicle = args[1] or 'adder'
    
    ESX.Game.SpawnVehicle(vehicle, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), function(veh)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    end)
end, 'spawn_vehicle')

-- Fix vehicle
RegisterAdminCommand('fix', function(source, args)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    
    if veh and veh ~= 0 then
        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        SetVehicleUndriveable(veh, false)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)
        ESX.ShowNotification('~g~Vehicle fixed!')
    else
        ESX.ShowNotification('~r~You are not in a vehicle!')
    end
end, 'spawn_vehicle')

-- Delete vehicle
RegisterAdminCommand('dv', function(source, args)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    
    if veh and veh ~= 0 then
        ESX.Game.DeleteVehicle(veh)
        ESX.ShowNotification('~g~Vehicle deleted!')
    else
        local coordA = GetEntityCoords(ped, 1)
        local coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
        local vehicle = getVehicleInDirection(coordA, coordB)
        
        if vehicle and vehicle ~= 0 then
            ESX.Game.DeleteVehicle(vehicle)
            ESX.ShowNotification('~g~Vehicle deleted!')
        else
            ESX.ShowNotification('~r~No vehicle found!')
        end
    end
end, 'spawn_vehicle')

function getVehicleInDirection(coordFrom, coordTo)
    local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
    local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

-- Toggle invisibility
RegisterAdminCommand('invisible', function(source, args)
    local ped = PlayerPedId()
    local invisible = not IsEntityVisible(ped)
    
    SetEntityVisible(ped, invisible, false)
    SetEntityInvincible(ped, invisible)
    
    ESX.ShowNotification(invisible and '~g~Visible again!' or '~b~Invisible!')
end, 'teleport')

-- Player list
RegisterAdminCommand('players', function(source, args)
    ESX.TriggerServerCallback('admin:getPlayers', function(players)
        local message = 'Online players (' .. #players .. '):\n'
        
        for _, player in ipairs(players) do
            message = message .. string.format('[%d] %s (%s)\n', player.id, player.name, player.steam)
        end
        
        print(message)
        ESX.ShowNotification('Player list printed to console (F8)')
    end)
end, 'manage_player')

-- Server info
RegisterAdminCommand('serverinfo', function(source, args)
    ESX.TriggerServerCallback('admin:getServerStats', function(stats)
        local message = string.format([[
Server Statistics:
- Total Players: %d
- Active Players (24h): %d
- Banned Players: %d
- Recent Admin Actions: %d
- Active Warnings: %d
- Average Session Time: %.1f minutes
]], stats.totalPlayers, stats.activePlayers, stats.bannedPlayers, 
   stats.recentActions, stats.totalWarnings, stats.avgSessionTime or 0)
        
        print(message)
        ESX.ShowNotification('Server info printed to console (F8)')
    end)
end, 'manage_server')
