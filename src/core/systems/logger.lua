--[[
    Logger System
    CERBERUS OPS - Core Module
    Versión: 1.0.0
    
    Sistema de registro de eventos del sistema.
    Implementa niveles de log y escritura a archivos.
]]

local Logger = {
    VERSION = "1.0.0",
    
    LEVELS = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4,
        FATAL = 5
    },
    
    COLORS = {
        DEBUG = colors.lightGray,
        INFO = colors.white,
        WARN = colors.yellow,
        ERROR = colors.red,
        FATAL = colors.red
    },
    
    currentLevel = 2,
    logToFile = true,
    logFile = "/cerberus/logs/system.log",
    enableColors = true
}

local function formatTimestamp()
    local t = os.date("!*t")
    return string.format("%04d-%02d-%02d %02d:%02d:%02d",
        t.year, t.month, t.day, t.hour, t.min, t.sec)
end

local function ensureLogDir()
    if not fs.exists("/cerberus/logs") then
        fs.makeDir("/cerberus/logs")
    end
end

function Logger:setLevel(level)
    self.currentLevel = level
end

function Logger:debug(msg, ...)
    if self.LEVELS.DEBUG >= self.currentLevel then
        self:log("DEBUG", string.format(msg, ...))
    end
end

function Logger:info(msg, ...)
    if self.LEVELS.INFO >= self.currentLevel then
        self:log("INFO", string.format(msg, ...))
    end
end

function Logger:warn(msg, ...)
    if self.LEVELS.WARN >= self.currentLevel then
        self:log("WARN", string.format(msg, ...))
    end
end

function Logger:error(msg, ...)
    if self.LEVELS.ERROR >= self.currentLevel then
        self:log("ERROR", string.format(msg, ...))
    end
end

function Logger:fatal(msg, ...)
    if self.LEVELS.FATAL >= self.currentLevel then
        self:log("FATAL", string.format(msg, ...))
    end
end

function Logger:log(level, message)
    local timestamp = formatTimestamp()
    local logLine = string.format("[%s] [%s] %s", timestamp, level, message)
    
    if self.enableColors and term.isColor then
        local prevColor = term.getTextColor()
        term.setTextColor(self.COLORS[level] or colors.white)
        print(logLine)
        term.setTextColor(prevColor)
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
    
    if not fs.exists(self.logFile) then
        return {}
    end
    
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

function Logger:getLogStats()
    if not fs.exists(self.logFile) then
        return {size = 0, lines = 0}
    end
    
    local file = fs.open(self.logFile, "r")
    local content = file.readAll()
    file.close()
    
    local lines = 0
    for _ in content:gmatch("\n") do
        lines = lines + 1
    end
    
    return {
        size = #content,
        lines = lines
    }
end

return Logger
