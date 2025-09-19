Config = {}

Config.Admin = {
    -- Admin groups and permissions
    Groups = {
        'superadmin',
        'admin', 
        'moderator',
        'helper'
    },

    Permissions = {
        kick = {'admin', 'superadmin', 'moderator'},
        ban = {'admin', 'superadmin'},
        teleport = {'admin', 'superadmin', 'moderator'},
        spectate = {'admin', 'superadmin'},
        revive = {'admin', 'superadmin', 'moderator'},
        spawn_vehicle = {'admin', 'superadmin'},
        spawn_item = {'admin', 'superadmin'},
        manage_player = {'admin', 'superadmin'},
        manage_server = {'superadmin'}
    },

    -- Command settings
    CommandPrefix = 'a', -- akick, aban, etc.
    DefaultBanDuration = 7, -- days

    -- UI settings
    MenuPosition = {x = 100, y = 100},
    MaxPlayersPerPage = 10,

    -- Logging
    LogActions = true,
    LogToConsole = true,
    LogToFile = true,

    -- Notification settings
    Notifications = {
        duration = 5000,
        position = 'top-right'
    }
}

Config.BanReasons = {
    "Cheating/Hacking",
    "Exploiting Bugs",
    "Toxic Behavior", 
    "Spamming",
    "Advertising",
    "Impersonation",
    "Other (Specify in notes)"
}

Config.KickReasons = {
    "Temporary Issue",
    "Behavior Warning", 
    "Server Rules Violation",
    "Connection Problems",
    "Other (Specify in notes)"
}

-- Admin menu themes
Config.Themes = {
    default = {
        primary = '#2c3e50',
        secondary = '#34495e',
        accent = '#3498db',
        success = '#27ae60',
        warning = '#f39c12',
        danger = '#e74c3c'
    },
    dark = {
        primary = '#1a1a1a',
        secondary = '#2d2d2d',
        accent = '#2980b9',
        success = '#219a52',
        warning = '#e67e22',
        danger = '#c0392b'
    },
    light = {
        primary = '#ffffff',
        secondary = '#f8f9fa',
        accent = '#3498db',
        success = '#27ae60',
        warning = '#f39c12',
        danger = '#e74c3c'
    }
}
