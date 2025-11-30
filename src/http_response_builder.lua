local HttpResponseBuilder = {}

local status_messages = {
    [200] = "OK",
    [201] = "Created",
    [400] = "Bad Request",
    [401] = "Unauthorized",
    [404] = "Not Found",
    [500] = "Internal Server Error"
}

local function build_status_line(status)
    local message = status_messages[status] or "Unknown"
    return string.format("HTTP/1.1 %d %s", status, message)
end

local function build_cors_headers()
    local cors_headers = {}
    table.insert(cors_headers, "Access-Control-Allow-Origin: *")
    table.insert(cors_headers, "Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS")
    table.insert(cors_headers, "Access-Control-Allow-Headers: Content-Type, Authorization")
    return cors_headers
end

local function build_custom_headers(headers)
    local header_lines = {}
    for key, value in pairs(headers or {}) do
        table.insert(header_lines, string.format("%s: %s", key, value))
    end
    return header_lines
end

local function build_content_length_header(body)
    if not body then
        return {}
    end
    return {string.format("Content-Length: %d", #body)}
end

function HttpResponseBuilder.build(status, headers, body)
    local response_lines = {}
    
    table.insert(response_lines, build_status_line(status))
    
    local cors_headers = build_cors_headers()
    for _, header in ipairs(cors_headers) do
        table.insert(response_lines, header)
    end
    
    local custom_headers = build_custom_headers(headers)
    for _, header in ipairs(custom_headers) do
        table.insert(response_lines, header)
    end
    
    local content_length_headers = build_content_length_header(body)
    for _, header in ipairs(content_length_headers) do
        table.insert(response_lines, header)
    end
    
    table.insert(response_lines, "")
    table.insert(response_lines, "")
    
    local response = table.concat(response_lines, "\r\n")
    
    if body then
        response = response .. body
    end
    
    return response
end

return HttpResponseBuilder

