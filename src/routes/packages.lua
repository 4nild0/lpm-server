local storage = require("storage")
local auth = require("auth")
local server = require("server")
local logger = require("logger")

local M = {}

function M.download(request, params)
    local name = params.name
    local version = params.version
    
    logger.info("Download request: " .. name .. "@" .. version)
    
    local data = storage.load_package(name, version)
    
    if not data then
        return server.create_response(404, "Package not found")
    end
    
    return server.create_response(200, data, "application/zip")
end

function M.upload(request, params)
    local name = params.name
    local version = params.version
    
    local token = auth.extract_from_header(request.headers["authorization"])
    
    if not auth.validate(token) then
        return server.create_response(401, "Unauthorized")
    end
    
    logger.info("Upload request: " .. name .. "@" .. version)
    
    local success = storage.save_package(name, version, request.body)
    
    if not success then
        return server.create_response(500, "Failed to save package")
    end
    
    return server.create_response(201, "Package uploaded")
end

function M.list(request, params)
    local packages = storage.list_packages()
    
    local result = {}
    for _, pkg in ipairs(packages) do
        table.insert(result, pkg.name .. "@" .. pkg.version)
    end
    
    local body = table.concat(result, "\n")
    return server.create_response(200, body, "text/plain")
end

return M
