package.path = "./deps/?.lua;./deps/?/main.lua;./deps/lpm-core/src/?.lua;./src/?.lua;./src/?/init.lua;" .. package.path
package.cpath = "./deps/lpm-core/src/?.so;" .. package.cpath

local Core = require("lpm-core")
local Server = require("server_init")

Server.start()
