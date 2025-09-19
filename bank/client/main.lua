local inBankZone = false
local currentBank = nil
local playerAccounts = {}
local bankBlips = {}

-- Create bank blips
Citizen.CreateThread(function()
    for _, bank in ipairs(Config.Bank.BankLocations) do
        if bank.blip then
            local blip = AddBlipForCoord(bank.coords.x, bank.coords.y, bank.coords.z)
            SetBlipSprite(blip, bank.blip.sprite or 434)
            SetBlipColour(blip, bank.blip.color or 2)
            SetBlipScale(blip, bank.blip.scale or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(bank.blip.name or "Bank")
            EndTextCommandSetBlipName(blip)
            table.insert(bankBlips, blip)
        end
    end
end)

-- Check bank proximity
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        inBankZone = false
        currentBank = nil
        
        for _, bank in ipairs(Config.Bank.BankLocations) do
            local distance = #(playerCoords - bank.coords)
            if distance < 3.0 then
                inBankZone = true
                currentBank = bank
                break
            end
        end
    end
end)

-- Draw markers and handle interactions
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, bank in ipairs(Config.Bank.BankLocations) do
            local distance = #(playerCoords - bank.coords)
            
            -- Draw marker
            if distance < 20.0 then
                DrawMarker(
                    27, -- type
                    bank.coords.x, bank.coords.y, bank.coords.z - 0.98, -- position
                    0.0, 0.0, 0.0, -- direction
                    0.0, 0.0, 0.0, -- rotation
                    1.5, 1.5, 1.5, -- scale
                    50, 205, 50, 100, -- color (green)
                    false, -- bob
                    true, -- face camera
                    2, -- rotate
                    false, -- texture
                    false, -- project on entities
                    false -- draw on entities
                )
            end
            
            -- Show help text and handle interaction
            if distance < 1.5 then
                ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to access the bank")
                
                if IsControlJustReleased(0, 38) then -- E key
                    OpenBankMenu()
                end
            end
        end
    end
end)

-- Open bank menu
function OpenBankMenu()
    if not inBankZone then
        ShowNotification(Config.NotificationMessages.not_in_bank, 'error')
        return
    end
    
    ESX.TriggerServerCallback('bank:getAccountInfo', function(accountInfo)
        if not accountInfo then
            ShowNotification(Config.NotificationMessages.account_error, 'error')
            return
        end
        
        ESX.TriggerServerCallback('bank:getTransactionHistory', function(transactions, totalCount)
            SendNUIMessage({
                type = 'openBank',
                account = accountInfo,
                transactions = transactions,
                config = Config.Bank
            })
            SetNuiFocus(true, true)
        end, 10, 0)
    end)
end

-- Show notification
function ShowNotification(message, type)
    ESX.ShowNotification(message)
    
    -- Also send to NUI for consistent styling
    SendNUIMessage({
        type = 'showNotification',
        message = message,
        notificationType = type or 'info',
        duration = 3000
    })
end

-- NUI callbacks
RegisterNUICallback('closeBank', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('transferMoney', function(data, cb)
    ESX.TriggerServerCallback('bank:transferMoney', function(success, message, newBalance)
        if success then
            ShowNotification(message, 'success')
            -- Update balance in UI
            SendNUIMessage({
                type = 'updateBalance',
                balance = newBalance
            })
        else
            ShowNotification(message, 'error')
        end
        cb({success = success, message = message})
    end, data.targetAccount, data.amount, data.description)
end)

RegisterNUICallback('depositMoney', function(data, cb)
    ESX.TriggerServerCallback('bank:depositMoney', function(success, message, newBalance)
        if success then
            ShowNotification(message, 'success')
            SendNUIMessage({
                type = 'updateBalance',
                balance = newBalance
            })
        else
            ShowNotification(message, 'error')
        end
        cb({success = success, message = message})
    end, data.amount, data.description)
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    ESX.TriggerServerCallback('bank:withdrawMoney', function(success, message, newBalance)
        if success then
            ShowNotification(message, 'success')
            SendNUIMessage({
                type = 'updateBalance',
                balance = newBalance
            })
        else
            ShowNotification(message, 'error')
        end
        cb({success = success, message = message})
    end, data.amount, data.description)
end)

RegisterNUICallback('loadMoreTransactions', function(data, cb)
    ESX.TriggerServerCallback('bank:getTransactionHistory', function(transactions, totalCount)
        cb({
            transactions = transactions,
            totalCount = totalCount,
            hasMore = #transactions >= (data.limit or 10)
        })
    end, data.limit, data.offset)
end)

-- Bank commands
RegisterCommand('bank', function()
    OpenBankMenu()
end, false)

RegisterCommand('bankbalance', function()
    ESX.TriggerServerCallback('bank:getBalance', function(balance)
        ShowNotification('Your balance: $' .. balance, 'info')
    end)
end, false)

-- Key mapping
RegisterKeyMapping('bank', 'Open Bank Menu', 'keyboard', 'f6')

-- Event handlers
RegisterNetEvent('bank:client:transferResult')
AddEventHandler('bank:client:transferResult', function(success, message)
    ShowNotification(message, success and 'success' or 'error')
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    if account.name == 'bank' then
        SendNUIMessage({
            type = 'updateBalance',
            balance = account.money
        })
    end
end)

-- Export functions
exports('OpenBankMenu', OpenBankMenu)
exports('GetBankBalance', function()
    ESX.TriggerServerCallback('bank:getBalance', function(balance)
        return balance
    end)
    return 0
end)
