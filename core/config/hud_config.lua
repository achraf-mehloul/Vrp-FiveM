HUDConfig = {
    -- إعدادات عامة
    General = {
        Enabled = true,
        Language = 'ar',
        Theme = 'dark',
        Animations = true,
        Transitions = true,
        Notifications = true,
        Sounds = true
    },
    
    -- إعدادات العناصر
    Elements = {
        Health = {
            Enabled = true,
            Position = {x = 0.015, y = 0.95},
            Color = '#FF0000',
            Icon = '❤️',
            ShowText = true,
            ShowPercent = true
        },
        
        Armor = {
            Enabled = true,
            Position = {x = 0.015, y = 0.92},
            Color = '#0066FF',
            Icon = '🛡️',
            ShowText = true,
            ShowPercent = true
        },
        
        Hunger = {
            Enabled = true,
            Position = {x = 0.015, y = 0.89},
            Color = '#FF9900',
            Icon = '🍔',
            ShowText = true,
            ShowPercent = true
        },
        
        Thirst = {
            Enabled = true,
            Position = {x = 0.015, y = 0.86},
            Color = '#00CCFF',
            Icon = '💧',
            ShowText = true,
            ShowPercent = true
        },
        
        Stress = {
            Enabled = true,
            Position = {x = 0.015, y = 0.83},
            Color = '#FF00FF',
            Icon = '😰',
            ShowText = true,
            ShowPercent = true
        },
        
        Voice = {
            Enabled = true,
            Position = {x = 0.015, y = 0.80},
            Color = '#00FF00',
            Icon = '🎤',
            ShowText = true,
            ShowLevel = true
        },
        
        Money = {
            Enabled = true,
            Position = {x = 0.95, y = 0.95},
            Color = '#00FF00',
            Icon = '💵',
            ShowText = true,
            ShowBank = true
        },
        
        Bank = {
            Enabled = true,
            Position = {x = 0.95, y = 0.92},
            Color = '#0066FF',
            Icon = '🏦',
            ShowText = true
        },
        
        Job = {
            Enabled = true,
            Position = {x = 0.95, y = 0.89},
            Color = '#FFFFFF',
            Icon = '💼',
            ShowText = true,
            ShowGrade = true
        },
        
        Time = {
            Enabled = true,
            Position = {x = 0.95, y = 0.86},
            Color = '#FFFFFF',
            Icon = '🕒',
            ShowText = true,
            ShowDate = true
        }
    },
    
    -- إعدادات الميني ماب
    Minimap = {
        Enabled = true,
        Position = {x = 0.93, y = 0.12},
        Width = 0.14,
        Height = 0.18,
        ShowCompass = true,
        ShowStreetNames = true,
        ShowPlayers = true,
        ShowVehicles = true
    },
    
    -- إعدادات سبيدوميتر
    Speedometer = {
        Enabled = true,
        Position = {x = 0.5, y = 0.93},
        Color = '#FFFFFF',
        ShowSpeed = true,
        ShowFuel = true,
        ShowGear = true,
        ShowRPM = true,
        ShowEngine = true,
        ShowLock = true
    },
    
    -- إعدادات الإشعارات
    Notifications = {
        Position = {x = 0.5, y = 0.25},
        MaxNotifications = 5,
        Duration = 5000,
        Animation = 'slide',
        Sound = true,
        Types = {
            success = {color = '#00FF00', icon = '✅'},
            error = {color = '#FF0000', icon = '❌'},
            warning = {color = '#FF9900', icon = '⚠️'},
            info = {color = '#0066FF', icon = 'ℹ️'}
        }
    },
    
    -- إعدادات القوائم
    Menus = {
        MainMenu = {
            Position = {x = 0.5, y = 0.5},
            Width = 0.3,
            Height = 0.6,
            Background = 'rgba(0, 0, 0, 0.8)',
            BorderRadius = 10
        },
        
        Inventory = {
            Position = {x = 0.5, y = 0.5},
            Width = 0.4,
            Height = 0.7,
            Slots = 40,
            Weight = true
        }
    },
    
    -- إعدادات الصوت
    Sounds = {
        Click = 'sounds/click.ogg',
        Notify = 'sounds/notification.ogg',
        Open = 'sounds/open.ogg',
        Close = 'sounds/close.ogg',
        Success = 'sounds/success.ogg',
        Error = 'sounds/error.ogg'
    },
    
    -- إعدادات الأداء
    Performance = {
        UpdateInterval = 100,
        FPSLimit = 60,
        MemoryOptimization = true,
        CacheEnabled = true
    }
}

print('^2[HUD] تم تحميل إعدادات الواجهة بنجاح^0')
