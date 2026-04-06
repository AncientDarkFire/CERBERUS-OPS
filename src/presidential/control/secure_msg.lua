--[[
    Secure Messaging System
    CERBERUS OPS - Presidential System
    Nivel de Seguridad: 3 (ROJO)
    Versión: 1.0.0
    
    Sistema de mensajería encriptada entre usuarios.
]]

local SecureMsg = {
    VERSION = "1.0.0",
    
    SECURITY_LEVEL = 3,
    config = {
        channel = 102,
        maxMessageLength = 500,
        messageTimeout = 30
    }
}

local modem = nil
local crypto = nil
local logger = nil

local inbox = {}
local outbox = {}
local contacts = {}
local myId = os.getComputerID()

function SecureMsg:init()
    self.modem = peripheral.find("modem")
    if self.modem then
        self.modem.open(self.config.channel)
    end
    
    self.crypto = require("/cerberus/core/systems/crypto")
    self.logger = require("/cerberus/core/systems/logger")
    
    self:loadContacts()
    self:loadMessages()
    
    self.logger:info("Secure Messaging inicializado")
    
    return self
end

function SecureMsg:loadContacts()
    local filePath = "/cerberus/config/contacts.dat"
    if fs.exists(filePath) then
        local file = fs.open(filePath, "r")
        local data = file.readAll()
        file.close()
        self.contacts = textutils.unserialize(data) or {}
    else
        self.contacts = {
            [100] = {name = "SENTINEL_HUD", level = 2},
            [101] = {name = "NUCLEAR_CONTROL", level = 4},
            [103] = {name = "SECURE_DOCS", level = 3}
        }
    end
end

function SecureMsg:loadMessages()
    local filePath = "/cerberus/config/messages.dat"
    if fs.exists(filePath) then
        local file = fs.open(filePath, "r")
        local data = file.readAll()
        file.close()
        self.inbox = textutils.unserialize(data) or {}
    end
end

function SecureMsg:saveMessages()
    local filePath = "/cerberus/config/messages.dat"
    fs.makeDir("/cerberus/config")
    local file = fs.open(filePath, "w")
    file.write(textutils.serialize(self.inbox))
    file.close()
end

function SecureMsg:encryptMessage(content, recipient)
    local key = self.crypto:generate_key(16)
    local encrypted = self.crypto:xor_encrypt(content, key)
    local encoded = self.crypto:base64_encode(encrypted)
    return encoded, key
end

function SecureMsg:decryptMessage(content, key)
    local decoded = self.crypto:base64_decode(content)
    return self.crypto:xor_decrypt(decoded, key)
end

function SecureMsg:sendMessage(recipientId, content)
    if not self.modem then
        return false, "Modem no disponible"
    end
    
    if #content > self.config.maxMessageLength then
        return false, "Mensaje muy largo"
    end
    
    local encrypted, key = self:encryptMessage(content, recipientId)
    
    local packet = {
        type = "SECURE_MSG",
        from = myId,
        to = recipientId,
        encrypted = encrypted,
        keyHint = key:sub(1, 4),
        timestamp = os.time(),
        messageId = tostring(myId) .. "_" .. tostring(os.time())
    }
    
    self.modem.transmit(self.config.channel, 0, packet)
    
    table.insert(self.outbox, {
        to = recipientId,
        content = content,
        timestamp = os.time(),
        delivered = true
    })
    
    self.logger:info("Mensaje enviado a " .. recipientId)
    return true, "Mensaje enviado"
end

function SecureMsg:broadcast(content)
    if not self.modem then
        return false, "Modem no disponible"
    end
    
    local encrypted, key = self:encryptMessage(content, "BROADCAST")
    
    local packet = {
        type = "SECURE_BROADCAST",
        from = myId,
        encrypted = encrypted,
        timestamp = os.time()
    }
    
    self.modem.transmit(self.config.channel, 0, packet)
    self.logger:info("Broadcast enviado")
    return true
end

function SecureMsg:checkInbox()
    while true do
        local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
        
        if channel == self.config.channel and type(message) == "table" then
            if message.to == myId or message.to == 0 then
                if message.type == "SECURE_MSG" or message.type == "SECURE_BROADCAST" then
                    local decrypted = self:decryptMessage(message.encrypted, message.keyHint .. "XXXXXXXXXXXX")
                    
                    local msgEntry = {
                        from = message.from,
                        content = decrypted,
                        timestamp = message.timestamp,
                        read = false
                    }
                    
                    table.insert(self.inbox, msgEntry)
                    self:saveMessages()
                    
                    self.logger:info("Nuevo mensaje de " .. message.from)
                end
            end
        end
    end
end

function SecureMsg:drawInbox()
    term.setBackgroundColor(colors.black)
    term.clear()
    
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(1, 1)
    term.write("╔══════════════════════════════════════════════════════════════╗")
    term.setCursorPos(1, 2)
    term.write("║              BANDEJA DE ENTRADA - MENSAJES SEGUROS           ║")
    term.setCursorPos(1, 3)
    term.write("╚══════════════════════════════════════════════════════════════╝")
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    local height = term.getSize()
    
    if #self.inbox == 0 then
        term.setCursorPos(1, 5)
        print("No hay mensajes.")
    else
        for i = 1, math.min(#self.inbox, height - 8) do
            local msg = self.inbox[#self.inbox - i + 1]
            local y = 5 + i
            
            term.setCursorPos(2, y)
            if msg.read then
                term.setTextColor(colors.gray)
            else
                term.setTextColor(colors.yellow)
            end
            
            local sender = self.contacts[msg.from] and self.contacts[msg.from].name or tostring(msg.from)
            local preview = msg.content:sub(1, 50)
            if #msg.content > 50 then preview = preview .. "..." end
            
            print(string.format("[%s] De: %s", os.date("%H:%M", msg.timestamp), sender))
            print("    " .. preview)
        end
    end
    
    term.setCursorPos(2, height - 2)
    term.setTextColor(colors.gray)
    print("[R] Leer mensaje | [N] Nuevo mensaje | [Q] Salir")
end

function SecureMsg:readMessage(index)
    if index < 1 or index > #self.inbox then
        print("Mensaje no encontrado")
        return
    end
    
    local msg = self.inbox[index]
    msg.read = true
    self:saveMessages()
    
    term.clear()
    print("═══════════════════════════════════════")
    print("DE: " .. (self.contacts[msg.from] and self.contacts[msg.from].name or tostring(msg.from)))
    print("FECHA: " .. os.date("%Y-%m-%d %H:%M:%S", msg.timestamp))
    print("═══════════════════════════════════════")
    print("")
    print(msg.content)
    print("")
    print("═══════════════════════════════════════")
    print("Presiona ENTER para volver")
    read()
end

function SecureMsg:composeMessage()
    term.clear()
    print("=== NUEVO MENSAJE ===")
    print("")
    
    write("Destinatario (ID): ")
    local recipient = tonumber(read())
    
    if not recipient then
        print("ID invalido")
        return
    end
    
    print("")
    print("Escribe tu mensaje (vacío para cancelar):")
    local content = read()
    
    if #content == 0 then
        print("Mensaje cancelado")
        return
    end
    
    local success, err = self:sendMessage(recipient, content)
    if success then
        print("Mensaje enviado!")
    else
        print("Error: " .. err)
    end
    
    sleep(1)
end

function SecureMsg:showContacts()
    term.clear()
    print("=== CONTACTOS ===")
    print("")
    
    for id, contact in pairs(self.contacts) do
        print(string.format("[%d] %s (Nivel %d)", id, contact.name, contact.level))
    end
    
    print("")
    print("Presiona ENTER para volver")
    read()
end

function SecureMsg:run()
    self:init()
    
    parallel.waitForAny(
        function() self:checkInbox() end,
        function()
            while true do
                self:drawInbox()
                
                local event, key = os.pullEvent("key")
                
                if key == keys.q then
                    self.logger:info("Cerrando Secure Messaging")
                    return
                elseif key == keys.n then
                    self:composeMessage()
                elseif key == keys.r then
                    term.setCursorPos(2, term.getSize() - 4)
                    write("Numero de mensaje: ")
                    local idx = tonumber(read())
                    if idx then
                        self:readMessage(idx)
                    end
                elseif key == keys.c then
                    self:showContacts()
                end
            end
        end
    )
end

return SecureMsg
