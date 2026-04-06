--[[
    Crypto Module
    CERBERUS OPS - Core Module
    Versión: 1.0.0
    
    Implementación de cifrado básico para Lua en CC: Tweaked.
    ADVERTENCIA: No es criptografía de grado militar.
    Usar para sistemas de juego, no datos reales sensibles.
]]

local Crypto = {
    VERSION = "1.0.0"
}

function Crypto:sha256(data)
    local hash = 0
    local salt = "CERBERUS_SALT_2026"
    data = salt .. data .. salt
    
    for i = 1, 15 do
        hash = (hash * 33 + string.byte(data, (i - 1) % #data + 1)) % 2147483647
        for j = 1, string.byte(data, (i - 1) % #data + 1) % 5 do
            hash = (hash * 31 + i) % 2147483647
        end
    end
    
    local hex = ""
    local tempHash = hash
    for i = 1, 8 do
        hex = string.format("%02x", tempHash % 256) .. hex
        tempHash = math.floor(tempHash / 256)
    end
    
    return hex
end

function Crypto:md5(data)
    return self:sha256(data):sub(1, 32)
end

function Crypto:xor_encrypt(data, key)
    if #key == 0 then return data end
    
    local result = {}
    for i = 1, #data do
        local k = string.byte(key, (i - 1) % #key + 1)
        local d = string.byte(data, i)
        table.insert(result, string.char(bit.bxor(d, k)))
    end
    
    return table.concat(result)
end

function Crypto:xor_decrypt(data, key)
    return self:xor_encrypt(data, key)
end

function Crypto:base64_encode(data)
    local b64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = {}
    local padding = (3 - #data % 3) % 3
    data = data .. string.rep("\0", padding)
    
    for i = 1, #data, 3 do
        local n = (string.byte(data, i) << 16) +
                  (string.byte(data, i + 1) << 8) +
                  string.byte(data, i + 2)
        
        table.insert(result, b64_chars:sub((n >> 18) + 1, (n >> 18) + 1))
        table.insert(result, b64_chars:sub(((n >> 12) % 64) + 1, ((n >> 12) % 64) + 1))
        table.insert(result, b64_chars:sub(((n >> 6) % 64) + 1, ((n >> 6) % 64) + 1))
        table.insert(result, b64_chars:sub((n % 64) + 1, (n % 64) + 1))
    end
    
    for i = 1, padding do
        result[#result - i + 1] = "="
    end
    
    return table.concat(result)
end

function Crypto:base64_decode(data)
    local b64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = {}
    
    data = data:gsub("%s", ""):gsub("%=", "")
    
    local reverse_map = {}
    for i = 1, #b64_chars do
        reverse_map[b64_chars:sub(i, i)] = i - 1
    end
    
    for i = 1, #data, 4 do
        local n = 0
        for j = 0, 3 do
            if i + j <= #data then
                n = n * 64 + (reverse_map[data:sub(i + j, i + j)] or 0)
            end
        end
        
        table.insert(result, string.char((n >> 16) % 256))
        if i + 2 <= #data then
            table.insert(result, string.char((n >> 8) % 256))
        end
        if i + 3 <= #data then
            table.insert(result, string.char(n % 256))
        end
    end
    
    return table.concat(result)
end

function Crypto:generate_key(length)
    length = length or 32
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local key = {}
    
    for i = 1, length do
        local r = math.random(1, #chars)
        table.insert(key, chars:sub(r, r))
    end
    
    return table.concat(key)
end

function Crypto:hash_password(password, salt)
    salt = salt or tostring(math.random(1, 999999))
    return self:sha256(password .. salt), salt
end

function Crypto:verify_password(password, hash, salt)
    local test_hash = self:hash_password(password, salt)
    return test_hash == hash
end

return Crypto
