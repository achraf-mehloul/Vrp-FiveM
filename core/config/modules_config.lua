ModulesConfig = {
    -- إعدادات نظام الإدارة
    Admin = {
        Enabled = true,
        PermissionSystem = 'ace', -- ace, license, custom
        LogActions = true,
        Screenshots = true,
        BanSystem = true,
        WarnSystem = true,
        KickSystem = true,
        Teleport = true,
        Spectate = true,
        Freeze = true,
        GodMode = true,
        Invisible = true,
        NoClip = true
    },
    
    -- إعدادات النظام البنكي
    Bank = {
        Enabled = true,
        Banks = {
            {name = "البنك المركزي", coords = vector3(150.0, -1040.0, 29.0)},
            {name = "بنك البلاد", coords = vector3(-1212.0, -330.0, 37.0)}
        },
        ATMs = true,
        Transactions = true,
        Loans = true,
        InterestRate = 0.02,
        TransferFee = 0.01,
        MaxWithdrawal = 10000,
        MaxDeposit = 50000
    },
    
    -- إعدادات المتاجر
    Shops = {
        Enabled = true,
        Types = {
            'weapon', 'vehicle', 'food', 'clothing', 
            'pharmacy', 'electronics', 'barber', 'jewelry'
        },
        Blips = true,
        Markers = true,
        Restock = true,
        Economy = true,
        BlackMarket = false,
        IllegalItems = false
    },
    
    -- إعدادات واجهة اللاعب
    HUD = {
        Enabled = true,
        Elements = {
            'health', 'armor', 'hunger', 'thirst', 
            'stress', 'voice', 'minimap', 'speedometer'
        },
        Customizable = true,
        Themes = {'default', 'dark', 'light', 'blue', 'green'},
        Animations = true
    },
    
    -- إعدادات الهاتف
    Phone = {
        Enabled = true,
        Apps = {
            'contacts', 'messages', 'calls', 'camera',
            'gallery', 'bank', 'twitter', 'weather',
            'settings', 'calculator', 'notes'
        },
        Wallpapers = true,
        Ringtones = true,
        Notifications = true
    },
    
    -- إعدادات الإيماءات
    Emotes = {
        Enabled = true,
        CustomEmotes = true,
        SharedEmotes = true,
        FavoriteEmotes = true,
        WalkStyles = true,
        FacialExpressions = true
    },
    
    -- إعدادات الأسلحة
    Weapons = {
        Enabled = true,
        DamageSystem = true,
        Recoil = true,
        Spread = true,
        AttachmentSystem = true,
        Customization = true,
        AmmoTypes = true,
        Durability = true
    },
    
    -- إعدادات الملابس
    Clothes = {
        Enabled = true,
        Outfits = true,
        Customization = true,
        Wardrobe = true,
        Accessories = true,
        Tattoos = true
    },
    
    -- إعدادات الحلاقة
    Barber = {
        Enabled = true,
        HairStyles = true,
        BeardStyles = true,
        Makeup = true,
        PlasticSurgery = false
    },
    
    -- إعدادات المناطق
    Zones = {
        Enabled = true,
        Types = {
            'safe', 'danger', 'restricted', 'no-pvp',
            'no-vehicle', 'no-weapon', 'speed-limit'
        },
        Notifications = true,
        AutoDetect = true
    },
    
    -- إعدادات البليبس
    Blips = {
        Enabled = true,
        Categories = {
            'shops', 'services', 'jobs', 'housing',
            'government', 'entertainment', 'illegal'
        },
        CustomBlips = true,
        DynamicBlips = true
    }
}

-- إعدادات التكامل
IntegrationConfig = {
    -- تكامل مع ESX
    ESX = {
        UseESX = true,
        Version = '1.2',
        Inventory = 'esx_inventoryhud',
        Skin = 'esx_skin',
        Status = 'esx_status',
        License = 'esx_license'
    },
    
    -- تكامل مع QBCore
    QBCore = {
        UseQBCore = false,
        Version = 'latest',
        Inventory = 'qb-inventory',
        Skin = 'qb-clothing',
        Phone = 'qb-phone'
    },
    
    -- تكامل مع oxmysql
    MySQL = {
        UseOxMySQL = true,
        ConnectionString = 'mysql://user:pass@localhost/db'
    },
    
    -- تكامل مع其他 المودات
    Other = {
        Voice = 'pma-voice',
        Radio = 'pma-voice',
        Map = 'qb-map',
        Notifications = 'qb-notify'
    }
}

print('^2[Core] تم تحميل إعدادات المودات بنجاح^0')
