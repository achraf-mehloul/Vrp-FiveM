-- نظام المحلات - قاعدة البيانات
CREATE TABLE IF NOT EXISTS `shops` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `location` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_items` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `shop_id` INT(11) NOT NULL,
  `item_name` VARCHAR(255) NOT NULL,
  `price` DECIMAL(12,2) NOT NULL,
  `stock` INT(11) NOT NULL DEFAULT 0,
  `max_stock` INT(11) NOT NULL DEFAULT 100,
  `category` VARCHAR(100) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `shop_id` (`shop_id`),
  KEY `item_name` (`item_name`),
  KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_transactions` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `shop_id` INT(11) NOT NULL,
  `player_identifier` VARCHAR(255) NOT NULL,
  `player_name` VARCHAR(255) DEFAULT NULL,
  `item_name` VARCHAR(255) NOT NULL,
  `item_label` VARCHAR(255) NOT NULL,
  `quantity` INT(11) NOT NULL,
  `unit_price` DECIMAL(12,2) NOT NULL,
  `total_price` DECIMAL(12,2) NOT NULL,
  `transaction_type` ENUM('purchase', 'restock', 'refund') DEFAULT 'purchase',
  `transaction_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `shop_id` (`shop_id`),
  KEY `player_identifier` (`player_identifier`),
  KEY `transaction_date` (`transaction_date`),
  KEY `item_name` (`item_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_balances` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `shop_id` INT(11) NOT NULL,
  `balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `shop_employees` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `shop_id` INT(11) NOT NULL,
  `player_identifier` VARCHAR(255) NOT NULL,
  `player_name` VARCHAR(255) NOT NULL,
  `role` ENUM('owner', 'manager', 'employee') DEFAULT 'employee',
  `salary` DECIMAL(10,2) DEFAULT 0.00,
  `hire_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `shop_id` (`shop_id`),
  KEY `player_identifier` (`player_identifier`),
  KEY `role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- إدخال البيانات الأولية للمتاجر
INSERT INTO `shops` (`id`, `name`, `type`, `location`) VALUES
(1, 'متجر الأسلحة المتقدم', 'weapon', '{"x":16.61,"y":-1120.68,"z":28.8}'),
(2, 'معرض السيارات الفاخرة', 'vehicle', '{"x":-33.83,"y":-1102.29,"z":25.42}'),
(3, 'سوبر ماركت المدينة', 'food', '{"x":374.34,"y":327.91,"z":102.56}'),
(4, 'بوتيك الأزياء الراقية', 'clothing', '{"x":72.3,"y":-1399.1,"z":28.4}'),
(5, 'صيدلية العائلة', 'pharmacy', '{"x":318.5,"y":-1078.6,"z":28.4}'),
(6, 'متجر التكنولوجيا الحديثة', 'electronics', '{"x":-658.87,"y":-857.15,"z":23.5}'),
(7, 'صالون الحلاقة الفاخر', 'barber', '{"x":-278.15,"y":6228.52,"z":30.7}'),
(8, 'مجوهرات الثريا', 'jewelry', '{"x":-622.24,"y":-230.88,"z":37.06}');

-- إدخال العناصر لكل متجر
-- متجر الأسلحة (ID: 1)
INSERT INTO `shop_items` (`shop_id`, `item_name`, `price`, `stock`, `max_stock`, `category`) VALUES
(1, 'WEAPON_PISTOL', 5000.00, 15, 30, 'مسدسات'),
(1, 'WEAPON_COMBATPISTOL', 7500.00, 10, 25, 'مسدسات'),
(1, 'WEAPON_APPISTOL', 12000.00, 8, 20, 'مسدسات'),
(1, 'WEAPON_REVOLVER', 8500.00, 7, 15, 'مسدسات'),
(1, 'WEAPON_SNSPISTOL', 6000.00, 12, 25, 'مسدسات'),
(1, 'WEAPON_KNIFE', 1000.00, 25, 50, 'أسلحة بيضاء'),
(1, 'WEAPON_BAT', 800.00, 20, 40, 'أسلحة بيضاء'),
(1, 'WEAPON_MICROSMG', 25000.00, 5, 10, 'رشاشات'),
(1, 'WEAPON_ASSAULTRIFLE', 45000.00, 3, 8, 'بنادق'),
(1, 'WEAPON_PUMPSHOTGUN', 18000.00, 6, 12, 'بنادق'),
(1, 'WEAPON_ASSAULTSMG', 5500.00, 8, 20, 'رشاشات'),
(1, 'WEAPON_CARBINERIFLE', 65000.00, 4, 10, 'بنادق'),
(1, 'WEAPON_SPECIALCARBINE', 75000.00, 3, 8, 'بنادق'),
(1, 'WEAPON_BULLPUPRIFLE', 85000.00, 3, 8, 'بنادق'),
(1, 'WEAPON_SNIPERRIFLE', 120000.00, 2, 5, 'بنادق'),
(1, 'ammo_pistol', 50.00, 100, 500, 'ذخيرة'),
(1, 'ammo_rifle', 100.00, 80, 400, 'ذخيرة'),
(1, 'ammo_shotgun', 150.00, 60, 300, 'ذخيرة'),
(1, 'ammo_smg', 80.00, 90, 450, 'ذخيرة');

-- معرض السيارات (ID: 2)
INSERT INTO `shop_items` (`shop_id`, `item_name`, `price`, `stock`, `max_stock`, `category`) VALUES
(2, 'sultan', 150000.00, 5, 10, 'رياضية'),
(2, 'adder', 1000000.00, 2, 5, 'فائقة'),
(2, 'banshee', 105000.00, 3, 8, 'رياضية'),
(2, 'bullet', 155000.00, 4, 8, 'فائقة'),
(2, 'cheetah', 950000.00, 2, 4, 'فائقة'),
(2, 'comet2', 125000.00, 6, 12, 'رياضية'),
(2, 'elegy2', 135000.00, 5, 10, 'رياضية'),
(2, 'feltzer2', 145000.00, 4, 8, 'رياضية'),
(2, 'jester', 165000.00, 4, 8, 'رياضية'),
(2, 'massacro', 175000.00, 3, 6, 'رياضية'),
(2, 'turismo2', 850000.00, 2, 4, 'فائقة'),
(2, 'zentorno', 950000.00, 2, 4, 'فائقة'),
(2, 'nero', 880000.00, 3, 6, 'فائقة'),
(2, 'vagner', 920000.00, 2, 4, 'فائقة'),
(2, 'xa21', 970000.00, 2, 4, 'فائقة'),
(2, 'cyclone', 1100000.00, 1, 2, 'فائقة'),
(2, 'visione', 1250000.00, 1, 2, 'فائقة'),
(2, 'sc1', 980000.00, 2, 4, 'فائقة'),
(2, 'autarch', 1050000.00, 1, 2, 'فائقة'),
(2, 'tyrant', 1150000.00, 1, 2, 'فائقة');

-- سوبر ماركت (ID: 3)
INSERT INTO `shop_items` (`shop_id`, `item_name`, `price`, `stock`, `max_stock`, `category`) VALUES
(3, 'bread', 10.00, 100, 300, 'مخبوزات'),
(3, 'water', 5.00, 200, 600, 'مشروبات'),
(3, 'burger', 25.00, 50, 150, 'وجبات'),
(3, 'sandwich', 15.00, 70, 200, 'وجبات'),
(3, 'chips', 8.00, 120, 400, ' snacks'),
(3, 'chocolate', 12.00, 90, 300, 'حلويات'),
(3, 'soda', 7.00, 150, 500, 'مشروبات'),
(3, 'coffee', 10.00, 80, 250, 'مشروبات'),
(3, 'milk', 8.00, 60, 200, 'مشتقات الحليب'),
(3, 'apple', 4.00, 200, 600, 'فواكه'),
(3, 'orange', 4.00, 180, 500, 'فواكه'),
(3, 'banana', 3.00, 160, 500, 'فواكه'),
(3, 'pizza', 35.00, 40, 120, 'وجبات'),
(3, 'donut', 6.00, 100, 300, 'حلويات'),
(3, 'icecream', 15.00, 60, 200, 'حلويات'),
(3, 'hotdog', 20.00, 80, 250, 'وجبات'),
(3, 'taco', 18.00, 70, 200, 'وجبات'),
(3, 'sushi', 45.00, 30, 100, 'وجبات'),
(3, 'steak', 60.00, 25, 80, 'وجبات'),
(3, 'salad', 15.00, 50, 150, 'وجبات');

-- متجر الملابس (ID: 4)
INSERT INTO `shop_items` (`shop_id`, `item_name`, `price`, `stock`, `max_stock`, `category`) VALUES
(4, 'tshirt', 50.00, 100, 300, 'ملابس علوية'),
(4, 'jeans', 80.00, 80, 250, 'ملابس سفلية'),
(4, 'shoes', 120.00, 60, 200, 'أحذية'),
(4, 'jacket', 200.00, 40, 100, 'ملابس علوية'),
(4, 'hat', 30.00, 70, 200, 'إكسسوارات'),
(4, 'glasses', 75.00, 50, 150, 'إكسسوارات'),
(4, 'watch', 150.00, 30, 100, 'إكسسوارات'),
(4, 'dress', 250.00, 25, 80, 'ملابس نسائية'),
(4, 'suit', 500.00, 20, 50, 'ملابس رسمية'),
(4, 'boots', 180.00, 35, 100, 'أحذية'),
(4, 'gloves', 40.00, 45, 120, 'إكسسوارات'),
(4, 'scarf', 35.00, 55, 150, 'إكسسوارات'),
(4, 'belt', 25.00, 65, 200, 'إكسسوارات'),
(4, 'bag', 120.00, 40, 100, 'إكسسوارات'),
(4, 'ring', 80.00, 50, 150, 'إكسسوارات');

-- صيدلية (ID: 5)
INSERT INTO `shop_items` (`shop_id`, `item_name`, `price`, `stock`, `max_stock`, `category`) VALUES
(5, 'bandage', 15.00, 50, 200, 'إسعافات'),
(5, 'medkit', 100.00, 20, 80, 'إسعافات'),
(5, 'painkiller', 30.00, 40, 150, 'أدوية'),
(5, 'antibiotic', 45.00, 35, 120, 'أدوية'),
(5, 'vitamins', 25.00, 60, 200, 'مكملات'),
(5, 'firstaid', 75.00, 25, 100, 'إسعافات'),
(5, 'antiseptic', 20.00, 45, 150, 'إسعافات'),
(5, 'thermometer', 35.00, 30, 100, 'أجهزة'),
(5, 'syringe', 10.00, 80, 300, 'مستلزمات'),
(5, 'ointment', 18.00, 55, 200, 'مستلزمات'),
(5, 'bandage_large', 25.00, 40, 150, 'إسعافات'),
(5, 'health_boost', 60.00, 15, 60, 'مكملات'),
(5, 'energy_drink', 12.00, 70, 250, 'مشروبات'),
(5, 'protein_bar', 8.00, 90, 300, 'مكملات'),
(5, 'sleeping_pills', 35.00, 25, 100, 'أدوية');

-- متجر الإلكترونيات (ID: 6)
INSERT INTO `shop_items` (`shop_id`, `item_name`, `price`, `stock`, `max_stock`, `category`) VALUES
(6, 'phone', 800.00, 25, 100, 'هواتف'),
(6, 'laptop', 1500.00, 15, 50, 'حواسيب'),
(6, 'tablet', 600.00, 20, 80, 'أجهزة لوحية'),
(6, 'camera', 450.00, 18, 60, 'كاميرات'),
(6, 'headphones', 120.00, 30, 100, 'إكسسوارات'),
(6, 'smartwatch', 350.00, 22, 80, 'إكسسوارات'),
(6, 'router', 100.00, 35, 120, 'شبكات'),
(6, 'speaker', 200.00, 28, 100, 'صوتيات'),
(6, 'mouse', 50.00, 40, 150, 'إكسسوارات'),
(6, 'keyboard', 80.00, 32, 120, 'إكسسوارات'),
(6, 'usb', 40.00, 50, 200, 'مستلزمات'),
(6, 'charger', 25.00, 60, 250, 'مستلزمات'),
(6, 'powerbank', 70.00, 45, 150, 'مستلزمات'),
(6, 'cable', 15.00, 80, 300, 'مستلزمات'),
(6, 'adapter', 30.00, 55, 200, 'مستلزمات');

-- صالون حلاقة (ID: 7)
INSERT INTO `shop_items` (`shop_id`, `item_name`, `price`, `stock`, `max_stock`, `category`) VALUES
(7, 'haircut_short', 30.00, 999, 999, 'خدمات'),
(7, 'haircut_medium', 40.00, 999, 999, 'خدمات'),
(7, 'haircut_long', 50.00, 999, 999, 'خدمات'),
(7, 'beard_trim', 20.00, 999, 999, 'خدمات'),
(7, 'shave', 25.00, 999, 999, 'خدمات'),
(7, 'hair_dye', 60.00, 999, 999, 'خدمات'),
(7, 'facial', 45.00, 999, 999, 'خدمات'),
(7, 'massage', 70.00, 999, 999, 'خدمات'),
(7, 'shampoo', 15.00, 50, 200, 'منتجات'),
(7, 'conditioner', 15.00, 45, 180, 'منتجات'),
(7, 'hair_gel', 10.00, 60, 250, 'منتجات'),
(7, 'razor', 25.00, 40, 150, 'منتجات'),
(7, 'perfume', 80.00, 35, 120, 'منتجات'),
(7, 'cream', 35.00, 55, 200, 'منتجات'),
(7, 'brush', 12.00, 65, 250, 'منتجات');

-- متجر المجوهرات (ID: 8)
INSERT INTO `shop_items` (`shop_id`, `item_name`, `price`, `stock`, `max_stock`, `category`) VALUES
(8, 'gold_ring', 500.00, 20, 80, 'خواتم'),
(8, 'diamond_ring', 2000.00, 10, 40, 'خواتم'),
(8, 'silver_ring', 300.00, 25, 100, 'خواتم'),
(8, 'gold_necklace', 800.00, 15, 60, 'قلادات'),
(8, 'diamond_necklace', 3500.00, 8, 30, 'قلادات'),
(8, 'pearl_necklace', 1200.00, 12, 50, 'قلادات'),
(8, 'gold_bracelet', 600.00, 18, 70, 'أساور'),
(8, 'silver_bracelet', 400.00, 22, 80, 'أساور'),
(8, 'diamond_earrings', 1500.00, 14, 60, 'أقراط'),
(8, 'pearl_earrings', 900.00, 16, 70, 'أقراط'),
(8, 'gold_earrings', 450.00, 20, 80, 'أقراط'),
(8, 'watch_luxury', 2500.00, 10, 40, 'ساعات'),
(8, 'bracelet_diamond', 1800.00, 8, 30, 'أساور'),
(8, 'necklace_gold', 1200.00, 12, 50, 'قلادات'),
(8, 'crown', 5000.00, 3, 10, 'تحف');

-- إدخال الأرصدة الأولية للمتاجر
INSERT INTO `shop_balances` (`shop_id`, `balance`) VALUES
(1, 50000.00),
(2, 200000.00),
(3, 25000.00),
(4, 40000.00),
(5, 30000.00),
(6, 60000.00),
(7, 15000.00),
(8, 100000.00);
