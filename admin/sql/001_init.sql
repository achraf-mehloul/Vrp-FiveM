-- Admin system tables

CREATE TABLE IF NOT EXISTS `admin_users` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(50) NOT NULL,
    `group` VARCHAR(20) NOT NULL DEFAULT 'helper',
    `active` TINYINT(1) NOT NULL DEFAULT 1,
    `added_by` VARCHAR(50) DEFAULT NULL,
    `added_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_by` VARCHAR(50) DEFAULT NULL,
    `updated_at` TIMESTAMP NULL,
    `removed_by` VARCHAR(50) DEFAULT NULL,
    `removed_at` TIMESTAMP NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier_unique` (`identifier`),
    KEY `group_index` (`group`),
    KEY `active_index` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `admin_log` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `admin_identifier` VARCHAR(50) NOT NULL,
    `target_identifier` VARCHAR(50) DEFAULT NULL,
    `action` VARCHAR(50) NOT NULL,
    `details` TEXT DEFAULT NULL,
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `admin_index` (`admin_identifier`),
    KEY `target_index` (`target_identifier`),
    KEY `action_index` (`action`),
    KEY `timestamp_index` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bans` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(50) NOT NULL,
    `license` VARCHAR(50) DEFAULT NULL,
    `discord` VARCHAR(50) DEFAULT NULL,
    `ip` VARCHAR(45) DEFAULT NULL,
    `reason` TEXT NOT NULL,
    `banned_by` VARCHAR(50) NOT NULL,
    `banned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL,
    `unbanned_at` TIMESTAMP NULL,
    `unbanned_by` VARCHAR(50) DEFAULT NULL,
    `active` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `identifier_index` (`identifier`),
    KEY `license_index` (`license`),
    KEY `discord_index` (`discord`),
    KEY `ip_index` (`ip`),
    KEY `active_index` (`active`),
    KEY `expires_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `warnings` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `player_identifier` VARCHAR(50) NOT NULL,
    `admin_identifier` VARCHAR(50) NOT NULL,
    `reason` TEXT NOT NULL,
    `severity` ENUM('low', 'medium', 'high') DEFAULT 'medium',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL,
    `acknowledged` TINYINT(1) DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `player_index` (`player_identifier`),
    KEY `admin_index` (`admin_identifier`),
    KEY `severity_index` (`severity`),
    KEY `expires_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default admin groups
INSERT IGNORE INTO `admin_users` (`identifier`, `group`, `added_by`) VALUES
('steam:110000112345678', 'superadmin', 'system'),
('steam:110000112345679', 'admin', 'system');

-- Create views for easier querying
CREATE OR REPLACE VIEW `active_bans` AS
SELECT * FROM `bans` WHERE `active` = 1 AND (`expires_at` IS NULL OR `expires_at` > NOW());

CREATE OR REPLACE VIEW `active_warnings` AS
SELECT * FROM `warnings` WHERE `expires_at` IS NULL OR `expires_at` > NOW();

CREATE OR REPLACE VIEW `admin_activity` AS
SELECT 
    a.*,
    p.name as admin_name,
    t.name as target_name
FROM `admin_log` a
LEFT JOIN `users` p ON a.admin_identifier = p.identifier
LEFT JOIN `users` t ON a.target_identifier = t.identifier
ORDER BY a.timestamp DESC;
