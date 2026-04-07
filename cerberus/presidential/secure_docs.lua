--[[
    Secure Documents System
    CERBERUS OPS - Presidential System v2.3.0
    Nivel de Seguridad: 3 (ROJO)
    Rebuilt: Document browser with panels, create/view flows, pagination, security-colored headers
]]

local SecureDocs = {}

local C = {
    bg      = colors.black,
    header  = colors.blue,
    accent  = colors.lightBlue,
    white   = colors.white,
    gray    = colors.gray,
    green   = colors.lime,
    yellow  = colors.yellow,
    red     = colors.red,
    panel   = colors.gray,
    black   = colors.black,
}

local SECURITY_LEVELS = {
    { name = "VERDE",    level = 1, color = colors.lime,   symbol = "[+]" },
    { name = "AMARILLO", level = 2, color = colors.yellow, symbol = "[++]" },
    { name = "ROJO",     level = 3, color = colors.red,    symbol = "[+++]" },
    { name = "NEGRO",    level = 4, color = colors.white,  symbol = "[////]" },
}

local config = { folder = "/cerberus/docs" }
local documents = {}
local currentUser = { name = "admin", level = 4 }

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

local function drawHeader(title, hdrColor)
    local w = term.getSize()
    hdrColor = hdrColor or C.header
    hline(1, " ", hdrColor, hdrColor)
    writeCentered(1, " " .. title .. " ", C.white, hdrColor)
    hline(2, "-", C.gray, C.bg)
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

local function ensureDir()
    if not fs.exists(config.folder) then
        fs.makeDir(config.folder)
    end
end

local function loadIndex()
    local path = config.folder .. "/index.dat"
    if fs.exists(path) then
        local f = fs.open(path, "r")
        local data = f.readAll()
        f.close()
        documents = textutils.unserialize(data) or {}
    end
end

local function saveIndex()
    local path = config.folder .. "/index.dat"
    local f = fs.open(path, "w")
    f.write(textutils.serialize(documents))
    f.close()
end

local function createDocument(title, content, secLevel)
    secLevel = math.max(1, math.min(4, secLevel or 1))
    local docId = tostring(os.time()) .. "_" .. math.random(1000, 9999)

    local encrypted = xorEncrypt(content, docId)
    local filePath = config.folder .. "/" .. docId .. ".dat"
    local f = fs.open(filePath, "w")
    f.write(encrypted)
    f.close()

    documents[docId] = {
        id = docId,
        title = title,
        securityLevel = secLevel,
        created = os.time(),
        modified = os.time(),
    }
    saveIndex()
    return docId
end

local function readDocument(docId)
    local doc = documents[docId]
    if not doc then return nil, "No encontrado" end
    if doc.securityLevel > currentUser.level then return nil, "Nivel de seguridad insuficiente" end

    local filePath = config.folder .. "/" .. docId .. ".dat"
    if not fs.exists(filePath) then return nil, "Archivo corrupto o eliminado" end

    local f = fs.open(filePath, "r")
    local encrypted = f.readAll()
    f.close()

    return xorEncrypt(encrypted, docId), doc
end

local function listDocuments()
    local results = {}
    for id, doc in pairs(documents) do
        if doc.securityLevel <= currentUser.level then
            table.insert(results, doc)
        end
    end
    table.sort(results, function(a, b)
        if a.securityLevel ~= b.securityLevel then return a.securityLevel > b.securityLevel end
        return a.modified > b.modified
    end)
    return results
end

local function drawDocList(docs, page)
    local w, h = term.getSize()
    page = page or 1
    local perPage = h - 11

    cls()
    drawHeader("DOCUMENTOS CLASIFICADOS")

    writeAt(3, 4, "USUARIO: " .. currentUser.name .. " (NIVEL " .. currentUser.level .. ")", C.gray, C.bg)
    writeAt(w - 16, 4, "TOTAL: " .. #docs, C.gray, C.bg)

    hline(5, "-", C.gray, C.bg, 3, w - 2)
    writeAt(3, 5, string.format("%-4s %-8s %-32s %-14s", "#", "NIVEL", "TITULO", "MODIFICADO"), C.accent, C.bg)
    hline(6, "-", C.gray, C.bg, 3, w - 2)

    if #docs == 0 then
        writeCentered(math.floor(h / 2), "No hay documentos almacenados", C.gray, C.bg)
    else
        local startIdx = (page - 1) * perPage + 1
        local endIdx = math.min(page * perPage, #docs)

        for i = startIdx, endIdx do
            local doc = docs[i]
            local y = 7 + (i - startIdx)
            local sec = SECURITY_LEVELS[doc.securityLevel]
            local timeStr = os.date("%d/%m %H:%M", doc.modified)

            writeAt(3, y, string.format("%-4d", i), C.gray, C.bg)
            writeAt(7, y, string.format("%-8s", sec.name), sec.color, C.bg)
            writeAt(16, y, doc.title:sub(1, 32), C.white, C.bg)
            writeAt(w - 16, y, timeStr, C.gray, C.bg)
        end
    end

    local totalPages = math.max(1, math.ceil(#docs / perPage))
    drawFooter(string.format("Pagina %d/%d", page, totalPages), "[N] Nuevo [V] Ver [Q] Salir")
end

local function viewDocument(doc)
    if not doc then return end

    local content, docInfo = readDocument(doc.id)
    if not content then
        local w, h = term.getSize()
        cls()
        drawHeader("ERROR")
        drawBox(4, 4, w - 5, 7, C.red, C.bg)
        writeCentered(5, tostring(docInfo), C.red, C.bg)
        sleep(2)
        return
    end

    local w, h = term.getSize()
    local lines = {}
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    if #lines == 0 and #content > 0 then
        table.insert(lines, content)
    end

    local sec = SECURITY_LEVELS[docInfo.securityLevel]
    local scrollY = 1
    local viewH = h - 9

    while true do
        cls()
        drawHeader(sec.name .. ": " .. docInfo.title, sec.color)

        local boxY1 = 4
        local boxY2 = h - 4
        drawBox(2, boxY1, w - 1, boxY2, sec.color, C.bg)

        writeAt(4, boxY1 + 1, "ID: " .. docInfo.id, C.gray, C.bg)
        writeAt(w - 20, boxY1 + 1, "NIVEL: " .. sec.name, sec.color, C.bg)
        writeAt(4, boxY1 + 2, "CREADO: " .. os.date("%d/%m/%Y %H:%M", docInfo.created), C.gray, C.bg)

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

local function createNewDocument()
    local w, h = term.getSize()
    cls()
    drawHeader("CREAR DOCUMENTO")

    drawBox(4, 4, w - 5, 6 + #SECURITY_LEVELS + 1, C.accent, C.bg)

    writeAt(6, 5, "TITULO:", C.accent, C.bg)
    writeAt(6, 6, "> ", C.white, C.bg)
    term.setCursorPos(9, 6)
    local title = read()
    if #title == 0 then return end

    writeAt(6, 8, "NIVEL DE SEGURIDAD:", C.accent, C.bg)
    for i, sec in ipairs(SECURITY_LEVELS) do
        local y = 8 + i
        writeAt(8, y, "[" .. i .. "]", sec.color, C.bg)
        writeAt(12, y, sec.name .. " " .. sec.symbol, sec.color, C.bg)
    end

    local selY = 8 + #SECURITY_LEVELS + 1
    writeAt(6, selY, "Seleccion: ", C.accent, C.bg)
    term.setCursorPos(18, selY)
    local secChoice = tonumber(read()) or 1
    secChoice = math.max(1, math.min(4, secChoice))

    cls()
    drawHeader("CREAR DOCUMENTO - CONTENIDO")
    writeAt(3, 4, "TITULO: " .. title, C.white, C.bg)
    local sec = SECURITY_LEVELS[secChoice]
    writeAt(3, 5, "NIVEL: " .. sec.name, sec.color, C.bg)
    writeAt(3, 6, "(Linea vacia para terminar)", C.gray, C.bg)
    hline(7, "-", C.gray, C.bg, 3, w - 2)

    local contentLines = {}
    local y = 8
    while y < term.getSize() - 2 do
        writeAt(3, y, "> ", C.accent, C.bg)
        term.setCursorPos(6, y)
        local line = read()
        if #line == 0 then break end
        table.insert(contentLines, line)
        y = y + 1
    end

    local content = table.concat(contentLines, "\n")
    if #content > 0 then
        createDocument(title, content, secChoice)
    end
end

function SecureDocs:run()
    ensureDir()
    loadIndex()

    local page = 1

    while true do
        local docs = listDocuments()
        drawDocList(docs, page)

        local ev, key = os.pullEvent("key")

        if key == keys.q then break
        elseif key == keys.n then
            createNewDocument()
        elseif key == keys.v then
            local perPage = term.getSize() - 11
            local totalItems = #docs
            if totalItems > 0 then
                writeAt(3, term.getSize() - 1, "Ver documento #: ")
                term.setCursorPos(22, term.getSize() - 1)
                local idx = tonumber(read())
                if idx and idx >= 1 and idx <= totalItems then
                    viewDocument(docs[idx])
                end
            end
        elseif key == keys.left and page > 1 then page = page - 1
        elseif key == keys.right then
            local totalPages = math.max(1, math.ceil(#docs / (term.getSize() - 11)))
            if page < totalPages then page = page + 1 end
        end
    end
end

return SecureDocs
