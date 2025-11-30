local HttpRequestReader = {}

function HttpRequestReader.read_headers(socket_library, client)
    local raw_headers = ""
    while true do
        local chunk = socket_library.recv(client, 4096)
        if not chunk or #chunk == 0 then
            break
        end
        raw_headers = raw_headers .. chunk
        if raw_headers:find("\r\n\r\n") then
            break
        end
    end
    return raw_headers
end

return HttpRequestReader

