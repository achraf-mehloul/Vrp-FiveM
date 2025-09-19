function ActivateThorLightning()
    -- تأثير البرق
    StartParticleFxLoopedAtCoord('veh_light_red', GetEntityCoords(PlayerPedId()), 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    
    -- اهتزاز الشاشة
    ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 1.0)
    
    -- صوت الرعد
    PlaySoundFrontend(-1, 'THUNDER', 'WEATHER_SOUNDS', true)
end

function ActivateThanosGauntlet()
    -- تأثير القفاز
    StartParticleFxLoopedAtCoord('ent_anim_arc_weld', GetEntityCoords(PlayerPedId()), 0.0, 0.0, 0.0, 2.0, false, false, false, false)
    
    -- تجميد اللاعبين القريبين
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        if GetDistanceBetweenPlayers(PlayerId(), player) < 50.0 then
            FreezeEntityPosition(GetPlayerPed(player), true)
            Citizen.Wait(3000)
            FreezeEntityPosition(GetPlayerPed(player), false)
        end
    end
end
