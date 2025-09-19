-- [file name]: shared/items.lua
-- نظام تعريف العناصر لمتاجر ميلكس - الإصدار 1.0
-- الملف المسؤول عن تعريف جميع العناصر المتاحة في المتاجر مع خصائصها الكاملة

Items = {
    -- =============================================
    --                  الأسلحة
    -- =============================================
    WEAPON_PISTOL = { 
        label = "مسدس عادي", 
        weight = 1.0, 
        type = "weapon", 
        description = "مسدس عادي للدفاع الشخصي",
        image = "weapons/pistol.png",
        rarity = "common",
        durability = 100,
        ammoType = "9mm"
    },
    
    WEAPON_COMBATPISTOL = { 
        label = "مسدس قتالي", 
        weight = 1.1, 
        type = "weapon", 
        description = "مسدس قتالي متقدم",
        image = "weapons/combatpistol.png",
        rarity = "uncommon",
        durability = 120,
        ammoType = "9mm"
    },
    
    WEAPON_APPISTOL = { 
        label = "مسدس AP", 
        weight = 1.2, 
        type = "weapon", 
        description = "مسدس ذاتي الدفع",
        image = "weapons/appistol.png",
        rarity = "rare",
        durability = 150,
        ammoType = "9mm"
    },
    
    WEAPON_REVOLVER = { 
        label = "مسدس دوار", 
        weight = 1.3, 
        type = "weapon", 
        description = "مسدس دوار تقليدي",
        image = "weapons/revolver.png",
        rarity = "uncommon",
        durability = 110,
        ammoType = ".44"
    },
    
    WEAPON_SNSPISTOL = { 
        label = "مسدس SNS", 
        weight = 0.9, 
        type = "weapon", 
        description = "مسدس صغير الحجم",
        image = "weapons/snspistol.png",
        rarity = "common",
        durability = 90,
        ammoType = ".380"
    },
    
    WEAPON_KNIFE = { 
        label = "سكين حاد", 
        weight = 0.5, 
        type = "weapon", 
        description = "سكين حاد متعدد الاستخدامات",
        image = "weapons/knife.png",
        rarity = "common",
        durability = 200
    },
    
    WEAPON_BAT = { 
        label = "مضرب بيسبول", 
        weight = 1.2, 
        type = "weapon", 
        description = "مضرب بيسبول خشبي",
        image = "weapons/bat.png",
        rarity = "common",
        durability = 150
    },
    
    WEAPON_MICROSMG = { 
        label = "ميكرو SMG", 
        weight = 3.5, 
        type = "weapon", 
        description = "رشاش صغير الحجم",
        image = "weapons/microsmg.png",
        rarity = "rare",
        durability = 200,
        ammoType = "9mm"
    },
    
    WEAPON_ASSAULTRIFLE = { 
        label = "بندقية هجومية", 
        weight = 4.2, 
        type = "weapon", 
        description = "بندقية هجومية متطورة",
        image = "weapons/assaultrifle.png",
        rarity = "epic",
        durability = 300,
        ammoType = "7.62mm"
    },
    
    WEAPON_PUMPSHOTGUN = { 
        label = "بندقية صيد", 
        weight = 3.8, 
        type = "weapon", 
        description = "بندقية صيد قوية",
        image = "weapons/pumpshotgun.png",
        rarity = "rare",
        durability = 250,
        ammoType = "12gauge"
    },
    
    WEAPON_ASSAULTSMG = { 
        label = "بندقية رشاشة", 
        weight = 3.0, 
        type = "weapon", 
        description = "بندقية رشاشة هجومية",
        image = "weapons/assaultsmg.png",
        rarity = "rare",
        durability = 220,
        ammoType = "9mm"
    },
    
    WEAPON_CARBINERIFLE = { 
        label = "بندقية كاربين", 
        weight = 4.0, 
        type = "weapon", 
        description = "بندقية كاربين متعددة الاستخدامات",
        image = "weapons/carbinerifle.png",
        rarity = "epic",
        durability = 280,
        ammoType = "5.56mm"
    },
    
    WEAPON_SPECIALCARBINE = { 
        label = "بندقية خاصة", 
        weight = 4.1, 
        type = "weapon", 
        description = "بندقية كاربين خاصة",
        image = "weapons/specialcarbine.png",
        rarity = "epic",
        durability = 290,
        ammoType = "5.56mm"
    },
    
    WEAPON_BULLPUPRIFLE = { 
        label = "بندقية بولتاب", 
        weight = 4.3, 
        type = "weapon", 
        description = "بندقية بولتاب متطورة",
        image = "weapons/bullpuprifle.png",
        rarity = "epic",
        durability = 270,
        ammoType = "5.56mm"
    },
    
    WEAPON_SNIPERRIFLE = { 
        label = "بندقية قنص", 
        weight = 5.0, 
        type = "weapon", 
        description = "بندقية قنص طويلة المدى",
        image = "weapons/sniperrifle.png",
        rarity = "legendary",
        durability = 200,
        ammoType = ".50"
    },

    -- =============================================
    --                  الذخيرة
    -- =============================================
    ammo_pistol = { 
        label = "ذخيرة مسدس", 
        weight = 0.1, 
        type = "ammo", 
        description = "ذخيرة للمسدسات",
        image = "weapons/ammo_pistol.png",
        rarity = "common",
        maxStack = 250
    },
    
    ammo_rifle = { 
        label = "ذخيرة بندقية", 
        weight = 0.2, 
        type = "ammo", 
        description = "ذخيرة للبنادق",
        image = "weapons/ammo_rifle.png",
        rarity = "common",
        maxStack = 150
    },
    
    ammo_shotgun = { 
        label = "ذخيرة بندقية صيد", 
        weight = 0.3, 
        type = "ammo", 
        description = "ذخيرة لبندقية الصيد",
        image = "weapons/ammo_shotgun.png",
        rarity = "common",
        maxStack = 100
    },
    
    ammo_smg = { 
        label = "ذخيرة SMG", 
        weight = 0.2, 
        type = "ammo", 
        description = "ذخيرة للرشاشات",
        image = "weapons/ammo_smg.png",
        rarity = "common",
        maxStack = 200
    },

    -- =============================================
    --                  السيارات
    -- =============================================
    sultan = { 
        label = "Sultan", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة رياضية 4 أبواب",
        image = "vehicles/sultan.png",
        rarity = "uncommon",
        seats = 4,
        maxSpeed = 220,
        acceleration = 8.5
    },
    
    adder = { 
        label = "Adder", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة فائقة السرعة",
        image = "vehicles/adder.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 380,
        acceleration = 9.8
    },
    
    banshee = { 
        label = "Banshee", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة رياضية أمريكية",
        image = "vehicles/banshee.png",
        rarity = "rare",
        seats = 2,
        maxSpeed = 320,
        acceleration = 9.2
    },
    
    bullet = { 
        label = "Bullet", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة سباق فائقة",
        image = "vehicles/bullet.png",
        rarity = "epic",
        seats = 2,
        maxSpeed = 350,
        acceleration = 9.5
    },
    
    cheetah = { 
        label = "Cheetah", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة فاخرة سريعة",
        image = "vehicles/cheetah.png",
        rarity = "epic",
        seats = 2,
        maxSpeed = 340,
        acceleration = 9.4
    },
    
    comet2 = { 
        label = "Comet", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة رياضية ألمانية",
        image = "vehicles/comet2.png",
        rarity = "rare",
        seats = 2,
        maxSpeed = 300,
        acceleration = 8.8
    },
    
    elegy2 = { 
        label = "Elegy", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة رياضية يابانية",
        image = "vehicles/elegy2.png",
        rarity = "uncommon",
        seats = 4,
        maxSpeed = 280,
        acceleration = 8.2
    },
    
    feltzer2 = { 
        label = "Feltzer", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة رياضية مكشوفة",
        image = "vehicles/feltzer2.png",
        rarity = "rare",
        seats = 2,
        maxSpeed = 310,
        acceleration = 9.0
    },
    
    jester = { 
        label = "Jester", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة رياضية أنيقة",
        image = "vehicles/jester.png",
        rarity = "uncommon",
        seats = 2,
        maxSpeed = 290,
        acceleration = 8.6
    },
    
    massacro = { 
        label = "Massacro", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة سباق بريطانية",
        image = "vehicles/massacro.png",
        rarity = "rare",
        seats = 2,
        maxSpeed = 315,
        acceleration = 9.1
    },
    
    turismo2 = { 
        label = "Turismo", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة إيطالية فائقة",
        image = "vehicles/turismo2.png",
        rarity = "epic",
        seats = 2,
        maxSpeed = 345,
        acceleration = 9.3
    },
    
    zentorno = { 
        label = "Zentorno", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة فائقة المستقبل",
        image = "vehicles/zentorno.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 370,
        acceleration = 9.7
    },
    
    nero = { 
        label = "Nero", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة فائقة إيطالية",
        image = "vehicles/nero.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 355,
        acceleration = 9.4
    },
    
    vagner = { 
        label = "Vagner", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة سباق فائقة",
        image = "vehicles/vagner.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 375,
        acceleration = 9.6
    },
    
    xa21 = { 
        label = "XA-21", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة فائقة بريطانية",
        image = "vehicles/xa21.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 365,
        acceleration = 9.5
    },
    
    cyclone = { 
        label = "Cyclone", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة كهربائية فائقة",
        image = "vehicles/cyclone.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 390,
        acceleration = 9.9
    },
    
    visione = { 
        label = "Visione", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة فائقة بمستقبلية",
        image = "vehicles/visione.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 380,
        acceleration = 9.7
    },
    
    sc1 = { 
        label = "SC1", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة فائقة فاخرة",
        image = "vehicles/sc1.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 360,
        acceleration = 9.4
    },
    
    autarch = { 
        label = "Autarch", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة سباق فائقة",
        image = "vehicles/autarch.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 370,
        acceleration = 9.6
    },
    
    tyrant = { 
        label = "Tyrant", 
        weight = 0, 
        type = "vehicle", 
        description = "سيارة فائقة قوية",
        image = "vehicles/tyrant.png",
        rarity = "legendary",
        seats = 2,
        maxSpeed = 385,
        acceleration = 9.8
    },

    -- =============================================
    --             الطعام والمشروبات
    -- =============================================
    bread = { 
        label = "خبز طازج", 
        weight = 0.2, 
        type = "food", 
        description = "خبز طازج من الفرن", 
        hunger = 20,
        image = "foods/bread.png",
        rarity = "common",
        effect = "hunger"
    },
    
    water = { 
        label = "ماء معدني", 
        weight = 0.5, 
        type = "drink", 
        description = "ماء معدني نقي", 
        thirst = 30,
        image = "foods/water.png",
        rarity = "common",
        effect = "thirst"
    },
    
    burger = { 
        label = "برغر لذيذ", 
        weight = 0.3, 
        type = "food", 
        description = "برغر لحم مع الخضار", 
        hunger = 35,
        image = "foods/burger.png",
        rarity = "common",
        effect = "hunger"
    },
    
    sandwich = { 
        label = "ساندويتش", 
        weight = 0.25, 
        type = "food", 
        description = "سандويتش جبن وخضار", 
        hunger = 25,
        image = "foods/sandwich.png",
        rarity = "common",
        effect = "hunger"
    },
    
    chips = { 
        label = "رقائق بطاطس", 
        weight = 0.15, 
        type = "food", 
        description = "رقائق بطاطس مقرمشة", 
        hunger = 15,
        image = "foods/chips.png",
        rarity = "common",
        effect = "hunger"
    },
    
    chocolate = { 
        label = "شوكولاتة", 
        weight = 0.1, 
        type = "food", 
        description = "شوكولاتة حلوة", 
        hunger = 10,
        image = "foods/chocolate.png",
        rarity = "common",
        effect = "hunger"
    },
    
    soda = { 
        label = "مشروب غازي", 
        weight = 0.4, 
        type = "drink", 
        description = "مشروب غازي منعش", 
        thirst = 20,
        image = "foods/soda.png",
        rarity = "common",
        effect = "thirst"
    },
    
    coffee = { 
        label = "قهوة ساخنة", 
        weight = 0.3, 
        type = "drink", 
        description = "قهوة عربية أصيلة", 
        thirst = 15,
        image = "foods/coffee.png",
        rarity = "common",
        effect = "thirst"
    },
    
    milk = { 
        label = "حليب طازج", 
        weight = 0.6, 
        type = "drink", 
        description = "حليب طازج مغذي", 
        thirst = 25,
        image = "foods/milk.png",
        rarity = "common",
        effect = "thirst"
    },
    
    apple = { 
        label = "تفاح طازج", 
        weight = 0.1, 
        type = "food", 
        description = "تفاح طازج وحلو", 
        hunger = 8,
        image = "foods/apple.png",
        rarity = "common",
        effect = "hunger"
    },
    
    orange = { 
        label = "برتقال", 
        weight = 0.1, 
        type = "food", 
        description = "برتقال عصيري", 
        hunger = 8,
        image = "foods/orange.png",
        rarity = "common",
        effect = "hunger"
    },
    
    banana = { 
        label = "موز", 
        weight = 0.1, 
        type = "food", 
        description = "موز طازج", 
        hunger = 7,
        image = "foods/banana.png",
        rarity = "common",
        effect = "hunger"
    },
    
    pizza = { 
        label = "بيتزا", 
        weight = 0.8, 
        type = "food", 
        description = "بيتزا لذيذة بالجبن", 
        hunger = 45,
        image = "foods/pizza.png",
        rarity = "uncommon",
        effect = "hunger"
    },
    
    donut = { 
        label = "دونات", 
        weight = 0.1, 
        type = "food", 
        description = "دونات محلاة", 
        hunger = 12,
        image = "foods/donut.png",
        rarity = "common",
        effect = "hunger"
    },
    
    icecream = { 
        label = "آيس كريم", 
        weight = 0.3, 
        type = "food", 
        description = "آيس كريم بارد ومنعش", 
        hunger = 18,
        image = "foods/icecream.png",
        rarity = "common",
        effect = "hunger"
    },
    
    hotdog = { 
        label = "هوت دوغ", 
        weight = 0.3, 
        type = "food", 
        description = "هوت دوغ ساخن", 
        hunger = 22,
        image = "foods/hotdog.png",
        rarity = "common",
        effect = "hunger"
    },
    
    taco = { 
        label = "تاكو", 
        weight = 0.3, 
        type = "food", 
        description = "تاكو مكسيكي لذيذ", 
        hunger = 20,
        image = "foods/taco.png",
        rarity = "uncommon",
        effect = "hunger"
    },
    
    sushi = { 
        label = "سوشي", 
        weight = 0.4, 
        type = "food", 
        description = "سوشي ياباني طازج", 
        hunger = 25,
        image = "foods/sushi.png",
        rarity = "rare",
        effect = "hunger"
    },
    
    steak = { 
        label = "ستيك", 
        weight = 0.7, 
        type = "food", 
        description = "ستيك لحم مشوي", 
        hunger = 50,
        image = "foods/steak.png",
        rarity = "rare",
        effect = "hunger"
    },
    
    salad = { 
        label = "سلطة", 
        weight = 0.3, 
        type = "food", 
        description = "سلطة طازجة وصحية", 
        hunger = 15,
        image = "foods/salad.png",
        rarity = "common",
        effect = "hunger"
    }
}

-- =============================================
--             الدوال المساعدة
-- =============================================

--- الحصول على معلومات العنصر بناءً على اسمه
-- @param itemName اسم العنصر المطلوب
-- @return جدول يحتوي على معلومات العنصر أو معلومات افتراضية إذا لم يوجد
function GetItemInfo(itemName)
    local item = Items[itemName]
    if not item then
        DebugPrint("تحذير: العنصر '" .. tostring(itemName) .. "' غير معرّف في items.lua", "warn")
        return { 
            label = itemName, 
            weight = 0.1, 
            type = "unknown", 
            description = "عنصر غير معروف",
            image = "default.png",
            rarity = "common"
        }
    end
    return item
end

--- الحصول على أيقونة العنصر بناءً على نوعه
-- @param itemName اسم العنصر المطلوب
-- @return أيقونة تمثل نوع العنصر
function GetItemIcon(itemName)
    local item = GetItemInfo(itemName)
    local icons = {
        weapon = "🔫",
        ammo = "🎯",
        vehicle = "🚗",
        food = "🍔",
        drink = "🥤",
        clothing = "👕",
        medical = "💊",
        electronics = "📱",
        jewelry = "💎"
    }
    return icons[item.type] or "📦"
end

--- الحصول على لون يمثل ندرة العنصر
-- @param rarity مستوى الندرة (common, uncommon, rare, epic, legendary)
-- @return لون HEX يمثل مستوى الندرة
function GetItemRarityColor(rarity)
    local colors = {
        common = "#FFFFFF",      -- أبيض
        uncommon = "#1EFF00",    -- أخضر
        rare = "#0070FF",        -- أزرق
        epic = "#A335EE",        -- أرجواني
        legendary = "#FF8000"    -- برتقالي
    }
    return colors[rarity] or "#FFFFFF"
end

-- رسالة تأكيد تحميل الملف
print('^2[Shops] ^3تم تحميل معلومات ^5' .. countTable(Items) .. ' ^3عنصر بنجاح^0')

-- دالة مساعدة لحساب عدد العناصر (موجودة في ملف functions.lua)
function countTable(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
