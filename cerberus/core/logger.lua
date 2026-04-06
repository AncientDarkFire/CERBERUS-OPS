--[[
    Logger System
    CERBERUS OPS - Core Module
    Versión: 2.0.0
]]

local Logger = {
    LEVELS = {DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, FATAL = 5},
    COLORS = {
        DEBUG = colors.lightGray,
        INFO = colors.white,
        WARN = colors.yellow,
        ERROR = colors.red,
        FATAL = colors.red
    },
    currentLevel = 2,
    logToFile = true,
    logFile = "/cerberus/logs/system.log"
}

local function formatTimestamp()
    local t = os.date("!*t")
    return string.format("%04d-%02d-%02d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
end

local function ensureLogDir()
    if not fs.exists("/cerberus/logs") then
        fs.makeDir("/cerberus/logs")
    end
end

function Logger:setLevel(level)
    self.currentLevel = level
end

function Logger:debug(msg, ...) self:log("DEBUG", string.format(msg, ...)) end
function Logger:info(msg, ...) self:log("INFO", string.format(msg, ...)) end
function Logger:warn(msg, ...) self:log("WARN", string.format(msg, ...)) end
function Logger:error(msg, ...) self:log("ERROR", string.format(msg, ...)) end
function Logger:fatal(msg, ...) self:log("FATAL", string.format(msg, ...)) end

function Logger:log(level, message)
    local logLine = string.format("[%s] [%s] %s", formatTimestamp(), level, message)
    
    if term.isColor then
        local prev = term.getTextColor()
        term.setTextColor(self.COLORS[level] or colors.white)
        print(logLine)
        term.setTextColor(prev)
    else
        print(logLine)
    end
    
    if self.logToFile then
        ensureLogDir()
        local file = fs.open(self.logFile, "a")
        if file then
            file.writeLine(logLine)
            file.close()
        end
    end
end

function Logger:getRecentLogs(lines)
    lines = lines or 50
    if not fs.exists(self.logFile) then return {} end
    
    local logs = {}
    local file = fs.open(self.logFile, "r")
    while true do
        local line = file.readLine()
        if not line then break end
        table.insert(logs, line)
    end
    file.close()
    
    local start = math.max(1, #logs - lines + 1)
    local result = {}
    for i = start, #logs do
        table.insert(result, logs[i])
    end
    return result
end

function Logger:clearLogs()
    if fs.exists(self.logFile) then
        fs.delete(self.logFile)
    end
end

return Logger
