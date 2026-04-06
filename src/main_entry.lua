--[[
    Cerberus OPS - Main Entry Point
    Versión: 1.0.0
    
    Este archivo es el punto de entrada principal del sistema.
    Copiar a /init.lua en la computadora principal.
]]

local Logger = require("core.systems.logger")
local Crypto = require("core.systems.crypto")
local Network = require("core.systems.network")
local UI = require("templates.ui.components")

local Main = {
    VERSION = "1.0.0",
    running = true
}

function Main:init()
    term.setBackgroundColor(colors.black)
    term.clear()
    
    term.setTextColor(colors.green)
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║                                                               ║")
    print("║                     CERBERUS OPS v" .. self.VERSION)
    print("║                   RED PRESIDENCIAL SYSTEM                     ║")
    print("║                                                               ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print("")
    
    sleep(0.5)
    
    Logger:info("Inicializando sistema...")
    sleep(0.2)
    
    Network:init(100)
    Logger:info("Red de comunicacion lista")
    
    sleep(0.2)
    print("Sistema listo.")
    print("")
    
    return self
end

function Main:showMenu()
    while self.running do
        term.setTextColor(colors.white)
        print("")
        print("┌─────────────────────────────────────┐")
        print("│         MENU PRINCIPAL              │")
        print("├─────────────────────────────────────┤")
        print("│  [1] SENTINEL HUD - Panel Central   │")
        print("│  [2] NUCLEAR CONTROL - Lanzamiento  │")
        print("│  [3] SECURE MSG - Mensajeria        │")
        print("│  [4] SECURE DOCS - Documentos       │")
        print("│  [5] DIAGNOSTICO - Sistema          │")
        print("├─────────────────────────────────────┤")
        print("│  [R] Reiniciar                      │")
        print("│  [Q] Apagar Sistema                 │")
        print("└─────────────────────────────────────┘")
        print("")
        
        write("Seleccion: ")
        local choice = read()
        
        if choice == "1" then
            print("Abriendo SENTINEL HUD...")
            Logger:info("Acceso a SENTINEL HUD")
            -- self:launchSentinel()
            
        elseif choice == "2" then
            print("Abriendo NUCLEAR CONTROL...")
            Logger:info("Acceso a NUCLEAR CONTROL")
            -- self:launchNuclear()
            
        elseif choice == "3" then
            print("Abriendo SECURE MSG...")
            Logger:info("Acceso a SECURE MSG")
            -- self:launchSecureMsg()
            
        elseif choice == "4" then
            print("Abriendo SECURE DOCS...")
            Logger:info("Acceso a SECURE DOCS")
            -- self:launchSecureDocs()
            
        elseif choice == "5" then
            self:runDiagnostics()
            
        elseif choice == "r" or choice == "R" then
            print("Reiniciando...")
            sleep(0.5)
            os.reboot()
            
        elseif choice == "q" or choice == "Q" then
            self:shutdown()
        else
            term.setTextColor(colors.red)
            print("Opcion no valida")
            term.setTextColor(colors.white)
        end
    end
end

function Main:runDiagnostics()
    term.clear()
    print("═══════════════════════════════════════")
    print("         DIAGNOSTICO DEL SISTEMA        ")
    print("═══════════════════════════════════════")
    print("")
    
    print("[CPU]")
    print("  Uptime: " .. math.floor(computer.uptime()) .. " segundos")
    print("  Memoria: " .. math.floor(computer.freeMemory() / 1024) .. " / " .. 
          math.floor(computer.totalMemory() / 1024) .. " KB")
    print("")
    
    print("[PERIFERICOS]")
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        local ptype = peripheral.getType(name) or "unknown"
        print("  " .. name .. ": " .. ptype)
    end
    if #names == 0 then
        print("  (ninguno)")
    end
    print("")
    
    print("[RED]")
    local modem = peripheral.find("modem")
    if modem then
        print("  Modem: OK")
    else
        print("  Modem: NO DETECTADO")
    end
    print("")
    
    print("[ARCHIVOS]")
    print("  Sistema: /cerberus/")
    if fs.exists("/cerberus") then
        print("  Estado: OK")
    else
        print("  Estado: NO INSTALADO")
    end
    print("")
    
    print("═══════════════════════════════════════")
    print("Presiona ENTER para volver...")
    read()
end

function Main:shutdown()
    print("")
    term.setTextColor(colors.yellow)
    print("Apagando sistema...")
    term.setTextColor(colors.white)
    
    Logger:info("Sistema apagado por usuario")
    
    sleep(0.5)
    os.shutdown()
end

function Main:run()
    self:init()
    self:showMenu()
end

Main:run()
