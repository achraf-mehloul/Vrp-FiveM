local QBCore = exports['qb-core']:GetCoreObject()

function CanPlayerBuyHero(source, heroId)
    local Player = QBCore.Functions.GetPlayer(source)
    local heroData = GetHeroData(heroId)
    
    if not Player or not heroData then
        return false
    end

    local playerMoney = Player.Functions.GetMoney('bank')
    return playerMoney >= heroData.cost
end

function GetPlayerEnergy(source)
    local identifier = GetPlayerIdentifier(source)
    local query = 'SELECT energy FROM player_heroes WHERE player_identifier = ? AND equipped = TRUE'
    local result = MySQL:querySync(query, {identifier})
    
    if result and result[1] then
        return result[1].energy
    end
    
    return 0
end

function SetPlayerEnergy(source, newEnergy)
    local identifier = GetPlayerIdentifier(source)
    local query = 'UPDATE player_heroes SET energy = ? WHERE player_identifier = ? AND equipped = TRUE'
    MySQL:execute(query, {newEnergy, identifier})
    
    -- تحديث الطاقة على العميل
    TriggerClientEvent('superheroes:updateEnergy', source, newEnergy)
end
