local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local currentHero = nil
local energy = 100
local cooldowns = {}

-- استدعاء الواجهة
function ToggleHeroUI()
    SetNuiFocus(true, true)
    SendNUIMessage({action = 'openHeroesStore'})
end

-- تفعيل القدرة
function ActivateAbility(abilityKey)
    if cooldowns[abilityKey] and cooldowns[abilityKey] > GetGameTimer() then
        QBCore.Functions.Notify('القدرة في حالة تبريد', 'error')
        return
    end

    if energy <= 0 then
        QBCore.Functions.Notify('طاقتك منخفضة', 'error')
        return
    end

    TriggerServerEvent('superheroes:activateAbility', abilityKey)
end

-- تحديث الطاقة
RegisterNetEvent('superheroes:updateEnergy')
AddEventHandler('superheroes:updateEnergy', function(newEnergy)
    energy = newEnergy
    SendNUIMessage({action = 'updateEnergy', value = energy})
end)

-- الأوامر
RegisterCommand('heroes', function()
    ToggleHeroUI()
end, false)

-- Keybinds
RegisterKeyMapping('heroes', 'فتح меню الأبطال', 'keyboard', 'F5')
