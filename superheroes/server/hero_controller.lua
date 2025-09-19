local QBCore = exports['qb-core']:GetCoreObject()

-- حدث شراء بطل
RegisterNetEvent('superheroes:buyHero', function(heroId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local identifier = Player.PlayerData.citizenid
    local heroData = GetHeroData(heroId)

    if not heroData then
        TriggerClientEvent('QBCore:Notify', src, 'هذا البطل غير موجود', 'error')
        return
    end

    if Player.Functions.RemoveMoney('bank', heroData.cost) then
        GiveHeroToPlayer(identifier, heroId)
        TriggerClientEvent('QBCore:Notify', src, 'تم شراء البطل بنجاح', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'ليس لديك رصيد كافي', 'error')
    end
end)
