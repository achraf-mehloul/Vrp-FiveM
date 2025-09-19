-- معالج الأحداث من NUI
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'hideMenu'})
    cb('ok')
end)

RegisterNUICallback('buttonAction', function(data, cb)
    local button = data.button
    
    if button == 'map' then
        TriggerEvent('pausemenu:openMap')
    elseif button == 'settings' then
        TriggerEvent('pausemenu:openSettings')
    elseif button == 'shortcuts' then
        TriggerEvent('pausemenu:openShortcuts')
    elseif button == 'frameworks' then
        TriggerEvent('pausemenu:openFrameworks')
    elseif button == 'exit' then
        TriggerServerEvent('pausemenu:disconnect')
    end
    
    cb('ok')
end)

RegisterNUICallback('changeFramerate', function(data, cb)
    TriggerEvent('pausemenu:changeFramerate', data.level)
    cb('ok')
end)

-- طلب تحديث البيانات
RegisterNUICallback('requestDataUpdate', function(data, cb)
    TriggerServerEvent('pausemenu:requestData')
    cb('ok')
end)

-- استقبال البيانات المحدثة من السيرفر
RegisterNetEvent('pausemenu:updateData')
AddEventHandler('pausemenu:updateData', function(data)
    SendNUIMessage({
        action = 'updateData',
        data = data
    })
end)

-- استقبال إعدادات السيرفر
RegisterNetEvent('pausemenu:setServerSettings')
AddEventHandler('pausemenu:setServerSettings', function(settings)
    SendNUIMessage({
        action = 'updateServerSettings',
        data = settings
    })
end)
