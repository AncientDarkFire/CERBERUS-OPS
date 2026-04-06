--[[
    CERBERUS OPS - Script de Instalacion en Disco
    Version: 2.1.0
    
    Este script copia todo el sistema a un floppy disk.
    Luego ese disco puede usarse para instalar en otras computadoras.
    
    Uso:
        wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main/install.lua install.lua
        install
]]

local Installer = {
    VERSION = "2.1.0",
    BASE_URL = "https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main",
    DISK_NAME = "CERBERUS-OPS",
    
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
    print("       CERBERUS OPS - INSTALADOR")
    print("       Version " .. self.VERSION)
    print("============================================")
    print("")
end

function Installer:findDiskDrive()
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        local ptype = peripheral.getType(name)
        if ptype == "drive" then
            return name
        end
    end
    return nil
end

function Installer:checkDisk(driveName)
    if not driveName then
        return false, "No se encontro Disk Drive"
    end
    
    if not disk.isPresent(driveName) then
        return false, "No hay disco en el Disk Drive"
    end
    
    return true, driveName
end

function Installer:prepareDisk(driveName)
    print("Preparando disco...")
    print("  Nombre: " .. self.DISK_NAME)
    
    local success, err = pcall(function()
        disk.setLabel(driveName, self.DISK_NAME)
    end)
    
    if not success then
        return false, "Error al renombrar disco: " .. tostring(err)
    end
    
    local label = disk.getLabel(driveName)
    print("  Label: " .. label)
    
    return true, driveName
end

function Installer:getDiskPath(driveName)
    local mountPath = disk.getMountPath(driveName)
    if not mountPath then
        return nil
    end
    return mountPath
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
        return true, response
    else
        return false, "Error al descargar"
    end
end

function Installer:createDirsOnDisk(basePath)
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
        local fullPath = basePath .. dir
        if not fs.exists(fullPath) then
            fs.makeDir(fullPath)
        end
    end
end

function Installer:writeFileOnDisk(basePath, relativePath, content)
    local fullPath = basePath .. relativePath
    local file = fs.open(fullPath, "w")
    if file then
        file.write(content)
        file.close()
        return true
    end
    return false
end

function Installer:installFilesOnDisk(diskPath)
    print("")
    print("Base URL: " .. self.BASE_URL)
    print("")
    
    self:createDirsOnDisk(diskPath)
    
    local installed = 0
    local failed = 0
    
    for _, file in ipairs(self.FILES) do
        local url = self.BASE_URL .. file.path
        local success, content = self:downloadFile(url, file.path)
        
        if success then
            local writeSuccess = self:writeFileOnDisk(diskPath, file.path, content)
            if writeSuccess then
                print("    OK: " .. file.path)
                installed = installed + 1
            else
                print("    ERROR al escribir: " .. file.path)
                failed = failed + 1
            end
        else
            print("    ERROR: " .. file.path)
            failed = failed + 1
        end
    end
    
    return installed, failed
end

function Installer:createDiagOnDisk(diskPath)
    local diag = [[
-- CERBERUS OPS - Diagnostico
term.clear()
term.setTextColor(colors.green)
print("============================================")
print("    CERBERUS OPS - DIAGNOSTICO")
print("============================================")
print("")
print("ID: " .. os.computerID())
print("RAM Total: " .. math.floor(computer.totalMemory()/1024) .. " KB")
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
    
    local fullPath = diskPath .. "/cerberus/diag.lua"
    local file = fs.open(fullPath, "w")
    if file then
        file.write(diag)
        file.close()
        print("  + /cerberus/diag.lua")
    end
end

function Installer:createAutorunOnDisk(diskPath)
    local autorun = [[
-- CERBERUS OPS - AutoRun
-- Este archivo se ejecuta automaticamente al insertar el disco

local function getDiskSide()
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        local ptype = peripheral.getType(name)
        if ptype == "drive" and disk.isPresent(name) then
            return name
        end
    end
    return nil
end

local side = getDiskSide()

if side and disk.hasData(side) then
    local mountPath = disk.getMountPath(side)
    sleep(0.5)
    shell.openTab("lua " .. mountPath .. "/cerberus/init.lua")
else
    term.clear()
    term.setTextColor(colors.red)
    print("ERROR: Sistema CERBERUS OPS no encontrado")
    print("")
    term.setTextColor(colors.white)
    print("Disco no detectado.")
    print("")
end
]]
    
    local fullPath = diskPath .. "/autorun.lua"
    local file = fs.open(fullPath, "w")
    if file then
        file.write(autorun)
        file.close()
        print("  + /autorun.lua")
    end
end

function Installer:run()
    self:printHeader()
    
    print("Buscando Disk Drive...")
    local driveName = self:findDiskDrive()
    
    local success, err = self:checkDisk(driveName)
    if not success then
        term.setTextColor(colors.red)
        print("ERROR: " .. err)
        print("")
        print("Asegurate de:")
        print("  1. Tener un Disk Drive conectado")
        print("  2. Tener un Floppy Disk insertado")
        print("")
        term.setTextColor(colors.white)
        return
    end
    
    print("Disk Drive encontrado: " .. driveName)
    print("")
    
    success, err = self:prepareDisk(driveName)
    if not success then
        term.setTextColor(colors.red)
        print("ERROR: " .. err)
        return
    end
    
    local diskPath = self:getDiskPath(driveName)
    if not diskPath then
        term.setTextColor(colors.red)
        print("ERROR: No se pudo montar el disco")
        return
    end
    
    print("Disco montado en: " .. diskPath)
    print("")
    
    local installed, failed = self:installFilesOnDisk(diskPath)
    self:createDiagOnDisk(diskPath)
    self:createAutorunOnDisk(diskPath)
    
    print("")
    print("============================================")
    
    if failed == 0 then
        term.setTextColor(colors.lime)
        print("  INSTALACION COMPLETADA")
        term.setTextColor(colors.green)
    else
        term.setTextColor(colors.yellow)
        print("  INSTALACION PARCIAL")
        print("  Instalados: " .. installed)
        print("  Fallidos: " .. failed)
        term.setTextColor(colors.green)
    end
    
    print("============================================")
    print("")
    print("Disco '" .. self.DISK_NAME .. "' listo!")
    print("")
    print("Para usar:")
    print("  1. Inserta el disco en la computadora")
    print("  2. Reinicia o escribe: reboot")
    print("  3. El sistema iniciara automaticamente")
    print("")
    print("O ejecuta manualmente:")
    print("  lua /cerberus/init")
    print("")
end

Installer:run()
