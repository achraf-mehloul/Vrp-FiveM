-- [file name]: server/database.lua
local Database = {}

-- تهيئة قاعدة البيانات
function Database:init()
    self:createTables()
    self:insertDefaultData()
    self:startCleanupTask()
end

-- إنشاء الجداول
function Database:createTables()
    -- جدول المتاجر
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `shops` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(255) NOT NULL,
            `type` VARCHAR(50) NOT NULL,
            `location` TEXT NOT NULL,
            `blip_enabled` TINYINT(1) DEFAULT 1,
            `marker_enabled` TINYINT(1) DEFAULT 1,
            `open_hour` INT(2) DEFAULT 9,
            `close_hour` INT(2) DEFAULT 21,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            INDEX `idx_type` (`type`),
            INDEX `idx_blip` (`blip_enabled`),
            INDEX `idx_marker` (`marker_enabled`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- جدول عناصر المتاجر
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `shop_items` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `shop_id` INT(11) NOT NULL,
            `item_name` VARCHAR(255) NOT NULL,
            `label` VARCHAR(255) NOT NULL,
            `price` DECIMAL(12,2) NOT NULL,
            `stock` INT(11) NOT NULL DEFAULT 0,
            `max_stock` INT(11) NOT NULL DEFAULT 100,
            `category` VARCHAR(100) DEFAULT 'عام',
            `weight` DECIMAL(8,2) DEFAULT 0.1,
            `metadata` TEXT,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `unique_shop_item` (`shop_id`, `item_name`),
            INDEX `idx_shop_id` (`shop_id`),
            INDEX `idx_item_name` (`item_name`),
            INDEX `idx_category` (`category`),
            INDEX `idx_price` (`price`),
            FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- جدول المعاملات
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `shop_transactions` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `shop_id` INT(11) NOT NULL,
            `player_identifier` VARCHAR(255) NOT NULL,
            `player_name` VARCHAR(255) NOT NULL,
            `item_name` VARCHAR(255) NOT NULL,
            `item_label` VARCHAR(255) NOT NULL,
            `quantity` INT(11) NOT NULL,
            `unit_price` DECIMAL(12,2) NOT NULL,
            `total_price` DECIMAL(12,2) NOT NULL,
            `discount_amount` DECIMAL(12,2) DEFAULT 0,
            `tax_amount` DECIMAL(12,2) DEFAULT 0,
            `final_price` DECIMAL(12,2) NOT NULL,
            `transaction_type` ENUM('purchase', 'restock', 'refund', 'admin') DEFAULT 'purchase',
            `transaction_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `metadata` TEXT,
            PRIMARY KEY (`id`),
            INDEX `idx_shop_id` (`shop_id`),
            INDEX `idx_player` (`player_identifier`),
            INDEX `idx_date` (`transaction_date`),
            INDEX `idx_type` (`transaction_type`),
            INDEX `idx_item` (`item_name`),
            FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- جدول إحصائيات المتاجر
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `shop_statistics` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `shop_id` INT(11) NOT NULL,
            `total_sales` DECIMAL(15,2) DEFAULT 0,
            `total_transactions` INT(11) DEFAULT 0,
            `unique_customers` INT(11) DEFAULT 0,
            `daily_revenue` DECIMAL(15,2) DEFAULT 0,
            `weekly_revenue` DECIMAL(15,2) DEFAULT 0,
            `monthly_revenue` DECIMAL(15,2) DEFAULT 0,
            `most_popular_item` VARCHAR(255),
            `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `unique_shop_stat` (`shop_id`),
            INDEX `idx_revenue` (`daily_revenue`),
            FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- جدول سلة التسوق
    MySQL.query([[
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
            INDEX `idx_player` (`player_identifier`),
            INDEX `idx_shop` (`shop_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    DebugPrint('تم إنشاء جداول قاعدة البيانات بنجاح', 'info')
end

-- إدخال البيانات الافتراضية
function Database:insertDefaultData()
    -- إدخال المتاجر
    for _, shop in ipairs(Config.Shops) do
        local locationJson = json.encode(Vector3ToTable(shop.location))
        
        MySQL.insert.await([[
            INSERT IGNORE INTO shops (id, name, type, location, open_hour, close_hour) 
            VALUES (?, ?, ?, ?, ?, ?)
        ]], {
            shop.id, shop.name, shop.type, locationJson, 
            shop.hours and shop.hours.open or 9, 
            shop.hours and shop.hours.close or 21
        })

        -- إدخال العناصر
        for _, item in ipairs(shop.items) do
            MySQL.insert.await([[
                INSERT IGNORE INTO shop_items (shop_id, item_name, label, price, stock, max_stock, category, weight) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                shop.id, item.name, item.label, item.price, item.stock, 
                item.max_stock or 100, item.category or 'عام', item.weight or 0.1
            })
        end

        -- إدخال الإحصائيات
        MySQL.insert.await([[
            INSERT IGNORE INTO shop_statistics (shop_id) VALUES (?)
        ]], {shop.id})
    end

    DebugPrint('تم إدخال البيانات الافتراضية بنجاح', 'info')
end

-- مهمة تنظيف السجلات القديمة
function Database:startCleanupTask()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(24 * 60 * 60 * 1000) -- كل 24 ساعة
            
            -- حذف المعاملات الأقدم من 30 يوم
            MySQL.update.await([[
                DELETE FROM shop_transactions 
                WHERE transaction_date < DATE_SUB(NOW(), INTERVAL 30 DAY)
            ]])
            
            -- حذف سلال التسوق الأقدم من 7 أيام
            MySQL.update.await([[
                DELETE FROM shop_carts 
                WHERE updated_at < DATE_SUB(NOW(), INTERVAL 7 DAY)
            ]])
            
            DebugPrint('تم تنظيف السجلالقديمة', 'info')
        end
    end)
end

-- الحصول على جميع المتاجر
function Database:getAllShops()
    local result = MySQL.query.await([[
        SELECT s.*, 
               (SELECT COUNT(*) FROM shop_items WHERE shop_id = s.id) as item_count,
               (SELECT COALESCE(SUM(total_sales), 0) FROM shop_statistics WHERE shop_id = s.id) as total_revenue
        FROM shops s 
        ORDER BY s.id
    ]])
    
    return result
end

-- الحصول على عناصر متجر معين
function Database:getShopItems(shopId)
    local result = MySQL.query.await([[
        SELECT si.*, i.type as item_type, i.description, i.image, i.rarity
        FROM shop_items si
        LEFT JOIN (SELECT ? as item_type) i ON true
        WHERE si.shop_id = ?
        ORDER BY si.category, si.label
    ]], {shopId, shopId})
    
    return result
end

-- تحديث مخزون العنصر
function Database:updateItemStock(shopId, itemName, newStock)
    local result = MySQL.update.await([[
        UPDATE shop_items 
        SET stock = ?, updated_at = CURRENT_TIMESTAMP 
        WHERE shop_id = ? AND item_name = ?
    ]], {newStock, shopId, itemName})
    
    return result
end

-- تحديث سعر العنصر
function Database:updateItemPrice(shopId, itemName, newPrice)
    local result = MySQL.update.await([[
        UPDATE shop_items 
        SET price = ?, updated_at = CURRENT_TIMESTAMP 
        WHERE shop_id = ? AND item_name = ?
    ]], {newPrice, shopId, itemName})
    
    return result
end

-- إضافة معاملة جديدة
function Database:addTransaction(transactionData)
    local result = MySQL.insert.await([[
        INSERT INTO shop_transactions 
        (shop_id, player_identifier, player_name, item_name, item_label, quantity, 
         unit_price, total_price, discount_amount, tax_amount, final_price, 
         transaction_type, metadata) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        transactionData.shopId,
        transactionData.playerIdentifier,
        transactionData.playerName,
        transactionData.itemName,
        transactionData.itemLabel,
        transactionData.quantity,
        transactionData.unitPrice,
        transactionData.totalPrice,
        transactionData.discountAmount or 0,
        transactionData.taxAmount or 0,
        transactionData.finalPrice,
        transactionData.transactionType or 'purchase',
        transactionData.metadata and json.encode(transactionData.metadata) or nil
    })
    
    return result
end

-- الحصول على سجل المعاملات
function Database:getTransactions(playerIdentifier, shopId, limit, offset)
    local query = [[
        SELECT st.*, s.name as shop_name
        FROM shop_transactions st
        JOIN shops s ON st.shop_id = s.id
        WHERE st.player_identifier = ?
    ]]
    
    local params = {playerIdentifier}
    
    if shopId then
        query = query .. " AND st.shop_id = ?"
        table.insert(params, shopId)
    end
    
    query = query .. " ORDER BY st.transaction_date DESC LIMIT ? OFFSET ?"
    table.insert(params, limit or 50)
    table.insert(params, offset or 0)
    
    local result = MySQL.query.await(query, params)
    return result
end

-- تحديث الإحصائيات
function Database:updateStatistics(shopId, amount, isNewCustomer)
    local updateQuery = [[
        UPDATE shop_statistics 
        SET total_sales = total_sales + ?,
            total_transactions = total_transactions + 1,
            daily_revenue = daily_revenue + ?,
            weekly_revenue = weekly_revenue + ?,
            monthly_revenue = monthly_revenue + ?,
            last_updated = CURRENT_TIMESTAMP
    ]]
    
    local params = {amount, amount, amount, amount}
    
    if isNewCustomer then
        updateQuery = updateQuery .. ", unique_customers = unique_customers + 1"
    end
    
    updateQuery = updateQuery .. " WHERE shop_id = ?"
    table.insert(params, shopId)
    
    MySQL.update.await(updateQuery, params)
end

-- حفظ سلة التسوق
function Database:saveCart(playerIdentifier, shopId, items, totalAmount)
    local itemsJson = json.encode(items)
    
    MySQL.insert.await([[
        INSERT INTO shop_carts (player_identifier, shop_id, items, total_amount) 
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
        items = VALUES(items), 
        total_amount = VALUES(total_amount),
        updated_at = CURRENT_TIMESTAMP
    ]], {playerIdentifier, shopId, itemsJson, totalAmount})
end

-- تحميل سلة التسوق
function Database:loadCart(playerIdentifier, shopId)
    local result = MySQL.query.await([[
        SELECT items, total_amount 
        FROM shop_carts 
        WHERE player_identifier = ? AND shop_id = ?
    ]], {playerIdentifier, shopId})
    
    if result and result[1] then
        return {
            items = json.decode(result[1].items),
            totalAmount = result[1].total_amount
        }
    end
    
    return nil
end

-- الحصول على الإحصائيات
function Database:getStatistics(shopId)
    local result = MySQL.query.await([[
        SELECT * FROM shop_statistics WHERE shop_id = ?
    ]], {shopId})
    
    return result and result[1] or nil
end

-- تهيئة قاعدة البيانات عند بدء المورد
AddEventHandler('onMySQLReady', function()
    Database:init()
    DebugPrint('تم تهيئة قاعدة البيانات بنجاح', 'success')
end)

-- تصدير الدوال
return Database
