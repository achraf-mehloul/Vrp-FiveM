Config = {}

-- HUD Configuration
Config.HUD = {
    UpdateInterval = 1000, -- Update interval in milliseconds
    DefaultVisibility = true, -- Whether HUD is visible by default
    LowThreshold = 20, -- Low value threshold for warnings
    Position = {x = 20, y = 20} -- Default HUD position
}

-- Status Configuration
Config.Status = {
    Health = {
        max = 100,
        warning = 20
    },
    Armor = {
        max = 100,
        warning = 10
    },
    Hunger = {
        max = 100,
        warning = 15,
        decreaseRate = 0.05 -- Per minute
    },
    Thirst = {
        max = 100,
        warning = 15,
        decreaseRate = 0.08 -- Per minute
    }
}

-- Framework Settings
Config.Framework = 'esx' -- 'esx' or 'qb-core'

-- Notification Settings
Config.Notifications = {
    Duration = 3000,
    Position = 'top-right'
}

-- Compatibility Settings
Config.Compatibility = {
    VRP = false,
    CWRP = false
}
