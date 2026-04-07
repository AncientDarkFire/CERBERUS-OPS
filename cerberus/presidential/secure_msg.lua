--[[
    Secure Messaging System
    CERBERUS OPS - Presidential System
    Nivel de Seguridad: 3 (ROJO)
    Versión: 2.1.0
]]

local SecureMsg = {
    config = {channel = 102}
}

local modem = nil
local crypto = nil
local inbox = {}
local myId = os.computerID()

function SecureMsg:init()
    self.modem = peripheral.find("modem")
    if self.modem then
        self.modem.open(self.config.channel)
    end
    self.crypto = require("crypto")
    return self
end

function SecureMsg:encryptMessage(content)
    local key = self.crypto:generate_key(16)
    local encrypted = self.crypto:xor_encrypt(content, key)
    local encoded = self.crypto:base64_encode(encrypted)
    return encoded, key
end

function SecureMsg:decryptMessage(content, keyHint)
    local decoded = self.crypto:base64_decode(content)
    return self.crypto:xor_decrypt(decoded, keyHint .. "XXXXXXXXXXXX")
end

function SecureMsg:sendMessage(recipientId, content)
    if not self.modem then
        return false, "Modem no disponible"
    end
    
    local encrypted, key = self:encryptMessage(content)
    
    local packet = {
        type = "SECURE_MSG",
        from = myId,
        to = recipientId,
        encrypted = encrypted,
        keyHint = key:sub(1, 4),
        timestamp = os.time()
    }
    
    self.modem.transmit(self.config.channel, 0, packet)
    return true
end

function SecureMsg:drawInbox()
    local w, h = term.getSize()
    
    term.setBackgroundColor(colors.black)
    term.clear()
    
    -- Header
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(1, 1)
    term.write(string.rep(" ", w))
    term.setCursorPos(1, 2)
    local title = "BANDEJA DE ENTRADA - MENSAJES SEGUROS"
    local x = math.floor((w - #title) / 2)
    if x < 1 then x = 1 end
    term.setCursorPos(x, 2)
    term.write(title)
    term.setCursorPos(1, 3)
    term.write(string.rep(" ", w))
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    local y = 5
    
    if #self.inbox == 0 then
        term.setCursorPos(2, y)
        print("No hay mensajes.")
    else
        for i = 1, math.min(#self.inbox, h - 10) do
            local msg = self.inbox[#self.inbox - i + 1]
            term.setCursorPos(2, y)
            term.setTextColor(msg.read and colors.gray or colors.yellow)
            local preview = msg.content:sub(1, 50)
            print(string.format("[%d] De: %d - %s", i, msg.from, preview))
            y = y + 1
        end
    end
    
    y = h - 3
    term.setCursorPos(2, y)
    term.setTextColor(colors.gray)
    print("[N] Nuevo mensaje | [Q] Salir")
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
    print("Escribe tu mensaje:")
    local content = read()
    
    if #content == 0 then
        print("Cancelado")
        return
    end
    
    local success = self:sendMessage(recipient, content)
    print(success and "Mensaje enviado!" or "Error al enviar")
    sleep(1)
end

function SecureMsg:checkInbox()
    while true do
        local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
        
        if channel == self.config.channel and type(message) == "table" then
            if message.to == myId or message.to == 0 then
                if message.type == "SECURE_MSG" then
                    local decrypted = self:decryptMessage(message.encrypted, message.keyHint)
                    
                    table.insert(self.inbox, {
                        from = message.from,
                        content = decrypted,
                        timestamp = message.timestamp,
                        read = false
                    })
                    
                    print("Nuevo mensaje de " .. message.from)
                end
            end
        end
    end
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
                    return
                elseif key == keys.n then
                    self:composeMessage()
                end
            end
        end
    )
end

return SecureMsg
