local Authentication = {}

local authentication_token = nil

function Authentication.init()
    authentication_token = _G.ENV.AUTH_TOKEN or "default-token"
end

function Authentication.validate(token)
    if not authentication_token then
        Authentication.init()
    end
    return token == authentication_token
end

function Authentication.extract_from_header(authorization_header)
    if not authorization_header then
        return nil
    end
    
    local token = authorization_header:match("^Bearer%s+(.+)$")
    if token then
        return token
    end
    
    return authorization_header
end

return Authentication
