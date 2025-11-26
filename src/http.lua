local M = {}

function M.parse_request(str)
    local lines = {}
    for line in str:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    if #lines == 0 then return nil end
    
    local method, path = lines[1]:match("^(%S+)%s+(%S+)")
    
    return {
        method = method,
        path = path
    }
end

function M.build_response(code, body)
    local status = "OK"
    if code == 404 then status = "Not Found" end
    if code == 400 then status = "Bad Request" end
    if code == 500 then status = "Internal Server Error" end
    if code == 201 then status = "Created" end
    
    return string.format(
        "HTTP/1.1 %d %s\r\nContent-Length: %d\r\nAccess-Control-Allow-Origin: *\r\nAccess-Control-Allow-Methods: GET, POST, OPTIONS\r\nAccess-Control-Allow-Headers: Content-Type\r\nContent-Type: application/json\r\n\r\n%s",
        code, status, #body, body
    )
end

return M
