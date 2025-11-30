local fs = require("fs")
local path = require("path")
local server = require("server")

local M = {}

local STATIC_DIR = "../lpm-page"

local function get_content_type(file_path)
    local ext = path.extension(file_path)
    
    local types = {
        html = "text/html",
        css = "text/css",
        js = "application/javascript",
        json = "application/json",
        png = "image/png",
        jpg = "image/jpeg",
        jpeg = "image/jpeg",
        gif = "image/gif",
        svg = "image/svg+xml"
    }
    
    return types[ext] or "application/octet-stream"
end

function M.serve(request, params)
    local file_path = request.path
    
    if file_path == "/" then
        file_path = "/index.html"
    end
    
    local full_path = path.join(STATIC_DIR, file_path)
    
    if not fs.exists(full_path) then
        return server.create_response(404, "File not found")
    end
    
    if not fs.is_file(full_path) then
        return server.create_response(404, "Not a file")
    end
    
    local content = fs.read_file(full_path)
    
    if not content then
        return server.create_response(500, "Failed to read file")
    end
    
    return server.create_response(200, content, get_content_type(full_path))
end

return M
