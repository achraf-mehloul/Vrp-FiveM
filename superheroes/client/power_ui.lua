local energy = 100
local maxEnergy = 100
local showUI = false

function DrawEnergyBar()
    if not showUI then return end

    DrawRect(0.15, 0.95, 0.2, 0.03, 0, 0, 0, 150)
    DrawRect(0.15, 0.95, (energy/maxEnergy)*0.2, 0.025, 0, 255, 255, 200)
    
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry('STRING')
    AddTextComponentString('الطاقة: ' .. math.floor(energy) .. '%')
    DrawText(0.05, 0.94)
end

-- تحديث الطاقة
RegisterNetEvent('superheroes:updateEnergy')
AddEventHandler('superheroes:updateEnergy', function(newEnergy)
    energy = newEnergy
end)

-- عرض/إخفاء الواجهة
RegisterNetEvent('superheroes:toggleEnergyUI')
AddEventHandler('superheroes:toggleEnergyUI', function(show)
    showUI = show
end)

-- الرسم المستمر
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        DrawEnergyBar()
    end
end)
