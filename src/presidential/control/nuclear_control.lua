--[[
    Nuclear Control Panel
    CERBERUS OPS - Presidential System
    Nivel de Seguridad: 4 (NEGRO)
    Versión: 1.0.0
]]

local NuclearControl = {
    VERSION = "1.0.0",
    
    STATUS = {
        STANDBY = "STANDBY",
        ARMED = "ARMED",
        LAUNCH_READY = "LAUNCH_READY",
        LAUNCHING = "LAUNCHING",
        ABORTED = "ABORTED"
    },
    
    state = {
        status = "STANDBY",
        authorized = false,
        launchArmed = false,
        sequenceActive = false,
        targetCoords = {x = 0, y = 0, z = 0},
        launchCode = nil,
        authLevel = 0
    },
    
    config = {
        channel = 101,
        redstoneOutput = "back",
        requireDualAuth = true
    }
}

local modem = nil
local logger = nil

function NuclearControl:init(config)
    config = config or {}
    
    self.modem = peripheral.find("modem")
    if self.modem then
        self.modem.open(self.config.channel)
    end
    
    self.logger = require("/cerberus/core/systems/logger")
    self.logger:info("Nuclear Control inicializado")
    
    return self
end

function NuclearControl:drawPanel()
    local width, height = term.getSize()
    
    term.setBackgroundColor(colors.black)
    term.clear()
    
    term.setBackgroundColor(colors.red)
    term.setCursorPos(1, 1)
    term.write(string.rep(" ", width))
    term.setCursorPos(1, 2)
    term.write("║  PANEL DE CONTROL NUCLEAR - CERBERUS OPS  ║")
    term.setCursorPos(1, 3)
    term.write(string.rep(" ", width))
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    term.setCursorPos(2, 5)
    term.write("═══════════════════════════════════════════════════")
    
    term.setCursorPos(2, 7)
    term.write("ESTADO DEL SISTEMA: ")
    term.setTextColor(self:getStatusColor())
    term.write(self.state.status)
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 9)
    term.write("AUTORIZACION: ")
    term.setTextColor(self.state.authorized and colors.green or colors.red)
    term.write(self.state.authorized and "CONCEDIDA" or "PENDIENTE")
    
    term.setTextColor(colors.white)
    term.setCursorPos(2, 11)
    term.write("ARMADO: ")
    term.setTextColor(self.state.launchArmed and colors.red or colors.gray)
    term.write(self.state.launchArmed and "ARMADO" or "NO ARMADO")
    
    term.setCursorPos(2, 13)
    term.write("═══════════════════════════════════════════════════")
    
    term.setCursorPos(2, 15)
    term.setTextColor(colors.gray)
    term.write("[1] Solicitar Autorizacion")
    term.setCursorPos(2, 16)
    term.write("[2] Armar Sistema")
    term.setCursorPos(2, 17)
    term.write("[3] Iniciar Secuencia de Lanzamiento")
    term.setCursorPos(2, 18)
    term.write("[4] Abortar Operacion")
    term.setCursorPos(2, 19)
    term.write("[5] Estado de Red")
    
    term.setCursorPos(2, height)
    term.write("Presiona [Q] para salir | Computer ID: " .. os.getComputerID())
    
    term.setBackgroundColor(colors.black)
end

function NuclearControl:getStatusColor()
    if self.state.status == self.STATUS.STANDBY then
        return colors.gray
    elseif self.state.status == self.STATUS.ARMED then
        return colors.yellow
    elseif self.state.status == self.STATUS.LAUNCH_READY then
        return colors.red
    elseif self.state.status == self.STATUS.LAUNCHING then
        return colors.red
    else
        return colors.gray
    end
end

function NuclearControl:requestAuthorization()
    if not self.modem then
        print("Error: Modem no disponible")
        return false
    end
    
    self.logger:warn("Solicitud de autorizacion enviada a Central")
    
    self.modem.transmit(100, self.config.channel, {
        type = "AUTH_REQUEST",
        system = "NUCLEAR",
        id = os.getComputerID(),
        timestamp = os.time()
    })
    
    print("Solicitud enviada. Esperando respuesta...")
    
    local timeout = os.startTimer(30)
    while true do
        local event, p1, p2, p3, p4 = os.pullEvent()
        
        if event == "modem_message" then
            local channel, reply, message = p2, p3, p4
            if channel == self.config.channel and message.type == "AUTH_RESPONSE" then
                if message.granted then
                    self.state.authorized = true
                    self.state.authLevel = message.level or 4
                    self.logger:info("Autorizacion concedida - Nivel " .. self.state.authLevel)
                    print("AUTORIZACION CONCEDIDA")
                    return true
                else
                    self.logger:error("Autorizacion denegada")
                    print("AUTORIZACION DENEGADA")
                    return false
                end
            end
        elseif event == "timer" and p1 == timeout then
            self.logger:warn("Timeout de autorizacion")
            print("Timeout - Sin respuesta")
            return false
        end
    end
end

function NuclearControl:armSystem()
    if not self.state.authorized then
        print("Error: Se requiere autorizacion primero")
        return false
    end
    
    self.logger:warn("Sistema de lanzamiento ARMADO")
    self.state.launchArmed = true
    self.state.status = self.STATUS.ARMED
    
    if self.config.redstoneOutput then
        redstone.setOutput(self.config.redstoneOutput, true)
    end
    
    print("Sistema armado correctamente")
    return true
end

function NuclearControl:initiateLaunchSequence()
    if not self.state.launchArmed then
        print("Error: Sistema no armado")
        return false
    end
    
    if not self.state.authorized then
        print("Error: Se requiere autorizacion")
        return false
    end
    
    self.logger:fatal("INICIANDO SECUENCIA DE LANZAMIENTO")
    self.state.status = self.STATUS.LAUNCHING
    self.state.sequenceActive = true
    
    print("SECUENCIA DE LANZAMIENTO ACTIVA")
    print("Contando...")
    
    for i = 10, 1, -1 do
        term.setCursorPos(2, 22)
        term.clearLine()
        term.setTextColor(colors.red)
        print(">>> " .. i .. " <<<")
        sleep(1)
    end
    
    print("LANZAMIENTO! (simulado)")
    self.logger:fatal("MISIL LANZADO")
    
    self.state.sequenceActive = false
    self.state.status = self.STATUS.STANDBY
    self.state.launchArmed = false
    self.state.authorized = false
    
    if self.config.redstoneOutput then
        redstone.setOutput(self.config.redstoneOutput, false)
    end
    
    return true
end

function NuclearControl:abort()
    self.logger:warn("ABORTO DE EMERGENCIA")
    
    self.state.status = self.STATUS.ABORTED
    self.state.launchArmed = false
    self.state.sequenceActive = false
    
    if self.config.redstoneOutput then
        redstone.setOutput(self.config.redstoneOutput, false)
    end
    
    print("Operacion abortada")
    
    os.sleep(2)
    self.state.status = self.STATUS.STANDBY
    
    return true
end

function NuclearControl:checkNetworkStatus()
    print("=== Estado de Red ===")
    print("Canal: " .. self.config.channel)
    
    if self.modem then
        print("Modem: OK")
    else
        print("Modem: NO DISPONIBLE")
    end
    
    print("=====================")
end

function NuclearControl:handleMessage(message)
    if message.type == "AUTH_RESPONSE" then
        if message.granted then
            self.state.authorized = true
            self.logger:info("Autorizacion actualizada")
        else
            self.state.authorized = false
        end
    elseif message.type == "REMOTE_ABORT" then
        self:abort()
    elseif message.type == "LAUNCH_COMMAND" then
        self:initiateLaunchSequence()
    end
end

function NuclearControl:run()
    self:init()
    
    while true do
        self:drawPanel()
        
        local event, key = os.pullEvent("key")
        
        if key == keys.one then
            self:requestAuthorization()
            os.sleep(1)
        elseif key == keys.two then
            self:armSystem()
            os.sleep(1)
        elseif key == keys.three then
            self:initiateLaunchSequence()
            os.sleep(1)
        elseif key == keys.four then
            self:abort()
            os.sleep(1)
        elseif key == keys.five then
            self:checkNetworkStatus()
            os.sleep(2)
        elseif key == keys.q or key == keys.q then
            term.setBackgroundColor(colors.black)
            term.clear()
            print("Saliendo del panel...")
            break
        end
    end
end

return NuclearControl
