local Logger = {}

local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

local current_level = LOG_LEVELS.INFO

function Logger.set_level(level)
    current_level = LOG_LEVELS[level] or LOG_LEVELS.INFO
end

local function format_message(level, message)
    return string.format("[%s] %s: %s", os.date("%Y-%m-%d %H:%M:%S"), level, message)
end

local function should_log(level)
    return LOG_LEVELS[level] >= current_level
end

function Logger.debug(message)
    if should_log("DEBUG") then
        print(format_message("DEBUG", message))
    end
end

function Logger.info(message)
    if should_log("INFO") then
        print(format_message("INFO", message))
    end
end

function Logger.warn(message)
    if should_log("WARN") then
        print(format_message("WARN", message))
    end
end

function Logger.error(message)
    if should_log("ERROR") then
        print(format_message("ERROR", message))
    end
end

return Logger
