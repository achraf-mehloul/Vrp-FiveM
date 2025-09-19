local isAdmin = false
local adminLevel = nil
local playerList = {}
local adminMenuOpen = false

-- Initialize admin system
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(1000)
    end

    -- Check admin status
    ESX.TriggerServerCallback('admin:checkAdmin', function(adminStatus, level)
        isAdmin = adminStatus
        adminLevel = level
        
        if isAdmin then
            Utils.Debug("Admin system initialized. Level: " .. (level or "unknown"))
            TriggerEvent('chat:addMessage', {
                args = {'Admin System', 'Admin privileges activated. Level: ' .. level}
            })
        end
    end)
end)

-- Admin menu toggle
function ToggleAdminMenu()
    if not isAdmin then
        ESX.ShowNotification('~r~You do not have admin permissions!')
        return
    end

    adminMenuOpen = not adminMenuOpen

    if adminMenuOpen then
        ESX.TriggerServerCallback('admin:getPlayers', function(players)
            playerList = players
            SendNUIMessage({
                type = 'openAdminMenu',
                players = players,
                adminLevel = adminLevel,
                config = Config.Admin
            })
            SetNuiFocus(true, true)
            SetCursorLocation(0.5, 0.5)
        end)
    else
        SendNUIMessage({type = 'closeAdminMenu'})
        SetNuiFocus(false, false)
    end
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    adminMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('kickPlayer', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:kickPlayer', data.playerId, data.reason)
    cb('ok')
end)

RegisterNUICallback('banPlayer', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:banPlayer', data.playerId, data.duration, data.reason)
    cb('ok')
end)

RegisterNUICallback('teleportToPlayer', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:teleportToPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('teleportPlayerToMe', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:teleportPlayerToMe', data.playerId)
    cb('ok')
end)

RegisterNUICallback('revivePlayer', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:revivePlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('spectatePlayer', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:spectatePlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('openPlayerInventory', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:openPlayerInventory', data.playerId)
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:giveItem', data.playerId, data.item, data.amount)
    cb('ok')
end)

RegisterNUICallback('giveWeapon', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:giveWeapon', data.playerId, data.weapon, data.ammo)
    cb('ok')
end)

RegisterNUICallback('setJob', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:setJob', data.playerId, data.job, data.grade)
    cb('ok')
end)

RegisterNUICallback('setMoney', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:setMoney', data.playerId, data.type, data.amount)
    cb('ok')
end)

RegisterNUICallback('warnPlayer', function(data, cb)
    if not isAdmin then return end
    
    TriggerServerEvent('admin:warnPlayer', data.playerId, data.reason, data.severity)
    cb('ok')
end)

RegisterNUICallback('getPlayerInfo', function(data, cb)
    if not isAdmin then return end
    
    ESX.TriggerServerCallback('admin:getPlayerInfo', function(playerInfo)
        cb(playerInfo)
    end, data.playerId)
end)

RegisterNUICallback('getServerStats', function(data, cb)
    if not isAdmin then return end
    
    ESX.TriggerServerCallback('admin:getServerStats', function(stats)
        cb(stats)
    end)
end)

-- Admin menu command
RegisterCommand('adminmenu', function()
    ToggleAdminMenu()
end, false)

RegisterKeyMapping('adminmenu', 'Open Admin Menu', 'keyboard', 'f10')

-- Event handlers
RegisterNetEvent('admin:client:showNotification')
AddEventHandler('admin:client:showNotification', function(message, type)
    ESX.ShowNotification(message)
    
    SendNUIMessage({
        type = 'showNotification',
        message = message,
        notificationType = type or 'info'
    })
end)

RegisterNetEvent('admin:client:updatePlayerList')
AddEventHandler('admin:client:updatePlayerList', function(players)
    playerList = players
    
    if adminMenuOpen then
        SendNUIMessage({
            type = 'updatePlayerList',
            players = players
        })
    end
end)

-- Spectate mode
local spectating = false
local spectateTarget = nil
local originalCoords = nil

RegisterNetEvent('admin:client:startSpectate')
AddEventHandler('admin:client:startSpectate', function(targetId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    spectateTarget = targetId
    spectating = true
    originalCoords = GetEntityCoords(PlayerPedId())
    
    NetworkSetInSpectatorMode(true, targetPed)
    
    SendNUIMessage({
        type = 'spectateStarted',
        targetId = targetId
    })
    
    Citizen.CreateThread(function()
        while spectating do
            Citizen.Wait(100)
            if IsControlJustPressed(0, 73) then -- X key to stop spectating
                TriggerEvent('admin:client:stopSpectate')
            end
        end
    end)
end)

RegisterNetEvent('admin:client:stopSpectate')
AddEventHandler('admin:client:stopSpectate', function()
    NetworkSetInSpectatorMode(false, PlayerPedId())
    spectating = false
    spectateTarget = nil
    
    if originalCoords then
        SetEntityCoords(PlayerPedId(), originalCoords.x, originalCoords.y, originalCoords.z, false, false, false, false)
    end
    
    SendNUIMessage({type = 'spectateStopped'})
end)

-- No-clip functionality
local noclip = false
local noclip_speed = 1.0

RegisterNetEvent('admin:client:toggleNoclip')
AddEventHandler('admin:client:toggleNoclip', function()
    if not isAdmin then return end
    
    noclip = not noclip
    local msg = noclip and "~g~Noclip enabled" or "~r~Noclip disabled"
    ESX.ShowNotification(msg)
    
    if noclip then
        Citizen.CreateThread(function()
            while noclip do
                Citizen.Wait(0)
                local ped = PlayerPedId()
                local x, y, z = getPosition()
                local dx, dy, dz = getCamDirection()
                local speed = noclip_speed
                
                SetEntityVisible(ped, not noclip, false)
                SetEntityInvincible(ped, noclip)
                SetEntityCollision(ped, not noclip, not noclip)
                
                if IsControlPressed(0, 21) then -- Left Shift
                    speed = speed * 2
                end
                
                if IsControlPressed(0, 32) then -- W
                    x = x + speed * dx
                    y = y + speed * dy
                    z = z + speed * dz
                end
                
                if IsControlPressed(0, 269) then -- S
                    x = x - speed * dx
                    y = y - speed * dy
                    z = z - speed * dz
                end
                
                SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
            end
            
            -- Reset when noclip is disabled
            local ped = PlayerPedId()
            SetEntityVisible(ped, true, false)
            SetEntityInvincible(ped, false)
            SetEntityCollision(ped, true, true)
        end)
    end
end)

function getPosition()
    local ped = PlayerPedId()
    return GetEntityCoords(ped)
end

function getCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x, y, z
end

-- Export functions
exports('IsAdmin', function()
    return isAdmin
end)

exports('GetAdminLevel', function()
    return adminLevel
end)

exports('OpenAdminMenu', function()
    ToggleAdminMenu()
end)

exports('TeleportToCoords', function(x, y, z)
    if not isAdmin then return false end
    SetEntityCoords(PlayerPedId(), x, y, z, false, false, false, false)
    return true
end)
