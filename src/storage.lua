local M = {}
local root_dir = "packages"

function M.init(dir)
    root_dir = dir or "packages"
    os.execute("mkdir -p " .. root_dir)
end

function M.save_package(name, version, manifest, archive_data)
    local pkg_dir = string.format("%s/%s/%s", root_dir, name, version)
    os.execute("mkdir -p " .. pkg_dir)
    
    local f_man = io.open(pkg_dir .. "/package.toml", "w")
    if not f_man then return false, "failed to write manifest" end
    f_man:write(manifest)
    f_man:close()
    
    local f_arc = io.open(pkg_dir .. "/archive.zip", "w")
    if not f_arc then return false, "failed to write archive" end
    f_arc:write(archive_data)
    f_arc:close()
    
    return true
end

function M.exists(name, version)
    local path = string.format("%s/%s/%s/package.toml", root_dir, name, version)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

function M.get_archive_path(name, version)
    return string.format("%s/%s/%s/archive.zip", root_dir, name, version)
end

function M.list_projects()
    local projects = {}
    local p = io.popen("ls -1 " .. root_dir)
    for name in p:lines() do
        table.insert(projects, name)
    end
    p:close()
    return projects
end

function M.get_versions(name)
    local versions = {}
    local p = io.popen("ls -1 " .. root_dir .. "/" .. name .. " 2>/dev/null")
    for v in p:lines() do
        table.insert(versions, v)
    end
    p:close()
    return versions
end

return M
