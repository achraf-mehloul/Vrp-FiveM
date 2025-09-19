CREATE TABLE IF NOT EXISTS `bank_accounts` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(50) NOT NULL,
    `account_number` VARCHAR(20) NOT NULL UNIQUE,
    `balance` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `account_type` VARCHAR(20) DEFAULT 'personal',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `identifier_index` (`identifier`),
    INDEX `account_number_index` (`account_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bank_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `transaction_id` VARCHAR(30) NOT NULL UNIQUE,
    `sender_account` VARCHAR(20) NOT NULL,
    `receiver_account` VARCHAR(20) NOT NULL,
    `amount` DECIMAL(10,2) NOT NULL,
    `transaction_type` VARCHAR(20) NOT NULL,
    `description` TEXT,
    `status` VARCHAR(20) DEFAULT 'pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL,
    PRIMARY KEY (`id`),
    INDEX `sender_index` (`sender_account`),
    INDEX `receiver_index` (`receiver_account`),
    INDEX `transaction_id_index` (`transaction_id`),
    INDEX `type_index` (`transaction_type`),
    FOREIGN KEY (`sender_account`) REFERENCES `bank_accounts`(`account_number`),
    FOREIGN KEY (`receiver_account`) REFERENCES `bank_accounts`(`account_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bank_cards` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `account_number` VARCHAR(20) NOT NULL,
    `card_number` VARCHAR(16) NOT NULL UNIQUE,
    `card_holder` VARCHAR(100) NOT NULL,
    `expiry_date` VARCHAR(5) NOT NULL,
    `cvv` VARCHAR(3) NOT NULL,
    `pin` VARCHAR(4) NOT NULL,
    `active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `blocked_at` TIMESTAMP NULL,
    PRIMARY KEY (`id`),
    INDEX `account_index` (`account_number`),
    INDEX `card_number_index` (`card_number`),
    FOREIGN KEY (`account_number`) REFERENCES `bank_accounts`(`account_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bank_loans` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `account_number` VARCHAR(20) NOT NULL,
    `loan_amount` DECIMAL(10,2) NOT NULL,
    `remaining_amount` DECIMAL(10,2) NOT NULL,
    `interest_rate` DECIMAL(5,2) NOT NULL,
    `installment_amount` DECIMAL(10,2) NOT NULL,
    `total_installments` INT(5) NOT NULL,
    `remaining_installments` INT(5) NOT NULL,
    `status` VARCHAR(20) DEFAULT 'active',
    `next_payment_date` DATE NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `account_index` (`account_number`),
    FOREIGN KEY (`account_number`) REFERENCES `bank_accounts`(`account_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
