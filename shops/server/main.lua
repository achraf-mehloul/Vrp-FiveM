-- [file name]: server/main.lua
-- الملف الرئيسي للسيرفر

-- طباعة رسالة البدء
print('^2[Shops] جاري تحميل نظام المتاجر...^0')

-- الانتظار حتى يتم تحميل ESX
if Config.UseESX then
    while not ESX do
        Citizen.Wait(100)
    end
    print('^2[Shops] تم اكتشاف ESX^0')
end

-- الانتظار حتى يتم تحميل oxmysql
while not MySQL do
    Citizen.Wait(100)
end
print('^2[Shops] تم اكتشاف oxmysql^0')

-- تحميل المكونات
local function loadModule(moduleName)
    local success, error = pcall(function()
        require(moduleName)
    end)
    
    if success then
        print('^2[Shops] تم تحميل: ' .. moduleName .. '^0')
    else
        print('^1[Shops] فشل في تحميل: ' .. moduleName .. ' - ' .. tostring(error) .. '^0')
    end
end

-- تحميل جميع المكونات
loadModule('server.database')
loadModule('server.shop_repository')
loadModule('server.shop_service')
loadModule('server.shop_controller')
loadModule('server.admin_commands')
loadModule('server.transaction_manager')

-- حدث تحميل المورد
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[Shops] تم تحميل نظام المتاجر بنجاح!^0')
        print('^2[Shops] عدد المتاجر: ' .. #Config.Shops .. '^0')
        print('^2[Shops] الإصدار: 1.0.0^0')
        print('^2[Shops] المطور: Melix Files^0')
        
        -- إشعار للاعبين
        TriggerClientEvent('chat:addMessage', -1, {
            args = {'^2[Shops]', 'تم تحميل نظام المتاجر بنجاح! اكتب /shops للمساعدة'}
        })
    end
end)

-- حدث إيقاف المورد
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^1[Shops] تم إيقاف نظام المتاجر^0')
    end
end)

-- أمر المساعدة
RegisterCommand('shops', function(source, args, rawCommand)
    local helpMessage = [[
        ^2[Shops] نظام المتاجر - أوامر المساعدة:
        ^3/shops help^0 - عرض هذه الرسالة
        ^3/shops list^0 - عرض قائمة المتاجر
        ^3/shops stats^0 - عرض الإحصائيات
        ^3/shops reload^0 - إعادة تحميل المتاجر (للمسؤولين)
    ]]
    
    TriggerClientEvent('chat:addMessage', source, { args = {'^2[Shops]', 'نظام المتاجر المتكامل'} })
    TriggerClientEvent('chat:addMessage', source, { args = {'^3[Shops]', helpMessage} })
end, false)

-- حدث للتحقق من صحة النظام
RegisterNetEvent('shops:checkSystem')
AddEventHandler('shops:checkSystem', function()
    local src = source
    local systemStatus = {
        database = MySQL ~= nil,
        esx = Config.UseESX and ESX ~= nil or true,
        shopsLoaded = #ShopService:getAllShops() > 0,
        version = '1.0.0'
    }
    
    TriggerClientEvent('shops:systemStatus', src, systemStatus)
end)

-- طباعة رسالة النجاح النهائية
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- انتظار تحميل جميع المكونات
    
    local totalShops = #ShopService:getAllShops()
    local totalItems = 0
    
    for _, shop in pairs(ShopService:getAllShops()) do
        totalItems = totalItems + countTable(shop.items)
    end
    
    print('^2[Shops] ========================================^0')
    print('^2[Shops] نظام المتاجر جاهز للعمل!^0')
    print('^2[Shops] المتاجر: ' .. totalShops .. '^0')
    print('^2[Shops] العناصر: ' .. totalItems .. '^0')
    print('^2[Shops] الإصدار: 1.0.0^0')
    print('^2[Shops] ========================================^0')
end)

-- دالة مساعدة
function countTable(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
