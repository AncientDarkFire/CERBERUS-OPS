--[[
    Configuración Global
    CERBERUS OPS
    Versión: 2.0.0
]]

local Config = {
    SYSTEM = {
        name = "CERBERUS OPS",
        version = "2.0.0"
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
        max_log_size = 1024000
    }
}

return Config
