--[[
    Secure Documents System
    CERBERUS OPS - Presidential System
    Nivel de Seguridad: 3 (ROJO)
    Versión: 2.0.0
]]

local SecureDocs = {
    SECURITY_LEVELS = {
        {name = "VERDE", level = 1, color = colors.green},
        {name = "AMARILLO", level = 2, color = colors.yellow},
        {name = "ROJO", level = 3, color = colors.red},
        {name = "NEGRO", level = 4, color = colors.black}
    },
    config = {folder = "/cerberus/docs"},
    documents = {}
}

local crypto = nil
local currentUser = {name = "admin", level = 4}

function SecureDocs:init()
    self.crypto = require("/cerberus/core/crypto")
    fs.makeDir(self.config.folder)
    self:loadIndex()
    return self
end

function SecureDocs:loadIndex()
    local indexPath = self.config.folder .. "/index.dat"
    if fs.exists(indexPath) then
        local file = fs.open(indexPath, "r")
        local data = file.readAll()
        file.close()
        self.documents = textutils.unserialize(data) or {}
    end
end

function SecureDocs:saveIndex()
    local indexPath = self.config.folder .. "/index.dat"
    local file = fs.open(indexPath, "w")
    file.write(textutils.serialize(self.documents))
    file.close()
end

function SecureDocs:createDocument(title, content, securityLevel)
    securityLevel = securityLevel or 1
    
    local docId = tostring(os.time()) .. "_" .. math.random(1000, 9999)
    
    local doc = {
        id = docId,
        title = title,
        securityLevel = securityLevel,
        securityName = self.SECURITY_LEVELS[securityLevel].name,
        created = os.time(),
        modified = os.time()
    }
    
    local encrypted = self.crypto:xor_encrypt(content, docId)
    
    local filePath = self.config.folder .. "/" .. docId .. ".dat"
    local file = fs.open(filePath, "w")
    file.write(encrypted)
    file.close()
    
    self.documents[docId] = doc
    self:saveIndex()
    
    return docId
end

function SecureDocs:readDocument(docId)
    local doc = self.documents[docId]
    if not doc then
        return nil, "No encontrado"
    end
    
    if doc.securityLevel > currentUser.level then
        return nil, "Nivel insuficiente"
    end
    
    local filePath = self.config.folder .. "/" .. docId .. ".dat"
    if not fs.exists(filePath) then
        return nil, "Archivo no encontrado"
    end
    
    local file = fs.open(filePath, "r")
    local encrypted = file.readAll()
    file.close()
    
    return self.crypto:xor_decrypt(encrypted, docId), doc
end

function SecureDocs:listDocuments()
    local results = {}
    for id, doc in pairs(self.documents) do
        if doc.securityLevel <= currentUser.level then
            table.insert(results, doc)
        end
    end
    table.sort(results, function(a, b)
        if a.securityLevel ~= b.securityLevel then
            return a.securityLevel > b.securityLevel
        end
        return a.modified > b.modified
    end)
    return results
end

function SecureDocs:drawList(docs, page)
    local w, h = term.getSize()
    page = page or 1
    local perPage = h - 12
    
    term.setBackgroundColor(colors.black)
    term.clear()
    
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(1, 1)
    term.write(string.rep(" ", w))
    term.setCursorPos(1, 2)
    local title = "DOCUMENTOS CLASIFICADOS - CERBERUS"
    term.setCursorPos(math.floor((w - #title) / 2), 2)
    term.write(title)
    term.setCursorPos(1, 3)
    term.write(string.rep(" ", w))
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    local y = 5
    term.setCursorPos(2, y)
    print(string.format("%-6s %-8s %-30s", "IDX", "NIVEL", "TITULO"))
    y = y + 1
    term.write(string.rep("─", 50))
    y = y + 1
    
    local startIdx = (page - 1) * perPage + 1
    local endIdx = math.min(page * perPage, #docs)
    
    for i = startIdx, endIdx do
        local doc = docs[i]
        term.setCursorPos(2, y)
        term.setTextColor(self.SECURITY_LEVELS[doc.securityLevel].color)
        print(string.format("%-6d %-8s %-30s", i, doc.securityName, doc.title:sub(1, 30)))
        y = y + 1
    end
    
    y = h - 4
    term.setCursorPos(2, y)
    term.setTextColor(colors.gray)
    print(string.format("Pagina %d | Total: %d documentos", page, #docs))
    y = y + 1
    print("[N] Nuevo | [V] Ver | [Q] Salir | [<] [>] Paginas")
end

function SecureDocs:showDocument(idx, docs)
    local content, doc = self:readDocument(docs[idx].id)
    
    if not content then
        print("Error: " .. doc)
        sleep(1)
        return
    end
    
    term.setBackgroundColor(colors.black)
    term.clear()
    
    term.setBackgroundColor(self.SECURITY_LEVELS[doc.securityLevel].color)
    term.setCursorPos(1, 1)
    term.write(" " .. doc.securityName .. ": " .. doc.title)
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    local lines = {}
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    local scrollY = 1
    local h = term.getSize()
    
    while true do
        term.clear()
        for i = 1, math.min(#lines, h - 4) do
            local lineIdx = scrollY + i - 1
            if lineIdx <= #lines then
                term.setCursorPos(2, i + 3)
                print(lines[lineIdx]:sub(1, 60))
            end
        end
        
        term.setCursorPos(2, h)
        term.setTextColor(colors.gray)
        print("[Q] Cerrar")
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q then
            break
        elseif key == keys.up and scrollY > 1 then
            scrollY = scrollY - 1
        elseif key == keys.down and scrollY < #lines - h + 5 then
            scrollY = scrollY + 1
        end
    end
end

function SecureDocs:createNewDocument()
    term.clear()
    print("=== CREAR NUEVO DOCUMENTO ===")
    print("")
    
    write("Titulo: ")
    local title = read()
    if #title == 0 then return end
    
    print("")
    print("Nivel de seguridad:")
    for i, level in ipairs(self.SECURITY_LEVELS) do
        print(string.format("  [%d] %s", i, level.name))
    end
    write("Seleccion: ")
    local secLevel = tonumber(read()) or 1
    
    print("")
    print("Contenido (linea vacia para terminar):")
    local lines = {}
    while true do
        local line = read()
        if #line == 0 then break end
        table.insert(lines, line)
    end
    
    local content = table.concat(lines, "\n")
    self:createDocument(title, content, secLevel)
    print("Documento creado")
    sleep(1)
end

function SecureDocs:run()
    self:init()
    
    local page = 1
    local docs = self:listDocuments()
    
    while true do
        self:drawList(docs, page)
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q then
            break
        elseif key == keys.n then
            self:createNewDocument()
            docs = self:listDocuments()
        elseif key == keys.v then
            term.setCursorPos(2, term.getSize() - 6)
            write("Ver documento #: ")
            local idx = tonumber(read())
            if idx and idx >= 1 and idx <= #docs then
                self:showDocument(idx, docs)
            end
        elseif key == keys.leftBracket and page > 1 then
            page = page - 1
        elseif key == keys.rightBracket then
            page = page + 1
        end
    end
end

return SecureDocs
