Config = {}

-- إعدادات التصحيح
Config.Debug = true
Config.LogLevel = 'info'

-- إعدادات النظام
Config.UseESX = true
Config.Framework = 'esx'
Config.Currency = '$'
Config.Language = 'ar'

-- أنواع المتاجر
Config.ShopTypes = {
    ['weapon'] = { 
        name = "متجر الأسلحة", 
        blip = 110, 
        color = 1, 
        scale = 0.8, 
        icon = "🔫"
    },
    ['vehicle'] = { 
        name = "معرض السيارات", 
        blip = 225, 
        color = 3, 
        scale = 0.9, 
        icon = "🚗"
    },
    ['food'] = { 
        name = "سوبر ماركت", 
        blip = 52, 
        color = 2, 
        scale = 0.7, 
        icon = "🍔"
    },
    ['clothing'] = { 
        name = "متجر الملابس", 
        blip = 73, 
        color = 4, 
        scale = 0.7, 
        icon = "👕"
    },
    ['pharmacy'] = { 
        name = "صيدلية", 
        blip = 51, 
        color = 2, 
        scale = 0.6, 
        icon = "💊"
    },
    ['electronics'] = { 
        name = "متجر الإلكترونيات", 
        blip = 606, 
        color = 5, 
        scale = 0.7, 
        icon = "📱"
    },
    ['barber'] = { 
        name = "صالون حلاقة", 
        blip = 71, 
        color = 6, 
        scale = 0.6, 
        icon = "✂️"
    },
    ['jewelry'] = { 
        name = "متجر المجوهرات", 
        blip = 617, 
        color = 7, 
        scale = 0.7, 
        icon = "💎"
    }
}

-- المتاجر الرئيسية
Config.Shops = {
    -- متجر الأسلحة 1
    {
        id = 1,
        name = "متجر الأسلحة المتقدم",
        type = "weapon",
        location = vector3(16.61, -1120.68, 28.8),
        blip = true,
        marker = {
            type = 27,
            scale = {x = 1.5, y = 1.5, z = 1.0},
            color = {r = 255, g = 0, b = 0, a = 100},
            rotate = true
        },
        hours = {
            open = 9,
            close = 21
        },
        items = {
            {name = "WEAPON_PISTOL", label = "مسدس عادي", price = 5000, stock = 15, weight = 1.0, category = "مسدسات", image = "weapons/pistol.png"},
            {name = "WEAPON_COMBATPISTOL", label = "مسدس قتالي", price = 7500, stock = 10, weight = 1.1, category = "مسدسات", image = "weapons/combatpistol.png"},
            {name = "WEAPON_APPISTOL", label = "مسدس AP", price = 12000, stock = 8, weight = 1.2, category = "مسدسات", image = "weapons/appistol.png"},
            {name = "WEAPON_REVOLVER", label = "مسدس دوار", price = 8500, stock = 7, weight = 1.3, category = "مسدسات", image = "weapons/revolver.png"},
            {name = "WEAPON_SNSPISTOL", label = "مسدس SNS", price = 6000, stock = 12, weight = 0.9, category = "مسدسات", image = "weapons/snspistol.png"},
            {name = "WEAPON_KNIFE", label = "سكين حاد", price = 1000, stock = 25, weight = 0.5, category = "أسلحة بيضاء", image = "weapons/knife.png"},
            {name = "WEAPON_BAT", label = "مضرب بيسبول", price = 800, stock = 20, weight = 1.2, category = "أسلحة بيضاء", image = "weapons/bat.png"},
            {name = "WEAPON_MICROSMG", label = "ميكرو SMG", price = 25000, stock = 5, weight = 3.5, category = "رشاشات", image = "weapons/microsmg.png"},
            {name = "WEAPON_ASSAULTRIFLE", label = "بندقية هجومية", price = 45000, stock = 3, weight = 4.2, category = "بنادق", image = "weapons/assaultrifle.png"},
            {name = "WEAPON_PUMPSHOTGUN", label = "بندقية صيد", price = 18000, stock = 6, weight = 3.8, category = "بنادق", image = "weapons/pumpshotgun.png"},
            {name = "WEAPON_ASSAULTSMG", label = "بندقية رشاشة", price = 5500, stock = 8, weight = 3.0, category = "رشاشات", image = "weapons/assaultsmg.png"},
            {name = "WEAPON_CARBINERIFLE", label = "بندقية كاربين", price = 65000, stock = 4, weight = 4.0, category = "بنادق", image = "weapons/carbinerifle.png"},
            {name = "WEAPON_SPECIALCARBINE", label = "بندقية خاصة", price = 75000, stock = 3, weight = 4.1, category = "بنادق", image = "weapons/specialcarbine.png"},
            {name = "WEAPON_BULLPUPRIFLE", label = "بندقية بولتاب", price = 85000, stock = 3, weight = 4.3, category = "بنادق", image = "weapons/bullpuprifle.png"},
            {name = "WEAPON_SNIPERRIFLE", label = "بندقية قنص", price = 120000, stock = 2, weight = 5.0, category = "بنادق", image = "weapons/sniperrifle.png"},
            {name = "ammo_pistol", label = "ذخيرة مسدس", price = 50, stock = 100, weight = 0.1, category = "ذخيرة", image = "weapons/ammo_pistol.png"},
            {name = "ammo_rifle", label = "ذخيرة بندقية", price = 100, stock = 80, weight = 0.2, category = "ذخيرة", image = "weapons/ammo_rifle.png"},
            {name = "ammo_shotgun", label = "ذخيرة بندقية صيد", price = 150, stock = 60, weight = 0.3, category = "ذخيرة", image = "weapons/ammo_shotgun.png"},
            {name = "ammo_smg", label = "ذخيرة SMG", price = 80, stock = 90, weight = 0.2, category = "ذخيرة", image = "weapons/ammo_smg.png"}
        }
    },

    -- معرض السيارات 2
    {
        id = 2,
        name = "معرض السيارات الفاخرة",
        type = "vehicle",
        location = vector3(-33.83, -1102.29, 25.42),
        blip = true,
        marker = {
            type = 36,
            scale = {x = 2.0, y = 2.0, z = 1.0},
            color = {r = 0, g = 255, b = 0, a = 100},
            rotate = true
        },
        hours = {
            open = 8,
            close = 20
        },
        items = {
            {name = "sultan", label = "Sultan", price = 150000, stock = 5, category = "رياضية", image = "vehicles/sultan.png"},
            {name = "adder", label = "Adder", price = 1000000, stock = 2, category = "فائقة", image = "vehicles/adder.png"},
            {name = "banshee", label = "Banshee", price = 105000, stock = 3, category = "رياضية", image = "vehicles/banshee.png"},
            {name = "bullet", label = "Bullet", price = 155000, stock = 4, category = "فائقة", image = "vehicles/bullet.png"},
            {name = "cheetah", label = "Cheetah", price = 950000, stock = 2, category = "فائقة", image = "vehicles/cheetah.png"},
            {name = "comet2", label = "Comet", price = 125000, stock = 6, category = "رياضية", image = "vehicles/comet2.png"},
            {name = "elegy2", label = "Elegy", price = 135000, stock = 5, category = "رياضية", image = "vehicles/elegy2.png"},
            {name = "feltzer2", label = "Feltzer", price = 145000, stock = 4, category = "رياضية", image = "vehicles/feltzer2.png"},
            {name = "jester", label = "Jester", price = 165000, stock = 4, category = "رياضية", image = "vehicles/jester.png"},
            {name = "massacro", label = "Massacro", price = 175000, stock = 3, category = "رياضية", image = "vehicles/massacro.png"},
            {name = "turismo2", label = "Turismo", price = 850000, stock = 2, category = "فائقة", image = "vehicles/turismo2.png"},
            {name = "zentorno", label = "Zentorno", price = 950000, stock = 2, category = "فائقة", image = "vehicles/zentorno.png"},
            {name = "nero", label = "Nero", price = 880000, stock = 3, category = "فائقة", image = "vehicles/nero.png"},
            {name = "vagner", label = "Vagner", price = 920000, stock = 2, category = "فائقة", image = "vehicles/vagner.png"},
            {name = "xa21", label = "XA-21", price = 970000, stock = 2, category = "فائقة", image = "vehicles/xa21.png"},
            {name = "cyclone", label = "Cyclone", price = 1100000, stock = 1, category = "فائقة", image = "vehicles/cyclone.png"},
            {name = "visione", label = "Visione", price = 1250000, stock = 1, category = "فائقة", image = "vehicles/visione.png"},
            {name = "sc1", label = "SC1", price = 980000, stock = 2, category = "فائقة", image = "vehicles/sc1.png"},
            {name = "autarch", label = "Autarch", price = 1050000, stock = 1, category = "فائقة", image = "vehicles/autarch.png"},
            {name = "tyrant", label = "Tyrant", price = 1150000, stock = 1, category = "فائقة", image = "vehicles/tyrant.png"}
        }
    },

    -- سوبر ماركت 3
    {
        id = 3,
        name = "سوبر ماركت المدينة",
        type = "food",
        location = vector3(374.34, 327.91, 102.56),
        blip = true,
        marker = {
            type = 29,
            scale = {x = 1.5, y = 1.5, z = 1.0},
            color = {r = 255, g = 255, b = 0, a = 100},
            rotate = true
        },
        hours = {
            open = 7,
            close = 23
        },
        items = {
            {name = "bread", label = "خبز طازج", price = 10, stock = 100, weight = 0.2, category = "مخبوزات", image = "foods/bread.png"},
            {name = "water", label = "ماء معدني", price = 5, stock = 200, weight = 0.5, category = "مشروبات", image = "foods/water.png"},
            {name = "burger", label = "برغر لذيذ", price = 25, stock = 50, weight = 0.3, category = "وجبات", image = "foods/burger.png"},
            {name = "sandwich", label = "ساندويتش", price = 15, stock = 70, weight = 0.25, category = "وجبات", image = "foods/sandwich.png"},
            {name = "chips", label = "رقائق بطاطس", price = 8, stock = 120, weight = 0.15, category = " snacks", image = "foods/chips.png"},
            {name = "chocolate", label = "شوكولاتة", price = 12, stock = 90, weight = 0.1, category = "حلويات", image = "foods/chocolate.png"},
            {name = "soda", label = "مشروب غازي", price = 7, stock = 150, weight = 0.4, category = "مشروبات", image = "foods/soda.png"},
            {name = "coffee", label = "قهوة ساخنة", price = 10, stock = 80, weight = 0.3, category = "مشروبات", image = "foods/coffee.png"},
            {name = "milk", label = "حليب طازج", price = 8, stock = 60, weight = 0.6, category = "مشتقات الحليب", image = "foods/milk.png"},
            {name = "apple", label = "تفاح طازج", price = 4, stock = 200, weight = 0.1, category = "فواكه", image = "foods/apple.png"},
            {name = "orange", label = "برتقال", price = 4, stock = 180, weight = 0.1, category = "فواكه", image = "foods/orange.png"},
            {name = "banana", label = "موز", price = 3, stock = 160, weight = 0.1, category = "فواكه", image = "foods/banana.png"},
            {name = "pizza", label = "بيتزا", price = 35, stock = 40, weight = 0.8, category = "وجبات", image = "foods/pizza.png"},
            {name = "donut", label = "دونات", price = 6, stock = 100, weight = 0.1, category = "حلويات", image = "foods/donut.png"},
            {name = "icecream", label = "آيس كريم", price = 15, stock = 60, weight = 0.3, category = "حلويات", image = "foods/icecream.png"},
            {name = "hotdog", label = "هوت دوغ", price = 20, stock = 80, weight = 0.3, category = "وجبات", image = "foods/hotdog.png"},
            {name = "taco", label = "تاكو", price = 18, stock = 70, weight = 0.3, category = "وجبات", image = "foods/taco.png"},
            {name = "sushi", label = "سوشي", price = 45, stock = 30, weight = 0.4, category = "وجبات", image = "foods/sushi.png"},
            {name = "steak", label = "ستيك", price = 60, stock = 25, weight = 0.7, category = "وجبات", image = "foods/steak.png"},
            {name = "salad", label = "سلطة", price = 15, stock = 50, weight = 0.3, category = "وجبات", image = "foods/salad.png"}
        }
    }
}

-- الرسائل والترجمة
Config.Locales = {
    ['buy_success'] = 'تم الشراء بنجاح!',
    ['buy_failed'] = 'فشل في الشراء!',
    ['not_enough_money'] = 'ليس لديك مال كافٍ!',
    ['no_stock'] = 'لا يوجد مخزون!',
    ['shop_not_found'] = 'المتجر غير موجود!',
    ['item_not_found'] = 'العنصر غير موجود!',
    ['invalid_quantity'] = 'الكمية غير صالحة!',
    ['player_not_found'] = 'اللاعب غير موجود!',
    ['system_error'] = 'خطأ في النظام!',
    ['shop_closed'] = 'المتجر مغلق حالياً!',
    ['no_permission'] = 'ليس لديك الصلاحية للوصول إلى هذا المتجر!',
    ['item_added'] = 'تم إضافة العنصر إلى سلة التسوق!',
    ['cart_cleared'] = 'تم تفريغ سلة التسوق!',
    ['purchase_complete'] = 'تم اكتمال عملية الشراء!',
    ['search_placeholder'] = 'ابحث عن عنصر...',
    ['sort_options'] = 'الفرز حسب:',
    ['price_low_high'] = 'السعر: من الأقل للأعلى',
    ['price_high_low'] = 'السعر: من الأعلى للأقل',
    ['name_az'] = 'الاسم: أ-ي',
    ['name_za'] = 'الاسم: ي-أ',
    ['stock'] = 'المخزون',
    ['category'] = 'الفئة'
}

-- إعدادات النظام
Config.Settings = {
    EnableBlips = true,
    EnableMarkers = true,
    EnableNotifications = true,
    EnableSounds = true,
    MaxPurchaseQuantity = 10,
    TransactionHistorySize = 20,
    AdminPermission = 'shops.admin',
    InteractionDistance = 3.0,
    OpenKey = 38,
    CloseKey = 202,
    CartMaxItems = 20,
    AutoRestock = true,
    RestockInterval = 3600,
    SaveTransactions = true,
    TaxRate = 0.05,
    Discounts = {
        {minAmount = 1000, discount = 0.05},
        {minAmount = 5000, discount = 0.10},
        {minAmount = 10000, discount = 0.15}
    }
}

-- إعدادات التصميم
Config.Design = {
    PrimaryColor = "rgba(76, 201, 240, 0.9)",
    SecondaryColor = "rgba(58, 134, 255, 0.8)",
    BackgroundColor = "rgba(13, 27, 42, 0.95)",
    TextColor = "#e0e1dd",
    AccentColor = "#ff9f1c",
    SuccessColor = "#4cc9f0",
    ErrorColor = "#ff4757",
    WarningColor = "#ffdd59",
    BorderRadius = "12px",
    BoxShadow = "0 10px 25px rgba(0, 0, 0, 0.5)",
    GlowEffect = "0 0 15px rgba(76, 201, 240, 0.7)",
    TransitionSpeed = "0.3s",
    FontFamily = "'Cairo', 'Segoe UI', 'Tahoma', sans-serif",
    FontSizes = {
        small = "12px",
        medium = "16px",
        large = "24px",
        xlarge = "32px"
    }
}

-- الأصوات
Config.Sounds = {
    PurchaseSuccess = {
        name = "Purchase_Success",
        sound = "success.ogg",
        volume = 0.7
    },
    PurchaseError = {
        name = "Purchase_Error",
        sound = "error.ogg",
        volume = 0.7
    },
    OpenMenu = {
        name = "Open_Menu",
        sound = "menu_open.ogg",
        volume = 0.5
    },
    CloseMenu = {
        name = "Close_Menu",
        sound = "menu_close.ogg",
        volume = 0.5
    }
}

-- إعدادات الأدمن
Config.AdminSettings = {
    CanAddItems = true,
    CanRemoveItems = true,
    CanEditPrices = true,
    CanEditStocks = true,
    CanViewTransactions = true,
    CanManageShops = true,
    LogActions = true
}

-- إعدادات قاعدة البيانات
Config.Database = {
    AutoCreateTables = true,
    BackupInterval = 86400,
    CleanOldTransactions = 30,
    MaxConnections = 10
}

-- إعدادات الأداء
Config.Performance = {
    MaxShopsLoad = 50,
    MaxItemsLoad = 1000,
    CacheTimeout = 300,
    PreloadImages = true,
    LazyLoading = true
}

print('^2[Shops] تم تحميل الإعدادات بنجاح^0')
