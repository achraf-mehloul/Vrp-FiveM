local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports['oxmysql']

function GiveHeroToPlayer(identifier, heroId)
    local query = 'INSERT INTO player_heroes (player_identifier, hero_id, level, upgrades, equipped) VALUES (?, ?, 1, "{}", FALSE)'
    MySQL:execute(query, {identifier, heroId})
end

function GetPlayerHeroes(identifier)
    local query = 'SELECT * FROM player_heroes WHERE player_identifier = ?'
    return MySQL:querySync(query, {identifier})
end

function EquipHero(identifier, heroId)
    -- إلغاء تجهيز كل الأبطال أولاً
    local query = 'UPDATE player_heroes SET equipped = FALSE WHERE player_identifier = ?'
    MySQL:execute(query, {identifier})
    
    -- تجهيز البطل المحدد
    query = 'UPDATE player_heroes SET equipped = TRUE WHERE player_identifier = ? AND hero_id = ?'
    MySQL:execute(query, {identifier, heroId})
end
