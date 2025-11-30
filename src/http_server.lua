local HttpServer = {}

local function create_response_object(status, body, content_type)
    local headers = {}
    if content_type then
        headers["Content-Type"] = content_type
    end
    return {
        status = status,
        headers = headers,
        body = body or ""
    }
end

local function handle_client_request(socket_library, logger, request_parser, body_reader, request_reader, response_builder, client, request_handler)
    logger.debug("Connection from " .. (client or "unknown"))
    
    local raw_headers = request_reader.read_headers(socket_library, client)
    local request = request_parser.parse(raw_headers)
    
    if not request then
        return
    end
    
    local content_length = tonumber(request.headers["content-length"]) or 0
    request.body = body_reader.read_body(socket_library, client, raw_headers, content_length)
    
    logger.info(request.method .. " " .. request.path)
    
    local response = request_handler(request)
    local response_data = response_builder.build(
        response.status,
        response.headers,
        response.body
    )
    
    socket_library.send(client, response_data)
end

local function accept_connections(socket_library, logger, request_parser, body_reader, request_reader, response_builder, server_socket, request_handler)
    while true do
        local client = socket_library.accept(server_socket)
        if not client then
            return
        end
        
        handle_client_request(socket_library, logger, request_parser, body_reader, request_reader, response_builder, client, request_handler)
        socket_library.close(client)
    end
end

local function setup_socket(socket_library, logger, host, port)
    local server_socket = socket_library.create()
    if not server_socket then
        logger.error("Failed to create socket")
        return nil
    end
    
    local bind_ok, bind_error = socket_library.bind(server_socket, host, port)
    if not bind_ok then
        logger.error("Failed to bind: " .. (bind_error or "unknown error"))
        socket_library.close(server_socket)
        return nil
    end
    
    local listen_ok, listen_error = socket_library.listen(server_socket, 10)
    if not listen_ok then
        logger.error("Failed to listen: " .. (listen_error or "unknown error"))
        socket_library.close(server_socket)
        return nil
    end
    
    return server_socket
end

function HttpServer.create_response(status, body, content_type)
    return create_response_object(status, body, content_type)
end

function HttpServer.start(host, port, request_handler)
    local logger = require("logger")
    local socket_library = require("lpm_socket")
    local request_parser = require("http_request_parser")
    local body_reader = require("http_request_body_reader")
    local request_reader = require("http_request_reader")
    local response_builder = require("http_response_builder")
    
    logger.info("Starting server on " .. host .. ":" .. port)
    
    local server_socket = setup_socket(socket_library, logger, host, port)
    if not server_socket then
        return
    end
    
    logger.info("Server listening")
    
    accept_connections(socket_library, logger, request_parser, body_reader, request_reader, response_builder, server_socket, request_handler)
end

return HttpServer

