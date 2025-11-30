local fs = require("fs")
local path = require("path")

local M = {}

local STORAGE_DIR = "packages"

function M.init()
    if not fs.exists(STORAGE_DIR) then
        fs.mkdir_p(STORAGE_DIR)
    end
end

function M.get_package_path(name, version)
    return path.join(STORAGE_DIR, name, version)
end

function M.get_package_file(name, version)
    local pkg_path = M.get_package_path(name, version)
    return path.join(pkg_path, name .. "-" .. version .. ".zip")
end

function M.save_package(name, version, data)
    local pkg_path = M.get_package_path(name, version)
    
    if not fs.exists(pkg_path) then
        fs.mkdir_p(pkg_path)
    end
    
    local file_path = M.get_package_file(name, version)
    return fs.write_file(file_path, data)
end

function M.load_package(name, version)
    local file_path = M.get_package_file(name, version)
    
    if not fs.exists(file_path) then
        return nil
    end
    
    return fs.read_file(file_path)
end

function M.list_packages()
    local packages = {}
    
    if not fs.exists(STORAGE_DIR) then
        return packages
    end
    
    local names = fs.list_dir(STORAGE_DIR)
    for _, name in ipairs(names) do
        local name_path = path.join(STORAGE_DIR, name)
        if fs.is_dir(name_path) then
            local versions = fs.list_dir(name_path)
            for _, version in ipairs(versions) do
                if fs.is_dir(path.join(name_path, version)) then
                    table.insert(packages, {
                        name = name,
                        version = version
                    })
                end
            end
        end
    end
    
    return packages
end

return M
