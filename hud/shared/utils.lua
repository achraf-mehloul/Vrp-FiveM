Utils = {}

-- Debug logging function
function Utils.Debug(message, data)
    if Config.Debug then
        local output = message
        if data then
            output = output .. ' | Data: ' .. json.encode(data)
        end
        print('^5[HUD DEBUG]^0: ' .. output)
    end
end

-- Validate value within range
function Utils.ValidateValue(value, min, max)
    if not value then return min end
    if value < min then return min end
    if value > max then return max end
    return value
end

-- Format number with commas
function Utils.FormatNumber(number)
    if not number then return "0" end
    return tostring(number):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

-- Deep copy table
function Utils.DeepCopy(table)
    if type(table) ~= 'table' then return table end
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = Utils.DeepCopy(v)
    end
    return copy
end

-- Get player identifier
function Utils.GetPlayerIdentifier(source)
    if not source then return nil end
    
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(identifier, 1, string.len("steam:")) == "steam:" then
            return identifier
        elseif string.sub(identifier, 1, string.len("license:")) == "license:" then
            return identifier
        end
    end
    
    return nil
end

-- Check if player has group/permission
function Utils.HasPermission(source, permission)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            for _, group in ipairs(Config.AdminGroups) do
                if xPlayer.getGroup() == group then
                    return true
                end
            end
        end
    elseif Config.Framework == 'qb-core' then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            for _, group in ipairs(Config.AdminGroups) do
                if player.PlayerData.permission == group then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Send NUI message with error handling
function Utils.SendNUIMessage(data, source)
    local target = source or -1
    try({
        function()
            SendNUIMessage(data)
        end,
        catch = function(error)
            Utils.Debug("NUI message failed: " .. tostring(error))
        end
    })
end
