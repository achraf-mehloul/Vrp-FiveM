ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local bankController = BankController:new()

-- Get player bank balance
ESX.RegisterServerCallback('bank:getBalance', function(source, cb)
    local response = bankController:handleGetBalance(source)
    cb(response.success and response.balance or 0)
end)

-- Transfer money
ESX.RegisterServerCallback('bank:transferMoney', function(source, cb, targetAccount, amount, description)
    local response = bankController:handleTransfer(source, targetAccount, amount, description)
    cb(response.success, response.message, response.new_balance)
end)

-- Deposit money
ESX.RegisterServerCallback('bank:depositMoney', function(source, cb, amount, description)
    local response = bankController:handleDeposit(source, amount, description)
    cb(response.success, response.message, response.new_balance)
end)

-- Withdraw money
ESX.RegisterServerCallback('bank:withdrawMoney', function(source, cb, amount, description)
    local response = bankController:handleWithdraw(source, amount, description)
    cb(response.success, response.message, response.new_balance)
end)

-- Get transaction history
ESX.RegisterServerCallback('bank:getTransactionHistory', function(source, cb, limit, offset)
    local response = bankController:handleGetHistory(source, limit, offset)
    if response.success then
        cb(response.transactions, response.total_count)
    else
        cb({}, 0)
    end
end)

-- Get account information
ESX.RegisterServerCallback('bank:getAccountInfo', function(source, cb)
    local response = bankController:handleGetAccountInfo(source)
    if response.success then
        cb(response.account)
    else
        cb(nil)
    end
end)

-- Event handlers
RegisterNetEvent('bank:server:transfer')
AddEventHandler('bank:server:transfer', function(targetAccount, amount, description)
    local source = source
    local response = bankController:handleTransfer(source, targetAccount, amount, description)
    
    TriggerClientEvent('bank:client:transferResult', source, response.success, response.message)
end)

-- Admin command to check bank balance
ESX.RegisterCommand('bankbalance', 'admin', function(source, args)
    local target = tonumber(args[1]) or source
    local response = bankController:handleGetBalance(target)
    
    if response.success then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'Bank System', 'Balance: $' .. response.balance}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {'Bank System', 'Error: ' .. response.error}
        })
    end
end, false)
