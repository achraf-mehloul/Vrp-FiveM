-- Additional indexes for performance optimization

-- Add composite indexes for better query performance
CREATE INDEX IF NOT EXISTS `ban_identifier_active` ON `bans` (`identifier`, `active`);
CREATE INDEX IF NOT EXISTS `ban_expires_active` ON `bans` (`expires_at`, `active`);
CREATE INDEX IF NOT EXISTS `admin_log_timestamp_action` ON `admin_log` (`timestamp`, `action`);
CREATE INDEX IF NOT EXISTS `warnings_player_expires` ON `warnings` (`player_identifier`, `expires_at`);

-- Add fulltext indexes for search functionality
ALTER TABLE `bans` ADD FULLTEXT INDEX `ft_reason` (`reason`);
ALTER TABLE `warnings` ADD FULLTEXT INDEX `ft_reason` (`reason`);
ALTER TABLE `admin_log` ADD FULLTEXT INDEX `ft_details` (`details`);

-- Create stored procedures for common operations

DELIMITER //

CREATE PROCEDURE `GetPlayerBans`(IN player_identifier VARCHAR(50))
BEGIN
    SELECT * FROM `bans` 
    WHERE (`identifier` = player_identifier OR `license` = player_identifier OR `discord` = player_identifier OR `ip` = player_identifier)
    AND `active` = 1
    ORDER BY `banned_at` DESC;
END //

CREATE PROCEDURE `GetPlayerWarnings`(IN player_identifier VARCHAR(50))
BEGIN
    SELECT * FROM `warnings` 
    WHERE `player_identifier` = player_identifier 
    AND (`expires_at` IS NULL OR `expires_at` > NOW())
    ORDER BY `created_at` DESC;
END //

CREATE PROCEDURE `GetAdminActions`(IN admin_identifier VARCHAR(50), IN limit_count INT, IN offset_count INT)
BEGIN
    SELECT * FROM `admin_log` 
    WHERE `admin_identifier` = admin_identifier 
    ORDER BY `timestamp` DESC 
    LIMIT limit_count OFFSET offset_count;
END //

CREATE PROCEDURE `SearchBans`(IN search_term VARCHAR(100))
BEGIN
    SELECT * FROM `bans` 
    WHERE `identifier` LIKE CONCAT('%', search_term, '%')
    OR `reason` LIKE CONCAT('%', search_term, '%')
    OR `banned_by` LIKE CONCAT('%', search_term, '%')
    ORDER BY `banned_at` DESC
    LIMIT 50;
END //

DELIMITER ;

-- Create triggers for automatic logging

DELIMITER //

CREATE TRIGGER `after_ban_insert`
AFTER INSERT ON `bans`
FOR EACH ROW
BEGIN
    INSERT INTO `admin_log` (`admin_identifier`, `target_identifier`, `action`, `details`)
    VALUES (NEW.banned_by, NEW.identifier, 'ban', 
            JSON_OBJECT('reason', NEW.reason, 'duration', TIMESTAMPDIFF(DAY, NEW.banned_at, NEW.expires_at)));
END //

CREATE TRIGGER `after_warning_insert`
AFTER INSERT ON `warnings`
FOR EACH ROW
BEGIN
    INSERT INTO `admin_log` (`admin_identifier`, `target_identifier`, `action`, `details`)
    VALUES (NEW.admin_identifier, NEW.player_identifier, 'warning', 
            JSON_OBJECT('reason', NEW.reason, 'severity', NEW.severity));
END //

DELIMITER ;

-- Create event for cleaning up expired records
CREATE EVENT IF NOT EXISTS `cleanup_expired_records`
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    -- Deactivate expired bans
    UPDATE `bans` SET `active` = 0 
    WHERE `active` = 1 AND `expires_at` IS NOT NULL AND `expires_at` <= NOW();
    
    -- Delete very old log entries (older than 90 days)
    DELETE FROM `admin_log` WHERE `timestamp` < DATE_SUB(NOW(), INTERVAL 90 DAY);
    
    -- Delete expired warnings
    DELETE FROM `warnings` WHERE `expires_at` IS NOT NULL AND `expires_at` <= NOW();
END;
