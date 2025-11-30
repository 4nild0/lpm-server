local JsonEncoder = {}

local function escape_string(str)
    return str:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
end

local function encode_string(value)
    return '"' .. escape_string(value) .. '"'
end

local function encode_number(value)
    return tostring(value)
end

local function encode_boolean(value)
    return value and "true" or "false"
end

local function encode_nil()
    return "null"
end

local function is_array_table(value)
    local max_index = 0
    local count = 0
    
    for key, _ in pairs(value) do
        count = count + 1
        if type(key) ~= "number" then
            return false, 0, 0
        end
        if key > max_index then
            max_index = key
        end
    end
    
    return max_index == count, max_index, count
end

local function encode_array_table(value, max_index)
    local encoded_items = {}
    for index = 1, max_index do
        table.insert(encoded_items, JsonEncoder.encode_value(value[index]))
    end
    return "[" .. table.concat(encoded_items, ",") .. "]"
end

local function encode_object_table(value)
    local encoded_items = {}
    for key, value_item in pairs(value) do
        table.insert(encoded_items, '"' .. tostring(key) .. '":' .. JsonEncoder.encode_value(value_item))
    end
    return "{" .. table.concat(encoded_items, ",") .. "}"
end

local function encode_table(value)
    local is_array, max_index = is_array_table(value)
    if is_array then
        return encode_array_table(value, max_index)
    end
    return encode_object_table(value)
end

function JsonEncoder.encode_value(value)
    local value_type = type(value)
    
    if value_type == "string" then
        return encode_string(value)
    end
    
    if value_type == "number" then
        return encode_number(value)
    end
    
    if value_type == "boolean" then
        return encode_boolean(value)
    end
    
    if value_type == "nil" then
        return encode_nil()
    end
    
    if value_type == "table" then
        return encode_table(value)
    end
    
    return encode_nil()
end

function JsonEncoder.encode(value)
    return JsonEncoder.encode_value(value)
end

local JsonDecoder = {}

local function skip_whitespace(str, position)
    while position <= #str and str:sub(position, position):match("%s") do
        position = position + 1
    end
    return position
end

local function decode_escape_sequence(str, position)
    position = position + 1
    local next_char = str:sub(position, position)
    
    if next_char == 'n' then
        return "\n", position + 1
    end
    
    if next_char == 'r' then
        return "\r", position + 1
    end
    
    if next_char == 't' then
        return "\t", position + 1
    end
    
    if next_char == '\\' then
        return "\\", position + 1
    end
    
    if next_char == '"' then
        return '"', position + 1
    end
    
    return next_char, position + 1
end

local function decode_string_value(str, position)
    local start_position = position + 1
    local decoded_result = ""
    position = start_position
    
    while position <= #str do
        local current_char = str:sub(position, position)
        
        if current_char == '\\' and position < #str then
            local decoded_char, new_position = decode_escape_sequence(str, position)
            decoded_result = decoded_result .. decoded_char
            position = new_position
        end
        
        if current_char == '"' then
            return decoded_result, position + 1
        end
        
        if current_char ~= '\\' then
            decoded_result = decoded_result .. current_char
            position = position + 1
        end
    end
    
    return decoded_result, position
end

local function decode_object_value(str, position)
    local decoded_object = {}
    position = position + 1
    
    while position <= #str do
        position = skip_whitespace(str, position)
        
        if str:sub(position, position) == '}' then
            return decoded_object, position + 1
        end
        
        local key, new_position = JsonDecoder.decode_value(str, position)
        if not key then
            break
        end
        position = new_position
        
        position = skip_whitespace(str, position)
        
        if str:sub(position, position) ~= ':' then
            break
        end
        position = position + 1
        
        local value, value_position = JsonDecoder.decode_value(str, position)
        if not value then
            break
        end
        position = value_position
        
        decoded_object[key] = value
        
        position = skip_whitespace(str, position)
        
        if str:sub(position, position) == ',' then
            position = position + 1
        end
    end
    
    return decoded_object, position
end

local function decode_array_value(str, position)
    local decoded_array = {}
    position = position + 1
    local array_index = 1
    
    while position <= #str do
        position = skip_whitespace(str, position)
        
        if str:sub(position, position) == ']' then
            return decoded_array, position + 1
        end
        
        local value, new_position = JsonDecoder.decode_value(str, position)
        if not value then
            break
        end
        position = new_position
        
        decoded_array[array_index] = value
        array_index = array_index + 1
        
        position = skip_whitespace(str, position)
        
        if str:sub(position, position) == ',' then
            position = position + 1
        end
    end
    
    return decoded_array, position
end

local function decode_number_value(str, position)
    local start_position = position
    while position <= #str and (str:sub(position, position):match("%d") or str:sub(position, position) == '.' or str:sub(position, position) == '-' or str:sub(position, position) == 'e' or str:sub(position, position) == 'E' or str:sub(position, position) == '+') do
        position = position + 1
    end
    local number_string = str:sub(start_position, position - 1)
    local number_value = tonumber(number_string)
    return number_value, position
end

local function decode_boolean_true(str, position)
    return true, position + 4
end

local function decode_boolean_false(str, position)
    return false, position + 5
end

local function decode_null_value(str, position)
    return nil, position + 4
end

function JsonDecoder.decode_value(str, position)
    position = position or 1
    position = skip_whitespace(str, position)
    
    if position > #str then
        return nil, position
    end
    
    local current_char = str:sub(position, position)
    
    if current_char == '"' then
        return decode_string_value(str, position)
    end
    
    if current_char == '{' then
        return decode_object_value(str, position)
    end
    
    if current_char == '[' then
        return decode_array_value(str, position)
    end
    
    if current_char:match("%d") or current_char == '-' then
        return decode_number_value(str, position)
    end
    
    if str:sub(position, position + 3) == "true" then
        return decode_boolean_true(str, position)
    end
    
    if str:sub(position, position + 4) == "false" then
        return decode_boolean_false(str, position)
    end
    
    if str:sub(position, position + 3) == "null" then
        return decode_null_value(str, position)
    end
    
    return nil, position
end

function JsonDecoder.decode(str)
    local value, _ = JsonDecoder.decode_value(str, 1)
    return value
end

local Json = {}

function Json.encode(value)
    return JsonEncoder.encode(value)
end

function Json.decode(str)
    return JsonDecoder.decode(str)
end

return Json
