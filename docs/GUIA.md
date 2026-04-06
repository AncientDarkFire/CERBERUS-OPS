# GUIA.md
## Guía de Implementación - CERBERUS OPS

Guía paso a paso para implementar sistemas en Minecraft con CC: Tweaked, CC:C Bridge y Create.

---

## 📋 ÍNDICE

1. [Método de Instalación Rápida](#método-de-instalación-rápida)
2. [Setup Inicial](#setup-inicial)
3. [Instalación de Computadora Central](#instalación-de-computadora-central)
4. [Configuración de Periféricos](#configuración-de-periféricos)
5. [Grabación de Discos de Boot](#grabación-de-discos-de-boot)
6. [Configuración de Red](#configuración-de-red)
7. [Instalación de Módulos](#instalación-de-módulos)
8. [Sistemas Create](#sistemas-create)
9. [Mantenimiento](#mantenimiento)

---

## ⚡ MÉTODO DE INSTALACIÓN RÁPIDA

### IMPORTANTE: No escribir código manualmente

> **Usa siempre descarga por URL.** La terminal de CC: Tweaked no permite pegar múltiples líneas fácilmente.

### Opciones de Descarga

#### Opción 1: Pastebin (Recomendado)
```bash
pastebin get CODIGO_PASTEBIN nombre_archivo.lua
```

#### Opción 2: WGET desde URL
```bash
wget https://url.com/archivo.lua
```

### Instalación Automática

```bash
# 1. Descargar script de instalación
pastebin get XXXXXXXXX install.lua

# 2. Ejecutar
install

# 3. Seleccionar opción 1 (Automática)
# 4. Esperar a que se descarguen todos los archivos
# 5. Reiniciar
reboot
```

### URLs de Descarga

Ver `docs/URLS.md` para la lista completa de URLs y códigos Pastebin.

### Manual: Descargar archivos individuales

Si prefieres instalar manualmente:

```bash
# 1. Crear estructura de carpetas
mkdir /cerberus
mkdir /cerberus/core
mkdir /cerberus/core/systems
mkdir /cerberus/presidential
mkdir /cerberus/presidential/control
mkdir /cerberus/templates
mkdir /cerberus/templates/ui
mkdir /cerberus/config

# 2. Descargar cada archivo
pastebin get XXXXXXXXX /cerberus/core/systems/logger.lua
pastebin get XXXXXXXXX /cerberus/core/systems/crypto.lua
pastebin get XXXXXXXXX /cerberus/core/systems/network.lua
pastebin get XXXXXXXXX /cerberus/templates/ui/components.lua
pastebin get XXXXXXXXX /cerberus/presidential/control/nuclear_control.lua
# ... continuar con el resto

# 3. Configurar el archivo de inicio
# Copiar el contenido de init.lua al archivo de inicio
```

---

## 1. SETUP INICIAL (Continuación)

### Materiales Requeridos

| Item | Cantidad | Uso |
|------|----------|-----|
| Computadora (CC: Tweaked) | 1+ | Sistema principal |
| Cable de Red | A大便 | Conexión de periféricos |
| Monitor | 1+ | Interfaz visual |
| Módem | 1+ | Comunicación de red |
| Unidad de Disquete | 1+ | Almacenamiento/boot |
| Floppy Disk | 2+ | Discos de boot y datos |
| Disco Duro (opcional) | 1 | Mayor almacenamiento |

### Estructura de Red Recomendada

```
                    [COMPUTADORA CENTRAL]
                           |
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    [MONITOR]         [MODEM]            [DISK DRIVE]
    (HUD Panel)      (RED)                (BOOT)
                           │
                    ┌──────┴──────┐
                    │             │
              [COMPUTADORA]  [COMPUTADORA]
              NUCLEAR CTL    SECURE DOCS
```

---

## 2. INSTALACIÓN DE COMPUTADORA CENTRAL

### Paso 2.1: Colocar la Computadora

```
1. Abre tu inventario o craftea una Computadora Avanzada
   Receta: 3x Redstone + 2x Diamond + 1x Iron Ingot + 1x Glass
   Ubicación: Mesa de crafteo estándar

2. Coloca la computadora en la ubicación deseada
   - Debe estar en un lugar accesible
   - Considera la distribución de periféricos
   - La computadora debe tener acceso a redstone si se requiere

3. Click derecho para interactuar con la terminal
```

### Paso 2.2: Encender la Computadora

```
1. Usa el item "Analyser" o haz click con el item correcto
2. O simplemente interactúa (click derecho) para abrir la terminal
3. La primera vez arrancará con el prompt de boot
```

### Comandos de Terminal Básicos

```lua
-- Navegación
ls                    -- Listar archivos
cd nombre_carpeta     -- Cambiar directorio
mkdir nombre          -- Crear directorio
rm archivo            -- Eliminar archivo

-- Edición
edit archivo.lua      -- Editor de texto integrado
type archivo          -- Ver contenido

-- Sistema
reboot                -- Reiniciar
shutdown              -- Apagar
help                  -- Ayuda
clear                 -- Limpiar pantalla
```

---

## 3. CONFIGURACIÓN DE PERIFÉRICOS

### Paso 3.1: Conectar Monitor

```
MATERIALES:
- 1x Monitor (Normal o Avanzado)
- 1x Cable de Red

PROCESO:
1. Craftea/Chequea el monitor:
   Normal: 6x Glass + 1x Iron Ingot + 1x Redstone
   Avanzado: 6x Glass + 1x Gold Ingot + 1x Redstone

2. Coloca el monitor adyacente a la computadora
   - El monitor debe tocar directamente la computadora
   - Cualquier lado funciona (top, bottom, left, right, front, back)

3. Verifica la conexión en la terminal:
   > monitor
   (debe retornar la dirección del periférico)

4. O prueba con:
   > peripheral.getNames()
   (verás el monitor en la lista)
```

### Paso 3.2: Conectar Módem

```
MATERIALES:
- 1x Módem de Red (o Wireless Módem)
- 1x Cable de Red

PROCESO:
1. Craftea el módem:
   Módem: 4x Stone + 2x Redstone + 1x Gold Ingot
   Wireless Módem: 1x Módem + 1x Iron Ingot

2. Coloca el módem adyacente a la computadora

3. Para red cableada, conecta cables de red entre módems

4. Verifica con:
   > peripheral.getNames()
   (debes ver "modem" en la lista)

5. Abre un canal de comunicación:
   > modem.open(42)
   (el número 42 es un ejemplo, usa el canal que necesites)
```

### Paso 3.3: Conectar Unidad de Disquete

```
MATERIALES:
- 1x Disk Drive (Unidad de Disquete)
- 1x Cable de Red

PROCESO:
1. Craftea la unidad:
   Receta: 4x Stone + 1x Iron Ingot + 1x Redstone + 1x Diamond

2. Coloca adyacente a la computadora

3. Inserta un Floppy Disk en la ranura superior del bloque

4. Verifica en terminal:
   > disk.isPresent("top")  -- (ajusta según ubicación)
   true

   > disk.getLabel("top")
   "MiDisco"
```

### Posiciones de Periféricos

```
           ┌─────────────┐
           │   MONITOR   │
           │    (top)    │
           └─────────────┘
                 │
┌───────┐  ┌─────────────┐  ┌───────┐
│ LEFT  │──│  COMPUTER   │──│ RIGHT │
│       │  │             │  │       │
└───────┘  └─────────────┘  └───────┘
     │           │              │
┌───────┐  ┌─────────────┐  ┌───────┐
│FRONT  │──│   BOTTOM    │──│ BACK  │
└───────┘  └─────────────┘  └───────┘
                 │
           ┌─────────────┐
           │ DISK DRIVE  │
           │             │
           └─────────────┘
```

### Verificación de Periféricos

```lua
-- Script de verificación
local function checkPeripherals()
    print("=== Verificacion de Perifericos ===")
    
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        local ptype = peripheral.getType(name) or "unknown"
        print(name .. ": " .. ptype)
    end
    
    -- Verificar específicos
    if peripheral.isPresent("top") then
        print("Top: " .. peripheral.getType("top"))
    end
    
    print("================================")
end

checkPeripherals()
```

---

## 4. GRABACIÓN DE DISCOS DE BOOT

### Paso 4.1: Crear un Disco de Boot

```
MATERIALES:
- 1x Floppy Disk (Disco Flexible)
- 1x Unidad de Disquete conectada
- 1x Computadora con el código

PROCESO:
1. Inserta un Floppy Disk en la unidad de disquete

2. En la terminal, formatea el disco:
   > disk.setLabel("top", "CERBERUS_BOOT")
   
3. Crea el archivo de boot en el disco:
   > cd /disk
   > edit init.lua

4. Escribe tu código de inicio:
   --[[
       CERBERUS OPS Boot Disk
       init.lua
   ]]
   
   print("Cargando CERBERUS OPS...")
   sleep(1)
   shell.openTab("/cerberus/main.lua")

5. Guarda (Ctrl + S) y cierra (Ctrl + W)

6. Verifica:
   > disk.isPresent("top")
   true
   > disk.getLabel("top")
   "CERBERUS_BOOT"
```

### Paso 4.2: Auto-Boot desde Disco

```
El sistema automáticamente ejecutará /init.lua del disco
cuando esté presente en una unidad de disquete.

1. Inserta el disco de boot en la unidad
2. Reinicia la computadora: > reboot
3. El sistema arrancará desde el disco automáticamente

NOTA: Si quieres que arranque sin disco,
copia los archivos al sistema de archivos de la computadora.
```

### Paso 4.3: Acceder a Archivos del Disco

```lua
-- Obtener ruta de montaje del disco
local mountPath = disk.getMountPath("top")

-- Navegar al disco (los discos aparecen como /disk0, /disk1, etc.)
cd /disk0
ls

-- Leer archivo directamente
local path = disk.getMountPath("top")
if path then
    local file = fs.open(path .. "/init.lua", "r")
    local content = file.readAll()
    file.close()
    print(content)
end
```

---

## 5. CONFIGURACIÓN DE RED

### Paso 5.1: Red Cableada

```
MATERIALES:
- 2+ Módems de Red
- Cable de Red (longitud necesaria)

PROCESO:
1. Coloca módems en las computadoras a conectar

2. Conecta con cables de red:
   - Click derecho en módem -> "Conectar por cable"
   - Arrastra al otro módem
   - O usa cables directamente entre ellos

3. Configura la red en cada computadora:

COMPUTADORA 0 (Central):
```lua
local modem = peripheral.find("modem")
modem.open(100)  -- Canal principal

-- Script de servidor
while true do
    local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
    if channel == 100 then
        print("Recibido: " .. tostring(message))
        
        -- Procesar mensaje
        local response = "ACK: " .. message
        modem.transmit(channel, 0, response)
    end
end
```

COMPUTADORA 1 (Cliente):
```lua
local modem = peripheral.find("modem")
modem.open(100)

while true do
    print("Enviando ping...")
    modem.transmit(100, 0, "ping")
    
    local event, side, channel, replyChannel, message = os.pullEvent("modem_message")
    if channel == 100 then
        print("Respuesta: " .. message)
    end
    
    sleep(5)
end
```

### Paso 5.2: Red Inalámbrica (Wireless Modem)

```
MATERIALES:
- 1+ Wireless Módem
- No requiere cables

PROCESO:
1. Coloca Wireless Módem en la computadora

2. Configura igual que red cableada
   - El módem transmite automáticamente
   - Rango: ~256 bloques (configurable en configs)

3. La ventaja es que no necesita cables físicos
```

### Paso 5.3: Canales de Comunicación

```
CANALES RESERVADOS PARA CERBERUS OPS:

| Canal | Sistema           | Descripción                    |
|-------|-------------------|--------------------------------|
| 100   | RED_PRINCIPAL     | Comunicación general          |
| 101   | NUCLEAR_CONTROL   | Panel de lanzamiento nuclear   |
| 102   | SECURE_MSG        | Mensajería encriptada          |
| 103   | SECURE_DOCS       | Documentos clasificados        |
| 104   | SENTINEL_HUD      | Panel de control central       |
| 200+  | Uso general       | Sistemas personalizados        |

NOTA: Elige canales que no estén en uso por otros sistemas.
```

### Paso 5.4: Testing de Red

```lua
-- Script de diagnóstico de red
local function networkTest(targetChannel)
    local modem = peripheral.find("modem")
    if not modem then
        print("Error: No se encontró módem")
        return
    end
    
    print("Abriendo canal " .. targetChannel .. "...")
    modem.open(targetChannel)
    
    print("Enviando paquete de prueba...")
    modem.transmit(targetChannel, 0, {
        type = "ping",
        from = os.getComputerID(),
        timestamp = os.time()
    })
    
    print("Esperando respuesta...")
    local timeout = os.startTimer(5)
    
    while true do
        local event, p1, p2, p3, p4 = os.pullEvent()
        
        if event == "modem_message" then
            local channel, reply, msg = p2, p3, p4
            print("Respuesta recibida:")
            print(textutils.serialize(msg))
            break
            
        elseif event == "timer" and p1 == timeout then
            print("Timeout: Sin respuesta")
            break
        end
    end
    
    modem.close(targetChannel)
end

-- Uso: networkTest(100)
```

---

## 6. INSTALACIÓN DE MÓDULOS

### Paso 6.1: Instalar Módulo de Login Seguro

```
UBICACIÓN: Computadora Central
PERIFÉRICOS NECESARIOS:
- Módem (conexión a red)
- Monitor (interfaz)

PROCESO DE INSTALACIÓN:

1. En la computadora central, crea la estructura:
   > mkdir /cerberus
   > mkdir /cerberus/core
   > mkdir /cerberus/core/auth

2. Crea el archivo de autenticación:
   > cd /cerberus/core/auth
   > edit login.lua

3. Contenido del módulo:

--[[
    Secure Login System
    CERBERUS OPS - Core Module
    Versión: 1.0.0
]]

local SecureLogin = {
    VERSION = "1.0.0",
    MAX_ATTEMPTS = 3,
    TIMEOUT = 300,
    users = {}
}

function SecureLogin:init()
    -- Cargar usuarios desde archivo
    local file = fs.open("/cerberus/config/users.dat", "r")
    if file then
        local data = file.readAll()
        file.close()
        self.users = textutils.unserialize(data) or {}
    end
end

function SecureLogin:authenticate(username, password)
    if not self.users[username] then
        return false, "Usuario no encontrado"
    end
    
    local user = self.users[username]
    local hash = sha256(password .. user.salt)
    
    if hash == user.password then
        return true, "Autenticación exitosa"
    else
        return false, "Contraseña incorrecta"
    end
end

function SecureLogin:addUser(username, password, level)
    local salt = tostring(math.random(1, 999999))
    self.users[username] = {
        password = sha256(password .. salt),
        salt = salt,
        level = level or 1
    }
    self:save()
end

function SecureLogin:save()
    local file = fs.open("/cerberus/config/users.dat", "w")
    file.write(textutils.serialize(self.users))
    file.close()
end

-- Helper SHA256 simple
function sha256(data)
    local hash = 0
    for i = 1, #data do
        hash = (hash * 31 + string.byte(data, i)) % 2147483647
    end
    return string.format("%08x", hash)
end

return SecureLogin

4. Crea el archivo de usuarios:
   > mkdir /cerberus/config
   > edit /cerberus/config/users.dat
   
   Escribe: {}
   
5. Añade un usuario administrador:
   
   > cd /cerberus
   > edit setup_admin.lua
   
--[[
    Setup Admin User
    EJECUTAR UNA SOLA VEZ
]]

local Login = require("core.auth.login")
Login:init()
Login:addUser("admin", "CHANGE_THIS_PASSWORD", 4)
print("Usuario admin creado. CAMBIA LA CONTRASEÑA!")

6. Ejecuta:
   > /cerberus/setup_admin.lua
```

### Paso 6.2: Instalar Panel de Control Nuclear

```
UBICACIÓN: Computadora dedicada (ID: 1)
PERIFÉRICOS NECESARIOS:
- Módem (conexión a red - canal 101)
- Monitor (panel visual)
- Redstone (para control físico de lanzamiento)
- Opcional: Printer (registros de lanzamiento)

PROCESO DE INSTALACIÓN:

1. Coloca la computadora en una sala segura
2. Conecta el monitor para el panel visual
3. Conecta módem para comunicación con sistema central

4. Crea los archivos:

Carpeta: /nuclear/
├── init.lua           -- Boot
├── panel.lua          -- Interfaz de control
├── auth.lua           -- Verificación de códigos
├── sequence.lua       -- Secuencia de lanzamiento
└── logger.lua         -- Registro de eventos

5. Contenido de panel.lua:

--[[
    Nuclear Control Panel
    CERBERUS OPS - Presidential System
    Nivel de seguridad: 4 (NEGRO)
]]

local NuclearControl = {
    AUTHORIZED = false,
    LAUNCH_ARMED = false,
    SEQUENCE_ACTIVE = false,
    STATUS = "STANDBY"
}

local modem = peripheral.find("modem")

function NuclearControl:drawPanel()
    term.clear()
    term.setCursorPos(1, 1)
    
    -- Header
    term.setBackgroundColor(colors.red)
    term.clearLine()
    term.setCursorPos(1, 1)
    term.write("╔════════════════════════════════════════════════╗")
    term.setCursorPos(1, 2)
    term.write("║         PANEL DE CONTROL NUCLEAR              ║")
    term.setCursorPos(1, 3)
    term.write("╚════════════════════════════════════════════════╝")
    
    -- Status
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, 5)
    print("ESTADO: " .. self.STATUS)
    print("AUTORIZADO: " .. (self.AUTHORIZED and "SI" or "NO"))
    print("ARMADO: " .. (self.LAUNCH_ARMED and "SI" or "NO"))
    
    -- Menú
    term.setCursorPos(1, 10)
    print("[1] Solicitar Autorización")
    print("[2] Armar Sistema")
    print("[3] Iniciar Secuencia")
    print("[4] Abortar")
    print("[5] Estado de Red")
end

function NuclearControl:requestAuth()
    print("Enviando solicitud a Central...")
    modem.transmit(100, 101, {
        type = "AUTH_REQUEST",
        system = "NUCLEAR",
        id = os.getComputerID()
    })
    print("Solicitud enviada. Esperando respuesta...")
end

function NuclearControl:handleMessage(msg)
    if msg.type == "AUTH_GRANTED" then
        self.AUTHORIZED = true
        print("AUTORIZACIÓN CONCEDIDA")
    elseif msg.type == "AUTH_DENIED" then
        self.AUTHORIZED = false
        print("AUTORIZACIÓN DENEGADA")
    elseif msg.type == "LAUNCH_CMD" then
        self:initiateLaunch()
    end
end

return NuclearControl
```

---

## 7. SISTEMAS CREATE

### Paso 7.1: Integración CC:C Bridge

```
REQUISITOS:
- Create mod instalado
- CC:C Bridge mod instalado
- Sensores mecánicos de Create

PROCESO:
1. Coloca un Mechanical Sensor de Create
2. Conéctalo a la computadora con Cable de Red
3. Programa el sensor:

SCRIPT DE CONFIGURACIÓN DE SENSOR:
```lua
-- Detectar bloques mekanism
local sensor = peripheral.find("sensor")

if sensor then
    print("Sensor mecánico encontrado")
    
    -- Detectar entidades
    local entities = sensor.getEntities()
    print("Entidades detectadas: " .. #entities)
    
    -- Detectar contenedores
    local containers = sensor.getContainers()
    for name, data in pairs(containers) do
        print(name .. ": " .. data.slotsUsed .. "/" .. data.slotsTotal)
    end
end
```

### Paso 7.2: Control de Encoders

```
Útil para sistemas de posicionamiento o control de tolvas.

MATERIALES:
- Rotary Encoder (Create)
- Depot
- Andesite casing

PROCESO:
1. Construye un eje con encoder
2. Conecta a la red de cables de Create
3. Programa el control:

```lua
local encoder = peripheral.find("encoder")

if encoder then
    local angle = encoder.getAngle()
    print("Ángulo actual: " .. angle)
    
    -- Mover a posición específica
    encoder.setAngle(90)  -- 90 grados
end
```

### Paso 7.3: Sistema de Stocking con Depots

```
Para monitorear niveles de items en create.

```lua
local function checkDepotStock(depotName)
    local depot = peripheral.wrap(depotName)
    
    local item = depot.getItem()
    if item then
        print("Item: " .. item.name)
        print("Cantidad: " .. item.count)
        print("Slots: " .. item.maxCount)
    else
        print("Depósito vacío")
    end
end

-- Monitoreo continuo
while true do
    checkDepotStock("top")
    sleep(5)
end
```

---

## 8. MANTENIMIENTO

### Respaldo de Archivos

```lua
-- Script de backup
local function backupSystem()
    local backupDir = "/backups/backup_" .. os.date("%Y%m%d_%H%M%S")
    
    -- Crear directorio de backup
    fs.makeDir(backupDir)
    
    -- Copiar archivos importantes
    local importantDirs = {
        "/cerberus",
        "/nuclear",
        "/config"
    }
    
    for _, dir in ipairs(importantDirs) do
        if fs.exists(dir) then
            -- Copiar directorio recursivamente
            local function copyDir(src, dst)
                fs.makeDir(dst)
                local files = fs.list(src)
                for _, file in ipairs(files) do
                    local srcPath = src .. "/" .. file
                    local dstPath = dst .. "/" .. file
                    if fs.isDir(srcPath) then
                        copyDir(srcPath, dstPath)
                    else
                        fs.copy(srcPath, dstPath)
                    end
                end
            end
            copyDir(dir, backupDir .. dir)
        end
    end
    
    print("Backup completado: " .. backupDir)
end
```

### Monitoreo de Salud del Sistema

```lua
local function systemHealth()
    local mem = math.floor(computer.freeMemory() / 1024)
    local total = math.floor(computer.totalMemory() / 1024)
    local uptime = math.floor(computer.uptime())
    
    print("=== HEALTH CHECK ===")
    print("Memoria: " .. mem .. "KB / " .. total .. "KB")
    print("Uptime: " .. uptime .. " segundos")
    print("CPU Load: " .. (100 - (mem / total * 100)) .. "%")
    print("===================")
end
```

### Comandos de Emergencia

```lua
-- FORzar apagado de emergencia
emergency_shutdown = function()
    print("APAGADO DE EMERGENCIA")
    -- Desactivar sistemas críticos
    redstone.setOutput("back", false)
    -- Cerrar módems
    modem.closeAll()
    -- Apagar
    computer.shutdown()
end
```

---

## 📞 TROUBLESHOOTING

### ⚠️ Regla Principal: Consultar documentación oficial

Si algo no funciona o no entiendes cómo funciona algo en CC: Tweaked:

**CONSULTAR SIEMPRE:** https://tweaked.cc

Esta es la fuente oficial de documentación. Antes de preguntar o experimentar, verifica ahí.

### Problemas Comunes

| Problema | Solución |
|----------|----------|
| Periférico no detectado | Verificar conexión física y cables |
| Red no funciona | Verificar módems y canales |
| Disco no se monta | Eject y reinsertar disco |
| Memoria llena | Limpiar logs antiguos |
| Código no funciona | Verificar sintaxis con `lua /archivo.lua` |
| Función no reconocida | Revisar tweaked.cc/api/ para la función correcta |

### Reset de Computadora

```lua
-- Para formatear completamente:
> cd /
> rm -f *
> reboot

-- O desde fuera (destroy):
/destroy (confirmar con Y)
```

---

## 📖 REFERENCIAS

- Wiki de CC: Tweaked: https://tweaked.cc/
- Documentación de Create: https://create.fandom.com/
- CC:C Bridge: Integración con Create

---

*Última actualización: 2026-04-05*
*Versión del documento: 1.0*
