local http = require("src.http")
local storage = require("src.storage")

local M = {}

function M.handle_request(req)
    if req.method == "GET" and req.path == "/projects" then
        local projects = storage.list_projects()
        local json = "["
        for i, p in ipairs(projects) do
            json = json .. '"' .. p .. '"'
            if i < #projects then json = json .. "," end
        end
        json = json .. "]"
        return http.build_response(200, json)
    end
    
    local name = req.path:match("^/projects/(.+)$")
    if req.method == "GET" and name then
        local versions = storage.get_versions(name)
        if #versions == 0 then return http.build_response(404, "Not Found") end
        
        local json = '{"name":"' .. name .. '","versions":['
        for i, v in ipairs(versions) do
            json = json .. '"' .. v .. '"'
            if i < #versions then json = json .. "," end
        end
        json = json .. "]}"
        return http.build_response(200, json)
    end
    
    if req.method == "POST" and req.path:find("^/packages") then
        local name = req.path:match("name=([^&]+)")
        local version = req.path:match("version=([^&]+)")
        
        if not name or not version then
            return http.build_response(400, '{"error":"Missing name or version"}')
        end
        
        if not req.body or #req.body == 0 then
            return http.build_response(400, '{"error":"Empty body"}')
        end
        
        local manifest = string.format('name = "%s"\nversion = "%s"', name, version)
        local ok, err = storage.save_package(name, version, manifest, req.body)
        if ok then
            return http.build_response(201, '{"status":"Uploaded"}')
        else
            return http.build_response(500, '{"error":"' .. tostring(err) .. '"}')
        end
    end

    if req.method == "GET" and req.path == "/stats" then
        local projects = storage.list_projects()
        local count = #projects
        return http.build_response(200, '{"packages":' .. count .. '}')
    end
    
    if req.method == "OPTIONS" then
        return "HTTP/1.1 204 No Content\r\nAccess-Control-Allow-Origin: *\r\nAccess-Control-Allow-Methods: GET, POST, OPTIONS\r\nAccess-Control-Allow-Headers: Content-Type\r\n\r\n"
    end
    
    return http.build_response(404, "Not Found")
end

function M.start(port)
    storage.init()
    
    local first_line = io.read()
    if not first_line then return end
    
    local method, path = first_line:match("^(%S+)%s+(%S+)")
    if not method then return end
    
    local headers = {}
    local content_length = 0
    
    while true do
        local line = io.read()
        if not line or line == "" or line == "\r" then break end
        local k, v = line:match("^(.-):%s*(.*)")
        if k then
            headers[k:lower()] = v
            if k:lower() == "content-length" then
                content_length = tonumber(v)
            end
        end
    end
    
    local body = ""
    if content_length > 0 then
        body = io.read(content_length)
    end
    
    local req = {
        method = method,
        path = path,
        headers = headers,
        body = body
    }
    
    local resp = M.handle_request(req)
    io.write(resp)
    io.flush()
end

return M
