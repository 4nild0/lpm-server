local M = {}

local auth_token = nil

function M.init()
    auth_token = _G.ENV.AUTH_TOKEN or "default-token"
end

function M.validate(token)
    if not auth_token then
        M.init()
    end
    return token == auth_token
end

function M.extract_from_header(auth_header)
    if not auth_header then
        return nil
    end
    
    local token = auth_header:match("^Bearer%s+(.+)$")
    if token then
        return token
    end
    
    return auth_header
end

return M
