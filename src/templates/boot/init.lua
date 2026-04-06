--[[
    CERBERUS OPS - Boot Sequence
    Sistema: init.lua
    Versión: 1.0.0
]]

local System = {
    NAME = "CERBERUS OPS",
    VERSION = "1.0.0",
    BUILD = "2026.04.05",
    SYSTEM_ID = os.getComputerID(),
    DEBUG = false
}

_G.CERBERUS = System

local function bootSequence()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.green)
    term.clear()
    
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║                                                              ║")
    print("║                    CERBERUS OPS v" .. System.VERSION)
    print("║                  RED PRESIDENCIAL SYSTEM                      ║")
    print("║                                                              ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print("")
    print("Sistema ID: " .. System.SYSTEM_ID)
    print("Build: " .. System.BUILD)
    print("")
    print("[BOOT] Inicializando...")
    
    sleep(0.5)
    
    -- Cargar package path
    package.path = "/cerberus/core/?.lua;/cerberus/lib/?.lua;/cerberus/presidential/?.lua;" .. package.path
    print("[OK] Paths de modulos configurados")
    
    sleep(0.3)
    
    -- Verificar periféricos
    local names = peripheral.getNames()
    print("[OK] Perifericos detectados: " .. #names)
    
    -- Verificar modem
    local modem = peripheral.find("modem")
    if modem then
        print("[OK] Modem de red encontrado")
        modem.open(100)
        print("[OK] Canal 100 abierto")
    else
        print("[WARN] No se detecto modem")
    end
    
    sleep(0.3)
    
    -- Boot completo
    term.setTextColor(colors.lime)
    print("")
    print("═══════════════════════════════════════════════════════════════")
    print("                    SISTEMA OPERATIVO                          ")
    print("                      LISTO PARA USO                           ")
    print("═══════════════════════════════════════════════════════════════")
    print("")
    print("Comandos disponibles:")
    print("  help     - Mostrar ayuda")
    print("  shell    - Abrir shell")
    print("  logout   - Cerrar sesion")
    print("")
    
    term.setTextColor(colors.white)
end

local function mainMenu()
    while true do
        term.setTextColor(colors.green)
        term.setCursorPos(1, 1)
        write("CERBERUS> ")
        
        local input = read()
        local args = {}
        for arg in input:gmatch("%S+") do
            table.insert(args, arg)
        end
        
        local cmd = args[1]
        
        if cmd == "help" then
            print("Comandos disponibles:")
            print("  help     - Esta ayuda")
            print("  clear    - Limpiar pantalla")
            print("  reboot   - Reiniciar sistema")
            print("  shutdown - Apagar sistema")
            print("  shell    - Abrir shell de sistema")
            print("  status   - Estado del sistema")
            print("  network  - Diagnostico de red")
            
        elseif cmd == "clear" then
            term.clear()
            
        elseif cmd == "reboot" then
            print("Reiniciando...")
            sleep(0.5)
            os.reboot()
            
        elseif cmd == "shutdown" or cmd == "exit" then
            print("Apagando sistema...")
            sleep(0.5)
            os.shutdown()
            
        elseif cmd == "status" then
            local mem = math.floor(computer.freeMemory() / 1024)
            local total = math.floor(computer.totalMemory() / 1024)
            local uptime = math.floor(computer.uptime())
            
            print("=== ESTADO DEL SISTEMA ===")
            print("ID: " .. System.SYSTEM_ID)
            print("Version: " .. System.VERSION)
            print("Memoria: " .. mem .. "KB / " .. total .. "KB")
            print("Uptime: " .. uptime .. "s")
            print("===========================")
            
        elseif cmd == "network" then
            local modem = peripheral.find("modem")
            if modem then
                print("Modem: OK")
            else
                print("Modem: NO DETECTADO")
            end
            
        elseif cmd == "shell" then
            print("Abriendo shell...")
            sleep(0.3)
            shell.openTab("")
            break
            
        elseif cmd == "logout" then
            print("Sesion cerrada.")
            break
            
        elseif cmd == nil then
            -- No hacer nada
            
        else
            term.setTextColor(colors.red)
            print("Comando desconocido: " .. cmd)
            term.setTextColor(colors.white)
        end
    end
end

bootSequence()
mainMenu()
