function GetPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.sub(identifier, 1, string.len('steam:')) == 'steam:' then
            return identifier
        end
    end
    return nil
end

function DeepCopy(table)
    local copy = {}
    for k, v in pairs(table) do
        if type(v) == 'table' then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function FormatNumber(number)
    return tostring(number):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end
