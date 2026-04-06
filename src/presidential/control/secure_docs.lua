--[[
    Secure Documents System
    CERBERUS OPS - Presidential System
    Nivel de Seguridad: 3 (ROJO)
    Versión: 1.0.0
    
    Sistema de almacenamiento de documentos clasificados.
    Implementa clasificación de seguridad y encriptación.
]]

local SecureDocs = {
    VERSION = "1.0.0",
    
    SECURITY_LEVELS = {
        {name = "VERDE", level = 1, color = colors.green},
        {name = "AMARILLO", level = 2, color = colors.yellow},
        {name = "ROJO", level = 3, color = colors.red},
        {name = "NEGRO", level = 4, color = colors.black}
    },
    
    config = {
        channel = 103,
        docsFolder = "/cerberus/docs"
    },
    
    documents = {}
}

local crypto = nil
local logger = nil
local currentUser = nil

function SecureDocs:init()
    self.crypto = require("/cerberus/core/systems/crypto")
    self.logger = require("/cerberus/core/systems/logger")
    
    fs.makeDir(self.config.docsFolder)
    self:loadDocumentIndex()
    
    self.logger:info("Secure Documents inicializado")
    
    return self
end

function SecureDocs:loadDocumentIndex()
    local indexPath = self.config.docsFolder .. "/index.dat"
    
    if fs.exists(indexPath) then
        local file = fs.open(indexPath, "r")
        local data = file.readAll()
        file.close()
        self.documents = textutils.unserialize(data) or {}
    end
end

function SecureDocs:saveDocumentIndex()
    local indexPath = self.config.docsFolder .. "/index.dat"
    local file = fs.open(indexPath, "w")
    file.write(textutils.serialize(self.documents))
    file.close()
end

function SecureDocs:createDocument(title, content, securityLevel, category)
    securityLevel = securityLevel or 1
    category = category or "General"
    
    local docId = tostring(os.time()) .. "_" .. math.random(1000, 9999)
    
    local doc = {
        id = docId,
        title = title,
        category = category,
        securityLevel = securityLevel,
        securityName = self.SECURITY_LEVELS[securityLevel].name,
        created = os.time(),
        modified = os.time(),
        author = currentUser or "system"
    }
    
    local encrypted = self.crypto:xor_encrypt(content, docId)
    
    local filePath = self.config.docsFolder .. "/" .. docId .. ".dat"
    local file = fs.open(filePath, "w")
    file.write(encrypted)
    file.close()
    
    self.documents[docId] = doc
    self:saveDocumentIndex()
    
    self.logger:info("Documento creado: " .. title .. " (Nivel " .. doc.securityName .. ")")
    
    return docId
end

function SecureDocs:readDocument(docId)
    local doc = self.documents[docId]
    if not doc then
        return nil, "Documento no encontrado"
    end
    
    if doc.securityLevel > (currentUser and currentUser.level or 0) then
        self.logger:warn("Intento de acceso no autorizado a documento clasificado")
        return nil, "Nivel de seguridad insuficiente"
    end
    
    local filePath = self.config.docsFolder .. "/" .. docId .. ".dat"
    if not fs.exists(filePath) then
        return nil, "Archivo no encontrado"
    end
    
    local file = fs.open(filePath, "r")
    local encrypted = file.readAll()
    file.close()
    
    local content = self.crypto:xor_decrypt(encrypted, docId)
    
    doc.modified = os.time()
    self:saveDocumentIndex()
    
    return content, doc
end

function SecureDocs:listDocuments(filterLevel)
    local results = {}
    
    for id, doc in pairs(self.documents) do
        local userLevel = currentUser and currentUser.level or 0
        
        if filterLevel then
            if doc.securityLevel <= userLevel and doc.securityLevel <= filterLevel then
                table.insert(results, doc)
            end
        else
            if doc.securityLevel <= userLevel then
                table.insert(results, doc)
            end
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

function SecureDocs:deleteDocument(docId)
    local doc = self.documents[docId]
    if not doc then
        return false, "Documento no encontrado"
    end
    
    if currentUser and currentUser.level < 4 then
        return false, "Se requiere nivel maximo de autorizacion"
    end
    
    local filePath = self.config.docsFolder .. "/" .. docId .. ".dat"
    if fs.exists(filePath) then
        fs.delete(filePath)
    end
    
    self.documents[docId] = nil
    self:saveDocumentIndex()
    
    self.logger:info("Documento eliminado: " .. doc.title)
    
    return true
end

function SecureDocs:drawDocumentList(docs, page, perPage)
    local width, height = term.getSize()
    page = page or 1
    perPage = perPage or (height - 10)
    
    term.setBackgroundColor(colors.black)
    term.clear()
    
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(1, 1)
    term.write("╔══════════════════════════════════════════════════════════════╗")
    term.setCursorPos(1, 2)
    term.write("║              DOCUMENTOS CLASIFICADOS - CERBERUS              ║")
    term.setCursorPos(1, 3)
    term.write("╚══════════════════════════════════════════════════════════════╝")
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    local startIdx = (page - 1) * perPage + 1
    local endIdx = math.min(page * perPage, #docs)
    
    term.setCursorPos(2, 5)
    print(string.format("%-6s %-6s %-20s %-15s %-10s",
        "ID", "NIVEL", "TITULO", "CATEGORIA", "FECHA"))
    print(string.rep("─", width - 4))
    
    for i = startIdx, endIdx do
        local doc = docs[i]
        local y = 6 + (i - startIdx)
        
        term.setCursorPos(2, y)
        term.setTextColor(self.SECURITY_LEVELS[doc.securityLevel].color)
        
        local title = doc.title:sub(1, 20)
        local cat = doc.category:sub(1, 15)
        local date = os.date("%Y-%m-%d", doc.modified)
        
        print(string.format("%-6d %-6s %-20s %-15s %-10s",
            i, doc.securityName, title, cat, date))
    end
    
    local totalPages = math.ceil(#docs / perPage)
    term.setCursorPos(2, height - 3)
    term.setTextColor(colors.gray)
    print(string.format("Pagina %d/%d | Total: %d documentos",
        page, totalPages, #docs))
    
    term.setCursorPos(2, height - 1)
    print("[N] Nuevo | [V] Ver | [E] Eliminar | [Q] Salir | [<] [>] Paginas")
end

function SecureDocs:showDocumentViewer(docId)
    local content, err = self:readDocument(docId)
    
    if not content then
        term.clear()
        print("Error: " .. err)
        sleep(2)
        return
    end
    
    term.setBackgroundColor(colors.black)
    term.clear()
    
    local doc = self.documents[docId]
    
    term.setBackgroundColor(self.SECURITY_LEVELS[doc.securityLevel].color)
    term.setTextColor(doc.securityLevel >= 3 and colors.white or colors.black)
    term.setCursorPos(1, 1)
    term.write(" " .. doc.securityName .. ": " .. doc.title .. string.rep(" ", 40))
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    local lines = {}
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    local scrollY = 1
    local height = term.getSize()
    
    while true do
        term.clear()
        
        for i = 1, math.min(#lines, height - 4) do
            local lineIdx = scrollY + i - 1
            if lineIdx <= #lines then
                term.setCursorPos(2, i + 3)
                print(lines[lineIdx]:sub(1, 60))
            end
        end
        
        term.setCursorPos(2, height)
        term.setTextColor(colors.gray)
        print("[↑↓] Scroll | [Q] Cerrar")
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q then
            break
        elseif key == keys.up and scrollY > 1 then
            scrollY = scrollY - 1
        elseif key == keys.down and scrollY < #lines - height + 5 then
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
    
    if #title == 0 then
        print("Cancelado")
        return
    end
    
    print("")
    print("Nivel de seguridad:")
    for i, level in ipairs(self.SECURITY_LEVELS) do
        print(string.format("  [%d] %s", i, level.name))
    end
    
    write("Seleccion: ")
    local secLevel = tonumber(read()) or 1
    
    print("")
    print("Categorias: General, Tecnico, Personal, Nuclear")
    write("Categoria: ")
    local category = read() or "General"
    
    print("")
    print("Escribe el contenido (linea vacia para terminar):")
    print("─" .. string.rep("─", 50))
    
    local lines = {}
    while true do
        local line = read()
        if #line == 0 then break end
        table.insert(lines, line)
    end
    
    local content = table.concat(lines, "\n")
    
    local docId = self:createDocument(title, content, secLevel, category)
    print("")
    print("Documento creado con ID: " .. docId)
    
    sleep(1)
end

function SecureDocs:run()
    self:init()
    
    currentUser = {name = "admin", level = 4}
    
    local page = 1
    local docs = self:listDocuments()
    
    while true do
        self:drawDocumentList(docs, page)
        
        local event, key = os.pullEvent("key")
        
        if key == keys.q then
            self.logger:info("Cerrando Secure Documents")
            break
            
        elseif key == keys.n then
            self:createNewDocument()
            docs = self:listDocuments()
            
        elseif key == keys.v then
            term.setCursorPos(2, term.getSize() - 5)
            write("Ver documento #: ")
            local idx = tonumber(read())
            if idx then
                local allDocs = self:listDocuments()
                if idx >= 1 and idx <= #allDocs then
                    self:showDocumentViewer(allDocs[idx].id)
                end
            end
            
        elseif key == keys.leftBracket then
            if page > 1 then
                page = page - 1
            end
            
        elseif key == keys.rightBracket then
            page = page + 1
        end
    end
end

return SecureDocs
