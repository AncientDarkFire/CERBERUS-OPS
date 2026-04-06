# SKILL.md
## Habilidades y Conocimiento - CC: Tweaked para CERBERUS OPS

---

## 🎮 CONOCIMIENTO DEL MOD

### Version Compatible
- **CC: Tweaked** 1.20.1 (última versión)
- **CC:C Bridge** Compatible con Create
- **Minecraft** 1.20.1
- **Forge** Compatible

### Computadora CC: Tweaked
| Especificación | Valor |
|----------------|-------|
| RAM | ~8KB (8192 bytes) |
| Ticks por segundo | 20 |
| Eventos por segundo | ~20 |
| Direcciones de red | 65535 |

### Periféricos Soportados
```lua
-- Lista de nombres de periféricos
peripheral.getNames()
-- Retorna: {"top", "right", "front", ...}

-- Obtener tipo de periférico en una posición
peripheral.getType("top")
-- Retorna: "modem", "monitor", "drive", etc.

-- Verificar si hay periférico
peripheral.isPresent("top")
-- Retorna: true/false

-- Encontrar primer periférico de un tipo
peripheral.find("modem")
-- Retorna: el objeto periférico

-- Wrapping
peripheral.wrap("top")
-- Retorna: el objeto periférico para usar sus métodos
```

---

## 🔧 APIS NATIVAS DE CC: TWEAKED

### Computer API
```lua
-- Control de computadora
computer.shutdown()
computer.reboot()
computer.uptime()
computer.totalMemory()
computer.freeMemory()

-- Tiempo
os.sleep(segundos)
os.time()  -- Retorna tiempo en ticks
os.date("!*t")  -- Retorna tabla con fecha/hora real

-- Eventos
os.pullEvent("event_name")
os.pullEventRaw("event_name")
```

### Peripheral API
```lua
-- Obtener lista de periféricos
local names = peripheral.getNames()
-- Retorna: {"top", "right", "front", ...}

-- Verificar si existe periférico
peripheral.isPresent("top")
-- Retorna: true/false

-- Obtener tipo de periférico
peripheral.getType("top")
-- Retorna: "modem", "monitor", "drive", etc.

-- Encontrar primer periférico de un tipo
local modem = peripheral.find("modem")

-- Wrapping (obtener objeto para usar métodos)
local monitor = peripheral.wrap("top")
monitor.write("texto")
```

### Redstone API
```lua
-- Entrada/Salida de redstone
redstone.getInput("top")
redstone.setOutput("bottom", true)

-- Colores de redstone
colors.white, colors.orange, colors.magenta, colors.lightBlue,
colors.yellow, colors.lime, colors.pink, colors.gray,
colors.silver, colors.cyan, colors.purple, colors.blue,
colors.brown, colors.green, colors.red, colors.black
```

### fs API (Sistema de Archivos)
```lua
-- Operaciones de archivo
fs.exists("ruta")
fs.isDir("ruta")
fs.isReadOnly("ruta")
fs.list("ruta")
fs.makeDir("ruta")
fs.move("origen", "destino")
fs.copy("origen", "destino")
fs.delete("ruta")

-- Lectura/Escritura
local file = fs.open("archivo.txt", "r")  -- r, w, a, r+, rb, wb
local content = file.readAll()
file.write("texto")
file.writeLine("linea")
file.close()
```

### io API
```lua
-- Lectura/Escritura simplificada
io.read()
io.write("texto")
io.open("archivo", "modo")
```

### HTTP API
```lua
-- Solicitudes web
local response = http.get("https://url.com")
local response = http.post("https://url.com", "data")

-- Response methods
response.readAll()
response.close()
response.getResponseCode()
```

### Turtle API
```lua
-- Movimiento
turtle.forward()
turtle.back()
turtle.up()
turtle.down()
turtle.turnLeft()
turtle.turnRight()

-- Detección
turtle.detect()
turtle.detectUp()
turtle.detectDown()
turtle.inspect()

-- Inventario
turtle.select(slot)
turtle.getItemCount(slot)
turtle.getItemDetail(slot)
turtle.drop(count)
turtle.suck(count)

-- Herramientas
turtle.dig()
turtle.attack()
turtle.place()
turtle.compare()
```

---

## 📡 MODEM / RED

### Configuración de Red
```lua
-- Abrir canal de comunicación
modem.open(channel)

-- Cerrar canal
modem.close(channel)
modem.closeAll()

-- Enviar mensaje
modem.transmit(channel, replyChannel, message)

-- Escuchar mensajes
os.pullEvent("modem_message")
```

### Ejemplo de Chat Privado
```lua
local modem = peripheral.find("modem")
modem.open(42)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if channel == 42 then
        print("Mensaje recibido: " .. message)
    end
end
```

---

## 🖥️ MONITOR

### Monitor API
```lua
-- Escribir en monitor
monitor.write("texto")
monitor.setCursorPos(x, y)

-- Tamaño del monitor
monitor.getSize()  -- Retorna {ancho, alto}

-- Colores
monitor.setBackgroundColor(color)
monitor.setTextColor(color)
monitor.setTextScale(scale)  -- 0.5, 1, 2, 3, 4, 5

-- Limpiar
monitor.clear()
monitor.clearLine()

-- Avanzar línea
monitor.scroll(1)

-- Bytes en cursor
monitor.getCursorPos()
monitor.isColor()
```

### Monitor de Alto Nivel
```lua
local m = peripheral.wrap("top")
m.setBackgroundColor(colors.black)
m.clear()
m.setCursorPos(1, 1)
m.write("CERBERUS OPS")
```

---

## 💾 DISCO / FLOPPY

### Disk API
```lua
-- Verificar disco presente
disk.isPresent("drive_side")
-- Retorna: true/false

-- Obtener label/nombre
disk.getLabel("drive_side")
-- Retorna: "nombre" o nil

-- Establecer label
disk.setLabel("drive_side", "nuevo_label")

-- Obtener ruta de montaje (para acceder con fs)
disk.getMountPath("drive_side")
-- Retorna: "/disk" o nil

-- Audio (discos de musica)
disk.hasAudio("drive_side")
disk.getAudioTitle("drive_side")
disk.playAudio("drive_side")
disk.stopAudio("drive_side")

-- Ejemplo de lectura de archivo en disco:
local mountPath = disk.getMountPath("top")
if mountPath then
    local file = fs.open(mountPath .. "/miarchivo.lua", "r")
    local content = file.readAll()
    file.close()
end
```

---

## 🖨️ IMPRESORA

### Printer API
```lua
local printer = peripheral.find("printer")

-- Estado
printer.newPage()
printer.endPage()

-- Escribir contenido
printer.write("texto")
printer.setCursorPos(x, y)

-- Configuración de página
printer.setPageTitle("titulo")
printer.getInkLevel()  -- Retorna nivel de tinta
printer.getPaperLevel()  -- Retorna nivel de papel

-- Detener
printer.cancel()
```

---

## 🔌 CC:C BRIDGE (Create Integration)

### Connected Peripherals
```lua
-- Sensores de Create
local sensor = peripheral.find("sensor")

-- Obtener entidades detectadas
local entities = sensor.getEntities()

-- Información detallada
local info = sensor.getEntityInfo(entity_uuid)
```

### Stream Peripherals
```lua
-- Streams de datos de Create
local stream = peripheral.find("stream")

-- Leer datos
stream.read()  -- Retorna tabla de datos
stream.available()  -- Retorna bytes disponibles
```

---

## 🏗️ CREATE MOD

### Encoders (para control de sistemas Create)
```lua
-- Encoder de rotary
local encoder = peripheral.find("stack", peripheral.find("rotary_steamer"))

encoder.getAngle()  -- Ángulo actual
encoder.setAngle(angle)  -- Establecer ángulo
```

### Controller Integration
```lua
-- Station + Controller setup
local station = peripheral.find("station")

station.pushItems("target", count, fromSlot, toSlot)
station.pullItems("source", count, fromSlot, toSlot)
```

---

## 🎯 PATRONES COMUNES EN CC: TWEAKED

### Loop Principal
```lua
while running do
    local event, p1, p2, p3 = os.pullEvent()
    
    if event == "key" then
        -- Manejar tecla
    elseif event == "modem_message" then
        -- Manejar mensaje de red
    elseif event == "timer" then
        -- Manejar temporizador
    elseif event == "term_resize" then
        -- Pantalla redimensionada
    end
end
```

### UI con Terminal
```lua
local w, h = term.getSize()

function drawBorder()
    term.setBackgroundColor(colors.gray)
    term.clear()
    term.setCursorPos(1, 1)
    term.write("╔" .. string.rep("═", w - 2) .. "╗")
    for i = 2, h - 1 do
        term.setCursorPos(1, i)
        term.write("║")
        term.setCursorPos(w, i)
        term.write("║")
    end
    term.setCursorPos(1, h)
    term.write("╚" .. string.rep("═", w - 2) .. "╝")
end
```

### Menu Interactivo
```lua
function menu(options)
    local selected = 1
    
    while true do
        term.clear()
        for i, opt in ipairs(options) do
            term.setCursorPos(1, i)
            if i == selected then
                term.write("> " .. opt)
            else
                term.write("  " .. opt)
            end
        end
        
        local event, key = os.pullEvent("key")
        if key == keys.up and selected > 1 then
            selected = selected - 1
        elseif key == keys.down and selected < #options then
            selected = selected + 1
        elseif key == keys.enter then
            return selected
        end
    end
end
```

### Timer Asíncrono
```lua
local timerID = os.startTimer(60)  -- 60 segundos

while true do
    local event, id = os.pullEvent("timer")
    if id == timerID then
        -- Acción periódica
        timerID = os.startTimer(60)
    end
end
```

---

## 🔐 CRIPTOGRAFÍA BÁSICA (Lua Puro)

### Hash SHA-256 Manual
```lua
local function sha256(data)
    -- Implementación simplificada para passwords
    local hash = 0
    for i = 1, #data do
        hash = (hash * 31 + string.byte(data, i)) % 2147483647
    end
    return string.format("%08x", hash)
end
```

### XOR Encryption (Básico)
```lua
local function xor_encrypt(data, key)
    local result = {}
    for i = 1, #data do
        result[i] = string.char(
            bit.bxor(string.byte(data, i), string.byte(key, (i - 1) % #key + 1))
        )
    end
    return table.concat(result)
end
```

### Base64 Encoding
```lua
local b64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64_encode(data)
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
```

---

## 📋 REFERENCIA RÁPIDA

### Colors API
```lua
colors.combine(c1, c2)      -- Combinar colores
colors.subtract(c1, c2)      -- Remover color
colors.test(combined, color) -- Testear color
```

### Keys API
```lua
keys.one, keys.two, ...      -- Teclas numéricas
keys.a, keys.b, ...          -- Letras
keys.space, keys.enter        -- Especiales
keys.up, keys.down           -- Flechas
keys.leftCtrl, keys.leftAlt   -- Modificadores
```

### Bit API
```lua
bit.blshift(n, bits)          -- Shift izquierda
bit.brshift(n, bits)          -- Shift derecha
bit.band(n1, n2)              -- AND binario
bit.bor(n1, n2)               -- OR binario
bit.bxor(n1, n2)              -- XOR binario
bit.bnot(n)                   -- NOT binario
```

---

## 🚨 LIMITACIONES CONOCIDAS

1. **No hay multithreading real** - Usar timers y eventos
2. **Memoria limitada** - ~8KB, ser cuidadoso con datos grandes
3. **No hay crypto nativa** - Implementar en Lua puro
4. **Strings son inmutables** - Crear nuevas strings, no modificar
5. **Tablas con índice numérico** son arrays, no mapas con strings

---

## 📝 BOOT SEQUENCE ESTÁNDAR

```lua
--[[
    CERBERUS OPS - Boot Sequence
    Autor: CERBERUS
    Versión: 1.0.0
]]

-- Configuración inicial
_G.CERBERUS = {
    VERSION = "1.0.0",
    DEBUG = false,
    SYSTEM_ID = os.getComputerID()
}

-- Cargar módulos core
package.path = "/cerberus/core/?.lua;/cerberus/lib/?.lua;" .. package.path

-- Inicializar Logger
local Logger = require("logger")
_G.Logger = Logger

-- Inicializar Crypto
local Crypto = require("crypto")
_G.Crypto = Crypto

-- Inicializar Network
local Network = require("network")
_G.Network = Network

-- Boot message
term.setBackgroundColor(colors.black)
term.clear()
print("CERBERUS OPS v" .. CERBERUS.VERSION)
print("Sistema ID: " .. CERBERUS.SYSTEM_ID)
print("==================")
print("Inicializando...")

-- Esperar por periféricos
sleep(1)
print("Periféricos: OK")
print("Red: OK")
print("Listo.")
print("")

-- Shell principal
shell.openTab("/cerberus/shell.lua")
```

---

*Referencia actualizada para CC: Tweaked 1.20.1*
