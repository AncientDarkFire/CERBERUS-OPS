--[[
    CERBERUS OPS - AutoRun
    Version: 2.1.0
    
    Este archivo se ejecuta automaticamente al insertar el disco.
    Abre una nueva terminal con el sistema principal.
]]

-- Verificar que existe el sistema
if fs.exists("/cerberus/init.lua") then
    -- Esperar un momento para que el sistema stabilize
    sleep(0.5)
    
    -- Abrir el sistema principal en una nueva pestana
    shell.openTab("lua /cerberus/init.lua")
else
    -- Error si no encuentra el sistema
    term.clear()
    term.setTextColor(colors.red)
    print("ERROR: Sistema CERBERUS OPS no encontrado")
    print("")
    term.setTextColor(colors.white)
    print("Reinstala el disco usando install.lua")
    print("")
end
