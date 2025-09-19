BankController = {}

function BankController:new(service)
    local instance = {
        service = service or BankService:new()
    }
    setmetatable(instance, { __index = BankController })
    return instance
end

function BankController:handleGetBalance(playerId)
    local account, err = self.service:getPlayerAccount(playerId)
    if not account then
        return {success = false, error = err}
    end
    
    return {
        success = true,
        balance = account.balance,
        account_number = account.account_number
    }
end

function BankController:handleTransfer(playerId, targetAccountNumber, amount, description)
    local senderAccount, err = self.service:getPlayerAccount(playerId)
    if not senderAccount then
        return {success = false, error = err}
    end
    
    local success, message, transactionId = self.service:transferMoney(
        senderAccount, targetAccountNumber, amount, description
    )
    
    return {
        success = success,
        message = message,
        transaction_id = transactionId,
        new_balance = success and self.service:getBankBalance(senderAccount.account_number) or senderAccount.balance
    }
end

function BankController:handleDeposit(playerId, amount, description)
    local account, err = self.service:getPlayerAccount(playerId)
    if not account then
        return {success = false, error = err}
    end
    
    local success, message = self.service:depositMoney(account.account_number, amount, description)
    
    return {
        success = success,
        message = message,
        new_balance = success and self.service:getBankBalance(account.account_number) or account.balance
    }
end

function BankController:handleWithdraw(playerId, amount, description)
    local account, err = self.service:getPlayerAccount(playerId)
    if not account then
        return {success = false, error = err}
    end
    
    local success, message = self.service:withdrawMoney(account.account_number, amount, description)
    
    return {
        success = success,
        message = message,
        new_balance = success and self.service:getBankBalance(account.account_number) or account.balance
    }
end

function BankController:handleGetHistory(playerId, limit, offset)
    local account, err = self.service:getPlayerAccount(playerId)
    if not account then
        return {success = false, error = err}
    end
    
    local transactions = self.service:getTransactionHistory(account.account_number, limit, offset)
    
    return {
        success = true,
        transactions = transactions,
        total_count = #transactions
    }
end

function BankController:handleGetAccountInfo(playerId)
    local account, err = self.service:getPlayerAccount(playerId)
    if not account then
        return {success = false, error = err}
    end
    
    return {
        success = true,
        account = {
            number = account.account_number,
            balance = account.balance,
            type = account.account_type,
            created_at = account.created_at
        }
    }
end
