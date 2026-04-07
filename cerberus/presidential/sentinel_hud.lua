--[[
    SENTINEL HUD - Panel de Control Central
    CERBERUS OPS - Presidential System
    Nivel de Seguridad: 2 (AMARILLO)
    Versión: 2.2.0
]]

local SentinelHUD = {
    systems = {
        {id = "NUCLEAR", name = "Control Nuclear", status = "OFF?", channel = 101},
        {id = "MSG", name = "Mensajeria", status = "OFF?", channel = 102},
        {id = "DOCS", name = "Documentos", status = "OFF?", channel = 103},
        {id = "AUTH", name = "Autenticacion", status = "OFF?", channel = 100}
    }
}

local modem = nil

function SentinelHUD:init()
    self.modem = peripheral.find("modem")
    if self.modem then
        self.modem.open(100)
    end
    return self
end

function SentinelHUD:pingSystem(channel)
    if not self.modem then return false end
    
    self.modem.transmit(channel, 0, {type = "PING", from = os.computerID()})
    
    local timeout = os.startTimer(2)
    while true do
        local event, p1, p2, p3 = os.pullEvent()
        
        if event == "timer" and p1 == timeout then
            return false
        elseif event == "modem_message" then
            local msg = p4
            if msg and msg.type == "PONG" then
                return true
            end
        end
    end
end

function SentinelHUD:checkAllSystems()
    for _, system in ipairs(self.systems) do
        local online = self:pingSystem(system.channel)
        system.status = online and "ONLINE" or "OFFLINE"
    end
end

function SentinelHUD:draw()
    local w, h = term.getSize()
    
    term.setBackgroundColor(colors.black)
    term.clear()
    
    -- Header
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(1, 1)
    term.write(string.rep(" ", w))
    term.setCursorPos(1, 2)
    local title = "SENTINEL HUD - PANEL DE CONTROL CENTRAL"
    local x = math.floor((w - #title) / 2)
    if x < 1 then x = 1 end
    term.setCursorPos(x, 2)
    term.write(title)
    term.setCursorPos(1, 3)
    term.write(string.rep(" ", w))
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    local y = 5
    term.setCursorPos(2, y)
    term.write("================================================")
    y = y + 1
    term.setCursorPos(2, y)
    term.write("ESTADO DEL SERVIDOR CENTRAL")
    y = y + 1
    term.setCursorPos(2, y)
    term.write("================================================")
    y = y + 2
    
    term.setCursorPos(2, y)
    print(string.format("%-12s %-25s %-10s", "ID", "NOMBRE", "ESTADO"))
    y = y + 1
    term.setCursorPos(2, y)
    term.write("------------------------------------------------")
    y = y + 1
    
    for _, sys in ipairs(self.systems) do
        term.setCursorPos(2, y)
        local color = sys.status == "ONLINE" and colors.green or colors.gray
        term.setTextColor(color)
        print(string.format("%-12s %-25s %-10s", sys.id, sys.name, sys.status))
        y = y + 1
    end
    
    y = y + 1
    term.setTextColor(colors.white)
    term.setCursorPos(2, y)
    term.write("================================================")
    y = y + 2
    
    term.setCursorPos(2, y)
    print("[1] NUCLEAR_CONTROL")
    y = y + 1
    term.setCursorPos(2, y)
    print("[2] SECURE_MSG")
    y = y + 1
    term.setCursorPos(2, y)
    print("[3] SECURE_DOCS")
    
    y = h - 4
    term.setCursorPos(2, y)
    term.setTextColor(colors.gray)
    term.write("------------------------------------------------")
    y = y + 1
    
    local uptime = math.floor(os.clock())
    term.setCursorPos(2, y)
    term.setTextColor(colors.white)
    print(string.format("ID: %d | Uptime: %d s", os.computerID(), uptime))
    
    y = y + 1
    term.setCursorPos(2, y)
    term.setTextColor(colors.green)
    print("[R] Refrescar | [Q] Salir")
    
    y = y + 1
    term.setCursorPos(2, y)
    term.setTextColor(colors.lime)
    print("CERBERUS OPS v" .. CERBERUS.version)
end

function SentinelHUD:run()
    self:init()
    
    while true do
        self:checkAllSystems()
        self:draw()
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q then
            break
        elseif key == keys.r then
            self:checkAllSystems()
        end
    end
end

return SentinelHUD
