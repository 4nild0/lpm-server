local HttpRequestParser = {}

local function extract_request_line(lines)
    if #lines == 0 then
        return nil
    end
    return lines[1]
end

local function parse_request_line(request_line)
    return request_line:match("^(%S+)%s+(%S+)%s+(%S+)$")
end

local function parse_headers(lines)
    local headers = {}
    local index = 2
    while index <= #lines and lines[index] ~= "" do
        local key, value = lines[index]:match("^([^:]+):%s*(.+)$")
        if key then
            headers[key:lower()] = value
        end
        index = index + 1
    end
    return headers
end

local function extract_body(raw_request)
    local body_start = raw_request:find("\r\n\r\n")
    if not body_start then
        return ""
    end
    return raw_request:sub(body_start + 4)
end

function HttpRequestParser.parse(raw_request)
    local lines = {}
    for line in raw_request:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    local request_line = extract_request_line(lines)
    if not request_line then
        return nil
    end
    
    local method, path, protocol = parse_request_line(request_line)
    if not method then
        return nil
    end
    
    local headers = parse_headers(lines)
    local body = extract_body(raw_request)
    
    return {
        method = method,
        path = path,
        protocol = protocol,
        headers = headers,
        body = body
    }
end

return HttpRequestParser

