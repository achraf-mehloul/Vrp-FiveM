-- [file name]: client/player_manager.lua
local PlayerManager = {
    playerData = {
        money = 0,
        bank = 0,
        inventory = {},
        weight = 0,
        maxWeight = 0
    },
    isDataLoaded = false
}

-- تهيئة مدير اللاعب
function PlayerManager:init()
    self:loadPlayerData()
    self:startUpdateTask()
    DebugPrint('تم تهيئة مدير اللاعب بنجاح', 'info')
end

-- تحميل بيانات اللاعب
function PlayerManager:loadPlayerData()
    if Config.UseESX then
        ESX.TriggerServerCallback('shops:getPlayerData', function(data)
            self.playerData = data
            self.isDataLoaded = true
            
            DebugPrint('تم تحميل بيانات اللاعب بنجاح', 'debug')
        end)
    else
        -- نظام QBCore أو غيره
        self:loadAlternativeData()
    end
end

-- تحميل بيانات بديلة
function PlayerManager:loadAlternativeData()
    if Config.Framework == 'qbcore' then
        QBCore.Functions.TriggerCallback('shops:getPlayerData', function(data)
            self.playerData = data
            self.isDataLoaded = true
        end)
    else
        -- نظام مخصص
        self.playerData = {
            money = 1000,
            bank = 5000,
            weight = 0,
            maxWeight = 50
        }
        self.isDataLoaded = true
    end
end

-- مهمة التحديث المستمر
function PlayerManager:startUpdateTask()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.Settings.UpdateInterval or 30000)
            
            if self.isDataLoaded then
                self:updatePlayerData()
            end
        end
    end)
end

-- تحديث بيانات اللاعب
function PlayerManager:updatePlayerData()
    if Config.UseESX then
        ESX.TriggerServerCallback('shops:getPlayerData', function(data)
            self.playerData = data
            self:sendDataToNUI()
        end)
    else
        self:updateAlternativeData()
    end
end

-- تحديث البيانات البديلة
function PlayerManager:updateAlternativeData()
    if Config.Framework == 'qbcore' then
        QBCore.Functions.TriggerCallback('shops:getPlayerData', function(data)
            self.playerData = data
            self:sendDataToNUI()
        end)
    end
end

-- إرسال البيانات إلى NUI
function PlayerManager:sendDataToNUI()
    SendNUIMessage({
        action = 'updatePlayerData',
        data = {
            money = self.playerData.money,
            bank = self.playerData.bank,
            weight = self.playerData.weight,
            maxWeight = self.playerData.maxWeight
        }
    })
end

-- التحقق من القدرة على الشراء
function PlayerManager:canAfford(amount)
    return self.playerData.money >= amount
end

-- التحقق من سعة المخزون
function PlayerManager:canCarry(itemName, quantity)
    if not self.playerData.maxWeight then return true end
    
    local itemWeight = GetItemWeight(itemName) or 0.1
    local totalWeight = self.playerData.weight + (itemWeight * quantity)
    
    return totalWeight <= self.playerData.maxWeight
end

-- الحصول على وزن العنصر
function GetItemWeight(itemName)
    if Config.Items[itemName] then
        return Config.Items[itemName].weight or 0.1
    end
    return 0.1
end

-- تحديث الرصيد
function PlayerManager:updateMoney(amount)
    self.playerData.money = amount
    self:sendDataToNUI()
end

-- تحديث البنك
function PlayerManager:updateBank(amount)
    self.playerData.bank = amount
    self:sendDataToNUI()
end

-- تحديث الوزن
function PlayerManager:updateWeight(weight)
    self.playerData.weight = weight
    self:sendDataToNUI()
end

-- استقبال تحديثات البيانات
RegisterNetEvent('shops:updatePlayerMoney')
AddEventHandler('shops:updatePlayerMoney', function(amount)
    PlayerManager:updateMoney(amount)
end)

RegisterNetEvent('shops:updatePlayerBank')
AddEventHandler('shops:updatePlayerBank', function(amount)
    PlayerManager:updateBank(amount)
end)

RegisterNetEvent('shops:updatePlayerWeight')
AddEventHandler('shops:updatePlayerWeight', function(weight)
    PlayerManager:updateWeight(weight)
end)

-- الحصول على بيانات اللاعب
function GetPlayerData()
    return PlayerManager.playerData
end

-- التحقق من تحميل البيانات
function IsPlayerDataLoaded()
    return PlayerManager.isDataLoaded
end

-- تهيئة المدير
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.Wait(1000) -- انتظار تحميل الإطار
        PlayerManager:init()
    end
end)

-- تنظيف البيانات
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerManager.isDataLoaded = false
        PlayerManager.playerData = {}
    end
end)

return PlayerManager
