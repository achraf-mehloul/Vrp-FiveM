BankService = {}

function BankService:new(repository)
    local instance = {
        repository = repository or BankRepository:new()
    }
    setmetatable(instance, { __index = BankService })
    return instance
end

function BankService:getPlayerAccount(playerId)
    local identifier = GetPlayerIdentifier(playerId)
    if not identifier then
        return nil, "Player identifier not found"
    end
    
    local account = self.repository:getAccountByIdentifier(identifier)
    if not account then
        local accountNumber = self.repository:createAccount(identifier)
        if not accountNumber then
            return nil, "Failed to create account"
        end
        account = self.repository:getAccountByNumber(accountNumber)
    end
    
    return account, nil
end

function BankService:transferMoney(senderAccount, receiverAccountNumber, amount, description)
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false, "Invalid amount"
    end
    
    -- Get receiver account
    local receiverAccount = self.repository:getAccountByNumber(receiverAccountNumber)
    if not receiverAccount then
        return false, "Receiver account not found"
    end
    
    -- Check sender balance
    if senderAccount.balance < amount then
        return false, "Insufficient funds"
    end
    
    -- Calculate fee
    local fee = amount * Config.Bank.TransactionSettings.transferFee
    local totalAmount = amount + fee
    
    -- Start transaction
    MySQL.Sync.execute('START TRANSACTION')
    
    try {
        function()
            -- Deduct from sender
            local success = self.repository:updateBalance(senderAccount.account_number, -totalAmount)
            if not success then
                error("Failed to deduct from sender")
            end
            
            -- Add to receiver
            success = self.repository:updateBalance(receiverAccountNumber, amount)
            if not success then
                error("Failed to add to receiver")
            end
            
            -- Record transaction
            local transactionData = {
                sender = senderAccount.account_number,
                receiver = receiverAccountNumber,
                amount = amount,
                type = "transfer",
                description = description or "Money transfer",
                status = "completed"
            }
            
            local transactionId = self.repository:createTransaction(transactionData)
            if not transactionId then
                error("Failed to record transaction")
            end
            
            MySQL.Sync.execute('COMMIT')
            return true, "Transfer successful", transactionId
        end,
        catch = function(error)
            MySQL.Sync.execute('ROLLBACK')
            return false, "Transfer failed: " .. tostring(error)
        end
    }
end

function BankService:depositMoney(accountNumber, amount, description)
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false, "Invalid amount"
    end
    
    local success = self.repository:updateBalance(accountNumber, amount)
    if not success then
        return false, "Deposit failed"
    end
    
    local transactionData = {
        sender = "CASH_DEPOSIT",
        receiver = accountNumber,
        amount = amount,
        type = "deposit",
        description = description or "Cash deposit",
        status = "completed"
    }
    
    self.repository:createTransaction(transactionData)
    return true, "Deposit successful"
end

function BankService:withdrawMoney(accountNumber, amount, description)
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false, "Invalid amount"
    end
    
    local account = self.repository:getAccountByNumber(accountNumber)
    if not account then
        return false, "Account not found"
    end
    
    if account.balance < amount then
        return false, "Insufficient funds"
    end
    
    local success = self.repository:updateBalance(accountNumber, -amount)
    if not success then
        return false, "Withdrawal failed"
    end
    
    local transactionData = {
        sender = accountNumber,
        receiver = "CASH_WITHDRAWAL",
        amount = amount,
        type = "withdraw",
        description = description or "Cash withdrawal",
        status = "completed"
    }
    
    self.repository:createTransaction(transactionData)
    return true, "Withdrawal successful"
end

function BankService:getTransactionHistory(accountNumber, limit, offset)
    return self.repository:getTransactionHistory(accountNumber, limit, offset)
end

function BankService:getBankBalance(accountNumber)
    local account = self.repository:getAccountByNumber(accountNumber)
    return account and account.balance or 0
end
