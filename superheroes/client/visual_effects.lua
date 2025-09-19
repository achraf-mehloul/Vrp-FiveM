function CreateHeroAura(heroId)
    Citizen.CreateThread(function()
        while currentHero == heroId do
            Citizen.Wait(1000)
            if heroId == 'thor' then
                StartParticleFxLoopedOnEntity('ent_anim_electricity', PlayerPedId(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            elseif heroId == 'thanos' then
                StartParticleFxLoopedOnEntity('ent_anim_purple_energy', PlayerPedId(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            end
        end
    end)
end
