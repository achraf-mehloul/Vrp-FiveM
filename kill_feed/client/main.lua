local config = Config.KillFeed
local currentLanguage = 'ar' 

function SendKillToUI(killer, victim, weapon)
    if not config.enabled then return end
    
    local weaponIcon = Config.WeaponIcons[weapon] or "💀"
    
    SendNUIMessage({
        action = "showKill",
        killer = killer,
        victim = victim,
        weapon = weapon,
        weaponIcon = weaponIcon,
        language = currentLanguage,
        textKilled = Config.Language[currentLanguage].killed
    })
end

RegisterNetEvent('killfeed:client:showKill')
AddEventHandler('killfeed:client:showKill', function(killer, victim, weapon)
    SendKillToUI(killer, victim, weapon)
end)

RegisterCommand('testkill', function()
    SendKillToUI("Player1", "Player2", `WEAPON_PISTOL`)
end, false)
