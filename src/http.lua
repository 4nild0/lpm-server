local M = {}

function M.parse_request(data)
    local lines = {}
    for line in data:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    if #lines == 0 then return nil end
    
    local method, path, version = lines[1]:match("^(%S+)%s+(%S+)%s+(%S+)$")
    if not method then return nil end
    
    local headers = {}
    local body_start = 2
    
    for i = 2, #lines do
        if lines[i] == "" then
            body_start = i + 1
            break
        end
        local key, value = lines[i]:match("^([^:]+):%s*(.+)$")
        if key then
            headers[key:lower()] = value
        end
    end
    
    local body = table.concat(lines, "\n", body_start)
    
    return {
        method = method,
        path = path,
        version = version,
        headers = headers,
        body = body
    }
end

function M.build_response(status, headers, body)
    local lines = {}
    table.insert(lines, "HTTP/1.1 " .. status)
    
    headers = headers or {}
    headers["Content-Length"] = headers["Content-Length"] or tostring(#(body or ""))
    
    for key, value in pairs(headers) do
        table.insert(lines, key .. ": " .. value)
    end
    
    table.insert(lines, "")
    table.insert(lines, body or "")
    
    return table.concat(lines, "\r\n")
end

return M
