local Queries = {
    prepared = {},
    cache = {},
    stats = {
        totalQueries = 0,
        cachedQueries = 0,
        failedQueries = 0
    }
}

function Queries:init()
    -- تحضير الاستعلامات الشائعة
    self:prepareCommonQueries()
    print('^2[Queries] ✅ تم تحميل نظام الاستعلامات^0')
end

function Queries:prepareCommonQueries()
    -- استعلامات اللاعبين
    self.prepared['get_player'] = MySQL.prepare(
        'SELECT * FROM players WHERE identifier = ?'
    )
    
    self.prepared['create_player'] = MySQL.prepare([[
        INSERT INTO players (identifier, name, money, bank, job, job_grade, group) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]])
    
    self.prepared['update_player_money'] = MySQL.prepare(
        'UPDATE players SET money = ? WHERE identifier = ?'
    )
    
    self.prepared['update_player_bank'] = MySQL.prepare(
        'UPDATE players SET bank = ? WHERE identifier = ?'
    )
    
    self.prepared['update_player_job'] = MySQL.prepare(
        'UPDATE players SET job = ?, job_grade = ? WHERE identifier = ?'
    )
    
    -- استعلامات المركبات
    self.prepared['get_player_vehicles'] = MySQL.prepare(
        'SELECT * FROM vehicles WHERE owner = ?'
    )
    
    self.prepared['get_vehicle_by_plate'] = MySQL.prepare(
        'SELECT * FROM vehicles WHERE plate = ?'
    )
    
    self.prepared['create_vehicle'] = MySQL.prepare([[
        INSERT INTO vehicles (owner, plate, model, vehicle_name, fuel, engine_health, body_health, position, heading) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]])
    
    self.prepared['update_vehicle_position'] = MySQL.prepare(
        'UPDATE vehicles SET position = ?, heading = ?, stored = ? WHERE plate = ?'
    )
    
    -- استعلامات العقارات
    self.prepared['get_player_properties'] = MySQL.prepare(
        'SELECT * FROM properties WHERE owner = ?'
    )
    
    self.prepared['get_property_by_id'] = MySQL.prepare(
        'SELECT * FROM properties WHERE id = ?'
    )
    
    self.prepared['create_property'] = MySQL.prepare([[
        INSERT INTO properties (owner, name, type, price, entrance, exit, interior, furniture) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]])
    
    -- استعلامات الاقتصاد
    self.prepared['create_transaction'] = MySQL.prepare([[
        INSERT INTO transactions (sender, receiver, amount, type, description, status) 
        VALUES (?, ?, ?, ?, ?, ?)
    ]])
    
    self.prepared['get_player_transactions'] = MySQL.prepare([[
        SELECT * FROM transactions 
        WHERE sender = ? OR receiver = ? 
        ORDER BY created_at DESC 
        LIMIT ? OFFSET ?
    ]])
    
    -- استعلامات الأسواق
    self.prepared['get_market_items'] = MySQL.prepare(
        'SELECT * FROM markets WHERE stock > 0 ORDER BY category, item_name'
    )
    
    self.prepared['update_market_stock'] = MySQL.prepare(
        'UPDATE markets SET stock = ?, updated_at = CURRENT_TIMESTAMP WHERE item_name = ?'
    )
    
    -- استعلامات الإحصائيات
    self.prepared['get_server_stats'] = MySQL.prepare([[
        SELECT 
            (SELECT COUNT(*) FROM players) as total_players,
            (SELECT COUNT(*) FROM vehicles) as total_vehicles,
            (SELECT COUNT(*) FROM properties) as total_properties,
            (SELECT SUM(money) FROM players) as total_money,
            (SELECT SUM(bank) FROM players) as total_bank,
            (SELECT COUNT(*) FROM transactions WHERE created_at >= CURDATE()) as today_transactions
    ]])
end

function Queries:get(queryName, params, callback, useCache)
    self.stats.totalQueries = self.stats.totalQueries + 1
    
    local cacheKey = queryName .. json.encode(params or {})
    
    -- التحقق من الكاش
    if useCache and self.cache[cacheKey] then
        self.stats.cachedQueries = self.stats.cachedQueries + 1
        if callback then
            callback(self.cache[cacheKey])
        end
        return self.cache[cacheKey]
    end
    
    local preparedQuery = self.prepared[queryName]
    if not preparedQuery then
        error('❌ الاستعلام غير موجود: ' .. queryName)
    end
    
    preparedQuery(params, function(result)
        if result then
            -- تخزين في الكاش
            if useCache then
                self.cache[cacheKey] = result
                SetTimeout(30000, function() -- 30 ثانية
                    self.cache[cacheKey] = nil
                end)
            end
            
            if callback then
                callback(result)
            end
        else
            self.stats.failedQueries = self.stats.failedQueries + 1
            if callback then
                callback(nil)
            end
        end
    end)
end

function Queries:execute(queryName, params, callback)
    self.stats.totalQueries = self.stats.totalQueries + 1
    
    local preparedQuery = self.prepared[queryName]
    if not preparedQuery then
        error('❌ الاستعلام غير موجود: ' .. queryName)
    end
    
    preparedQuery(params, function(affectedRows)
        if affectedRows and callback then
            callback(affectedRows > 0, affectedRows)
        elseif callback then
            callback(false, 0)
        end
    end)
end

function Queries:transaction(queries, callback)
    local transactionQueries = {}
    
    for _, queryInfo in ipairs(queries) do
        local preparedQuery = self.prepared[queryInfo.query]
        if not preparedQuery then
            error('❌ الاستعلام غير موجود: ' .. queryInfo.query)
        end
        
        table.insert(transactionQueries, {
            sql = preparedQuery.sql,
            values = queryInfo.params
        })
    end
    
    MySQL.transaction(transactionQueries, function(success)
        if callback then
            callback(success)
        end
    end)
end

function Queries:clearCache()
    self.cache = {}
    print('^2[Queries] 🧹 تم مسح كاش الاستعلامات^0')
end

function Queries:getStats()
    return {
        total = self.stats.totalQueries,
        cached = self.stats.cachedQueries,
        failed = self.stats.failedQueries,
        cacheSize = countTable(self.cache),
        prepared = countTable(self.prepared)
    }
end

-- تنظيف الكاش تلقائياً
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000) -- كل 30 ثانية
        self:clearCache()
    end
end)

return Queries
