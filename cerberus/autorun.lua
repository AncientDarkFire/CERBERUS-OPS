--[[
    CERBERUS OPS - AutoRun
    Version: 2.1.0
    
    Este archivo se ejecuta automaticamente al insertar el disco.
    Detecta automaticamente la ruta de montaje del disco.
]]

local function findDiskMount()
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        local ptype = peripheral.getType(name)
        if ptype == "drive" and disk.isPresent(name) and disk.hasData(name) then
            return disk.getMountPath(name)
        end
    end
    return nil
end

local diskPath = findDiskMount()

if diskPath and fs.exists(diskPath .. "/cerberus/init.lua") then
    sleep(0.5)
    shell.openTab("lua " .. diskPath .. "/cerberus/init.lua")
else
    term.clear()
    term.setTextColor(colors.red)
    print("ERROR: Sistema CERBERUS OPS no encontrado")
    print("")
    term.setTextColor(colors.white)
    print("Disco no detectado o corrupto.")
    print("")
end
