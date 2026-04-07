local SecureMsg = {
    config = {channel = 102}
}

local modem = nil
local inbox = {}
local myId = os.computerID()

local function xorEncrypt(data, key)
    if #key == 0 then return data end
    local result = {}
    for i = 1, #data do
        local k = string.byte(key, (i - 1) % #key + 1)
        local d = string.byte(data, i)
        table.insert(result, string.char(bit.bxor(d, k)))
    end
    return table.concat(result)
end

local function base64Encode(data)
    local b64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = {}
    local padding = (3 - #data % 3) % 3
    data = data .. string.rep("\0", padding)
    for i = 1, #data, 3 do
        local n = bit.blshift(string.byte(data, i), 16) + 
                  bit.blshift(string.byte(data, i + 1), 8) + 
                  string.byte(data, i + 2)
        table.insert(result, b64_chars:sub(bit.brshift(n, 18) + 1, bit.brshift(n, 18) + 1))
        table.insert(result, b64_chars:sub(bit.band(bit.brshift(n, 12), 63) + 1, bit.band(bit.brshift(n, 12), 63) + 1))
        table.insert(result, b64_chars:sub(bit.band(bit.brshift(n, 6), 63) + 1, bit.band(bit.brshift(n, 6), 63) + 1))
        table.insert(result, b64_chars:sub(bit.band(n, 63) + 1, bit.band(n, 63) + 1))
    end
    for i = 1, padding do result[#result - i + 1] = "=" end
    return table.concat(result)
end

local function base64Decode(data)
    local b64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    data = data:gsub("[^A-Za-z0-9+/=]", "")
    local result = {}
    local i = 1
    while i <= #data do
        local a = b64_chars:find(data:sub(i, i)) - 1
        local b = b64_chars:find(data:sub(i + 1, i + 1)) - 1
        local c = b64_chars:find(data:sub(i + 2, i + 2)) - 1
        local d = b64_chars:find(data:sub(i + 3, i + 3)) - 1
        local n = bit.blshift(a, 18) + bit.blshift(b, 12) + ((c >= 0 and bit.blshift(c, 6) or 0) + ((d >= 0 and d) or 0))
        table.insert(result, string.char(bit.band(bit.brshift(n, 16), 255)))
        if c >= 0 then table.insert(result, string.char(bit.band(bit.brshift(n, 8), 255))) end
        if d >= 0 then table.insert(result, string.char(bit.band(n, 255))) end
        i = i + 4
    end
    return table.concat(result):gsub("%z+$", "")
end

local function generateKey(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local key = {}
    for i = 1, length do
        table.insert(key, chars:sub(math.random(1, #chars), math.random(1, #chars)))
    end
    return table.concat(key)
end

function SecureMsg:init()
    self.modem = peripheral.find("modem")
    if self.modem then
        self.modem.open(self.config.channel)
    end
    return self
end

function SecureMsg:encryptMessage(content)
    local key = generateKey(16)
    local encrypted = xorEncrypt(content, key)
    local encoded = base64Encode(encrypted)
    return encoded, key
end

function SecureMsg:decryptMessage(content, key)
    local decoded = base64Decode(content)
    return xorEncrypt(decoded, key)
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