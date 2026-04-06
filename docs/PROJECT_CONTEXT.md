# PROJECT_CONTEXT.md
## Contexto y Reglas del Proyecto CERBERUS OPS

---

## 🎯 IDENTIDAD DEL PROYECTO

**Nombre:** CERBERUS OPS
**Tipo:** Sistema de red presidencial para Minecraft con CC: Tweaked
**Objetivo:** Crear una infraestructura de cómputo centralizada que controle sistemas críticos, desde documentos clasificados hasta lanzamiento nuclear.

---

## 📋 REGLAS FUNDAMENTALES

### 1. Estructura de Código

```
PATRÓN DE命名:
- Archivos Lua: snake_case.lua (ej: secure_login.lua)
- Variables: camelCase (ej: userAuth)
- Constantes: UPPER_SNAKE_CASE (ej: MAX_RETRIES)
- Funciones: snake_case() (ej: authenticate_user())
- Módulos: PascalCase (ej: SecureAuth)
```

### 2. Sistema de Archivos del Proyecto

```
cerberus/
├── init.lua                    # Boot principal
├── diag.lua                    # Script de diagnostico
├── core/
│   ├── logger.lua             # Logs del sistema
│   ├── crypto.lua             # Cifrado
│   └── network.lua            # Red
├── lib/
│   └── ui.lua                 # Componentes UI
├── config/
│   └── system.lua             # Configuracion
├── presidential/
│   ├── sentinel_hud.lua       # Panel central
│   ├── nuclear_control.lua    # Lanzamiento nuclear
│   ├── secure_msg.lua         # Mensajeria segura
│   └── secure_docs.lua        # Documentos clasificados
├── logs/                      # Logs
└── docs/                      # Documentos guardados
```

### 3. Convenciones Lua

```lua
-- MÓDULO EJEMPLO (src/core/auth/login.lua)
--[[
    Módulo: Secure Login System
    Versión: 1.0.0
    Descripción: Sistema de autenticación con múltiples factores
]]

local SecureLogin = {
    VERSION = "1.0.0",
    MAX_ATTEMPTS = 3,
    TIMEOUT = 300
}

-- Dependencias
local Encryption = require("core.crypto.encryption")
local Logger = require("core.logger.system")

function SecureLogin:authenticate(username, password)
    -- implementación
end

return SecureLogin
```

### 4. Organización de Archivos en CC: Tweaked

```
COMPUTADORA PRINCIPAL (ID: 0)
├── /cerberus/
│   ├── init.lua              # Boot principal
│   ├── config.lua            # Configuración global
│   ├── core/
│   │   ├── auth.lua
│   │   ├── crypto.lua
│   │   └── logger.lua
│   ├── presidential/
│   │   ├── nuclear_control.lua
│   │   ├── secure_docs.lua
│   │   └── secure_msg.lua
│   └── lib/
│       ├── ui.lua
│       └── network.lua

COMPUTADORA SECUNDARIA (Nuclear Control - ID: 1)
├── /nuclear/
│   ├── init.lua
│   ├── panel.lua
│   └── launch_sequence.lua
```

---

## 🔒 NORMAS DE SEGURIDAD

### Archivos `secrets.lua` (NUNCA COMMITEAR)
```lua
-- config/secrets_example.lua
return {
    master_password = "CHANGE_THIS",
    nuclear_codes = {
        primary = "XXXX-XXXX",
        secondary = "XXXX-XXXX"
    },
    api_keys = {}
}
```

### Reglas de Cifrado
- Contraseñas: SHA-256 con salt
- Mensajes: AES-256
- Archivos críticos: Cifrado doble

### Protocolo de Documentos Clasificados
- Nivel 1 (VERDE): Acceso libre
- Nivel 2 (AMARILLO): Requiere autorización
- Nivel 3 (ROJO): Solo personal autorizado
- Nivel 4 (NEGRO): Nivel máximo, nuclear

---

## 🏗️ ARQUITECTURA DE SISTEMAS

### Red Presidencial - Diagrama de Conexiones

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVIDOR CENTRAL                         │
│                    (Computadora 0)                          │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │
│  │  AUTH   │ │ LOGGER  │ │ CRYPTO  │ │ NETWORK │           │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘           │
└───────┼────────────┼───────────┼───────────┼────────────────┘
        │            │           │           │
        ▼            ▼           ▼           ▼
┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐
│  NUCLEAR  │ │ SECURE    │ │ SECURE    │ │ SENTINEL  │
│  CONTROL  │ │  DOCS     │ │   MSG     │ │   HUD     │
│  (ID: 1)  │ │  (ID: 2)  │ │  (ID: 3)  │ │  (ID: 4)  │
└───────────┘ └───────────┘ └───────────┘ └───────────┘
        │            │           │           │
        └────────────┴───────────┴───────────┘
                         │
                    CC:C BRIDGE
                         │
                    CREATE NETWORK
```

### Periféricos Utilizados
| Periférico | Uso | Conexión |
|------------|-----|----------|
| monitor | HUD y paneles | Cable de red |
| modem | Comunicación | Cable de red |
| printer | Documentos | Cable de red |
| disk drive | Almacenamiento | Directo |
| sensor | Monitoreo | Create network |

---

## 📝 PROMPTS Y WORKFLOW

### Prompt Base para Nuevos Sistemas
```
Necesito crear [NOMBRE_DEL_SISTEMA] para CERBERUS OPS:
- Función: [DESCRIPCIÓN]
- Nivel de seguridad: [1-4]
- Requiere periféricos: [LISTA]
- Conexión a: [SISTEMAS_DEPENDIENTES]
```

### Proceso de Desarrollo

```
1. ANÁLISIS
   - Definir propósito del sistema
   - Identificar dependencias
   - Determinar nivel de seguridad

2. DISEÑO
   - Crear spec en docs/
   - Definir API del módulo
   - Planificar pruebas

3. IMPLEMENTACIÓN
   - Crear archivo en src/
   - Seguir convenciones Lua
   - Documentar funciones

4. INTEGRACIÓN
   - Actualizar GUIA.md
   - Crear script de instalación
   - Probar en juego

5. VALIDACIÓN
   - Verificar seguridad
   - Testear límites
   - Documentar uso
```

---

## 🔧 APIS Y MÓDULOS

### API Core - Logger
```lua
local Logger = require("core.logger")

Logger:info("Sistema iniciado")
Logger:warn("Uso elevado de memoria")
Logger:error("Fallo de autenticación")
Logger:debug("Paquete recibido")
```

### API Core - Crypto
```lua
local Crypto = require("core.crypto")

local hash = Crypto:sha256("password")
local encrypted = Crypto:aes_encrypt(data, key)
local decrypted = Crypto:aes_decrypt(encrypted, key)
```

### API Core - Network
```lua
local Network = require("core.network")

Network:broadcast("sistema", "mensaje", data)
Network:send(target_id, "mensaje", data)
Network:listen("mensaje", callback)
```

### API Presidential - Nuclear Control
```lua
local NuclearControl = require("presidential.nuclear_control")

NuclearControl:get_status()
NuclearControl:authorize(codes)
NuclearControl:initiate_launch()
NuclearControl:abort()
```

---

## 📊 METRICAS Y MONITOREO

### Logs del Sistema
- Ubicación: `/cerberus/logs/`
- Formato: `[TIMESTAMP] [LEVEL] [SOURCE] mensaje`
- Rotación: Diaria
- Retención: 7 días

### Métricas de Salud
- CPU: Uso de ticks
- Memoria: Slots de disco usados
- Red: Paquetes/segundo
- Errores: Count por hora

---

## 🚀 DESPLIEGUE

### Flujo de Instalación en Juego
1. Colocar computadora central
2. Conectar periféricos via cable de red
3. Insertar disco de boot
4. Encender y seguir `docs/GUIA.md`

### Comandos de Red
```lua
-- Identificar ID de computadoras
ls /dev/

-- Probar conexión
ping <id>

-- Ver periféricos disponibles
peripheral.getNames()
```

---

## 📌 NOTAS IMPORTANTES

1. **NUNCA** usar passwords hardcodeadas en commits
2. **SIEMPRE** documentar funciones con comentarios LuaDoc
3. **RESPETAR** jerarquía de seguridad
4. **MANTENER** logs de todas las operaciones críticas
5. **TESTEAR** en ambiente de desarrollo antes de producción

---

## 🔍 CONSULTA DE DOCUMENTACIÓN

### Regla OBLIGATORIA: Consultar wiki oficial

Si algún proceso, función o API de CC: Tweaked no está clara o no funciona como esperado:

**CONSULTAR SIEMPRE:** https://tweaked.cc

Esta es la fuente oficial de documentación y siempre debe ser la referencia primaria.

### Patrón de verificación:
```
1. ¿No funciona una función? → Revisar tweaked.cc
2. ¿No entiendo un periférico? → Revisar tweaked.cc
3. ¿Error desconocido? → Buscar en tweaked.cc/api/
```

---

## 📡 SISTEMA DE INSTALACIÓN EN DISCO

### Metodo Recomendado: Instalacion en Floppy Disk

1. Conectar Disk Drive a la computadora
2. Insertar Floppy Disk
3. Descargar e instalar:
   ```bash
   wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main/install.lua install.lua
   install
   ```
4. El disco se renombra automaticamente a **CERBERUS-OPS**
5. Usar el disco en cualquier computadora

### Estructura del Disco

```
CERBERUS-OPS/
├── autorun.lua       # Auto-ejecuta al insertar
└── cerberus/
    ├── init.lua      # Boot principal
    ├── core/         # Modulos core
    ├── lib/          # Librerias
    ├── config/       # Configuracion
    └── presidential/ # Sistemas presicenciales
```

### Configurar repositorio propio

Cuando subas a tu propio repositorio, cambia la URL en install.lua:
```lua
BASE_URL = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/cerberus"
```

---

*Última actualización: 2026-04-06*
*Versión del documento: 2.0*
