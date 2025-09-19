AdminRepository = {}

function AdminRepository:new()
    local instance = {}
    setmetatable(instance, { __index = AdminRepository })
    return instance
end

-- Ban management
function AdminRepository:BanPlayer(banData)
    local query = [[
        INSERT INTO bans (identifier, license, discord, ip, reason, banned_by, expires_at, active)
        VALUES (@identifier, @license, @discord, @ip, @reason, @banned_by, @expires_at, 1)
    ]]
    
    return MySQL.Sync.execute(query, banData) > 0
end

function AdminRepository:UnbanPlayer(identifier, unbannedBy)
    local query = 'UPDATE bans SET active = 0, unbanned_by = @unbanned_by, unbanned_at = NOW() WHERE identifier = @identifier AND active = 1'
    return MySQL.Sync.execute(query, {['@identifier'] = identifier, ['@unbanned_by'] = unbannedBy}) > 0
end

function AdminRepository:GetActiveBans()
    local query = 'SELECT * FROM bans WHERE active = 1 ORDER BY banned_at DESC'
    return MySQL.Sync.fetchAll(query)
end

function AdminRepository:IsPlayerBanned(identifier)
    local query = 'SELECT * FROM bans WHERE identifier = @identifier AND active = 1 AND (expires_at IS NULL OR expires_at > NOW())'
    local result = MySQL.Sync.fetchAll(query, {['@identifier'] = identifier})
    return result and #result > 0, result and result[1] or nil
end

-- Warning management
function AdminRepository:AddWarning(warningData)
    local query = [[
        INSERT INTO warnings (player_identifier, admin_identifier, reason, severity, expires_at)
        VALUES (@player_identifier, @admin_identifier, @reason, @severity, @expires_at)
    ]]
    
    return MySQL.Sync.execute(query, warningData) > 0
end

function AdminRepository:GetPlayerWarnings(playerIdentifier)
    local query = 'SELECT * FROM warnings WHERE player_identifier = @player_identifier AND (expires_at IS NULL OR expires_at > NOW()) ORDER BY created_at DESC'
    return MySQL.Sync.fetchAll(query, {['@player_identifier'] = playerIdentifier})
end

function AdminRepository:ClearWarnings(playerIdentifier)
    local query = 'UPDATE warnings SET expires_at = NOW() WHERE player_identifier = @player_identifier AND (expires_at IS NULL OR expires_at > NOW())'
    return MySQL.Sync.execute(query, {['@player_identifier'] = playerIdentifier}) > 0
end

-- Admin management
function AdminRepository:GetAdminUsers()
    local query = 'SELECT * FROM admin_users WHERE active = 1 ORDER BY group, added_at DESC'
    return MySQL.Sync.fetchAll(query)
end

function AdminRepository:AddAdminUser(adminData)
    local query = [[
        INSERT INTO admin_users (identifier, group, added_by)
        VALUES (@identifier, @group, @added_by)
    ]]
    
    return MySQL.Sync.execute(query, adminData) > 0
end

function AdminRepository:RemoveAdminUser(identifier, removedBy)
    local query = 'UPDATE admin_users SET active = 0, removed_by = @removed_by, removed_at = NOW() WHERE identifier = @identifier'
    return MySQL.Sync.execute(query, {['@identifier'] = identifier, ['@removed_by'] = removedBy}) > 0
end

-- Logging
function AdminRepository:LogAction(logData)
    if not Config.Admin.LogActions then return true end
    
    local query = [[
        INSERT INTO admin_log (admin_identifier, target_identifier, action, details)
        VALUES (@admin_identifier, @target_identifier, @action, @details)
    ]]
    
    return MySQL.Sync.execute(query, logData) > 0
end

function AdminRepository:GetAdminLog(limit, offset)
    local query = 'SELECT * FROM admin_log ORDER BY timestamp DESC LIMIT @limit OFFSET @offset'
    return MySQL.Sync.fetchAll(query, {['@limit'] = limit or 50, ['@offset'] = offset or 0})
end

-- Player management
function AdminRepository:GetAllPlayers()
    local query = 'SELECT * FROM users WHERE last_connection > DATE_SUB(NOW(), INTERVAL 7 DAY) ORDER BY name'
    return MySQL.Sync.fetchAll(query)
end

function AdminRepository:SearchPlayers(searchTerm)
    local query = 'SELECT * FROM users WHERE identifier LIKE @search OR name LIKE @search ORDER BY last_connection DESC LIMIT 50'
    return MySQL.Sync.fetchAll(query, {['@search'] = '%' .. searchTerm .. '%'})
end

-- Server statistics
function AdminRepository:GetServerStats()
    local stats = {}
    
    -- Player counts
    stats.totalPlayers = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM users')
    stats.activePlayers = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM users WHERE last_connection > DATE_SUB(NOW(), INTERVAL 1 DAY)')
    stats.bannedPlayers = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM bans WHERE active = 1')
    
    -- Admin actions
    stats.recentActions = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM admin_log WHERE timestamp > DATE_SUB(NOW(), INTERVAL 1 DAY)')
    stats.totalWarnings = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM warnings WHERE expires_at IS NULL OR expires_at > NOW()')
    
    -- Server performance
    stats.avgSessionTime = MySQL.Sync.fetchScalar('SELECT AVG(TIMESTAMPDIFF(MINUTE, last_login, last_logout)) FROM users WHERE last_logout IS NOT NULL')
    
    return stats
end

-- Export functions
function AdminRepository:ExportData(dataType, format)
    local query = ''
    
    if dataType == 'bans' then
        query = 'SELECT * FROM bans ORDER BY banned_at DESC'
    elseif dataType == 'warnings' then
        query = 'SELECT * FROM warnings ORDER BY created_at DESC'
    elseif dataType == 'admin_log' then
        query = 'SELECT * FROM admin_log ORDER BY timestamp DESC'
    else
        return nil
    end
    
    local data = MySQL.Sync.fetchAll(query)
    
    if format == 'json' then
        return json.encode(data)
    elseif format == 'csv' then
        return self:ConvertToCSV(data)
    else
        return data
    end
end

function AdminRepository:ConvertToCSV(data)
    if not data or #data == 0 then return '' end
    
    local csv = {}
    local headers = {}
    
    -- Get headers
    for k in pairs(data[1]) do
        table.insert(headers, k)
    end
    
    table.insert(csv, table.concat(headers, ','))
    
    -- Add rows
    for _, row in ipairs(data) do
        local values = {}
        for _, header in ipairs(headers) do
            table.insert(values, tostring(row[header] or ''))
        end
        table.insert(csv, table.concat(values, ','))
    end
    
    return table.concat(csv, '\n')
end
