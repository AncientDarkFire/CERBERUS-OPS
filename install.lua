--[[
    CERBERUS OPS - Script de Instalación
    Versión: 1.0.0
    
    Uso: 
        wget <URL_RAW_DE_GITHUB>/install.lua
        install
    
    O desde pastebin:
        pastebin get <codigo> install.lua
        install
]]

local Installer = {
    VERSION = "1.0.0",
    BASE_URL = "",  -- URL base del repositorio (configurar)
    
    FILES = {
        -- Estructura principal
        {
            path = "/cerberus/core/systems/logger.lua",
            pastebin = "KQmTnG9g",  -- Reemplazar con código pastebin real
            desc = "Sistema de logs"
        },
        {
            path = "/cerberus/core/systems/crypto.lua",
            pastebin = "KQmTnG9g",
            desc = "Sistema de cifrado"
        },
        {
            path = "/cerberus/core/systems/network.lua",
            pastebin = "KQmTnG9g",
            desc = "Sistema de red"
        },
        {
            path = "/cerberus/templates/ui/components.lua",
            pastebin = "KQmTnG9g",
            desc = "Componentes UI"
        },
        {
            path = "/cerberus/presidential/control/nuclear_control.lua",
            pastebin = "KQmTnG9g",
            desc = "Panel de Control Nuclear"
        },
        {
            path = "/cerberus/presidential/control/secure_msg.lua",
            pastebin = "KQmTnG9g",
            desc = "Sistema de Mensajería Segura"
        },
        {
            path = "/cerberus/presidential/control/secure_docs.lua",
            pastebin = "KQmTnG9g",
            desc = "Sistema de Documentos Clasificados"
        },
        {
            path = "/cerberus/presidential/control/sentinel_hud.lua",
            pastebin = "KQmTnG9g",
            desc = "Panel SENTINEL HUD"
        },
        {
            path = "/cerberus/init.lua",
            pastebin = "KQmTnG9g",
            desc = "Archivo de inicio principal"
        },
        {
            path = "/cerberus/config/system.lua",
            pastebin = "KQmTnG9g",
            desc = "Configuración del sistema"
        }
    }
}

local BASE_PASTEBIN = "https://pastebin.com/raw/"

function Installer:printHeader()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setTextColor(colors.green)
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║                                                               ║")
    print("║              CERBERUS OPS - INSTALADOR v" .. self.VERSION)
    print("║                   Red Presidencial System                     ║")
    print("║                                                               ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print("")
end

function Installer:createDirs()
    print("[1/4] Creando estructura de directorios...")
    
    local dirs = {
        "/cerberus",
        "/cerberus/core",
        "/cerberus/core/systems",
        "/cerberus/presidential",
        "/cerberus/presidential/control",
        "/cerberus/templates",
        "/cerberus/templates/ui",
        "/cerberus/templates/boot",
        "/cerberus/config",
        "/cerberus/logs",
        "/cerberus/docs"
    }
    
    for _, dir in ipairs(dirs) do
        if not fs.exists(dir) then
            fs.makeDir(dir)
            print("  + " .. dir)
        else
            print("  = " .. dir .. " (existe)")
        end
    end
    
    print("  ✓ Directorios listos")
    print("")
end

function Installer:downloadFile(url, path)
    print("  Descargando: " .. path)
    
    local success, response = pcall(function()
        local handle = http.get(url, nil, true)
        if not handle then
            return nil, "No se pudo conectar"
        end
        
        local content = handle.readAll()
        handle.close()
        
        return content
    end)
    
    if success and response then
        local file = fs.open(path, "w")
        file.write(response)
        file.close()
        print("    ✓ Descargado")
        return true
    else
        print("    ✗ Error: " .. tostring(response))
        return false
    end
end

function Installer:downloadFromPastebin(pastebinCode, path)
    local url = BASE_PASTEBIN .. pastebinCode
    return self:downloadFile(url, path)
end

function Installer:installFiles()
    print("[2/4] Instalando archivos...")
    print("")
    
    local installed = 0
    local failed = 0
    
    local function getParentPath(path)
        local i = #path
        while i > 0 do
            local c = path:sub(i, i)
            if c == "/" or c == "\\" then
                return path:sub(1, i - 1)
            end
            i = i - 1
        end
        return ""
    end
    
    for _, file in ipairs(self.FILES) do
        local parent = getParentPath(file.path)
        if parent ~= "" and not fs.exists(parent) then
            fs.makeDir(parent)
        end
        
        local url = self.BASE_URL .. file.path
        
        local success = self:downloadFile(url, file.path)
        
        if not success and file.pastebin then
            print("  Intentando con Pastebin...")
            success = self:downloadFromPastebin(file.pastebin, file.path)
        end
        
        if success then
            installed = installed + 1
        else
            failed = failed + 1
        end
    end
    
    print("")
    print("  ✓ Instalados: " .. installed)
    if failed > 0 then
        print("  ✗ Fallidos: " .. failed)
    end
    print("")
end

function Installer:showFileList()
    print("[3/4] Archivos instalados:")
    print("")
    
    for _, file in ipairs(self.FILES) do
        print(string.format("  %-50s %s", file.path, file.desc))
    end
    
    print("")
end

function Installer:createQuickScripts()
    print("[4/4] Creando scripts de acceso rapido...")
    print("")
    
    local diagCode = "term.clear()\n"..
    "term.setTextColor(colors.green)\n"..
    "print(\"═══════════════════════════════════════\")\n"..
    "print(\"    CERBERUS OPS - DIAGNOSTICO         \")\n"..
    "print(\"═══════════════════════════════════════\")\n"..
    "print(\"\")\n"..
    "print(\"[PERIFERICOS]\")\n"..
    "local names = peripheral.getNames()\n"..
    "for _, name in ipairs(names) do\n"..
    "    local ptype = peripheral.getType(name) or \"unknown\"\n"..
    "    print(\"  \" .. name .. \": \" .. ptype)\n"..
    "end\n"..
    "if #names == 0 then\n"..
    "    print(\"  (ninguno)\")\n"..
    "end\n"..
    "print(\"\")\n"..
    "print(\"[RED]\")\n"..
    "local modem = peripheral.find(\"modem\")\n"..
    "if modem then\n"..
    "    print(\"  Modem: OK\")\n"..
    "else\n"..
    "    print(\"  Modem: NO DETECTADO\")\n"..
    "end\n"..
    "print(\"\")\n"..
    "print(\"[SISTEMA]\")\n"..
    "print(\"  ID: \" .. os.getComputerID())\n"..
    "print(\"  RAM Libre: \" .. math.floor(computer.freeMemory() / 1024) .. \" KB\")\n"..
    "print(\"  Uptime: \" .. math.floor(computer.uptime()) .. \"s\")\n"..
    "print(\"\")\n"..
    "print(\"[ARCHIVOS]\")\n"..
    "if fs.exists(\"/cerberus\") then\n"..
    "    print(\"  /cerberus: INSTALADO\")\n"..
    "else\n"..
    "    print(\"  /cerberus: NO INSTALADO\")\n"..
    "end\n"..
    "print(\"\")\n"..
    "print(\"═══════════════════════════════════════\")"
    
    local file = fs.open("/cerberus/quick_diag.lua", "w")
    file.write(diagCode)
    file.close()
    print("  + /cerberus/quick_diag.lua")
    
    print("")
    print("  Scripts creados")
    print("")
end

function Installer:manualInstall()
    print("[MANUAL] Instalación manual requerida")
    print("")
    print("Para instalar manualmente:")
    print("")
    print("1. Crea las carpetas:")
    print("   mkdir /cerberus/core/systems")
    print("   mkdir /cerberus/presidential/control")
    print("   mkdir /cerberus/templates/ui")
    print("   mkdir /cerberus/config")
    print("")
    print("2. Descarga cada archivo desde las URLs en docs/URLS.md")
    print("")
    print("3. Usa: pastebin get <codigo> <archivo>")
    print("   o: wget <url> <archivo>")
    print("")
    
    print("URLs de Pastebin:")
    print("")
    
    for _, file in ipairs(self.FILES) do
        local pb = file.pastebin or "N/A"
        print(string.format("  %-40s pastebin:%s", file.path, pb))
    end
    
    print("")
end

function Installer:run()
    self:printHeader()
    
    print("¿Instalación automática o manual?")
    print("")
    print("  [1] Automática (requiere HTTP)")
    print("  [2] Manual (muestra URLs)")
    print("  [3] Solo crear estructura")
    print("")
    write("Seleccion: ")
    
    local choice = read()
    
    if choice == "1" then
        self:createDirs()
        self:installFiles()
        self:showFileList()
        self:createQuickScripts()
        
        print("═══════════════════════════════════════")
        term.setTextColor(colors.lime)
        print("  INSTALACIÓN COMPLETADA")
        term.setTextColor(colors.green)
        print("═══════════════════════════════════════")
        print("")
        print("Para iniciar: reboot")
        print("")
        
    elseif choice == "2" then
        self:manualInstall()
        
    elseif choice == "3" then
        self:createDirs()
        self:manualInstall()
        
    else
        print("Opción inválida")
    end
    
    print("")
    write("Presiona ENTER para continuar...")
    read()
end

-- Ejecutar instalación
Installer:run()
