-- Add deps to path
package.path = package.path .. ";deps/?.lua"

local runner = require("lpm-test.src.runner")

local files = {
    "tests/test_http.lua",
    "tests/test_server.lua",
    "tests/test_storage.lua"
}

local success = runner.run(files)

if not success then
    os.exit(1)
end
