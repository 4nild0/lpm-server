local filesystem_operations = require("fs")
local path_operations = require("path")
local metadata_manager = require("metadata")
local toml_parser = require("toml")

local PackageStorage = {}

local STORAGE_DIR = "packages"

function PackageStorage.init()
    if not filesystem_operations.exists(STORAGE_DIR) then
        filesystem_operations.mkdir_p(STORAGE_DIR)
    end
end

function PackageStorage.get_package_path(package_name, package_version)
    return path_operations.join(STORAGE_DIR, package_name, package_version)
end

function PackageStorage.get_package_file(package_name, package_version)
    local package_path = PackageStorage.get_package_path(package_name, package_version)
    return path_operations.join(package_path, package_name .. "-" .. package_version .. ".zip")
end

function PackageStorage.get_package_metadata_file(package_name, package_version)
    local package_path = PackageStorage.get_package_path(package_name, package_version)
    return path_operations.join(package_path, "package.toml")
end

function PackageStorage.save_package(package_name, package_version, package_data)
    local package_path = PackageStorage.get_package_path(package_name, package_version)
    
    if not filesystem_operations.exists(package_path) then
        filesystem_operations.mkdir_p(package_path)
    end
    
    local file_path = PackageStorage.get_package_file(package_name, package_version)
    return filesystem_operations.write_file(file_path, package_data)
end

function PackageStorage.update_package(package_name, package_version, package_data)
    local file_path = PackageStorage.get_package_file(package_name, package_version)
    
    if not filesystem_operations.exists(file_path) then
        return false
    end
    
    return filesystem_operations.write_file(file_path, package_data)
end

function PackageStorage.delete_package(package_name, package_version)
    local package_path = PackageStorage.get_package_path(package_name, package_version)
    
    if not filesystem_operations.exists(package_path) then
        return false
    end
    
    return filesystem_operations.remove(package_path)
end

function PackageStorage.load_package(package_name, package_version)
    local file_path = PackageStorage.get_package_file(package_name, package_version)
    
    if not filesystem_operations.exists(file_path) then
        return nil
    end
    
    return filesystem_operations.read_file(file_path)
end

function PackageStorage.get_package_info(package_name, package_version)
    local package_path = PackageStorage.get_package_path(package_name, package_version)
    
    if not filesystem_operations.exists(package_path) then
        return nil
    end
    
    local metadata_file = PackageStorage.get_package_metadata_file(package_name, package_version)
    local metadata_content = nil
    
    if filesystem_operations.exists(metadata_file) then
        metadata_content = filesystem_operations.read_file(metadata_file)
    end
    
    local file_path = PackageStorage.get_package_file(package_name, package_version)
    local file_size = 0
    if filesystem_operations.exists(file_path) then
        local pipe = io.popen("stat -c %s " .. file_path .. " 2>/dev/null")
        if pipe then
            file_size = tonumber(pipe:read("*n")) or 0
            pipe:close()
        end
    end
    
    return {
        name = package_name,
        version = package_version,
        metadata = metadata_content and toml_parser.decode(metadata_content) or nil,
        size = file_size,
        path = package_path
    }
end

function PackageStorage.list_packages()
    local packages = {}
    
    if not filesystem_operations.exists(STORAGE_DIR) then
        return packages
    end
    
    local package_names = filesystem_operations.list_dir(STORAGE_DIR)
    for _, package_name in ipairs(package_names) do
        local name_path = path_operations.join(STORAGE_DIR, package_name)
        if filesystem_operations.is_dir(name_path) then
            local versions = filesystem_operations.list_dir(name_path)
            for _, version in ipairs(versions) do
                if filesystem_operations.is_dir(path_operations.join(name_path, version)) then
                    table.insert(packages, {
                        name = package_name,
                        version = version
                    })
                end
            end
        end
    end
    
    return packages
end

function PackageStorage.list_versions(package_name)
    local name_path = path_operations.join(STORAGE_DIR, package_name)
    
    if not filesystem_operations.exists(name_path) or not filesystem_operations.is_dir(name_path) then
        return {}
    end
    
    local versions = {}
    local version_directories = filesystem_operations.list_dir(name_path)
    for _, version in ipairs(version_directories) do
        if filesystem_operations.is_dir(path_operations.join(name_path, version)) then
            table.insert(versions, version)
        end
    end
    
    return versions
end

return PackageStorage
