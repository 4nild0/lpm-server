local http_server = require("server")
local request_router = require("router")
local package_storage = require("storage")
local authentication = require("auth")
local logger_module = require("logger")

local packages_route = require("routes.packages")
local static_route = require("routes.static")

local ServerInitializer = {}

function ServerInitializer.initialize()
    package_storage.init()
    authentication.init()
    
    if _G.ENV.DEBUG == "true" then
        logger_module.set_level("DEBUG")
    end
    
    request_router.register("GET", "/packages", packages_route.list)
    request_router.register("GET", "/packages/:name/versions", packages_route.list_versions)
    request_router.register("GET", "/packages/:name/:version", packages_route.get)
    request_router.register("GET", "/packages/:name/:version/download", packages_route.download)
    request_router.register("POST", "/packages/:name/:version", packages_route.create)
    request_router.register("PUT", "/packages/:name/:version", packages_route.update)
    request_router.register("DELETE", "/packages/:name/:version", packages_route.delete)
    request_router.register("GET", "/*", static_route.serve)
end

function ServerInitializer.handle_request(request)
    if request.method == "OPTIONS" then
        return http_server.create_response(200, "")
    end
    
    local handler, params = request_router.route(request.method, request.path)
    
    if not handler then
        return http_server.create_response(404, "Not found")
    end
    
    return handler(request, params or {})
end

function ServerInitializer.start()
    ServerInitializer.initialize()
    
    local host = _G.ENV.HOST or "0.0.0.0"
    local port = tonumber(_G.ENV.PORT) or 8080
    
    http_server.start(host, port, ServerInitializer.handle_request)
end

return ServerInitializer
