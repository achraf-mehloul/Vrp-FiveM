Config = {}

Config.ServerMode = "vrp" -- vrp, esx, qbcore, standalone

Config.KillFeed = {
    displayTime = 5000,
    maxMessages = 5,
    position = "top-right",
    enabled = true,
    theme = "dark",
    sounds = true,
    avatars = true,
    animations = true
}

Config.Themes = {
    dark = {
        background = "rgba(0, 0, 0, 0.8)",
        textColor = "#ffffff",
        accentColor = "#ff4444",
        borderColor = "#ff0000"
    },
    light = {
        background = "rgba(255, 255, 255, 0.9)",
        textColor = "#333333",
        accentColor = "#ff4444",
        borderColor = "#ff0000"
    },
    custom = {
        background = "rgba(30, 30, 30, 0.85)",
        textColor = "#00ffcc",
        accentColor = "#ffaa00",
        borderColor = "#ff5500"
    }
}

Config.WeaponData = {
    [GetHashKey("WEAPON_PISTOL")] = { 
        icon = "🔫", 
        sound = "client/ui/sounds/pistol_shot.ogg",
        type = "pistol"
    },
    [GetHashKey("WEAPON_KNIFE")] = { 
        icon = "🗡️", 
        sound = "client/ui/sounds/knife_stab.ogg",
        type = "melee",
        highlight = "knife_kill"
    },
    [GetHashKey("WEAPON_SNIPERRIFLE")] = { 
        icon = "🎯", 
        sound = "client/ui/sounds/sniper_shot.ogg",
        type = "sniper",
        highlight = "headshot"
    },
    [GetHashKey("WEAPON_ASSAULTRIFLE")] = { 
        icon = "🔫", 
        sound = "client/ui/sounds/rifle_shot.ogg",
        type = "rifle"
    },
    [GetHashKey("WEAPON_PUMPSHOTGUN")] = { 
        icon = "🔫", 
        sound = "client/ui/sounds/shotgun_shot.ogg",
        type = "shotgun"
    },
    [GetHashKey("WEAPON_MICROSMG")] = { 
        icon = "🔫", 
        sound = "client/ui/sounds/smg_shot.ogg",
        type = "smg"
    },
    [GetHashKey("DEFAULT")] = { 
        icon = "💀", 
        sound = "client/ui/sounds/default.ogg",
        type = "default"
    }
}

Config.Highlights = {
    headshot = { 
        color = "#ff0000", 
        icon = "🎯", 
        text = "HEADSHOT", 
        sound = "client/ui/sounds/headshot.ogg" 
    },
    knife_kill = { 
        color = "#00ff00", 
        icon = "🔪", 
        text = "KNIFE KILL", 
        sound = "client/ui/sounds/knife_kill.ogg" 
    },
    double_kill = { 
        color = "#ffff00", 
        icon = "⚡", 
        text = "DOUBLE KILL", 
        sound = "client/ui/sounds/double_kill.ogg" 
    },
    suicide = { 
        color = "#666666", 
        icon = "💀", 
        text = "SUICIDE", 
        sound = "client/ui/sounds/suicide.ogg" 
    }
}

Config.Language = {
    ['en'] = { 
        killed = "killed", 
        headshot = "Headshot", 
        suicide = "Suicide" 
    },
    ['ar'] = { 
        killed = "قتل", 
        headshot = "رأسية", 
        suicide = "انتحار" 
    }
}

function GetWeaponData(weaponHash)
    for weaponKey, weaponData in pairs(Config.WeaponData) do
        if weaponKey == weaponHash then
            return weaponData
        end
    end
    return Config.WeaponData[GetHashKey("DEFAULT")]
end

function GetHighlightData(highlightType)
    return Config.Highlights[highlightType]
end

-- اللغة الحالية
currentLanguage = 'ar'
