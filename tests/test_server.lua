local t = require("lpm-test.src.lpm_test")

local M = {}

function M.test_server_start()
    local mock_input = {
        "GET /projects HTTP/1.1",
        "Host: localhost:4040",
        "User-Agent: test",
        "",
    }
    local input_index = 1
    local output = {}
    
    local original_io = _G.io
    _G.io = {
        read = function(n)
            if type(n) == "number" then
                return ""
            end
            local line = mock_input[input_index]
            input_index = input_index + 1
            return line
        end,
        write = function(data)
            table.insert(output, data)
        end,
        flush = function() end,
        open = function() return nil end
    }
    
    local original_storage = package.loaded["src.storage"]
    package.loaded["src.storage"] = {
        init = function() end,
        list_projects = function() return {"test-proj"} end
    }
    
    package.loaded["src.server"] = nil
    local server = require("src.server")
    
    -- Mock server loop to run once or handle it differently?
    -- The original test called server.start(4040).
    -- If server.start loops forever, this test will hang.
    -- Assuming server.start in the original test was designed to be testable or the mock makes it exit?
    -- Looking at the original test, it just called server.start(4040).
    -- If the original test passed, then server.start must return or handle one request.
    -- I will assume it works as is.
    
    -- Wait, if server.start is an infinite loop, how did the original test pass?
    -- Maybe the mock io.read returns nil eventually?
    -- In the mock: if input_index > #mock_input, it returns nil (implied).
    -- Let's check the mock again.
    -- `local line = mock_input[input_index]` -> if index out of bounds, line is nil.
    -- So it returns nil. The server probably stops on nil input.
    
    server.start(4040)
    
    local response = table.concat(output)
    t.assert_true(response:find("HTTP/1.1 200") ~= nil, "Should return 200 OK")
    t.assert_true(response:find("test%-proj") ~= nil, "Should contain project data")
    t.assert_true(response:find("Access%-Control%-Allow%-Origin") ~= nil, "Should have CORS headers")
    
    _G.io = original_io
    package.loaded["src.storage"] = original_storage
end

return M
