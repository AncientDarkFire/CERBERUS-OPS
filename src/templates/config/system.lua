--[[
    Configuración Global
    CERBERUS OPS
    
    Este archivo NO debe contener passwords reales.
    Usa config/secrets_example.lua como referencia.
]]

local Config = {
    VERSION = "1.0.0",
    
    SYSTEM = {
        name = "CERBERUS OPS",
        id = os.getComputerID(),
        build = "2026.04.05"
    },
    
    NETWORK = {
        primary_channel = 100,
        nuclear_channel = 101,
        secure_msg_channel = 102,
        secure_docs_channel = 103,
        hud_channel = 104
    },
    
    SECURITY = {
        max_login_attempts = 3,
        lockout_duration = 300,
        session_timeout = 1800,
        require_encryption = true
    },
    
    NUCLEAR = {
        require_dual_auth = true,
        countdown_seconds = 10,
        auto_abort_on_error = true
    },
    
    LOGGING = {
        enabled = true,
        level = 2,
        log_to_file = true,
        max_log_size = 1024000,
        rotation_days = 7
    },
    
    UI = {
        theme = "dark",
        refresh_rate = 1,
        animation_enabled = true
    }
}

function Config:get(key)
    local keys = {}
    for k in key:gmatch("[^.]+") do
        table.insert(keys, k)
    end
    
    local value = self
    for _, k in ipairs(keys) do
        if type(value) ~= "table" then
            return nil
        end
        value = value[k]
    end
    
    return value
end

function Config:set(key, value)
    local keys = {}
    for k in key:gmatch("[^.]+") do
        table.insert(keys, k)
    end
    
    local current = self
    for i = 1, #keys - 1 do
        if type(current[keys[i]]) ~= "table" then
            current[keys[i]] = {}
        end
        current = current[keys[i]]
    end
    
    current[keys[#keys]] = value
end

function Config:save(path)
    path = path or "/cerberus/config/system.lua"
    local file = fs.open(path, "w")
    file.write(textutils.serialize(self))
    file.close()
end

function Config:load(path)
    path = path or "/cerberus/config/system.lua"
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local data = file.readAll()
        file.close()
        local loaded = textutils.unserialize(data)
        if loaded then
            for k, v in pairs(loaded) do
                self[k] = v
            end
        end
    end
end

return Config
