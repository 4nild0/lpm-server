local sock_lib = require("lpm_socket")
local logger = require("logger")

local M = {}

local function parse_request(raw)
    local lines = {}
    for line in raw:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    if #lines == 0 then
        return nil
    end
    
    local request_line = lines[1]
    local method, path, protocol = request_line:match("^(%S+)%s+(%S+)%s+(%S+)$")
    
    if not method then
        return nil
    end
    
    local headers = {}
    local i = 2
    while i <= #lines and lines[i] ~= "" do
        local key, value = lines[i]:match("^([^:]+):%s*(.+)$")
        if key then
            headers[key:lower()] = value
        end
        i = i + 1
    end
    
    local body_start = raw:find("\r\n\r\n")
    local body = ""
    if body_start then
        body = raw:sub(body_start + 4)
    end
    
    return {
        method = method,
        path = path,
        protocol = protocol,
        headers = headers,
        body = body
    }
end

local function build_response(status, headers, body)
    local status_messages = {
        [200] = "OK",
        [201] = "Created",
        [400] = "Bad Request",
        [401] = "Unauthorized",
        [404] = "Not Found",
        [500] = "Internal Server Error"
    }
    
    local lines = {}
    table.insert(lines, string.format("HTTP/1.1 %d %s", status, status_messages[status] or "Unknown"))
    
    table.insert(lines, "Access-Control-Allow-Origin: *")
    table.insert(lines, "Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS")
    table.insert(lines, "Access-Control-Allow-Headers: Content-Type, Authorization")
    
    for key, value in pairs(headers or {}) do
        table.insert(lines, string.format("%s: %s", key, value))
    end
    
    if body then
        table.insert(lines, string.format("Content-Length: %d", #body))
    end
    
    table.insert(lines, "")
    table.insert(lines, "")
    
    local response = table.concat(lines, "\r\n")
    
    if body then
        response = response .. body
    end
    
    return response
end

function M.create_response(status, body, content_type)
    local headers = {}
    if content_type then
        headers["Content-Type"] = content_type
    end
    return {
        status = status,
        headers = headers,
        body = body or ""
    }
end

function M.start(host, port, handler)
    logger.info("Starting server on " .. host .. ":" .. port)
    
    local sock = sock_lib.create()
    if not sock then
        logger.error("Failed to create socket")
        return
    end
    
    local ok, err = sock_lib.bind(sock, host, port)
    if not ok then
        logger.error("Failed to bind: " .. (err or "unknown error"))
        sock_lib.close(sock)
        return
    end
    
    ok, err = sock_lib.listen(sock, 10)
    if not ok then
        logger.error("Failed to listen: " .. (err or "unknown error"))
        sock_lib.close(sock)
        return
    end
    
    logger.info("Server listening")
    
    while true do
        local client, client_ip = sock_lib.accept(sock)
        
        if client then
            logger.debug("Connection from " .. (client_ip or "unknown"))
            
            local raw_headers = ""
            while true do
                local chunk = sock_lib.recv(client, 4096)
                if not chunk or #chunk == 0 then
                    break
                end
                raw_headers = raw_headers .. chunk
                if raw_headers:find("\r\n\r\n") then
                    break
                end
            end
            
            local request = parse_request(raw_headers)
            
            if request then
                local content_length = tonumber(request.headers["content-length"]) or 0
                
                if content_length > 0 then
                    local body_start = raw_headers:find("\r\n\r\n")
                    if body_start then
                        local already_read = #raw_headers - body_start - 3
                        request.body = raw_headers:sub(body_start + 4)
                        
                        local remaining = content_length - already_read
                        while remaining > 0 do
                            local chunk = sock_lib.recv(client, math.min(remaining, 8192))
                            if not chunk or #chunk == 0 then
                                break
                            end
                            request.body = request.body .. chunk
                            remaining = remaining - #chunk
                        end
                    end
                end
                
                logger.info(request.method .. " " .. request.path)
                
                local response = handler(request)
                local response_data = build_response(
                    response.status,
                    response.headers,
                    response.body
                )
                
                sock_lib.send(client, response_data)
            end
            
            sock_lib.close(client)
        end
    end
end

return M
