

package.path = package.path .. ";./src/?.lua;./deps/lpm-core/src/?.lua;./deps/lpm-core/src/init.lua"

local core = require("init")

local http = require("http")
local storage = require("storage")

local function assert_eq(a, b, msg)
    if a ~= b then
        error(string.format("%s: expected %s, got %s", msg or "Assertion failed", tostring(b), tostring(a)))
    end
end

local function test_http_parse()
    print("Testing HTTP parse...")
    local data = "GET /test HTTP/1.1\r\nHost: localhost\r\n\r\n"
    local req = http.parse_request(data)
    assert_eq(req.method, "GET", "method mismatch")
    assert_eq(req.path, "/test", "path mismatch")
end

local function test_http_build()
    print("Testing HTTP build...")
    local response = http.build_response("200 OK", {}, "Hello")
    assert_eq(response:match("200 OK") ~= nil, true, "status not found")
    assert_eq(response:match("Hello") ~= nil, true, "body not found")
end

local function test_storage()
    print("Testing storage...")
    storage.init()
    local ok = storage.save_package("test", "1.0.0", "test data")
    assert_eq(ok, true, "save failed")
    local data = storage.get_package("test", "1.0.0")
    assert_eq(data, "test data", "data mismatch")
end


test_http_parse()
test_http_build()
test_storage()

print("All tests passed!")
