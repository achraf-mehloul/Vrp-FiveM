local Config = {}

Config.Framework = 'vRP' -- أو 'CWRP' أو 'ESX'

Config.Energy = {
    default_energy = 100,
    regen_per_sec = 1.5,
    drain_rates = {
        flight = 2.0,
        speed = 1.5,
        strength = 1.0
    }
}

Config.Cooldowns = {
    default_cooldown = 5000, -- 5 ثواني
    ability_cooldowns = {
        flight = 10000,
        speed_boost = 8000,
        fire_attack = 6000
    }
}

Config.Costs = {
    unlock_hero = 5000, -- سعر فتح البطل
    upgrade_cost_multiplier = 2.5
}

Config.Permissions = {
    admin_ranks = {'admin', 'superadmin'}, -- الرتب التي يمكنها استخدام أوامر الأدمن
    max_heroes_per_player = 3 -- الحد الأقصى للأبطال التي يمكن امتلاكها
}

return Config
