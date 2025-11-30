local server = require("server")
local router = require("router")
local storage = require("storage")
local auth = require("auth")
local logger = require("logger")

local packages = require("routes.packages")
local static = require("routes.static")

local M = {}

function M.init()
    storage.init()
    auth.init()
    
    if _G.ENV.DEBUG == "true" then
        logger.set_level("DEBUG")
    end
    
    router.register("GET", "/packages/:name/:version", packages.download)
    router.register("POST", "/packages/:name/:version", packages.upload)
    router.register("GET", "/packages", packages.list)
    router.register("GET", "/*", static.serve)
end

function M.handle_request(request)
    if request.method == "OPTIONS" then
        return server.create_response(200, "")
    end
    
    local handler, params = router.route(request.method, request.path)
    
    if not handler then
        return server.create_response(404, "Not found")
    end
    
    return handler(request, params or {})
end

function M.start()
    M.init()
    
    local host = _G.ENV.HOST or "0.0.0.0"
    local port = tonumber(_G.ENV.PORT) or 8080
    
    server.start(host, port, M.handle_request)
end

return M
