local cooldowns = {}

function SetCooldown(src, abilityKey)
    local identifier = GetPlayerIdentifier(src)
    local cooldownTime = Config.Cooldowns.ability_cooldowns[abilityKey] or Config.Cooldowns.default_cooldown
    
    cooldowns[identifier] = cooldowns[identifier] or {}
    cooldowns[identifier][abilityKey] = GetGameTimer() + cooldownTime
end

function CheckCooldown(src, abilityKey)
    local identifier = GetPlayerIdentifier(src)
    if not cooldowns[identifier] or not cooldowns[identifier][abilityKey] then
        return true
    end

    if GetGameTimer() < cooldowns[identifier][abilityKey] then
        TriggerClientEvent('QBCore:Notify', src, 'القدرة في حالة تبريد', 'error')
        return false
    end

    return true
end
