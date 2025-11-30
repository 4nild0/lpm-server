local t = require("lpm-test.src.lpm_test")
local storage = require("src.storage")

local M = {}

function M.test_save_package()
    os.execute("rm -rf test_packages")
    storage.init("test_packages")
    
    local manifest = 'name = "test"\nversion = "1.0.0"'
    local archive_data = "PK\3\4..." 
    
    local ok, err = storage.save_package("test", "1.0.0", manifest, archive_data)
    t.assert_true(ok, "Save should succeed: " .. tostring(err))
    
    t.assert_true(storage.exists("test", "1.0.0"), "Package should exist")
    
    local path = storage.get_archive_path("test", "1.0.0")
    local f = io.open(path, "r")
    t.assert_true(f ~= nil, "Archive file should exist")
    
    local content = f:read("*a")
    f:close()
    
    t.assert_equal(archive_data, content, "Archive content should match")
    
    os.execute("rm -rf test_packages")
end

return M
