--[[
    CERBERUS OPS - AutoRun
    Version: 2.1.0
    
    Este archivo se ejecuta automaticamente al insertar el disco.
]]

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
