ClientConfig = {
    -- إعدادات الواجهة
    UI = {
        Language = 'ar',
        Theme = 'dark',
        Animations = true,
        Transitions = true,
        Notifications = true,
        Sounds = true,
        Cursor = true,
        Tooltips = true,
        LoadingScreen = true,
        SplashScreen = true
    },
    
    -- إعدادات HUD
    HUD = {
        Enabled = true,
        Position = 'top-right',
        ShowHealth = true,
        ShowArmor = true,
        ShowHunger = true,
        ShowThirst = true,
        ShowStress = true,
        ShowVoice = true,
        ShowMinimap = true,
        ShowCrosshair = false,
        ShowSpeedometer = true,
        ShowFuel = true,
        ShowTime = true,
        ShowDate = true
    },
    
    -- إعدادات الرسومات
    Graphics = {
        Quality = 'high',
        Resolution = '1920x1080',
        VSync = true,
        AntiAliasing = true,
        Shadows = true,
        Reflections = true,
        TextureQuality = 'high',
        WaterQuality = 'high',
        ParticleQuality = 'high',
        AnisotropicFiltering = 16,
        PostFX = true,
        MotionBlur = false,
        DepthOfField = false
    },
    
    -- إعدادات التحكم
    Controls = {
        Sensitivity = 0.5,
        InvertMouse = false,
        MouseAcceleration = false,
        ControllerEnabled = true,
        Keybindings = {
            openMenu = 'F1',
            openInventory = 'TAB',
            openPhone = 'M',
            openMap = 'F2',
            voiceChat = 'L',
            radio = 'CAPSLOCK'
        }
    },
    
    -- إعدادات الصوت
    Audio = {
        MasterVolume = 0.8,
        MusicVolume = 0.5,
        EffectsVolume = 0.7,
        VoiceVolume = 0.8,
        RadioVolume = 0.6,
        AmbientVolume = 0.4,
        UIVolume = 0.5,
        MuteWhenMinimized = true
    },
    
    -- إعدادات الأداء
    Performance = {
        StreamingRange = 300.0,
        PedDensity = 0.5,
        VehicleDensity = 0.5,
        ObjectDensity = 0.7,
        TextureBudget = 45.0,
        FPSLimit = 60,
        MemoryAllocation = 1024,
        CacheEnabled = true
    },
    
    -- إعدادات التواصل
    Communication = {
        VoiceChat = true,
        VoiceRange = 5.0,
        RadioEnabled = true,
        RadioRange = 3.0,
        PhoneEnabled = true,
        ChatEnabled = true,
        Notifications = true
    },
    
    -- إعدادات المساعدة
    Accessibility = {
        Subtitles = false,
        ColorBlindMode = 'none',
        FontSize = 'normal',
        Contrast = 'normal',
        ScreenShake = true,
        MotionSickness = false,
        AutoAim = false,
        AutoDrive = false
    }
}

-- إعدادات التخصيص
Customization = {
    Crosshair = {
        Enabled = false,
        Style = 'default',
        Color = '#FFFFFF',
        Size = 20,
        Thickness = 2
    },
    
    Minimap = {
        Enabled = true,
        Position = 'bottom-right',
        Size = 'normal',
        ShowStreetNames = true,
        ShowPlayers = true
    },
    
    Notifications = {
        Position = 'top-right',
        Duration = 5000,
        Animation = 'slide',
        Sound = true
    }
}

print('^2[Core] تم تحميل إعدادات الكلينت بنجاح^0')
