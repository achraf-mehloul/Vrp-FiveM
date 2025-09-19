CREATE INDEX `idx_hero_cooldowns` ON `hero_cooldowns` (`player_identifier`, `hero_id`, `ability_key`);
CREATE INDEX `idx_hero_stats` ON `hero_stats` (`player_identifier`, `hero_id`);
