package.path = package.path .. ";./src/?.lua"

local server = require("src.server")

if arg[1] then
    local port = tonumber(arg[1]) or 8080
    server.start(port)
end
