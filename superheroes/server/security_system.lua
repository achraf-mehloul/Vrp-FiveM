local abilityUsage = {}

function CheckAbilityAbuse(source, abilityKey)
    local identifier = GetPlayerIdentifier(source)
    local currentTime = GetGameTimer()
    
    abilityUsage[identifier] = abilityUsage[identifier] or {}
    abilityUsage[identifier][abilityKey] = abilityUsage[identifier][abilityKey] or {count = 0, lastUsed = 0}
    
    local abilityData = abilityUsage[identifier][abilityKey]
    
    -- منع الاستخدام السريع
    if currentTime - abilityData.lastUsed < 1000 then
        abilityData.count = abilityData.count + 1
        if abilityData.count > 5 then
            TriggerEvent('banPlayer', source, 'Ability abuse')
            return false
        end
    else
        abilityData.count = 0
    end
    
    abilityData.lastUsed = currentTime
    return true
end
