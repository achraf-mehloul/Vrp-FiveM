CoreConfig = {
    Debug = true,
    LogLevel = 'info',
    
    -- إعدادات قاعدة البيانات
    Database = {
        Host = 'localhost',
        User = 'fivem_user',
        Password = 'secure_password_123',
        Database = 'fivem_main',
        Port = 3306,
        AutoCreateTables = true,
        BackupInterval = 3600,
        MaxConnections = 20,
        ConnectionTimeout = 10000,
        AcquireTimeout = 10000,
        Reconnect = true,
        Debug = false
    },
    
    -- إعدادات الأمان
    Security = {
        AntiCheat = true,
        AntiExploit = true,
        RateLimiting = true,
        MaxConnectionsPerIP = 5,
        BlacklistEnabled = true,
        WhitelistEnabled = false,
        VPNBlocking = true,
        GeoIPRestrictions = false,
        AllowedCountries = {'SA', 'KW', 'AE', 'QA', 'BH', 'OM', 'IQ', 'JO', 'EG'},
        AutoBlacklistAttempts = 5,
        BlacklistDuration = 24 -- ساعات
    },
    
    -- إعدادات الأداء
    Performance = {
        MaxPlayers = 128,
        TickRate = 30,
        StreamingBudget = 45.0,
        MemoryAllocation = 2048,
        CacheEnabled = true,
        CacheTimeout = 300,
        PreloadResources = true,
        LazyLoading = true,
        GarbageCollection = true,
        GCInterval = 60
    },
    
    -- إعدادات الاقتصاد
    Economy = {
        StartingMoney = 5000,
        StartingBank = 10000,
        MaxCash = 1000000,
        MaxBank = 10000000,
        TaxRate = 0.05,
        CurrencySymbol = '$',
        CurrencyName = 'دولار',
        EnableInflation = false,
        InflationRate = 0.01,
        SalaryInterval = 3600, -- ثانية
        DefaultSalary = 500
    },
    
    -- إعدادات اللاعب
    Player = {
        MaxWeight = 50.0,
        StartingLevel = 1,
        MaxLevel = 100,
        LevelMultiplier = 1.5,
        EnableStamina = true,
        EnableStress = true,
        EnableHungerThirst = true,
        RespawnTime = 5,
        HospitalRespawn = true,
        BleedoutTime = 300,
        EnableVoiceChat = true,
        VoiceRange = 5.0
    },
    
    -- إعدادات الخريطة
    World = {
        TimeSync = true,
        WeatherSync = true,
        DynamicWeather = true,
        TimeSpeed = 0.4,
        WeatherChangeTime = 30,
        BlackoutEnabled = false,
        TrafficDensity = 0.5,
        PedDensity = 0.5,
        ParkedVehicles = true,
        RandomEvents = true,
        EnableTimeCycle = true
    },
    
    -- إعدادات المركبات
    Vehicles = {
        FuelSystem = true,
        FuelConsumption = 0.5,
        EngineDamage = true,
        VehicleTracking = true,
        MaxVehiclesPerPlayer = 3,
        VehicleDespawn = true,
        DespawnTime = 300,
        EnableCarWash = true,
        EnableVehicleLock = true,
        EnableKeysSystem = true
    },
    
    -- إعدادات النظام
    System = {
        AutoRestart = true,
        RestartTime = 6, -- ساعات
        BackupEnabled = true,
        BackupInterval = 24, -- ساعات
        LogRetention = 30, -- أيام
        MetricsEnabled = true,
        UpdateCheck = true,
        MaintenanceMode = false,
        WhitelistMode = false
    },
    
    -- إعدادات التواصل
    Communication = {
        ChatEnabled = true,
        VoiceEnabled = true,
        RadioEnabled = true,
        PhoneEnabled = true,
        EmailEnabled = true,
        TwitterEnabled = true,
        AdvertisementEnabled = true,
        EmergencyCalls = true
    },
    
    -- إعدادات المودات
    Modules = {
        AutoLoad = true,
        LoadOrder = {
            'admin', 'bank', 'shops', 'hud', 'phone', 
            'emotes', 'weapons', 'clothes', 'barber',
            'zones', 'blips', 'pausemenu', 'chat'
        },
        DependencyCheck = true,
        VersionCheck = true,
        AutoUpdate = false
    }
}

-- إعدادات الخادم
ServerSettings = {
    ServerName = "🇸🇦 | Middle East Roleplay | 🇰🇼",
    MaxClients = 128,
    LicenseKey = "YOUR_LICENSE_KEY",
    Tags = {'roleplay', 'arabic', 'realism', 'economy'},
    Locale = 'ar',
    Crosshair = false,
    OneSync = true,
    EnablePVP = true,
    StreamRange = 400.0
}

-- إعدادات التوافق
Compatibility = {
    Framework = 'esx', -- esx, qbcore, standalone
    ESXVersion = '1.2',
    QBVersion = 'latest',
    MySQL = 'oxmysql',
    Async = true,
    Inventory = 'esx_inventoryhud',
    Skin = 'esx_skin'
}

-- إعدادات التطوير
Development = {
    DebugMode = true,
    Testing = false,
    Profiling = false,
    Benchmarking = false,
    HotReload = true,
    DevTools = true
}

print('^2[Core] تم تحميل إعدادات السيرفر بنجاح^0')
