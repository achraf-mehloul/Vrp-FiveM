CREATE TABLE IF NOT EXISTS `heroes_catalog` (
    `hero_id` VARCHAR(50) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `default_energy` INT DEFAULT 100,
    `cooldown_default` INT DEFAULT 5000,
    `cost` DECIMAL(10,2) DEFAULT 0,
    `meta` LONGTEXT,
    PRIMARY KEY (`hero_id`)
);

CREATE TABLE IF NOT EXISTS `player_heroes` (
    `id` INT AUTO_INCREMENT,
    `player_identifier` VARCHAR(64) NOT NULL,
    `hero_id` VARCHAR(50) NOT NULL,
    `unlocked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `level` INT DEFAULT 1,
    `upgrades` LONGTEXT,
    `equipped` BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`hero_id`) REFERENCES `heroes_catalog`(`hero_id`) ON DELETE CASCADE,
    INDEX `idx_player_identifier` (`player_identifier`)
);

CREATE TABLE IF NOT EXISTS `hero_cooldowns` (
    `id` INT AUTO_INCREMENT,
    `player_identifier` VARCHAR(64) NOT NULL,
    `hero_id` VARCHAR(50) NOT NULL,
    `ability_key` VARCHAR(50) NOT NULL,
    `expiry_timestamp` BIGINT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_player_hero` (`player_identifier`, `hero_id`)
);

CREATE TABLE IF NOT EXISTS `hero_stats` (
    `id` INT AUTO_INCREMENT,
    `player_identifier` VARCHAR(64) NOT NULL,
    `hero_id` VARCHAR(50) NOT NULL,
    `uses` INT DEFAULT 0,
    `last_used_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
);
