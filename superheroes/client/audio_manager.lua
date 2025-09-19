local currentHeroMusic = nil

function PlayHeroMusic(heroId)
    if currentHeroMusic then
        StopResourceKvp(currentHeroMusic)
    end
    
    local musicData = Config.HeroMusic[heroId]
    if musicData then
        currentHeroMusic = GetResourceKvpString('hero_music')
        SendNUIMessage({
            action = 'playMusic',
            url = musicData.url,
            volume = musicData.volume
        })
    end
end

function StopHeroMusic()
    SendNUIMessage({action = 'stopMusic'})
    currentHeroMusic = nil
end

-- عند تجهيز البطل
RegisterNetEvent('superheroes:clientEquipHero')
AddEventHandler('superheroes:clientEquipHero', function(heroData)
    PlayHeroMusic(heroData.hero_id)
    SetDiscordAppId(Config.DiscordAppId)
    SetDiscordRichPresenceAsset(heroData.image)
    SetDiscordRichPresenceAssetText(heroData.name)
end)

-- عند إلغاء التجهيز
RegisterNetEvent('superheroes:clientUnequipHero')
AddEventHandler('superheroes:clientUnequipHero', function()
    StopHeroMusic()
    SetDiscordRichPresenceAsset('default_image')
end)
