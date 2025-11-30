local RequestRouter = {}

local registered_routes = {}

function RequestRouter.register(method, pattern, handler)
    if not registered_routes[method] then
        registered_routes[method] = {}
    end
    
    table.insert(registered_routes[method], {
        pattern = pattern,
        handler = handler
    })
end

local function match_route(pattern, path)
    local params = {}
    local pattern_parts = {}
    local path_parts = {}
    
    for part in pattern:gmatch("[^/]+") do
        table.insert(pattern_parts, part)
    end
    
    for part in path:gmatch("[^/]+") do
        table.insert(path_parts, part)
    end
    
    if #pattern_parts ~= #path_parts then
        return nil
    end
    
    for i, pattern_part in ipairs(pattern_parts) do
        local param_name = pattern_part:match("^:(.+)$")
        if param_name then
            params[param_name] = path_parts[i]
        end
        
        if not param_name and pattern_part ~= path_parts[i] then
            return nil
        end
    end
    
    return params
end

function RequestRouter.route(method, path)
    local method_routes = registered_routes[method]
    
    if not method_routes then
        return nil
    end
    
    for _, route_item in ipairs(method_routes) do
        local params = match_route(route_item.pattern, path)
        if params then
            return route_item.handler, params
        end
    end
    
    return nil
end

return RequestRouter
