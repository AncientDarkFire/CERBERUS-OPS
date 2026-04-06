--[[
    CERBERUS OPS - Script de Instalacion
    Version: 2.1.0
    
    Uso:
        wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install.lua install.lua
        install
]]

local Installer = {
    VERSION = "2.1.0",
    BASE_URL = "https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus",
    
    FILES = {
        {path = "/cerberus/init.lua", desc = "Boot principal"},
        {path = "/cerberus/core/logger.lua", desc = "Sistema de logs"},
        {path = "/cerberus/core/crypto.lua", desc = "Sistema de cifrado"},
        {path = "/cerberus/core/network.lua", desc = "Sistema de red"},
        {path = "/cerberus/lib/ui.lua", desc = "Componentes UI"},
        {path = "/cerberus/config/system.lua", desc = "Configuracion"},
        {path = "/cerberus/presidential/sentinel_hud.lua", desc = "SENTINEL HUD"},
        {path = "/cerberus/presidential/nuclear_control.lua", desc = "Control Nuclear"},
        {path = "/cerberus/presidential/secure_msg.lua", desc = "Mensajeria Segura"},
        {path = "/cerberus/presidential/secure_docs.lua", desc = "Documentos Clasificados"}
    }
}

function Installer:printHeader()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setTextColor(colors.green)
    print("============================================")
    print("       CERBERUS OPS - INSTALADOR v" .. self.VERSION)
    print("         Red Presidencial System")
    print("============================================")
    print("")
end

function Installer:createDirs()
    print("[1/3] Creando estructura de directorios...")
    
    local dirs = {
        "/cerberus",
        "/cerberus/core",
        "/cerberus/lib",
        "/cerberus/presidential",
        "/cerberus/config",
        "/cerberus/logs",
        "/cerberus/docs"
    }
    
    for _, dir in ipairs(dirs) do
        if not fs.exists(dir) then
            fs.makeDir(dir)
            print("  + " .. dir)
        end
    end
    
    print("  OK")
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
    
    if success and response and #response > 0 then
        local file = fs.open(path, "w")
        file.write(response)
        file.close()
        print("    OK")
        return true
    else
        print("    Error: " .. tostring(response))
        return false
    end
end

function Installer:installFiles()
    print("[2/3] Instalando archivos...")
    print("")
    print("  Base: " .. self.BASE_URL)
    print("")
    
    local installed = 0
    local failed = 0
    
    for _, file in ipairs(self.FILES) do
        local url = self.BASE_URL .. file.path
        local success = self:downloadFile(url, file.path)
        
        if success then
            installed = installed + 1
        else
            failed = failed + 1
        end
    end
    
    print("")
    print("  Instalados: " .. installed)
    if failed > 0 then
        print("  Fallidos: " .. failed)
    end
    print("")
end

function Installer:createQuickScripts()
    print("[3/3] Creando script de diagnostico...")
    
    local diag = [[
-- CERBERUS OPS - Diagnostico
term.clear()
term.setTextColor(colors.green)
print("============================================")
print("    CERBERUS OPS - DIAGNOSTICO")
print("============================================")
print("")
print("ID: " .. os.getComputerID())
print("RAM: " .. math.floor(computer.freeMemory()/1024) .. " KB")
print("")
print("Perifericos:")
for _, n in ipairs(peripheral.getNames()) do
    print("  " .. n .. ": " .. peripheral.getType(n))
end
print("")
print("Modem: " .. (peripheral.find("modem") and "OK" or "NO"))
print("Monitor: " .. (peripheral.find("monitor") and "OK" or "NO"))
print("")
if fs.exists("/cerberus") then
    print("/cerberus: INSTALADO")
else
    print("/cerberus: NO INSTALADO")
end
print("")
print("============================================")
]]
    
    local f = fs.open("/cerberus/diag.lua", "w")
    f.write(diag)
    f.close()
    print("  + /cerberus/diag.lua")
    print("")
end

function Installer:run()
    self:printHeader()
    
    print("Instalando CERBERUS OPS...")
    print("")
    
    self:createDirs()
    self:installFiles()
    self:createQuickScripts()
    
    print("============================================")
    term.setTextColor(colors.lime)
    print("  INSTALACION COMPLETADA")
    term.setTextColor(colors.green)
    print("============================================")
    print("")
    print("Reiniciar con: reboot")
    print("")
    print("Sistemas disponibles:")
    print("  hud      - Panel SENTINEL")
    print("  nuclear  - Control Nuclear")
    print("  msg      - Mensajeria Segura")
    print("  docs     - Documentos Clasificados")
    print("")
end

Installer:run()
