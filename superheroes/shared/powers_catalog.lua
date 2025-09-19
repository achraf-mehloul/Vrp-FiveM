local HeroesCatalog = {
    {
        hero_id = 'thor',
        name = 'ثور',
        description = 'إله الرعد والبرق',
        default_energy = 200,
        cooldown_default = 3000,
        cost = 25000,
        image = 'thor.png',
        music = 'thor_music.mp3',
        abilities = {
            {
                key = 'lightning_strike',
                name = 'ضربة البرق',
                energy_cost = 25,
                cooldown = 8000,
                damage = 50,
                effect = 'lightning'
            },
            {
                key = 'thunder_storm',
                name = 'عاصفة رعدية',
                energy_cost = 40,
                cooldown = 15000,
                damage = 80,
                effect = 'storm'
            }
        }
    },
    {
        hero_id = 'thanos',
        name = 'ثانوس',
        description = 'الطاغيه القوي',
        default_energy = 300,
        cooldown_default = 5000,
        cost = 50000,
        image = 'thanos.png',
        music = 'thanos_music.mp3',
        abilities = {
            {
                key = 'infinity_gauntlet',
                name = 'قفاز الانفينتي',
                energy_cost = 60,
                cooldown = 20000,
                damage = 100,
                effect = 'gauntlet'
            }
        }
    }
}
