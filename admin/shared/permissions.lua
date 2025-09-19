Permissions = {}

-- Check if player has permission
function Permissions:HasPermission(source, permission)
    local playerGroup = self:GetPlayerGroup(source)
    local allowedGroups = Config.Admin.Permissions[permission] or {}
    
    for _, group in ipairs(allowedGroups) do
        if playerGroup == group then
            return true
        end
    end
    
    return false
end

-- Get player's admin group
function Permissions:GetPlayerGroup(source)
    if not source then return nil end
    
    local identifier = GetPlayerIdentifier(source)
    if not identifier then return nil end

    -- Check if player is in admin table
    local result = MySQL.Sync.fetchAll('SELECT * FROM admin_users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })

    if result and #result > 0 then
        return result[1].group
    end

    return nil
end

-- Get all players with admin permissions
function Permissions:GetAllAdmins()
    local result = MySQL.Sync.fetchAll('SELECT * FROM admin_users WHERE active = 1')
    return result or {}
end

-- Add admin permission
function Permissions:AddAdmin(identifier, group, addedBy)
    MySQL.Sync.execute(
        'INSERT INTO admin_users (identifier, group, added_by, added_at) VALUES (@identifier, @group, @addedBy, NOW())',
        {
            ['@identifier'] = identifier,
            ['@group'] = group,
            ['@addedBy'] = addedBy
        }
    )
end

-- Remove admin permission
function Permissions:RemoveAdmin(identifier, removedBy)
    MySQL.Sync.execute(
        'UPDATE admin_users SET active = 0, removed_by = @removedBy, removed_at = NOW() WHERE identifier = @identifier',
        {
            ['@identifier'] = identifier,
            ['@removedBy'] = removedBy
        }
    )
end

-- Update admin group
function Permissions:UpdateAdminGroup(identifier, newGroup, updatedBy)
    MySQL.Sync.execute(
        'UPDATE admin_users SET group = @newGroup, updated_by = @updatedBy, updated_at = NOW() WHERE identifier = @identifier',
        {
            ['@identifier'] = identifier,
            ['@newGroup'] = newGroup,
            ['@updatedBy'] = updatedBy
        }
    )
end

-- Check if identifier is admin
function Permissions:IsAdmin(identifier)
    local result = MySQL.Sync.fetchAll(
        'SELECT * FROM admin_users WHERE identifier = @identifier AND active = 1',
        {['@identifier'] = identifier}
    )
    return result and #result > 0
end

-- Get admin log
function Permissions:GetAdminLog(limit, offset)
    local result = MySQL.Sync.fetchAll(
        'SELECT * FROM admin_log ORDER BY timestamp DESC LIMIT @limit OFFSET @offset',
        {
            ['@limit'] = limit or 50,
            ['@offset'] = offset or 0
        }
    )
    return result
end

-- Log admin action
function Permissions:LogAction(source, action, target, details)
    if not Config.Admin.LogActions then return end

    local adminIdentifier = GetPlayerIdentifier(source)
    local targetIdentifier = target and GetPlayerIdentifier(target) or nil

    MySQL.Sync.execute(
        'INSERT INTO admin_log (admin_identifier, target_identifier, action, details, timestamp) VALUES (@adminId, @targetId, @action, @details, NOW())',
        {
            ['@adminId'] = adminIdentifier,
            ['@targetId'] = targetIdentifier,
            ['@action'] = action,
            ['@details'] = json.encode(details or {})
        }
    )

    if Config.Admin.LogToConsole then
        print(string.format('[ADMIN] %s performed %s on %s', adminIdentifier, action, targetIdentifier or 'N/A'))
    end
end
