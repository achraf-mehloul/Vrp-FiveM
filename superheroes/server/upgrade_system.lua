function UpgradeAbility(source, heroId, abilityKey, upgradeType)
    local Player = QBCore.Functions.GetPlayer(source)
    local identifier = GetPlayerIdentifier(source)
    
    local upgradeCost = CalculateUpgradeCost(heroId, abilityKey, upgradeType)
    
    if Player.Functions.RemoveMoney('bank', upgradeCost) then
        MySQL:execute(
            'UPDATE player_heroes SET upgrades = JSON_SET(upgrades, "$.'..abilityKey..'", upgrades->>"$.'..abilityKey..'" + 1) WHERE player_identifier = ? AND hero_id = ?',
            {identifier, heroId}
        )
        return true
    end
    return false
end

function CalculateUpgradeCost(heroId, abilityKey, level)
    return math.floor(5000 * (1.5 ^ (level - 1)))
end
