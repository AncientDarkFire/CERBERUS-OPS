local NuclearControl = {
    STATUS = {STANDBY = "STANDBY", ARMED = "ARMED", LAUNCHING = "LAUNCHING"},
    state = {status = "STANDBY", authorized = false, launchArmed = false}
}

local modem = nil

function NuclearControl:init()
    self.modem = peripheral.find("modem")
    if self.modem then
        self.modem.open(101)
    end
    return self
end

function NuclearControl:drawPanel()
    local w, h = term.getSize()

    term.setBackgroundColor(colors.black)
    term.clear()

    -- Header
    term.setBackgroundColor(colors.red)
    term.setCursorPos(1, 1)
    term.write(string.rep(" ", w))
    term.setCursorPos(1, 2)
    local title = "PANEL DE CONTROL NUCLEAR - CERBERUS OPS"
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
    y = y + 2

    term.setCursorPos(2, y)
    term.write("ESTADO DEL SISTEMA: ")
    local statusColor = self.state.status == "STANDBY" and colors.gray or
                       self.state.status == "ARMED" and colors.yellow or colors.red
    term.setTextColor(statusColor)
    print(self.state.status)
    y = y + 2

    term.setTextColor(colors.white)
    term.setCursorPos(2, y)
    term.write("AUTORIZACION: ")
    term.setTextColor(self.state.authorized and colors.green or colors.red)
    print(self.state.authorized and "CONCEDIDA" or "PENDIENTE")
    y = y + 2

    term.setTextColor(colors.white)
    term.setCursorPos(2, y)
    term.write("ARMADO: ")
    term.setTextColor(self.state.launchArmed and colors.red or colors.gray)
    print(self.state.launchArmed and "ARMADO" or "NO ARMADO")
    y = y + 2

    term.setCursorPos(2, y)
    term.write("================================================")
    y = y + 2

    term.setCursorPos(2, y)
    term.setTextColor(colors.gray)
    print("[1] Solicitar Autorizacion")
    y = y + 1
    print("[2] Armar Sistema")
    y = y + 1
    print("[3] Iniciar Secuencia de Lanzamiento")
    y = y + 1
    print("[4] Abortar Operacion")
    y = y + 1
    print("[5] Estado de Red")
    y = y + 2

    term.setCursorPos(2, h - 2)
    term.setTextColor(colors.gray)
    print("[Q] Salir | ID: " .. os.computerID())
end

function NuclearControl:requestAuth()
    if not self.modem then
        print("Error: Modem no disponible")
        return false
    end

    print("Enviando solicitud a Central...")
    self.modem.transmit(100, 101, {type = "AUTH_REQUEST", system = "NUCLEAR", id = os.computerID()})

    local timeout = os.startTimer(30)
    while true do
        local event, p1, p2, p3, p4 = os.pullEvent()

        if event == "modem_message" then
            local msg = p4
            if msg and msg.type == "AUTH_RESPONSE" then
                self.state.authorized = msg.granted or false
                print(self.state.authorized and "AUTORIZACION CONCEDIDA" or "DENEGADA")
                return self.state.authorized
            end
        elseif event == "timer" and p1 == timeout then
            print("Timeout - Sin respuesta")
            return false
        end
    end
end

function NuclearControl:armSystem()
    if not self.state.authorized then
        print("Error: Se requiere autorizacion")
        return false
    end

    self.state.launchArmed = true
    self.state.status = self.STATUS.ARMED
    print("Sistema armado correctamente")

    if peripheral.find("redstone") then
        redstone.setOutput("back", true)
    end

    return true
end

function NuclearControl:initiateLaunch()
    if not self.state.launchArmed then
        print("Error: Sistema no armado")
        return false
    end

    self.state.status = self.STATUS.LAUNCHING
    print("SECUENCIA DE LANZAMIENTO ACTIVA")
    print("Contando...")

    for i = 10, 1, -1 do
        term.setCursorPos(2, 18)
        term.clearLine()
        term.setTextColor(colors.red)
        print(">>> " .. i .. " <<<")
        sleep(1)
    end

    print("LANZAMIENTO! (simulado)")

    self.state.launchArmed = false
    self.state.status = self.STATUS.STANDBY
    self.state.authorized = false

    if peripheral.find("redstone") then
        redstone.setOutput("back", false)
    end

    return true
end

function NuclearControl:abort()
    print("ABORTO DE EMERGENCIA")
    self.state.status = self.STATUS.STANDBY
    self.state.launchArmed = false

    if peripheral.find("redstone") then
        redstone.setOutput("back", false)
    end

    sleep(2)
    return true
end

function NuclearControl:checkNetwork()
    print("=== Estado de Red ===")
    print("Canal: 101")
    print("Modem: " .. (self.modem and "OK" or "NO"))
    print("=====================")
end

function NuclearControl:run()
    self:init()

    while true do
        self:drawPanel()

        local event, key = os.pullEvent("key")

        if key == keys.one then
            self:requestAuth()
            sleep(1)
        elseif key == keys.two then
            self:armSystem()
            sleep(1)
        elseif key == keys.three then
            self:initiateLaunch()
            sleep(1)
        elseif key == keys.four then
            self:abort()
            sleep(1)
        elseif key == keys.five then
            self:checkNetwork()
            sleep(2)
        elseif key == keys.q then
            break
        end
    end
end

return NuclearControl