local config = Config

local killHistory = {}

AddEventHandler('baseevents:onPlayerKilled', function(killerId, killerInfo, victimId, weaponHash)
    local victimSource = source
    local killerSource = killerId
    
    if killerSource == victimSource then
        TriggerClientEvent('killfeed:client:showKill', -1, 
            GetPlayerName(victimSource), 
            GetPlayerName(victimSource), 
            weaponHash, 
            { type = "suicide", text = Config.Language[GetPlayerLanguage(victimSource)].suicide }
        )
        return
    end
    
    local isHeadshot = IsPedHeadshot(victimSource)
    local highlight = nil
    
    if isHeadshot then
        highlight = { type = "headshot", text = Config.Language[GetPlayerLanguage(victimSource)].headshot }
    end
    
    TriggerClientEvent('killfeed:client:showKill', -1, 
        GetPlayerName(killerSource), 
        GetPlayerName(victimSource), 
        weaponHash, 
        highlight
    )
    
    table.insert(killHistory, 1, {
        killer = GetPlayerName(killerSource),
        victim = GetPlayerName(victimSource),
        weapon = weaponHash,
        timestamp = os.time(),
        highlight = highlight
    })
    
    if #killHistory > 20 then
        table.remove(killHistory, 21)
    end
end)

if config.ServerMode == "vrp" then
    AddEventHandler('vrp:playerKilled', function(victimSource, killerSource, weaponHash)
    end)
end

RegisterCommand('killhistory', function(source)
    local historyToSend = {}
    for i = 1, math.min(10, #killHistory) do
        table.insert(historyToSend, killHistory[i])
    end
    TriggerClientEvent('killfeed:client:showHistory', source, historyToSend)
end, false)
