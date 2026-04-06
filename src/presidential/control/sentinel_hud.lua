--[[
    SENTINEL HUD
    CERBERUS OPS - Presidential System
    Panel de Control Central
    Nivel de Seguridad: 2 (AMARILLO)
    Versión: 1.0.0
    
    Dashboard central que muestra el estado de todos los sistemas.
]]

local SentinelHUD = {
    VERSION = "1.0.0",
    
    REFRESH_RATE = 1,
    
    systems = {
        {id = "NUCLEAR", name = "Control Nuclear", status = "OFFLINE", color = colors.gray, channel = 101},
        {id = "SECURE_MSG", name = "Mensajería", status = "OFFLINE", color = colors.gray, channel = 102},
        {id = "SECURE_DOCS", name = "Documentos", status = "OFFLINE", color = colors.gray, channel = 103},
        {id = "AUTH", name = "Autenticación", status = "OFFLINE", color = colors.gray, channel = 100}
    }
}

local modem = nil
local logger = nil
local ui = nil

function SentinelHUD:init()
    self.modem = peripheral.find("modem")
    if self.modem then
        self.modem.open(100)
        self.modem.open(101)
        self.modem.open(102)
        self.modem.open(103)
    end
    
    self.logger = require("/cerberus/core/systems/logger")
    self.ui = require("/cerberus/templates/ui/components")
    
    self.logger:info("SENTINEL HUD inicializado")
    
    return self
end

function SentinelHUD:pingSystem(channel)
    if not self.modem then return false, "offline" end
    
    local startTime = os.clock()
    
    self.modem.transmit(channel, 0, {
        type = "PING",
        from = os.getComputerID(),
        timestamp = os.time()
    })
    
    local timeout = os.startTimer(2)
    
    while true do
        local event, p1, p2, p3 = os.pullEvent()
        
        if event == "timer" and p1 == timeout then
            return false, "timeout"
        elseif event == "modem_message" then
            local rcvChannel = p2
            if rcvChannel == channel then
                local msg = p4
                if msg and msg.type == "PONG" then
                    return true, "online"
                end
            end
        end
    end
end

function SentinelHUD:checkAllSystems()
    for _, system in ipairs(self.systems) do
        local success, status = self:pingSystem(system.channel)
        
        if success then
            system.status = "ONLINE"
            system.color = colors.green
        else
            system.status = "OFFLINE"
            system.color = colors.gray
        end
    end
end

function SentinelHUD:drawHUD()
    local width, height = term.getSize()
    
    term.setBackgroundColor(colors.black)
    term.clear()
    
    self.ui.drawHeader("SENTINEL HUD - PANEL DE CONTROL CENTRAL", width, 3)
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    term.setCursorPos(2, 5)
    term.write("════════════════════════════════════════════════════════════")
    
    term.setCursorPos(2, 6)
    term.write("ESTADO DEL SERVIDOR CENTRAL")
    term.setCursorPos(2, 7)
    term.write("════════════════════════════════════════════════════════════")
    
    term.setCursorPos(2, 9)
    print(string.format("%-15s %-25s %-10s %-10s",
        "ID", "NOMBRE", "CANAL", "ESTADO"))
    print(string.rep("─", 65))
    
    for _, system in ipairs(self.systems) do
        term.setCursorPos(2, 10 + _ - 1)
        term.setTextColor(system.color)
        print(string.format("%-15s %-25s %-10d %-10s",
            system.id, system.name, system.channel, system.status))
    end
    
    term.setCursorPos(2, 15)
    term.setTextColor(colors.white)
    term.write("════════════════════════════════════════════════════════════")
    
    term.setCursorPos(2, 17)
    term.write("SISTEMAS PRESIDENCIALES")
    term.setCursorPos(2, 18)
    term.write("════════════════════════════════════════════════════════════")
    
    local y = 20
    term.setCursorPos(2, y)
    print("[1] NUCLEAR_CONTROL - Panel de lanzamiento nuclear")
    term.setCursorPos(2, y + 1)
    print("[2] SECURE_MSG - Mensajería segura")
    term.setCursorPos(2, y + 2)
    print("[3] SECURE_DOCS - Documentos clasificados")
    
    term.setCursorPos(2, height - 4)
    term.setTextColor(colors.gray)
    print("────────────────────────────────────────────────────────────")
    
    local mem = math.floor(computer.freeMemory() / 1024)
    local total = math.floor(computer.totalMemory() / 1024)
    local uptime = math.floor(computer.uptime())
    local hours = math.floor(uptime / 3600)
    local mins = math.floor((uptime % 3600) / 60)
    local secs = uptime % 60
    
    term.setCursorPos(2, height - 3)
    term.setTextColor(colors.white)
    print(string.format("ID: %d | RAM: %d/%d KB | Uptime: %02d:%02d:%02d",
        os.getComputerID(), mem, total, hours, mins, secs))
    
    term.setCursorPos(2, height - 2)
    print("[R] Refrescar | [Q] Salir | [SPACE] Auto-refresh: ON")
    
    term.setCursorPos(2, height - 1)
    term.setTextColor(colors.green)
    print("CERBERUS OPS v" .. self.VERSION .. " | " .. os.date("%Y-%m-%d %H:%M:%S"))
end

function SentinelHUD:handleCommand(cmd)
    if cmd == "1" then
        term.setBackgroundColor(colors.black)
        term.clear()
        print("Abriendo NUCLEAR_CONTROL...")
        print("(Esta función requiere abrir una sesión en la computadora de Control Nuclear)")
        print("")
        print("Presiona cualquier tecla para volver...")
        os.pullEvent("key")
        
    elseif cmd == "2" then
        term.setBackgroundColor(colors.black)
        term.clear()
        print("Abriendo SECURE_MSG...")
        print("(Esta función requiere abrir una sesión en la computadora de Mensajería)")
        print("")
        print("Presiona cualquier tecla para volver...")
        os.pullEvent("key")
        
    elseif cmd == "3" then
        term.setBackgroundColor(colors.black)
        term.clear()
        print("Abriendo SECURE_DOCS...")
        print("(Esta función requiere abrir una sesión en la computadora de Documentos)")
        print("")
        print("Presiona cualquier tecla para volver...")
        os.pullEvent("key")
    end
end

function SentinelHUD:run()
    self:init()
    
    local autoRefresh = true
    local refreshTimer = os.startTimer(self.REFRESH_RATE)
    
    while true do
        self:drawHUD()
        
        local events = {"key", "timer"}
        if autoRefresh then
            table.insert(events, "other")
        end
        
        local event, p1, p2, p3 = os.pullEvent()
        
        if event == "key" then
            if p1 == keys.q then
                self.logger:info("Sentinel HUD cerrado")
                break
                
            elseif p1 == keys.r then
                self:checkAllSystems()
                
            elseif p1 == keys.space then
                autoRefresh = not autoRefresh
                
            elseif p1 == keys.one then
                self:handleCommand("1")
                
            elseif p1 == keys.two then
                self:handleCommand("2")
                
            elseif p1 == keys.three then
                self:handleCommand("3")
            end
            
        elseif event == "timer" and p1 == refreshTimer then
            self:checkAllSystems()
            refreshTimer = os.startTimer(self.REFRESH_RATE)
        end
    end
end

return SentinelHUD
