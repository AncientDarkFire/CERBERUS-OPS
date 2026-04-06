--[[
    Configuración de Secrets - EJEMPLO
    NO COMMITEAR ESTE ARCHIVO
    Copiar a secrets.lua y cambiar los valores
]]

local Secrets = {
    master_password = "CAMBIAR_ESTA_PASSWORD",
    
    nuclear_codes = {
        primary = "XXXX-XXXX-XXXX",
        secondary = "XXXX-XXXX-XXXX",
        emergency = "XXXX-XXXX-XXXX"
    },
    
    api_keys = {},
    
    session_tokens = {},
    
    admin_users = {
        ["admin"] = "HASH_DE_PASSWORD_AQUI"
    }
}

return Secrets
