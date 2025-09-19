local serverSettings = {
    serverName = "Melix Files V1",
    serverLogo = "assets/logo.png"
}

local playersData = {}

-- حدث طلب البيانات من العميل
RegisterServerEvent('pausemenu:requestData')
AddEventHandler('pausemenu:requestData', function()
    local src = source
    local playerName = GetPlayerName(src)
    
    local data = {
        playerId = src,
        playerName = playerName,
        serverName = serverSettings.serverName,
        serverLogo = serverSettings.serverLogo,
        wantedLevel = 0,
        playTime = GetPlayerPlayTime(src),
        serverTime = os.date("%H:%M"),
        onlinePlayers = #GetPlayers()
    }
    
    TriggerClientEvent('pausemenu:updateData', src, data)
end)

-- حدث الحصول على إعدادات السيرفر
RegisterServerEvent('pausemenu:getServerSettings')
AddEventHandler('pausemenu:getServerSettings', function()
    local src = source
    TriggerClientEvent('pausemenu:setServerSettings', src, serverSettings)
end)

-- حدث الخروج من السيرفر
RegisterServerEvent('pausemenu:disconnect')
AddEventHandler('pausemenu:disconnect', function()
    local src = source
    DropPlayer(src, "تم الخروج من السيرفر")
end)

-- حدث تغيير إعدادات السيرفر (للمشرفين)
RegisterServerEvent('pausemenu:updateServerSettings')
AddEventHandler('pausemenu:updateServerSettings', function(settings)
    if IsPlayerAceAllowed(source, "pausemenu.settings") then
        if settings.serverName then
            serverSettings.serverName = settings.serverName
        end
        if settings.serverLogo then
            serverSettings.serverLogo = settings.serverLogo
        end
        print("^2[PauseMenu] Server settings updated^0")
    end
end)

-- دالة للحصول على وقت اللعب
function GetPlayerPlayTime(source)
    if not playersData[source] then
        playersData[source] = {
            joinTime = os.time()
        }
    end
    
    local playTimeSeconds = os.time() - playersData[source].joinTime
    local hours = math.floor(playTimeSeconds / 3600)
    local minutes = math.floor((playTimeSeconds % 3600) / 60)
    local seconds = playTimeSeconds % 60
    
    return string.format("%d:%02d:%02d", hours, minutes, seconds)
end

-- تنظيف بيانات اللاعب عند الخروج
AddEventHandler('playerDropped', function(reason)
    local src = source
    playersData[src] = nil
end)

-- أمر لتغيير إعدادات السيرفر
RegisterCommand('setpausemenusettings', function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "pausemenu.settings") then
        if #args >= 2 then
            local settingType = args[1]
            local settingValue = table.concat(args, " ", 2)
            
            if settingType == "name" then
                serverSettings.serverName = settingValue
                TriggerClientEvent('pausemenu:setServerSettings', -1, serverSettings)
                print("^2[PauseMenu] Server name updated to:^0", settingValue)
            elseif settingType == "logo" then
                serverSettings.serverLogo = settingValue
                TriggerClientEvent('pausemenu:setServerSettings', -1, serverSettings)
                print("^2[PauseMenu] Server logo updated to:^0", settingValue)
            end
        else
            print("^1Usage: setpausemenusettings [name/logo] [value]^0")
        end
    end
end, false)
