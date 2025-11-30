local package_storage = require("storage")
local authentication = require("auth")
local http_server = require("server")
local logger_module = require("logger")
local json_encoder = require("json")

local PackagesRoute = {}

function PackagesRoute.list(request, params)
    local packages = package_storage.list_packages()
    
    local result = {}
    for _, package_item in ipairs(packages) do
        table.insert(result, {
            name = package_item.name,
            version = package_item.version
        })
    end
    
    local body = json_encoder.encode(result)
    return http_server.create_response(200, body, "application/json")
end

function PackagesRoute.get(request, params)
    local package_name = params.name
    local package_version = params.version
    
    if not package_name or not package_version then
        return http_server.create_response(400, "Name and version required")
    end
    
    logger_module.info("Get package: " .. package_name .. "@" .. package_version)
    
    local package_info = package_storage.get_package_info(package_name, package_version)
    
    if not package_info then
        return http_server.create_response(404, json_encoder.encode({error = "Package not found"}), "application/json")
    end
    
    local body = json_encoder.encode(package_info)
    return http_server.create_response(200, body, "application/json")
end

function PackagesRoute.download(request, params)
    local package_name = params.name
    local package_version = params.version
    
    logger_module.info("Download request: " .. package_name .. "@" .. package_version)
    
    local package_data = package_storage.load_package(package_name, package_version)
    
    if not package_data then
        return http_server.create_response(404, "Package not found")
    end
    
    return http_server.create_response(200, package_data, "application/zip")
end

function PackagesRoute.create(request, params)
    local package_name = params.name
    local package_version = params.version
    
    if not package_name or not package_version then
        return http_server.create_response(400, "Name and version required")
    end
    
    local token = authentication.extract_from_header(request.headers["authorization"])
    
    if not authentication.validate(token) then
        return http_server.create_response(401, json_encoder.encode({error = "Unauthorized"}), "application/json")
    end
    
    logger_module.info("Create package: " .. package_name .. "@" .. package_version)
    
    if not request.body or #request.body == 0 then
        return http_server.create_response(400, json_encoder.encode({error = "Package data required"}), "application/json")
    end
    
    local success = package_storage.save_package(package_name, package_version, request.body)
    
    if not success then
        return http_server.create_response(500, json_encoder.encode({error = "Failed to save package"}), "application/json")
    end
    
    local package_info = package_storage.get_package_info(package_name, package_version)
    local body = json_encoder.encode({message = "Package created", package = package_info})
    return http_server.create_response(201, body, "application/json")
end

function PackagesRoute.update(request, params)
    local package_name = params.name
    local package_version = params.version
    
    if not package_name or not package_version then
        return http_server.create_response(400, "Name and version required")
    end
    
    local token = authentication.extract_from_header(request.headers["authorization"])
    
    if not authentication.validate(token) then
        return http_server.create_response(401, json_encoder.encode({error = "Unauthorized"}), "application/json")
    end
    
    logger_module.info("Update package: " .. package_name .. "@" .. package_version)
    
    if not request.body or #request.body == 0 then
        return http_server.create_response(400, json_encoder.encode({error = "Package data required"}), "application/json")
    end
    
    local success = package_storage.update_package(package_name, package_version, request.body)
    
    if not success then
        return http_server.create_response(404, json_encoder.encode({error = "Package not found"}), "application/json")
    end
    
    local package_info = package_storage.get_package_info(package_name, package_version)
    local body = json_encoder.encode({message = "Package updated", package = package_info})
    return http_server.create_response(200, body, "application/json")
end

function PackagesRoute.delete(request, params)
    local package_name = params.name
    local package_version = params.version
    
    if not package_name or not package_version then
        return http_server.create_response(400, "Name and version required")
    end
    
    local token = authentication.extract_from_header(request.headers["authorization"])
    
    if not authentication.validate(token) then
        return http_server.create_response(401, json_encoder.encode({error = "Unauthorized"}), "application/json")
    end
    
    logger_module.info("Delete package: " .. package_name .. "@" .. package_version)
    
    local success = package_storage.delete_package(package_name, package_version)
    
    if not success then
        return http_server.create_response(404, json_encoder.encode({error = "Package not found"}), "application/json")
    end
    
    local body = json_encoder.encode({message = "Package deleted"})
    return http_server.create_response(200, body, "application/json")
end

function PackagesRoute.list_versions(request, params)
    local package_name = params.name
    
    if not package_name then
        return http_server.create_response(400, "Name required")
    end
    
    local versions = package_storage.list_versions(package_name)
    local body = json_encoder.encode({name = package_name, versions = versions})
    return http_server.create_response(200, body, "application/json")
end

return PackagesRoute
