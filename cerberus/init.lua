--[[
    CERBERUS OPS - Boot Sequence
    Versión: 2.0.0
]]

local System = {
    NAME = "CERBERUS OPS",
    VERSION = "2.0.0",
    SYSTEM_ID = os.getComputerID()
}

_G.CERBERUS = System

local function bootSequence()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.green)
    term.clear()
    
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║                                                              ║")
    print("║                    CERBERUS OPS v" .. System.VERSION)
    print("║                  RED PRESIDENCIAL SYSTEM                    ║")
    print("║                                                              ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print("")
    print("Sistema ID: " .. System.SYSTEM_ID)
    print("")
    print("[BOOT] Inicializando...")
    sleep(0.5)
    
    package.path = "/cerberus/core/?.lua;/cerberus/lib/?.lua;" .. package.path
    print("[OK] Paths configurados")
    
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
    print("═══════════════════════════════════════════════════════════════")
    print("                    SISTEMA LISTO                            ")
    print("═══════════════════════════════════════════════════════════════")
    print("")
    print("Comandos:")
    print("  help     - Mostrar ayuda")
    print("  status   - Estado del sistema")
    print("  reboot   - Reiniciar")
    print("  shutdown - Apagar")
    print("")
    term.setTextColor(colors.white)
end

local function mainMenu()
    while true do
        term.setTextColor(colors.green)
        write("CERBERUS> ")
        
        local input = read()
        local args = {}
        for arg in input:gmatch("%S+") do
            table.insert(args, arg)
        end
        
        local cmd = args[1]
        
        if cmd == "help" then
            print("Comandos: help, status, clear, reboot, shutdown")
            print("Sistemas:")
            print("  hud        - Panel SENTINEL")
            print("  nuclear    - Control Nuclear")
            print("  msg        - Mensajería Segura")
            print("  docs       - Documentos")
            
        elseif cmd == "status" then
            local mem = math.floor(computer.freeMemory() / 1024)
            local total = math.floor(computer.totalMemory() / 1024)
            print("ID: " .. System.SYSTEM_ID)
            print("Memoria: " .. mem .. "KB / " .. total .. "KB")
            
        elseif cmd == "clear" then
            term.clear()
            
        elseif cmd == "reboot" then
            os.reboot()
            
        elseif cmd == "shutdown" then
            os.shutdown()
            
        elseif cmd == "hud" then
            shell.openTab("lua /cerberus/presidential/sentinel_hud")
            
        elseif cmd == "nuclear" then
            shell.openTab("lua /cerberus/presidential/nuclear_control")
            
        elseif cmd == "msg" then
            shell.openTab("lua /cerberus/presidential/secure_msg")
            
        elseif cmd == "docs" then
            shell.openTab("lua /cerberus/presidential/secure_docs")
            
        elseif cmd == nil then
            -- nada
            
        else
            term.setTextColor(colors.red)
            print("Comando desconocido: " .. cmd)
            term.setTextColor(colors.white)
        end
    end
end

bootSequence()
mainMenu()
