BankRepository = {}

function BankRepository:new()
    local instance = {}
    setmetatable(instance, { __index = BankRepository })
    return instance
end

function BankRepository:getAccountByIdentifier(identifier)
    local query = 'SELECT * FROM bank_accounts WHERE identifier = @identifier'
    local parameters = { ['@identifier'] = identifier }
    
    local result = MySQL.Sync.fetchAll(query, parameters)
    return result[1]
end

function BankRepository:getAccountByNumber(accountNumber)
    local query = 'SELECT * FROM bank_accounts WHERE account_number = @account_number'
    local parameters = { ['@account_number'] = accountNumber }
    
    local result = MySQL.Sync.fetchAll(query, parameters)
    return result[1]
end

function BankRepository:createAccount(identifier, accountType)
    local accountNumber = self:generateAccountNumber()
    
    local query = [[
        INSERT INTO bank_accounts (identifier, account_number, account_type, balance)
        VALUES (@identifier, @account_number, @account_type, 0.00)
    ]]
    
    local parameters = {
        ['@identifier'] = identifier,
        ['@account_number'] = accountNumber,
        ['@account_type'] = accountType or 'personal'
    }
    
    local result = MySQL.Sync.execute(query, parameters)
    return result > 0 and accountNumber or nil
end

function BankRepository:updateBalance(accountNumber, amount)
    local query = 'UPDATE bank_accounts SET balance = balance + @amount WHERE account_number = @account_number'
    local parameters = {
        ['@account_number'] = accountNumber,
        ['@amount'] = amount
    }
    
    local result = MySQL.Sync.execute(query, parameters)
    return result > 0
end

function BankRepository:createTransaction(transactionData)
    local transactionId = self:generateTransactionId()
    
    local query = [[
        INSERT INTO bank_transactions 
        (transaction_id, sender_account, receiver_account, amount, transaction_type, description, status)
        VALUES (@transaction_id, @sender_account, @receiver_account, @amount, @transaction_type, @description, @status)
    ]]
    
    local parameters = {
        ['@transaction_id'] = transactionId,
        ['@sender_account'] = transactionData.sender,
        ['@receiver_account'] = transactionData.receiver,
        ['@amount'] = transactionData.amount,
        ['@transaction_type'] = transactionData.type,
        ['@description'] = transactionData.description,
        ['@status'] = transactionData.status or 'pending'
    }
    
    local result = MySQL.Sync.execute(query, parameters)
    return result > 0 and transactionId or nil
end

function BankRepository:getTransactionHistory(accountNumber, limit, offset)
    local query = [[
        SELECT * FROM bank_transactions 
        WHERE sender_account = @account_number OR receiver_account = @account_number
        ORDER BY created_at DESC 
        LIMIT @limit OFFSET @offset
    ]]
    
    local parameters = {
        ['@account_number'] = accountNumber,
        ['@limit'] = limit or 10,
        ['@offset'] = offset or 0
    }
    
    return MySQL.Sync.fetchAll(query, parameters)
end

function BankRepository:generateAccountNumber()
    local accountNumber = nil
    local exists = true
    
    while exists do
        accountNumber = tostring(math.random(10000000, 99999999))
        local query = 'SELECT COUNT(*) as count FROM bank_accounts WHERE account_number = @account_number'
        local result = MySQL.Sync.fetchAll(query, { ['@account_number'] = accountNumber })
        exists = result[1].count > 0
    end
    
    return accountNumber
end

function BankRepository:generateTransactionId()
    return os.time() .. math.random(1000, 9999)
end
