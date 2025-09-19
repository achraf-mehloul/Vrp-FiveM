-- Add additional indexes for performance optimization
CREATE INDEX IF NOT EXISTS `transactions_date_index` ON `bank_transactions` (`created_at`);
CREATE INDEX IF NOT EXISTS `transactions_status_index` ON `bank_transactions` (`status`);
CREATE INDEX IF NOT EXISTS `accounts_balance_index` ON `bank_accounts` (`balance`);
CREATE INDEX IF NOT EXISTS `accounts_type_index` ON `bank_accounts` (`account_type`);

-- Create transaction history view
CREATE OR REPLACE VIEW `bank_transaction_history` AS
SELECT 
    t.transaction_id,
    t.sender_account,
    t.receiver_account,
    t.amount,
    t.transaction_type,
    t.description,
    t.status,
    t.created_at,
    t.completed_at,
    s.identifier as sender_identifier,
    r.identifier as receiver_identifier
FROM `bank_transactions` t
LEFT JOIN `bank_accounts` s ON t.sender_account = s.account_number
LEFT JOIN `bank_accounts` r ON t.receiver_account = r.account_number;

-- Create account overview view
CREATE OR REPLACE VIEW `bank_accounts_overview` AS
SELECT 
    a.*,
    COUNT(t.id) as total_transactions,
    SUM(CASE WHEN t.transaction_type = 'deposit' THEN t.amount ELSE 0 END) as total_deposits,
    SUM(CASE WHEN t.transaction_type = 'withdraw' THEN t.amount ELSE 0 END) as total_withdrawals
FROM `bank_accounts` a
LEFT JOIN `bank_transactions` t ON a.account_number = t.sender_account OR a.account_number = t.receiver_account
GROUP BY a.id;
