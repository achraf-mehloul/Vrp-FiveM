function TrackAbilityUsage(source, heroId, abilityKey)
    local identifier = GetPlayerIdentifier(source)
    
    MySQL:execute(
        'INSERT INTO hero_stats (player_identifier, hero_id, ability_key, uses) VALUES (?, ?, ?, 1) ON DUPLICATE KEY UPDATE uses = uses + 1',
        {identifier, heroId, abilityKey}
    )
end

function GetPlayerStats(source)
    local identifier = GetPlayerIdentifier(source)
    return MySQL:querySync(
        'SELECT hero_id, ability_key, uses FROM hero_stats WHERE player_identifier = ?',
        {identifier}
    )
end
