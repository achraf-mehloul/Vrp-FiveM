local Migrations = {
    currentVersion = 1,
    migrations = {}
}

function Migrations:init()
    self.migrations = {
        {
            version = 1,
            description = 'إنشاء الجداول الأساسية',
            up = function(callback)
                local queries = {
                    -- جدول اللاعبين
                    [[CREATE TABLE IF NOT EXISTS players (
                        identifier VARCHAR(255) PRIMARY KEY,
                        name VARCHAR(255) NOT NULL,
                        money INT DEFAULT 0,
                        bank INT DEFAULT 0,
                        job VARCHAR(100) DEFAULT 'unemployed',
                        job_grade INT DEFAULT 0,
                        group VARCHAR(100) DEFAULT 'user',
                        first_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        play_time INT DEFAULT 0,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        INDEX idx_name (name),
                        INDEX idx_job (job),
                        INDEX idx_group (group)
                    )]],

                    -- جدول المركبات
                    [[CREATE TABLE IF NOT EXISTS vehicles (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        owner VARCHAR(255) NOT NULL,
                        plate VARCHAR(10) UNIQUE NOT NULL,
                        model VARCHAR(100) NOT NULL,
                        vehicle_name VARCHAR(100) NOT NULL,
                        fuel DOUBLE DEFAULT 100.0,
                        engine_health DOUBLE DEFAULT 1000.0,
                        body_health DOUBLE DEFAULT 1000.0,
                        position TEXT,
                        heading FLOAT DEFAULT 0.0,
                        stored BOOLEAN DEFAULT true,
                        disabled BOOLEAN DEFAULT false,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        FOREIGN KEY (owner) REFERENCES players(identifier) ON DELETE CASCADE,
                        INDEX idx_owner (owner),
                        INDEX idx_plate (plate),
                        INDEX idx_stored (stored)
                    )]],

                    -- جدول العقارات
                    [[CREATE TABLE IF NOT EXISTS properties (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        owner VARCHAR(255),
                        name VARCHAR(255) NOT NULL,
                        type VARCHAR(50) NOT NULL,
                        price INT NOT NULL,
                        entrance TEXT NOT NULL,
                        exit TEXT,
                        interior VARCHAR(100),
                        furniture TEXT,
                        locked BOOLEAN DEFAULT true,
                        for_sale BOOLEAN DEFAULT false,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        FOREIGN KEY (owner) REFERENCES players(identifier) ON DELETE SET NULL,
                        INDEX idx_owner (owner),
                        INDEX idx_type (type),
                        INDEX idx_for_sale (for_sale)
                    )]],

                    -- جدول العناصر
                    [[CREATE TABLE IF NOT EXISTS items (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        name VARCHAR(255) UNIQUE NOT NULL,
                        label VARCHAR(255) NOT NULL,
                        weight DOUBLE DEFAULT 0.1,
                        rare BOOLEAN DEFAULT false,
                        can_remove BOOLEAN DEFAULT true,
                        type VARCHAR(50) DEFAULT 'item',
                        description TEXT,
                        image TEXT,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        INDEX idx_name (name),
                        INDEX idx_type (type)
                    )]],

                    -- جدول inventories
                    [[CREATE TABLE IF NOT EXISTS inventories (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        owner VARCHAR(255) NOT NULL,
                        name VARCHAR(255) NOT NULL,
                        type VARCHAR(50) NOT NULL,
                        data LONGTEXT,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        FOREIGN KEY (owner) REFERENCES players(identifier) ON DELETE CASCADE,
                        INDEX idx_owner (owner),
                        INDEX idx_type (type)
                    )]]
                }

                self:runQueries(queries, callback)
            end,
            down = function(callback)
                local queries = {
                    'DROP TABLE IF EXISTS inventories',
                    'DROP TABLE IF EXISTS items',
                    'DROP TABLE IF EXISTS properties',
                    'DROP TABLE IF EXISTS vehicles',
                    'DROP TABLE IF EXISTS players'
                }
                self:runQueries(queries, callback)
            end
        },
        {
            version = 2,
            description = 'إضافة جداول الاقتصاد',
            up = function(callback)
                local queries = {
                    -- جدول المعاملات
                    [[CREATE TABLE IF NOT EXISTS transactions (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        sender VARCHAR(255) NOT NULL,
                        receiver VARCHAR(255) NOT NULL,
                        amount INT NOT NULL,
                        type VARCHAR(50) NOT NULL,
                        description TEXT,
                        status VARCHAR(20) DEFAULT 'pending',
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        INDEX idx_sender (sender),
                        INDEX idx_receiver (receiver),
                        INDEX idx_type (type),
                        INDEX idx_status (status)
                    )]],

                    -- جدول الأسواق
                    [[CREATE TABLE IF NOT EXISTS markets (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        item_name VARCHAR(255) NOT NULL,
                        price INT NOT NULL,
                        stock INT DEFAULT 0,
                        max_stock INT DEFAULT 100,
                        category VARCHAR(100) DEFAULT 'general',
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        FOREIGN KEY (item_name) REFERENCES items(name) ON DELETE CASCADE,
                        INDEX idx_category (category),
                        INDEX idx_item_name (item_name)
                    )]]
                }
                self:runQueries(queries, callback)
            end,
            down = function(callback)
                local queries = {
                    'DROP TABLE IF EXISTS markets',
                    'DROP TABLE IF EXISTS transactions'
                }
                self:runQueries(queries, callback)
            end
        }
    }
end

function Migrations:run(callback)
    self:init()
    
    -- الحصول على آخر version
    self:getCurrentVersion(function(currentVersion)
        local targetVersion = self.currentVersion
        
        if currentVersion < targetVersion then
            print('^2[Migrations] 🔄 جاري تحديث قاعدة البيانات من v' .. currentVersion .. ' إلى v' .. targetVersion .. '^0')
            self:migrateUp(currentVersion, targetVersion, callback)
        elseif currentVersion > targetVersion then
            print('^3[Migrations] 🔄 جاري استرجاع قاعدة البيانات من v' .. currentVersion .. ' إلى v' .. targetVersion .. '^0')
            self:migrateDown(currentVersion, targetVersion, callback)
        else
            print('^2[Migrations] ✅ قاعدة البيانات محدثة^0')
            if callback then callback(true, 'قاعدة البيانات محدثة') end
        end
    end)
end

function Migrations:migrateUp(fromVersion, toVersion, callback)
    local migrationsToRun = {}
    
    for _, migration in ipairs(self.migrations) do
        if migration.version > fromVersion and migration.version <= toVersion then
            table.insert(migrationsToRun, migration)
        end
    end
    
    table.sort(migrationsToRun, function(a, b)
        return a.version < b.version
    end)
    
    self:runMigrations(migrationsToRun, 'up', callback)
end

function Migrations:migrateDown(fromVersion, toVersion, callback)
    local migrationsToRun = {}
    
    for _, migration in ipairs(self.migrations) do
        if migration.version <= fromVersion and migration.version > toVersion then
            table.insert(migrationsToRun, migration)
        end
    end
    
    table.sort(migrationsToRun, function(a, b)
        return a.version > b.version
    end)
    
    self:runMigrations(migrationsToRun, 'down', callback)
end

function Migrations:runMigrations(migrations, direction, callback)
    if #migrations == 0 then
        if callback then callback(true, 'لا توجد migrations لتشغيلها') end
        return
    end
    
    local function runNext(index)
        if index > #migrations then
            self:setVersion(direction == 'up' and migrations[#migrations].version or migrations[#migrations].version - 1)
            if callback then callback(true, 'تم تشغيل جميع migrations بنجاح') end
            return
        end
        
        local migration = migrations[index]
        print('^2[Migrations] 🚀 تشغيل migration v' .. migration.version .. ': ' .. migration.description .. '^0')
        
        migration[direction](function(success, message)
            if success then
                print('^2[Migrations] ✅ تم migration v' .. migration.version .. ' بنجاح^0')
                runNext(index + 1)
            else
                print('^1[Migrations] ❌ فشل migration v' .. migration.version .. ': ' .. message .. '^0')
                if callback then callback(false, message) end
            end
        end)
    end
    
    runNext(1)
end

function Migrations:runQueries(queries, callback)
    local completed = 0
    local total = #queries
    local errors = {}
    
    for _, query in ipairs(queries) do
        MySQL.query(query, {}, function(result)
            completed = completed + 1
            
            if not result then
                table.insert(errors, query)
            end
            
            if completed == total then
                if #errors > 0 then
                    if callback then callback(false, 'فشل في بعض الاستعلامات') end
                else
                    if callback then callback(true, 'تم جميع الاستعلامات بنجاح') end
                end
            end
        end)
    end
end

function Migrations:getCurrentVersion(callback)
    MySQL.query('SELECT version FROM schema_version ORDER BY id DESC LIMIT 1', {}, function(result)
        if result and result[1] then
            callback(result[1].version)
        else
            -- إذا لم يكن الجدول موجوداً
            MySQL.query([[
                CREATE TABLE IF NOT EXISTS schema_version (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    version INT NOT NULL,
                    migrated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ]], {}, function()
                MySQL.query('INSERT INTO schema_version (version) VALUES (0)', {}, function()
                    callback(0)
                end)
            end)
        end
    end)
end

function Migrations:setVersion(version, callback)
    MySQL.query('INSERT INTO schema_version (version) VALUES (?)', {version}, function()
        if callback then callback() end
    end)
end

return Migrations
