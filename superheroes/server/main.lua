local QBCore = exports['qb-core']:GetCoreObject()
local Config = exports['superheroes']:GetConfig()

RegisterNetEvent('superheroes:activateAbility', function(abilityKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local identifier = Player.PlayerData.citizenid
    local heroData = GetPlayerHeroData(identifier)

    if not heroData or not heroData.equipped then
        TriggerClientEvent('QBCore:Notify', src, 'ليس لديك بطل مجهز', 'error')
        return
    end

    -- التحقق من الطاقة والتبريد
    if not CheckEnergy(src, abilityKey) or not CheckCooldown(src, abilityKey) then
        return
    end

    -- خصم الطاقة وتفعيل التبريد
    DeductEnergy(src, abilityKey)
    SetCooldown(src, abilityKey)

    -- تفعيل القدرة على العميل
    TriggerClientEvent('superheroes:clientActivateAbility', src, abilityKey)
end)
