local Database = {
    connection = nil,
    isConnected = false,
    connectionPool = {},
    queryCache = {},
    transactionQueue = {}
}

function Database:connect(config)
    print('^2[Database] 🔌 جاري الاتصال بقاعدة البيانات...^0')
    
    local connectionString = string.format(
        'mysql://%s:%s@%s/%s',
        config.User, config.Password, config.Host, config.Database
    )
    
    -- إعداد اتصال MySQL
    MySQL = {
        ready = false,
        queries = {},
        async = {}
    }
    
    -- تهيئة oxmysql
    if GetResourceState('oxmysql') == 'started' then
        exports.oxmysql:execute('SELECT 1', {}, function(result)
            if result then
                self.connection = exports.oxmysql
                self.isConnected = true
                self.ready = true
                
                print('^2[Database] ✅ تم الاتصال بقاعدة البيانات بنجاح^0')
                print('^2[Database] 📊 السيرفر: ' .. config.Host .. '^0')
                print('^2[Database] 🗃️  قاعدة البيانات: ' .. config.Database .. '^0')
                
                -- تشغيل migrations تلقائياً
                self:runMigrations()
            else
                print('^1[Database] ❌ فشل الاتصال بقاعدة البيانات^0')
            end
        end)
    else
        print('^1[Database] ❌ oxmysql غير موجود^0')
    end
end

function Database:query(sql, params, callback)
    if not self.isConnected then
        error('❌ قاعدة البيانات غير متصلة')
    end
    
    local queryId = #self.queries + 1
    local startTime = GetGameTimer()
    
    -- استخدام الكاش إذا كان مفعل
    local cacheKey = sql .. json.encode(params or {})
    if self.queryCache[cacheKey] and config.CacheEnabled then
        if callback then
            callback(self.queryCache[cacheKey])
        end
        return self.queryCache[cacheKey]
    end
    
    exports.oxmysql:execute(sql, params or {}, function(result)
        local executionTime = GetGameTimer() - startTime
        
        -- تسجيل وقت الاستعلام
        if executionTime > 100 then
            print('^3[Database] ⚠️  استعلام بطيء: ' .. executionTime .. 'ms - ' .. sql:sub(1, 100) .. '^0')
        end
        
        -- تخزين في الكاش
        if config.CacheEnabled then
            self.queryCache[cacheKey] = result
            SetTimeout(config.CacheTimeout or 30000, function()
                self.queryCache[cacheKey] = nil
            end)
        end
        
        if callback then
            callback(result)
        end
    end)
    
    self.queries[queryId] = {
        sql = sql,
        params = params,
        timestamp = os.time()
    }
end

function Database:execute(sql, params, callback)
    if not self.isConnected then
        error('❌ قاعدة البيانات غير متصلة')
    end
    
    exports.oxmysql:execute(sql, params or {}, function(affectedRows)
        if callback then
            callback(affectedRows)
        end
    end)
end

function Database:insert(sql, params, callback)
    if not self.isConnected then
        error('❌ قاعدة البيانات غير متصلة')
    end
    
    exports.oxmysql:insert(sql, params or {}, function(insertId)
        if callback then
            callback(insertId)
        end
    end)
end

function Database:transaction(queries, callback)
    if not self.isConnected then
        error('❌ قاعدة البيانات غير متصلة')
    end
    
    exports.oxmysql:transaction(queries, function(success)
        if callback then
            callback(success)
        end
    end)
end

function Database:prepare(sql)
    if not self.isConnected then
        error('❌ قاعدة البيانات غير متصلة')
    end
    
    return function(params, callback)
        self:query(sql, params, callback)
    end
end

function Database:runMigrations()
    print('^2[Database] 📝 جاري تشغيل migrations...^0')
    
    local migrations = require 'core/db/migrations'
    migrations:run(function(success, message)
        if success then
            print('^2[Database] ✅ تم تشغيل migrations بنجاح^0')
        else
            print('^1[Database] ❌ فشل في تشغيل migrations: ' .. message .. '^0')
        end
    end)
end

function Database:backup(callback)
    if not self.isConnected then
        error('❌ قاعدة البيانات غير متصلة')
    end
    
    local backupFile = 'backups/db_backup_' .. os.date('%Y%m%d_%H%M%S') .. '.sql'
    
    exports.oxmysql:execute('SHOW TABLES', {}, function(tables)
        local backupQueries = {}
        
        for _, tableInfo in ipairs(tables) do
            local tableName = tableInfo[1]
            backupQueries[#backupQueries + 1] = {
                sql = 'SELECT * FROM ' .. tableName,
                action = 'backup'
            }
        end
        
        self:transaction(backupQueries, function(success)
            if success and callback then
                callback(true, backupFile)
            elseif callback then
                callback(false, 'فشل في النسخ الاحتياطي')
            end
        end)
    end)
end

function Database:getStats()
    return {
        connected = self.isConnected,
        totalQueries = #self.queries,
        cacheSize = countTable(self.queryCache),
        pendingTransactions = #self.transactionQueue
    }
end

-- تنظيف الكاش تلقائياً
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- كل دقيقة
        self.queryCache = {}
        print('^2[Database] 🧹 تم تنظيف كاش الاستعلامات^0')
    end
end)

return Database
