local HttpRequestBodyReader = {}

function HttpRequestBodyReader.read_body(socket_library, client, raw_headers, content_length)
    if content_length <= 0 then
        return ""
    end
    
    local body_start = raw_headers:find("\r\n\r\n")
    if not body_start then
        return ""
    end
    
    local already_read = #raw_headers - body_start - 3
    local body = raw_headers:sub(body_start + 4)
    
    local remaining = content_length - already_read
    while remaining > 0 do
        local chunk = socket_library.recv(client, math.min(remaining, 8192))
        if not chunk or #chunk == 0 then
            break
        end
        body = body .. chunk
        remaining = remaining - #chunk
    end
    
    return body
end

return HttpRequestBodyReader

