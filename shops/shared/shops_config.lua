ShopsConfig = {
    Debug = true,
    
    -- أنواع المتاجر
    ShopTypes = {
        weapon = { name = "متجر الأسلحة", blip = 110, color = 1, scale = 0.8 },
        vehicle = { name = "معرض السيارات", blip = 225, color = 3, scale = 0.9 },
        food = { name = "سوبر ماركت", blip = 52, color = 2, scale = 0.7 },
        clothing = { name = "متجر الملابس", blip = 73, color = 4, scale = 0.7 },
        pharmacy = { name = "صيدلية", blip = 51, color = 2, scale = 0.6 },
        electronics = { name = "متجر الإلكترونيات", blip = 606, color = 5, scale = 0.7 },
        barber = { name = "صالون حلاقة", blip = 71, color = 6, scale = 0.6 },
        jewelry = { name = "متجر المجوهرات", blip = 617, color = 7, scale = 0.7 }
    },

    -- المتاجر
    Shops = {
        -- متجر الأسلحة
        {
            id = 1,
            name = "متجر الأسلحة المتقدم",
            type = "weapon",
            location = vector3(16.61, -1120.68, 28.8),
            blip = true,
            items = {
                {name = "WEAPON_PISTOL", label = "مسدس عادي", price = 5000, stock = 15, weight = 1.0},
                {name = "WEAPON_COMBATPISTOL", label = "مسدس قتالي", price = 7500, stock = 10, weight = 1.1},
                {name = "WEAPON_APPISTOL", label = "مسدس AP", price = 12000, stock = 8, weight = 1.2},
                {name = "WEAPON_REVOLVER", label = "مسدس دوار", price = 8500, stock = 7, weight = 1.3},
                {name = "WEAPON_SNSPISTOL", label = "مسدس SNS", price = 6000, stock = 12, weight = 0.9},
                {name = "WEAPON_KNIFE", label = "سكين حاد", price = 1000, stock = 25, weight = 0.5},
                {name = "WEAPON_BAT", label = "مضرب بيسبول", price = 800, stock = 20, weight = 1.2},
                {name = "WEAPON_MICROSMG", label = "ميكرو SMG", price = 25000, stock = 5, weight = 3.5},
                {name = "WEAPON_ASSAULTRIFLE", label = "بندقية هجومية", price = 45000, stock = 3, weight = 4.2},
                {name = "WEAPON_PUMPSHOTGUN", label = "بندقية صيد", price = 18000, stock = 6, weight = 3.8},
                {name = "WEAPON_ASSAULTSMG", label = "بندقية رشاشة", price = 5500, stock = 8, weight = 3.0},
                {name = "WEAPON_CARBINERIFLE", label = "بندقية كاربين", price = 65000, stock = 4, weight = 4.0},
                {name = "WEAPON_SPECIALCARBINE", label = "بندقية خاصة", price = 75000, stock = 3, weight = 4.1},
                {name = "WEAPON_BULLPUPRIFLE", label = "بندقية بولتاب", price = 85000, stock = 3, weight = 4.3},
                {name = "WEAPON_SNIPERRIFLE", label = "بندقية قنص", price = 120000, stock = 2, weight = 5.0},
                {name = "ammo_pistol", label = "ذخيرة مسدس", price = 50, stock = 100, weight = 0.1},
                {name = "ammo_rifle", label = "ذخيرة بندقية", price = 100, stock = 80, weight = 0.2},
                {name = "ammo_shotgun", label = "ذخيرة بندقية صيد", price = 150, stock = 60, weight = 0.3},
                {name = "ammo_smg", label = "ذخيرة SMG", price = 80, stock = 90, weight = 0.2}
            }
        },

        -- معرض السيارات
        {
            id = 2,
            name = "معرض السيارات الفاخرة",
            type = "vehicle",
            location = vector3(-33.83, -1102.29, 25.42),
            blip = true,
            items = {
                {name = "sultan", label = "Sultan", price = 150000, stock = 5, category = "رياضية"},
                {name = "adder", label = "Adder", price = 1000000, stock = 2, category = "فائقة"},
                {name = "banshee", label = "Banshee", price = 105000, stock = 3, category = "رياضية"},
                {name = "bullet", label = "Bullet", price = 155000, stock = 4, category = "فائقة"},
                {name = "cheetah", label = "Cheetah", price = 950000, stock = 2, category = "فائقة"},
                {name = "comet2", label = "Comet", price = 125000, stock = 6, category = "رياضية"},
                {name = "elegy2", label = "Elegy", price = 135000, stock = 5, category = "رياضية"},
                {name = "feltzer2", label = "Feltzer", price = 145000, stock = 4, category = "رياضية"},
                {name = "jester", label = "Jester", price = 165000, stock = 4, category = "رياضية"},
                {name = "massacro", label = "Massacro", price = 175000, stock = 3, category = "رياضية"},
                {name = "turismo2", label = "Turismo", price = 850000, stock = 2, category = "فائقة"},
                {name = "zentorno", label = "Zentorno", price = 950000, stock = 2, category = "فائقة"},
                {name = "nero", label = "Nero", price = 880000, stock = 3, category = "فائقة"},
                {name = "vagner", label = "Vagner", price = 920000, stock = 2, category = "فائقة"},
                {name = "xa21", label = "XA-21", price = 970000, stock = 2, category = "فائقة"},
                {name = "cyclone", label = "Cyclone", price = 1100000, stock = 1, category = "فائقة"},
                {name = "visione", label = "Visione", price = 1250000, stock = 1, category = "فائقة"},
                {name = "sc1", label = "SC1", price = 980000, stock = 2, category = "فائقة"},
                {name = "autarch", label = "Autarch", price = 1050000, stock = 1, category = "فائقة"},
                {name = "tyrant", label = "Tyrant", price = 1150000, stock = 1, category = "فائقة"}
            }
        },

        -- سوبر ماركت
        {
            id = 3,
            name = "سوبر ماركت المدينة",
            type = "food",
            location = vector3(374.34, 327.91, 102.56),
            blip = true,
            items = {
                {name = "bread", label = "خبز طازج", price = 10, stock = 100, weight = 0.2, category = "مخبوزات"},
                {name = "water", label = "ماء معدني", price = 5, stock = 200, weight = 0.5, category = "مشروبات"},
                {name = "burger", label = "برغر لذيذ", price = 25, stock = 50, weight = 0.3, category = "وجبات"},
                {name = "sandwich", label = "ساندويتش", price = 15, stock = 70, weight = 0.25, category = "وجبات"},
                {name = "chips", label = "رقائق بطاطس", price = 8, stock = 120, weight = 0.15, category = " snacks"},
                {name = "chocolate", label = "شوكولاتة", price = 12, stock = 90, weight = 0.1, category = "حلويات"},
                {name = "soda", label = "مشروب غازي", price = 7, stock = 150, weight = 0.4, category = "مشروبات"},
                {name = "coffee", label = "قهوة ساخنة", price = 10, stock = 80, weight = 0.3, category = "مشروبات"},
                {name = "milk", label = "حليب طازج", price = 8, stock = 60, weight = 0.6, category = "مشتقات الحليب"},
                {name = "apple", label = "تفاح طازج", price = 4, stock = 200, weight = 0.1, category = "فواكه"},
                {name = "orange", label = "برتقال", price = 4, stock = 180, weight = 0.1, category = "فواكه"},
                {name = "banana", label = "موز", price = 3, stock = 160, weight = 0.1, category = "فواكه"},
                {name = "pizza", label = "بيتزا", price = 35, stock = 40, weight = 0.8, category = "وجبات"},
                {name = "donut", label = "دونات", price = 6, stock = 100, weight = 0.1, category = "حلويات"},
                {name = "icecream", label = "آيس كريم", price = 15, stock = 60, weight = 0.3, category = "حلويات"},
                {name = "hotdog", label = "هوت دوغ", price = 20, stock = 80, weight = 0.3, category = "وجبات"},
                {name = "taco", label = "تاكو", price = 18, stock = 70, weight = 0.3, category = "وجبات"},
                {name = "sushi", label = "سوشي", price = 45, stock = 30, weight = 0.4, category = "وجبات"},
                {name = "steak", label = "ستيك", price = 60, stock = 25, weight = 0.7, category = "وجبات"},
                {name = "salad", label = "سلطة", price = 15, stock = 50, weight = 0.3, category = "وجبات"}
            }
        },

        -- متجر الملابس
        {
            id = 4,
            name = "بوتيك الأزياء الراقية",
            type = "clothing",
            location = vector3(72.3, -1399.1, 28.4),
            blip = true,
            items = {
                {name = "tshirt", label = "تيشيرت قطني", price = 50, stock = 100, weight = 0.3, category = "ملابس علوية"},
                {name = "jeans", label = "جينز", price = 80, stock = 80, weight = 0.5, category = "ملابس سفلية"},
                {name = "shoes", label = "حذاء رياضي", price = 120, stock = 60, weight = 0.7, category = "أحذية"},
                {name = "jacket", label = "جاكت جلد", price = 200, stock = 40, weight = 0.9, category = "ملابس علوية"},
                {name = "hat", label = "قبعة", price = 30, stock = 70, weight = 0.2, category = "إكسسوارات"},
                {name = "glasses", label = "نظارات شمسية", price = 75, stock = 50, weight = 0.1, category = "إكسسوارات"},
                {name = "watch", label = "ساعة يد", price = 150, stock = 30, weight = 0.1, category = "إكسسوارات"},
                {name = "dress", label = "فستان", price = 250, stock = 25, weight = 0.6, category = "ملابس نسائية"},
                {name = "suit", label = "بدلة رسمية", price = 500, stock = 20, weight = 1.2, category = "ملابس رسمية"},
                {name = "boots", label = "أحذية طويلة", price = 180, stock = 35, weight = 0.8, category = "أحذية"},
                {name = "gloves", label = "قفازات", price = 40, stock = 45, weight = 0.1, category = "إكسسوارات"},
                {name = "scarf", label = "وشاح", price = 35, stock = 55, weight = 0.1, category = "إكسسوارات"},
                {name = "belt", label = "حزام", price = 25, stock = 65, weight = 0.2, category = "إكسسوارات"},
                {name = "bag", label = "حقيبة", price = 120, stock = 40, weight = 0.5, category = "إكسسوارات"},
                {name = "ring", label = "خاتم", price = 80, stock = 50, weight = 0.05, category = "إكسسوارات"}
            }
        },

        -- صيدلية
        {
            id = 5,
            name = "صيدلية العائلة",
            type = "pharmacy",
            location = vector3(318.5, -1078.6, 28.4),
            blip = true,
            items = {
                {name = "bandage", label = "ضمادة طبية", price = 15, stock = 50, weight = 0.1, category = "إسعافات"},
                {name = "medkit", label = "علبة إسعافات", price = 100, stock = 20, weight = 1.0, category = "إسعافات"},
                {name = "painkiller", label = "مسكن ألم", price = 30, stock = 40, weight = 0.2, category = "أدوية"},
                {name = "antibiotic", label = "مضاد حيوي", price = 45, stock = 35, weight = 0.2, category = "أدوية"},
                {name = "vitamins", label = "فيتامينات", price = 25, stock = 60, weight = 0.15, category = "مكملات"},
                {name = "firstaid", label = "إسعاف أولي", price = 75, stock = 25, weight = 0.8, category = "إسعافات"},
                {name = "antiseptic", label = "مطهر", price = 20, stock = 45, weight = 0.3, category = "إسعافات"},
                {name = "thermometer", label = "ميزان حرارة", price = 35, stock = 30, weight = 0.1, category = "أجهزة"},
                {name = "syringe", label = "محقن طبي", price = 10, stock = 80, weight = 0.05, category = "مستلزمات"},
                {name = "ointment", label = "مرهم", price = 18, stock = 55, weight = 0.1, category = "مستلزمات"},
                {name = "bandage_large", label = "ضمادة كبيرة", price = 25, stock = 40, weight = 0.2, category = "إسعافات"},
                {name = "health_boost", label = "معزز صحي", price = 60, stock = 15, weight = 0.2, category = "مكملات"},
                {name = "energy_drink", label = "مشروب طاقة", price = 12, stock = 70, weight = 0.3, category = "مشروبات"},
                {name = "protein_bar", label = "بروتين بار", price = 8, stock = 90, weight = 0.1, category = "مكملات"},
                {name = "sleeping_pills", label = "حبوب نوم", price = 35, stock = 25, weight = 0.1, category = "أدوية"}
            }
        },

        -- متجر الإلكترونيات
        {
            id = 6,
            name = "متجر التكنولوجيا الحديثة",
            type = "electronics",
            location = vector3(-658.87, -857.15, 23.5),
            blip = true,
            items = {
                {name = "phone", label = "هاتف ذكي", price = 800, stock = 25, weight = 0.3, category = "هواتف"},
                {name = "laptop", label = "لابتوب", price = 1500, stock = 15, weight = 2.0, category = "حواسيب"},
                {name = "tablet", label = "تابلت", price = 600, stock = 20, weight = 0.5, category = "أجهزة لوحية"},
                {name = "camera", label = "كاميرا", price = 450, stock = 18, weight = 0.7, category = "كاميرات"},
                {name = "headphones", label = "سماعات", price = 120, stock = 30, weight = 0.2, category = "إكسسوارات"},
                {name = "smartwatch", label = "ساعة ذكية", price = 350, stock = 22, weight = 0.1, category = "إكسسوارات"},
                {name = "router", label = "راوتر", price = 100, stock = 35, weight = 0.4, category = "شبكات"},
                {name = "speaker", label = "سماعة Bluetooth", price = 200, stock = 28, weight = 0.6, category = "صوتيات"},
                {name = "mouse", label = "ماوس", price = 50, stock = 40, weight = 0.1, category = "إكسسوارات"},
                {name = "keyboard", label = "لوحة مفاتيح", price = 80, stock = 32, weight = 0.4, category = "إكسسوارات"},
                {name = "usb", label = "USB 64GB", price = 40, stock = 50, weight = 0.05, category = "مستلزمات"},
                {name = "charger", label = "شاحن", price = 25, stock = 60, weight = 0.1, category = "مستلزمات"},
                {name = "powerbank", label = "شاحن محمول", price = 70, stock = 45, weight = 0.3, category = "مستلزمات"},
                {name = "cable", label = "كابل شحن", price = 15, stock = 80, weight = 0.1, category = "مستلزمات"},
                {name = "adapter", label = "محول", price = 30, stock = 55, weight = 0.1, category = "مستلزمات"}
            }
        },

        -- صالون حلاقة
        {
            id = 7,
            name = "صالون الحلاقة الفاخر",
            type = "barber",
            location = vector3(-278.15, 6228.52, 30.7),
            blip = true,
            items = {
                {name = "haircut_short", label = "قصة شعر قصيرة", price = 30, stock = 999, weight = 0, category = "خدمات"},
                {name = "haircut_medium", label = "قصة شعر متوسطة", price = 40, stock = 999, weight = 0, category = "خدمات"},
                {name = "haircut_long", label = "قصة شعر طويلة", price = 50, stock = 999, weight = 0, category = "خدمات"},
                {name = "beard_trim", label = "تهذيب اللحية", price = 20, stock = 999, weight = 0, category = "خدمات"},
                {name = "shave", label = "حلاقة كاملة", price = 25, stock = 999, weight = 0, category = "خدمات"},
                {name = "hair_dye", label = "صبغة شعر", price = 60, stock = 999, weight = 0, category = "خدمات"},
                {name = "facial", label = "عناية بالبشرة", price = 45, stock = 999, weight = 0, category = "خدمات"},
                {name = "massage", label = "تدليك", price = 70, stock = 999, weight = 0, category = "خدمات"},
                {name = "shampoo", label = "شامبو", price = 15, stock = 50, weight = 0.4, category = "منتجات"},
                {name = "conditioner", label = "بلسم", price = 15, stock = 45, weight = 0.4, category = "منتجات"},
                {name = "hair_gel", label = "جل شعر", price = 10, stock = 60, weight = 0.2, category = "منتجات"},
                {name = "razor", label = "ماكينة حلاقة", price = 25, stock = 40, weight = 0.1, category = "منتجات"},
                {name = "perfume", label = "عطر", price = 80, stock = 35, weight = 0.2, category = "منتجات"},
                {name = "cream", label = "كريم", price = 35, stock = 55, weight = 0.3, category = "منتجات"},
                {name = "brush", label = "فرشاة شعر", price = 12, stock = 65, weight = 0.1, category = "منتجات"}
            }
        },

        -- متجر المجوهرات
        {
            id = 8,
            name = "مجوهرات الثريا",
            type = "jewelry",
            location = vector3(-622.24, -230.88, 37.06),
            blip = true,
            items = {
                {name = "gold_ring", label = "خاتم ذهب", price = 500, stock = 20, weight = 0.05, category = "خواتم"},
                {name = "diamond_ring", label = "خاتم ماس", price = 2000, stock = 10, weight = 0.05, category = "خواتم"},
                {name = "silver_ring", label = "خاتم فضة", price = 300, stock = 25, weight = 0.05, category = "خواتم"},
                {name = "gold_necklace", label = "قلادة ذهب", price = 800, stock = 15, weight = 0.1, category = "قلادات"},
                {name = "diamond_necklace", label = "قلادة ماس", price = 3500, stock = 8, weight = 0.1, category = "قلادات"},
                {name = "pearl_necklace", label = "قلادة لؤلؤ", price = 1200, stock = 12, weight = 0.1, category = "قلادات"},
                {name = "gold_bracelet", label = "سوار ذهب", price = 600, stock = 18, weight = 0.08, category = "أساور"},
                {name = "silver_bracelet", label = "سوار فضة", price = 400, stock = 22, weight = 0.08, category = "أساور"},
                {name = "diamond_earrings", label = "أقراط ماس", price = 1500, stock = 14, weight = 0.03, category = "أقراط"},
                {name = "pearl_earrings", label = "أقراط لؤلؤ", price = 900, stock = 16, weight = 0.03, category = "أقراط"},
                {name = "gold_earrings", label = "أقراط ذهب", price = 450, stock = 20, weight = 0.03, category = "أقراط"},
                {name = "watch_luxury", label = "ساعة فاخرة", price = 2500, stock = 10, weight = 0.1, category = "ساعات"},
                {name = "bracelet_diamond", label = "سوار ماس", price = 1800, stock = 8, weight = 0.07, category = "أساور"},
                {name = "necklace_gold", label = "قلادة ذهبية", price = 1200, stock = 12, weight = 0.09, category = "قلادات"},
                {name = "crown", label = "تاج", price = 5000, stock = 3, weight = 0.5, category = "تحف"}
            }
        }
    },

    -- الرسائل
    Locales = {
        ['buy_success'] = 'تم الشراء بنجاح!',
        ['buy_failed'] = 'فشل في الشراء!',
        ['not_enough_money'] = 'ليس لديك مال كافٍ!',
        ['no_stock'] = 'لا يوجد مخزون!',
        ['shop_not_found'] = 'المتجر غير موجود!',
        ['item_not_found'] = 'العنصر غير موجود!',
        ['invalid_quantity'] = 'الكمية غير صالحة!',
        ['player_not_found'] = 'اللاعب غير موجود!',
        ['system_error'] = 'خطأ في النظام!'
    },

    -- إعدادات إضافية
    Settings = {
        EnableBlips = true,
        EnableNotifications = true,
        MaxPurchaseQuantity = 10,
        TransactionHistorySize = 20,
        AdminPermission = 'shops.admin'
    }
}
