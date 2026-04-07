--[[
    CERBERUS OPS - Boot Sequence
    Versión: 2.1.0
]]

local System = {
    NAME = "CERBERUS OPS",
    VERSION = "2.1.0",
    SYSTEM_ID = os.computerID(),
    BASE_PATH = nil
}

local function findDiskMount()
    local runningProgram = shell.getRunningProgram()
    if runningProgram then
        local mountPath = runningProgram:match("^(/disk%d*)")
        if mountPath then
            local basePath = mountPath .. "/cerberus"
            if fs.exists(basePath .. "/init.lua") then
                return basePath
            end
        end
    end
    
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        local ptype = peripheral.getType(name)
        if ptype == "drive" and disk.isPresent(name) and disk.hasData(name) then
            local mountPath = disk.getMountPath(name)
            if mountPath then
                local basePath = mountPath .. "/cerberus"
                if fs.exists(basePath .. "/init.lua") then
                    return basePath
                end
            end
        end
    end
    
    return nil
end

local function bootSequence()
    System.BASE_PATH = findDiskMount()
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.green)
    term.clear()
    
    print("============================================")
    print("        CERBERUS OPS v" .. System.VERSION)
    print("      RED PRESIDENCIAL SYSTEM")
    print("============================================")
    print("")
    print("Sistema ID: " .. System.SYSTEM_ID)
    print("")
    print("[BOOT] Inicializando...")
    sleep(0.5)
    
    if System.BASE_PATH then
        print("[OK] Disco detectado: " .. System.BASE_PATH)
    else
        print("[WARN] Disco no detectado")
    end
    print("[OK] Sistema inicializado")
    
    sleep(0.3)
    
    local names = peripheral.getNames()
    print("[OK] Perifericos: " .. #names)
    
    local modem = peripheral.find("modem")
    if modem then
        print("[OK] Modem detectado")
        modem.open(100)
        print("[OK] Canal 100 abierto")
    end
    
    sleep(0.3)
    
    term.setTextColor(colors.lime)
    print("")
    print("============================================")
    print("              SISTEMA LISTO")
    print("============================================")
    print("")
    print("Comandos:")
    print("  help     - Mostrar ayuda")
    print("  status   - Estado del sistema")
    print("  reboot   - Reiniciar")
    print("  shutdown - Apagar")
    print("")
    term.setTextColor(colors.white)
end

local function showHelp()
    print("")
    print("=== COMANDOS DISPONIBLES ===")
    print("")
    print("  General:")
    print("    help     - Esta ayuda")
    print("    status   - Estado del sistema")
    print("    clear    - Limpiar pantalla")
    print("    shell    - Abrir shell")
    print("    reboot   - Reiniciar computadora")
    print("    shutdown - Apagar computadora")
    print("")
    print("  Sistemas:")
    print("    hud      - Panel SENTINEL (Control Central)")
    print("    nuclear  - Panel de Control Nuclear")
    print("    msg      - Sistema de Mensajeria Segura")
    print("    docs     - Sistema de Documentos Clasificados")
    print("")
    print("  Utilidades:")
    print("    diag     - Diagnostico rapido")
    print("    peripherals - Ver perifericos")
    print("")
end

local function showStatus()
    local uptime = math.floor(os.clock())
    
    print("")
    print("=== ESTADO DEL SISTEMA ===")
    print("  ID: " .. System.SYSTEM_ID)
    print("  Version: " .. System.VERSION)
    print("  Uptime: " .. uptime .. " segundos")
    print("  Perifericos: " .. #peripheral.getNames())
    print("")
    
    local modem = peripheral.find("modem")
    print("  Modem: " .. (modem and "OK" or "NO DETECTADO"))
    
    local monitor = peripheral.find("monitor")
    print("  Monitor: " .. (monitor and "OK" or "NO DETECTADO"))
    print("")
end

local function showPeripherals()
    print("")
    print("=== PERIFERICOS ===")
    print("")
    
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        local ptype = peripheral.getType(name)
        print("  " .. name .. " -> " .. ptype)
    end
    
    if #names == 0 then
        print("  (ninguno)")
    end
    print("")
end

local function runSystem(systemName)
    local basePath = System.BASE_PATH or "/cerberus"
    
    local paths = {
        hud = basePath .. "/presidential/sentinel_hud",
        nuclear = basePath .. "/presidential/nuclear_control",
        msg = basePath .. "/presidential/secure_msg",
        docs = basePath .. "/presidential/secure_docs",
        diag = basePath .. "/diag"
    }
    
    local path = paths[systemName]
    if path then
        if fs.exists(path .. ".lua") then
            print("Ejecutando " .. systemName .. "...")
            sleep(0.5)
            local module = dofile(path .. ".lua")
            if module and type(module.run) == "function" then
                module:run()
            end
        else
            print("Error: Sistema no encontrado")
        end
    else
        print("Sistema desconocido: " .. systemName)
    end
end

local function mainMenu()
    while true do
        term.setTextColor(colors.green)
        write("CERBERUS> ")
        
        local input = read()
        local trimmed = input:gsub("^%s+", ""):gsub("%s+$", "")
        
        if #trimmed == 0 then
            -- nada
        elseif trimmed == "help" or trimmed == "?" then
            showHelp()
            
        elseif trimmed == "status" or trimmed == "info" then
            showStatus()
            
        elseif trimmed == "clear" or trimmed == "cls" then
            term.clear()
            
        elseif trimmed == "shell" then
            print("Abriendo shell...")
            term.setTextColor(colors.white)
            shell.run("")
            term.setTextColor(colors.green)
            print("")
            
        elseif trimmed == "reboot" then
            print("Reiniciando...")
            sleep(0.5)
            os.reboot()
            
        elseif trimmed == "shutdown" or trimmed == "exit" then
            print("Apagando sistema...")
            sleep(0.5)
            os.shutdown()
            
        elseif trimmed == "hud" then
            runSystem("hud")
            
        elseif trimmed == "nuclear" then
            runSystem("nuclear")
            
        elseif trimmed == "msg" or trimmed == "message" then
            runSystem("msg")
            
        elseif trimmed == "docs" or trimmed == "documents" then
            runSystem("docs")
            
        elseif trimmed == "diag" or trimmed == "diagnostic" then
            runSystem("diag")
            
        elseif trimmed == "peripherals" or trimmed == "peri" then
            showPeripherals()
            
        else
            term.setTextColor(colors.red)
            print("Comando desconocido: " .. trimmed)
            term.setTextColor(colors.white)
            print("Escribe 'help' para ver comandos disponibles")
        end
    end
end

bootSequence()
mainMenu()
