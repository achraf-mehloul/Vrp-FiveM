QBCore.Commands.Add('sethero', 'منح بطل للاعب', {{name='id', help='Player ID'}, {name='hero', help='Hero ID'}}, true, function(source, args)
    local target = tonumber(args[1])
    local heroId = args[2]
    TriggerEvent('superheroes:adminSetHero', source, target, heroId)
end, 'admin')

QBCore.Commands.Add('resetcooldowns', 'إعادة تعيين التبريد', {{name='id', help='Player ID'}}, true, function(source, args)
    local target = tonumber(args[1])
    TriggerEvent('superheroes:adminResetCooldowns', source, target)
end, 'admin')
