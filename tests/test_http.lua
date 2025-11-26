local t = require("lpm-test.src.lpm_test")
local http = require("src.http")

local M = {}

function M.test_parse_request()
    local req_str = "GET /test HTTP/1.1\r\nHost: localhost\r\n\r\n"
    local req = http.parse_request(req_str)
    
    t.assert_equal("GET", req.method, "Method should be GET")
    t.assert_equal("/test", req.path, "Path should be /test")
end

function M.test_build_response()
    local resp = http.build_response(200, "ok")
    t.assert_true(resp:find("200 OK") ~= nil, "Response should contain 200 OK")
end

return M
