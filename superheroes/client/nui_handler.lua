RegisterNUICallback('buyHero', function(data, cb)
    TriggerServerEvent('superheroes:buyHero', data.heroId)
    cb('ok')
end)

RegisterNUICallback('equipHero', function(data, cb)
    TriggerServerEvent('superheroes:equipHero', data.heroId)
    cb('ok')
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
