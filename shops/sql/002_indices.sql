-- فهارس إضافية لتحسين أداء قاعدة البيانات
CREATE INDEX idx_shop_items_shop_id ON shop_items(shop_id);
CREATE INDEX idx_shop_items_item_name ON shop_items(item_name);
CREATE INDEX idx_shop_items_category ON shop_items(category);
CREATE INDEX idx_shop_items_price ON shop_items(price);

CREATE INDEX idx_shop_transactions_shop_id ON shop_transactions(shop_id);
CREATE INDEX idx_shop_transactions_player_identifier ON shop_transactions(player_identifier);
CREATE INDEX idx_shop_transactions_transaction_date ON shop_transactions(transaction_date);
CREATE INDEX idx_shop_transactions_item_name ON shop_transactions(item_name);
CREATE INDEX idx_shop_transactions_transaction_type ON shop_transactions(transaction_type);

CREATE INDEX idx_shop_employees_shop_id ON shop_employees(shop_id);
CREATE INDEX idx_shop_employees_player_identifier ON shop_employees(player_identifier);
CREATE INDEX idx_shop_employees_role ON shop_employees(role);
CREATE INDEX idx_shop_employees_status ON shop_employees(status);

CREATE INDEX idx_shop_balances_shop_id ON shop_balances(shop_id);

-- إجراءات مساعدة للصيانة
DELIMITER //

CREATE PROCEDURE CleanOldTransactions(IN days_old INT)
BEGIN
    DELETE FROM shop_transactions 
    WHERE transaction_date < DATE_SUB(NOW(), INTERVAL days_old DAY);
END//

CREATE PROCEDURE RestockShopItems(IN shop_id_param INT)
BEGIN
    UPDATE shop_items 
    SET stock = max_stock 
    WHERE shop_id = shop_id_param AND stock < max_stock;
END//

CREATE PROCEDURE GetShopInventory(IN shop_id_param INT)
BEGIN
    SELECT si.item_name, si.price, si.stock, si.max_stock, si.category
    FROM shop_items si
    WHERE si.shop_id = shop_id_param
    ORDER BY si.category, si.item_name;
END//

CREATE PROCEDURE GetShopSalesReport(IN shop_id_param INT, IN start_date DATE, IN end_date DATE)
BEGIN
    SELECT 
        item_name,
        item_label,
        SUM(quantity) as total_quantity,
        SUM(total_price) as total_revenue,
        AVG(unit_price) as average_price
    FROM shop_transactions
    WHERE shop_id = shop_id_param 
    AND transaction_date BETWEEN start_date AND end_date
    AND transaction_type = 'purchase'
    GROUP BY item_name, item_label
    ORDER BY total_revenue DESC;
END//

DELIMITER ;

-- أحداث مجدولة للصيانة التلقائية
CREATE EVENT IF NOT EXISTS CleanupOldTransactions
ON SCHEDULE EVERY 1 WEEK
DO
    CALL CleanOldTransactions(30);

CREATE EVENT IF NOT EXISTS DailyRestock
ON SCHEDULE EVERY 1 DAY
DO
    CALL RestockShopItems(1);

-- تحديث الإحصائيات
CREATE TABLE IF NOT EXISTS `shop_statistics` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `shop_id` INT(11) NOT NULL,
    `total_sales` DECIMAL(15,2) DEFAULT 0.00,
    `total_transactions` INT(11) DEFAULT 0,
    `unique_customers` INT(11) DEFAULT 0,
    `most_popular_item` VARCHAR(255) DEFAULT NULL,
    `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- إدخال الإحصائيات الأولية
INSERT IGNORE INTO `shop_statistics` (`shop_id`, `total_sales`, `total_transactions`, `unique_customers`) VALUES
(1, 0.00, 0, 0),
(2, 0.00, 0, 0),
(3, 0.00, 0, 0),
(4, 0.00, 0, 0),
(5, 0.00, 0, 0),
(6, 0.00, 0, 0),
(7, 0.00, 0, 0),
(8, 0.00, 0, 0);

-- إجراءات إضافية للإدارة
DELIMITER //

CREATE PROCEDURE GetShopPerformance(IN shop_id_param INT)
BEGIN
    SELECT 
        s.name as shop_name,
        s.type as shop_type,
        COALESCE(ss.total_sales, 0) as total_sales,
        COALESCE(ss.total_transactions, 0) as total_transactions,
        COALESCE(ss.unique_customers, 0) as unique_customers,
        ss.most_popular_item,
        COUNT(si.id) as total_items,
        SUM(si.stock) as total_stock,
        AVG(si.price) as average_price
    FROM shops s
    LEFT JOIN shop_statistics ss ON s.id = ss.shop_id
    LEFT JOIN shop_items si ON s.id = si.shop_id
    WHERE s.id = shop_id_param
    GROUP BY s.id;
END//

CREATE PROCEDURE GetTopSellingItems(IN shop_id_param INT, IN limit_count INT)
BEGIN
    SELECT 
        item_name,
        item_label,
        SUM(quantity) as total_sold,
        SUM(total_price) as total_revenue,
        AVG(unit_price) as average_price
    FROM shop_transactions
    WHERE shop_id = shop_id_param
    AND transaction_type = 'purchase'
    GROUP BY item_name, item_label
    ORDER BY total_sold DESC
    LIMIT limit_count;
END//

CREATE PROCEDURE GetCustomerHistory(IN player_identifier_param VARCHAR(255))
BEGIN
    SELECT 
        s.name as shop_name,
        st.item_name,
        st.item_label,
        SUM(st.quantity) as total_purchased,
        SUM(st.total_price) as total_spent,
        MAX(st.transaction_date) as last_purchase
    FROM shop_transactions st
    JOIN shops s ON st.shop_id = s.id
    WHERE st.player_identifier = player_identifier_param
    GROUP BY st.shop_id, st.item_name
    ORDER BY last_purchase DESC;
END//

DELIMITER ;

-- تحديث الجداول بإضافة الحقول الجديدة
ALTER TABLE `shops` 
ADD COLUMN IF NOT EXISTS `blip_enabled` TINYINT(1) DEFAULT 1 AFTER `location`,
ADD COLUMN IF NOT EXISTS `marker_enabled` TINYINT(1) DEFAULT 1 AFTER `blip_enabled`,
ADD COLUMN IF NOT EXISTS `open_hour` INT(2) DEFAULT 9 AFTER `marker_enabled`,
ADD COLUMN IF NOT EXISTS `close_hour` INT(2) DEFAULT 21 AFTER `open_hour`;

ALTER TABLE `shop_items`
ADD COLUMN IF NOT EXISTS `label` VARCHAR(255) AFTER `item_name`,
ADD COLUMN IF NOT EXISTS `weight` DECIMAL(8,2) DEFAULT 0.1 AFTER `max_stock`,
ADD COLUMN IF NOT EXISTS `metadata` TEXT AFTER `weight`;

-- تحديث البيانات الموجودة
UPDATE `shops` SET 
blip_enabled = 1,
marker_enabled = 1,
open_hour = 9,
close_hour = 21
WHERE blip_enabled IS NULL;

UPDATE `shop_items` si
JOIN (
    SELECT 'WEAPON_PISTOL' as item_name, 'مسدس عادي' as label, 1.0 as weight UNION
    SELECT 'WEAPON_COMBATPISTOL', 'مسدس قتالي', 1.1 UNION
    SELECT 'WEAPON_APPISTOL', 'مسدس AP', 1.2 UNION
    SELECT 'WEAPON_REVOLVER', 'مسدس دوار', 1.3 UNION
    SELECT 'WEAPON_SNSPISTOL', 'مسدس SNS', 0.9 UNION
    SELECT 'WEAPON_KNIFE', 'سكين حاد', 0.5 UNION
    SELECT 'WEAPON_BAT', 'مضرب بيسبول', 1.2 UNION
    SELECT 'WEAPON_MICROSMG', 'ميكرو SMG', 3.5 UNION
    SELECT 'WEAPON_ASSAULTRIFLE', 'بندقية هجومية', 4.2 UNION
    SELECT 'WEAPON_PUMPSHOTGUN', 'بندقية صيد', 3.8 UNION
    SELECT 'WEAPON_ASSAULTSMG', 'بندقية رشاشة', 3.0 UNION
    SELECT 'WEAPON_CARBINERIFLE', 'بندقية كاربين', 4.0 UNION
    SELECT 'WEAPON_SPECIALCARBINE', 'بندقية خاصة', 4.1 UNION
    SELECT 'WEAPON_BULLPUPRIFLE', 'بندقية بولتاب', 4.3 UNION
    SELECT 'WEAPON_SNIPERRIFLE', 'بندقية قنص', 5.0 UNION
    SELECT 'ammo_pistol', 'ذخيرة مسدس', 0.1 UNION
    SELECT 'ammo_rifle', 'ذخيرة بندقية', 0.2 UNION
    SELECT 'ammo_shotgun', 'ذخيرة بندقية صيد', 0.3 UNION
    SELECT 'ammo_smg', 'ذخيرة SMG', 0.2 UNION
    SELECT 'bread', 'خبز طازج', 0.2 UNION
    SELECT 'water', 'ماء معدني', 0.5 UNION
    SELECT 'burger', 'برغر لذيذ', 0.3 UNION
    SELECT 'sandwich', 'ساندويتش', 0.25 UNION
    SELECT 'chips', 'رقائق بطاطس', 0.15 UNION
    SELECT 'chocolate', 'شوكولاتة', 0.1 UNION
    SELECT 'soda', 'مشروب غازي', 0.4 UNION
    SELECT 'coffee', 'قهوة ساخنة', 0.3 UNION
    SELECT 'milk', 'حليب طازج', 0.6 UNION
    SELECT 'apple', 'تفاح طازج', 0.1 UNION
    SELECT 'orange', 'برتقال', 0.1 UNION
    SELECT 'banana', 'موز', 0.1 UNION
    SELECT 'pizza', 'بيتزا', 0.8 UNION
    SELECT 'donut', 'دونات', 0.1 UNION
    SELECT 'icecream', 'آيس كريم', 0.3 UNION
    SELECT 'hotdog', 'هوت دوغ', 0.3 UNION
    SELECT 'taco', 'تاكو', 0.3 UNION
    SELECT 'sushi', 'سوشي', 0.4 UNION
    SELECT 'steak', 'ستيك', 0.7 UNION
    SELECT 'salad', 'سلطة', 0.3
) AS item_data ON si.item_name = item_data.item_name
SET si.label = item_data.label, si.weight = item_data.weight
WHERE si.label IS NULL;

-- إنشاء جدول سلة التسوق
CREATE TABLE IF NOT EXISTS `shop_carts` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `player_identifier` VARCHAR(255) NOT NULL,
    `shop_id` INT(11) NOT NULL,
    `items` TEXT NOT NULL,
    `total_amount` DECIMAL(12,2) DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_player_shop` (`player_identifier`, `shop_id`),
    KEY `idx_player` (`player_identifier`),
    KEY `idx_shop` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- إضافة حقول الخصم والضريبة
ALTER TABLE `shop_transactions`
ADD COLUMN IF NOT EXISTS `discount_amount` DECIMAL(12,2) DEFAULT 0 AFTER `total_price`,
ADD COLUMN IF NOT EXISTS `tax_amount` DECIMAL(12,2) DEFAULT 0 AFTER `discount_amount`,
ADD COLUMN IF NOT EXISTS `final_price` DECIMAL(12,2) AFTER `tax_amount`,
ADD COLUMN IF NOT EXISTS `metadata` TEXT AFTER `final_price`;

-- تحديث المعاملات القديمة
UPDATE `shop_transactions` 
SET final_price = total_price 
WHERE final_price IS NULL;

print('^2[Shops] تم تنفيذ استعلامات SQL بنجاح^0');
