--[[
    Secure Messaging System
    CERBERUS OPS - Presidential System v2.3.0
    Nivel de Seguridad: 3 (ROJO)
    Rebuilt: Fixed encryption (full key transmitted), inbox UI, message detail, compose panel
]]

local SecureMsg = {}

local C = {
    bg      = colors.black,
    header  = colors.red,
    accent  = colors.orange,
    white   = colors.white,
    gray    = colors.gray,
    green   = colors.lime,
    yellow  = colors.yellow,
    red     = colors.red,
    panel   = colors.gray,
    blue    = colors.blue,
}

local CHANNEL = 102
local modem = nil
local inbox = {}
local myId = os.computerID()

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function cls()
    term.setBackgroundColor(C.bg)
    term.clear()
    term.setCursorPos(1, 1)
end

local function writeAt(x, y, text, fg, bg)
    term.setBackgroundColor(bg or C.bg)
    term.setTextColor(fg or C.white)
    term.setCursorPos(x, y)
    term.write(text)
end

local function writeCentered(y, text, fg, bg)
    local w = term.getSize()
    local x = math.max(1, math.floor((w - #text) / 2) + 1)
    writeAt(x, y, text, fg, bg)
end

local function hline(y, ch, fg, bg, x1, x2)
    local w = term.getSize()
    x1 = x1 or 1
    x2 = x2 or w
    writeAt(x1, y, string.rep(ch, x2 - x1 + 1), fg, bg)
end

local function drawBox(x1, y1, x2, y2, fg, bg)
    bg = bg or C.bg
    for y = y1, y2 do
        writeAt(x1, y, " ", fg, bg)
        writeAt(x2, y, " ", fg, bg)
    end
    writeAt(x1, y1, "+", fg, bg)
    writeAt(x2, y1, "+", fg, bg)
    writeAt(x1, y2, "+", fg, bg)
    writeAt(x2, y2, "+", fg, bg)
    for x = x1 + 1, x2 - 1 do
        writeAt(x, y1, "-", fg, bg)
        writeAt(x, y2, "-", fg, bg)
    end
end

local function drawHeader(title)
    local w = term.getSize()
    hline(1, " ", C.header, C.header)
    writeCentered(1, " " .. title .. " ", C.white, C.header)
    hline(2, "=", C.accent, C.bg)
end

local function drawFooter(left, right)
    local w, h = term.getSize()
    hline(h, " ", C.white, C.header)
    writeAt(2, h, left or "CERBERUS OPS v2.3.0", C.white, C.header)
    if right then
        writeAt(w - #right - 1, h, right, C.gray, C.header)
    end
end

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
    local result = {}
    local padding = (3 - #data % 3) % 3
    data = data .. string.rep("\0", padding)
    for i = 1, #data, 3 do
        local n = bit.blshift(string.byte(data, i), 16) +
                  bit.blshift(string.byte(data, i + 1), 8) +
                  string.byte(data, i + 2)
        table.insert(result, b64chars:sub(bit.brshift(n, 18) + 1, bit.brshift(n, 18) + 1))
        table.insert(result, b64chars:sub(bit.band(bit.brshift(n, 12), 63) + 1, bit.band(bit.brshift(n, 12), 63) + 1))
        table.insert(result, b64chars:sub(bit.band(bit.brshift(n, 6), 63) + 1, bit.band(bit.brshift(n, 6), 63) + 1))
        table.insert(result, b64chars:sub(bit.band(n, 63) + 1, bit.band(n, 63) + 1))
    end
    for i = 1, padding do result[#result - i + 1] = "=" end
    return table.concat(result)
end

local function base64Decode(data)
    data = data:gsub("[^A-Za-z0-9+/=]", "")
    local result = {}
    local i = 1
    while i <= #data do
        local a = b64chars:find(data:sub(i, i)) - 1
        local b = b64chars:find(data:sub(i + 1, i + 1)) - 1
        local c = b64chars:find(data:sub(i + 2, i + 2)) - 1
        local d = b64chars:find(data:sub(i + 3, i + 3)) - 1
        c = c or 0
        d = d or 0
        local n = bit.blshift(a, 18) + bit.blshift(b, 12) + bit.blshift(c, 6) + d
        table.insert(result, string.char(bit.band(bit.brshift(n, 16), 255)))
        if b64chars:find(data:sub(i + 2, i + 2)) and data:sub(i + 2, i + 2) ~= "=" then
            table.insert(result, string.char(bit.band(bit.brshift(n, 8), 255)))
        end
        if b64chars:find(data:sub(i + 3, i + 3)) and data:sub(i + 3, i + 3) ~= "=" then
            table.insert(result, string.char(bit.band(n, 255)))
        end
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

local function encryptMessage(content)
    local key = generateKey(16)
    local encrypted = xorEncrypt(content, key)
    local encoded = base64Encode(encrypted)
    return encoded, key
end

local function decryptMessage(encoded, key)
    local decoded = base64Decode(encoded)
    return xorEncrypt(decoded, key)
end

local function sendMessage(recipientId, content)
    if not modem then return false, "Modem no disponible" end
    local encrypted, key = encryptMessage(content)
    local packet = {
        type = "SECURE_MSG",
        from = myId,
        to = recipientId,
        encrypted = encrypted,
        key = key,
        timestamp = os.time()
    }
    modem.transmit(CHANNEL, 0, packet)
    return true
end

local function timeAgo(ts)
    if not ts then return "Desconocido" end
    local diff = os.time() - ts
    if diff < 60 then return "Hace " .. diff .. "s" end
    if diff < 3600 then return "Hace " .. math.floor(diff / 60) .. "m" end
    if diff < 86400 then return "Hace " .. math.floor(diff / 3600) .. "h" end
    return "Hace " .. math.floor(diff / 86400) .. "d"
end

local function drawInboxList(docs, page)
    local w, h = term.getSize()
    page = page or 1
    local perPage = h - 10

    cls()
    drawHeader("MENSAJERIA SEGURA")

    local countLabel = "MENSAJES: " .. #inbox
    writeAt(3, 4, countLabel, C.gray, C.bg)

    if modem then
        writeAt(w - 16, 4, "CANAL: " .. CHANNEL, C.gray, C.bg)
    end

    hline(5, "-", C.gray, C.bg, 3, w - 2)
    writeAt(3, 5, string.format("%-4s %-8s %-30s %-12s", "#", "DE", "VISTA PREVIA", "TIEMPO"), C.accent, C.bg)
    hline(6, "-", C.gray, C.bg, 3, w - 2)

    if #inbox == 0 then
        writeCentered(math.floor(h / 2), "No hay mensajes", C.gray, C.bg)
    else
        local startIdx = (page - 1) * perPage + 1
        local endIdx = math.min(page * perPage, #inbox)

        for i = startIdx, endIdx do
            local msg = inbox[#inbox - i + 1]
            local y = 7 + (i - startIdx)
            local preview = msg.content:sub(1, 30)
            local msgCol = msg.read and C.gray or C.yellow
            local indicator = msg.read and " " or "*"

            writeAt(3, y, string.format("%-4s", i), C.gray, C.bg)
            writeAt(7, y, string.format("%-8s", tostring(msg.from)), msgCol, C.bg)
            writeAt(16, y, indicator, msgCol, C.bg)
            writeAt(18, y, preview, msgCol, C.bg)
            writeAt(w - 14, y, timeAgo(msg.timestamp), C.gray, C.bg)
        end
    end

    local totalPages = math.max(1, math.ceil(#inbox / perPage))
    drawFooter(string.format("Pagina %d/%d", page, totalPages), "[N] Nuevo [V] Ver [Q] Salir")
end

local function viewMessage(msg)
    if not msg then return end
    msg.read = true

    local w, h = term.getSize()
    local lines = {}
    for line in msg.content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    if #lines == 0 then
        table.insert(lines, msg.content)
    end

    local scrollY = 1
    local viewH = h - 9

    while true do
        cls()
        drawHeader("MENSAJE #" .. tostring(msg.from))

        local boxY1 = 4
        local boxY2 = h - 4
        drawBox(2, boxY1, w - 1, boxY2, C.accent, C.bg)

        writeAt(4, boxY1 + 1, "DE: " .. tostring(msg.from), C.yellow, C.bg)
        writeAt(4, boxY1 + 2, "PARA: " .. tostring(myId), C.white, C.bg)
        writeAt(w - 20, boxY1 + 1, timeAgo(msg.timestamp), C.gray, C.bg)

        hline(boxY1 + 3, "-", C.gray, C.bg, 4, w - 2)

        for i = 1, viewH - 2 do
            local lineIdx = scrollY + i - 1
            if lineIdx <= #lines then
                writeAt(4, boxY1 + 3 + i, lines[lineIdx]:sub(1, w - 8), C.white, C.bg)
            end
        end

        hline(boxY2 - 1, "-", C.gray, C.bg, 4, w - 2)
        writeAt(4, boxY2, "[Q] Cerrar  [Up/Down] Scroll", C.gray, C.bg)

        local ev, key = os.pullEvent("key")
        if key == keys.q then break
        elseif key == keys.up and scrollY > 1 then scrollY = scrollY - 1
        elseif key == keys.down and scrollY < math.max(1, #lines - viewH + 3) then scrollY = scrollY + 1
        end
    end
end

local function composeMessage()
    local w, h = term.getSize()
    cls()
    drawHeader("NUEVO MENSAJE")

    drawBox(4, 4, w - 5, 12, C.accent, C.bg)

    writeAt(6, 5, "DESTINATARIO (ID):", C.accent, C.bg)
    writeAt(6, 6, "> ", C.white, C.bg)
    term.setCursorPos(9, 6)
    local recipientStr = read()
    local recipient = tonumber(recipientStr)
    if not recipient then return end

    writeAt(6, 8, "MENSAJE:", C.accent, C.bg)
    writeAt(6, 9, "> ", C.white, C.bg)
    term.setCursorPos(9, 9)
    local content = read()
    if #content == 0 then return end

    local ok, err = sendMessage(recipient, content)

    drawBox(4, 14, w - 5, 16, ok and C.green or C.red, C.bg)
    writeCentered(15, ok and "MENSAJE ENVIADO CORRECTAMENTE" or "ERROR: " .. tostring(err), ok and C.green or C.red, C.bg)
    sleep(2)
end

local function listenForMessages()
    while true do
        local ev, side, ch, replyCh, message = os.pullEvent("modem_message")
        if ch == CHANNEL and type(message) == "table" and message.type == "SECURE_MSG" then
            if message.to == myId or message.to == 0 then
                local decrypted = ""
                if message.key then
                    decrypted = decryptMessage(message.encrypted, message.key)
                else
                    decrypted = "[ERROR: Sin clave de cifrado]"
                end

                table.insert(inbox, {
                    from = message.from,
                    content = decrypted,
                    timestamp = message.timestamp or os.time(),
                    read = false
                })
            end
        end
    end
end

function SecureMsg:run()
    modem = peripheral.find("modem")
    if modem then modem.open(CHANNEL) end

    local page = 1

    parallel.waitForAny(
        function() listenForMessages() end,
        function()
            while true do
                drawInboxList(inbox, page)
                local ev, key = os.pullEvent("key")

                if key == keys.q then break
                elseif key == keys.n then composeMessage()
                elseif key == keys.v then
                    local perPage = term.getSize() - 10
                    local totalItems = #inbox
                    if totalItems > 0 then
                        writeAt(3, term.getSize() - 1, "Ver mensaje #: ")
                        term.setCursorPos(18, term.getSize() - 1)
                        local idx = tonumber(read())
                        if idx and idx >= 1 and idx <= totalItems then
                            local displayIdx = totalItems - ((page - 1) * perPage + idx) + 1
                            if displayIdx >= 1 and displayIdx <= #inbox then
                                viewMessage(inbox[displayIdx])
                            end
                        end
                    end
                elseif key == keys.left and page > 1 then page = page - 1
                elseif key == keys.right then
                    local totalPages = math.max(1, math.ceil(#inbox / (term.getSize() - 10)))
                    if page < totalPages then page = page + 1 end
                end
            end
        end
    )
end

return SecureMsg
