-- دوال مساعدة مشتركة بين السيرفر والكلينت

-- طباعة رسائل التصحيح
function DebugPrint(message, level)
    if not Config.Debug then return end
    
    local levels = {
        debug = "^7[DEBUG]^0 ",
        info = "^5[INFO]^0 ",
        warn = "^3[WARN]^0 ",
        error = "^1[ERROR]^0 "
    }
    
    local prefix = levels[level] or levels['info']
    print(prefix .. message)
end

-- تحويل المتجه إلى جدول
function Vector3ToTable(vector)
    return {x = vector.x, y = vector.y, z = vector.z}
end

-- تحويل الجدول إلى متجه
function TableToVector3(table)
    return vector3(table.x, table.y, table.z)
end

-- حساب المسافة بين نقطتين
function CalculateDistance(coords1, coords2)
    return #(coords1 - coords2)
end

-- تنسيق الأرقام بفواصل
function FormatNumber(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- تنسيق السعر
function FormatPrice(price)
    return Config.Currency .. FormatNumber(price)
end

-- تحويل الوقت إلى تنسيق مقروء
function FormatTime(timestamp)
    return os.date("%Y/%m/%d %H:%M", timestamp)
end

-- التحقق إذا كان المتجر مفتوحاً
function IsShopOpen(openHour, closeHour)
    local currentHour = tonumber(os.date("%H"))
    return currentHour >= openHour and currentHour < closeHour
end

-- إنشاء معرف فريد
function GenerateUniqueId()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- تحويل الجدول إلى JSON
function TableToJson(tableData)
    return json.encode(tableData)
end

-- تحويل JSON إلى جدول
function JsonToTable(jsonData)
    return json.decode(jsonData)
end

-- التحقق من الصلاحيات
function HasPermission(source, permission)
    if IsPlayerAceAllowed(source, permission) then
        return true
    end
    return false
end

-- الحصول على اسم اللاعب
function GetPlayerName(source)
    return GetPlayerName(source) or "Unknown"
end

-- الحصول على معرف اللاعب
function GetPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, 'license:') then
            return identifier
        end
    end
    return nil
end

-- التحقق إذا كان العنصر موجوداً
function IsItemValid(itemName)
    return Items[itemName] ~= nil
end

-- الحصول على فئة المتجر
function GetShopTypeName(shopType)
    return Config.ShopTypes[shopType] and Config.ShopTypes[shopType].name or "غير معروف"
end

-- الحصول على أيقونة المتجر
function GetShopTypeIcon(shopType)
    return Config.ShopTypes[shopType] and Config.ShopTypes[shopType].icon or "🏪"
end

-- حساب الخصم
function CalculateDiscount(totalAmount)
    local discount = 0
    for _, discountRule in ipairs(Config.Settings.Discounts) do
        if totalAmount >= discountRule.minAmount then
            discount = math.max(discount, discountRule.discount)
        end
    end
    return discount
end

-- حساب الضريبة
function CalculateTax(amount)
    return amount * Config.Settings.TaxRate
end

-- حساب السعر النهائي
function CalculateFinalPrice(amount)
    local discount = CalculateDiscount(amount)
    local discountedAmount = amount * (1 - discount)
    local tax = CalculateTax(discountedAmount)
    return discountedAmount + tax, discount, tax
end

-- تحميل الصورة
function LoadImage(imagePath)
    if not Config.Performance.PreloadImages then
        return imagePath
    end
    
    -- هنا يمكن إضافة منطق تحميل الصور مسبقاً
    return imagePath
end

-- إدارة الذاكرة المؤقتة
local cache = {}
function SetCache(key, value, ttl)
    cache[key] = {
        value = value,
        expiry = os.time() + (ttl or Config.Performance.CacheTimeout)
    }
end

function GetCache(key)
    local item = cache[key]
    if item and os.time() < item.expiry then
        return item.value
    end
    return nil
end

function ClearCache(key)
    cache[key] = nil
end

-- دالة للتحقق من اتصال قاعدة البيانات
function CheckDatabaseConnection()
    local connected = MySQL ~= nil
    if not connected then
        DebugPrint("قاعدة البيانات غير متصلة", "error")
    end
    return connected
end

-- دالة للتحقق من اتصال ESX
function CheckESXConnection()
    if Config.UseESX then
        local esxConnected = ESX ~= nil
        if not esxConnected then
            DebugPrint("ESX غير متصل", "error")
        end
        return esxConnected
    end
    return true
end

-- دالة للتحقق من صحة البيانات
function ValidateData(data, requiredFields)
    for _, field in ipairs(requiredFields) do
        if data[field] == nil then
            return false, "حقل " .. field .. " مطلوب"
        end
    end
    return true, "البيانات صالحة"
end

-- دالة لإنشاء تأخير
function Delay(ms)
    Citizen.Wait(ms)
end

-- دالة للتحقق من وجود ملف
function FileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- دالة لتحميل الصور
function LoadImages(imageList)
    for _, imagePath in ipairs(imageList) do
        if FileExists("client/ui/assets/" .. imagePath) then
            DebugPrint("تم تحميل الصورة: " .. imagePath, "debug")
        else
            DebugPrint("الصورة غير موجودة: " .. imagePath, "warn")
        end
    end
end

-- دالة للتحقق من إعدادات اللاعب
function CheckPlayerSettings(playerId)
    local settings = {
        soundEnabled = true,
        notificationsEnabled = true,
        language = Config.Language,
        theme = "default"
    }
    return settings
end

-- دالة لتسجيل الأخطاء
function LogError(errorMessage, context)
    local errorData = {
        message = errorMessage,
        context = context,
        timestamp = os.time(),
        resource = GetCurrentResourceName()
    }
    
    DebugPrint("خطأ: " .. errorMessage .. " | السياق: " .. context, "error")
    
    -- يمكن إضافة حفظ الأخطاء في ملف أو قاعدة البيانات هنا
end

-- دالة لإنشاء ID فريد
function CreateUniqueId()
    return math.random(100000, 999999) .. os.time()
end

-- دالة للتحقق من صحة الإحداثيات
function IsValidCoordinates(coords)
    return coords and coords.x and coords.y and coords.z
end

-- دالة للتحقق من صحة السعر
function IsValidPrice(price)
    return price and type(price) == "number" and price >= 0
end

-- دالة للتحقق من صحة المخزون
function IsValidStock(stock)
    return stock and type(stock) == "number" and stock >= 0
end

print('^2[Shops] تم تحميل الدوال المساعدة بنجاح^0')
