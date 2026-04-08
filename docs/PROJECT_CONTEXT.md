# PROJECT_CONTEXT.md
## Contexto y Reglas del Proyecto CERBERUS OPS

---

## 🎯 IDENTIDAD DEL PROYECTO

**Nombre:** CERBERUS OPS
**Tipo:** Sistema de red presidencial para Minecraft con CC: Tweaked
**Objetivo:** Crear una infraestructura de cómputo centralizada que controle sistemas críticos, desde documentos clasificados hasta lanzamiento nuclear.
**Version:** 2.3.0

---

## 📋 REGLAS FUNDAMENTALES

### 1. Estructura de Código

```
PATRÓN DE命名:
- Archivos Lua: snake_case.lua (ej: secure_msg.lua)
- Variables: camelCase (ej: userAuth)
- Constantes: UPPER_SNAKE_CASE (ej: MAX_INBOX)
- Funciones: snake_case() (ej: encrypt_content())
- Módulos: PascalCase (ej: SecureMsg)
```

### 2. Sistema de Archivos del Proyecto

```
CERBERUS-OPS/
├── install.lua                    # Instalador
├── README.md                      # Documentacion principal
├── docs/
│   ├── GUIA.md                    # Guia de instalacion
│   ├── PROJECT_CONTEXT.md         # Este archivo
│   ├── SKILL.md                   # Referencia CC: Tweaked
│   ├── URLS.md                    # URLs de descarga
│   └── PROMPTS.md                 # Plantillas de prompts
└── cerberus/
    ├── init.lua                   # Boot principal (contiene version)
    ├── diag.lua                   # Script de diagnostico
    └── presidential/
        ├── sentinel_hud.lua       # Panel central
        ├── nuclear_control.lua    # Lanzamiento nuclear
        ├── secure_msg.lua         # Mensajeria segura
        └── secure_docs.lua        # Documentos clasificados
```

### 3. Convenciones Lua

```lua
-- MÓDULO EJEMPLO (cerberus/presidential/secure_msg.lua)
--[[
    Módulo: Secure Message System
    Versión: 2.3.0
    Descripción: Sistema de mensajería encriptada punto a punto
]]

local SecureMsg = {
    VERSION = "2.3.0",
    CHANNEL = 102,
    MAX_INBOX = 20
}

-- Paleta de colores consistente
local C = {
    bg       = colors.black,
    panel    = colors.blue,
    accent   = colors.lightBlue,
    title    = colors.white,
    dim      = colors.gray,
    ok       = colors.lime,
    warn     = colors.yellow,
    err      = colors.red,
}

function SecureMsg:run()
    -- implementación
end

return SecureMsg
```

---

## 🔒 NORMAS DE SEGURIDAD

### Contraseñas de Usuario (secure_docs.lua)
```lua
local USERS = {
    { name = "operador", passhash = "op2024",    level = 2 },
    { name = "oficial",  passhash = "ofi3sec",   level = 3 },
    { name = "admin",    passhash = "adm4cerb",  level = 4 },
}
```

### Niveles de Seguridad de Documentos
- Nivel 1 (VERDE): Acceso libre
- Nivel 2 (AMARILLO): Requiere autorización (operador)
- Nivel 3 (ROJO): Solo personal autorizado (oficial)
- Nivel 4 (NEGRO): Nivel máximo (admin)

### Protocolo de Cifrado
- Mensajes: XOR + Base64 con clave por destinatario
- Documentos: XOR con clave aleatoria de 32 chars
- Claves almacenadas en archivo separado (keys.dat)

---

## 🏗️ ARQUITECTURA DE SISTEMAS

### Red Presidencial - Canales de Comunicación

```
┌─────────────────────────────────────────────────────────────┐
│                    COMPUTADORA CENTRAL                       │
│                    (Boot: init.lua v2.2.0)                  │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐         │
│  │ MODEM   │ │MONITOR  │ │  DISK   │ │TERMINAL │         │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘         │
└───────┼───────────┼───────────┼───────────┼─────────────────┘
        │           │           │           │
        ▼           ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ SENTINEL│ │ NUCLEAR │ │  MSG    │ │  DOCS   │
   │   HUD   │ │ CONTROL │ │         │ │         │
   │  (ch100)│ │ (ch101) │ │ (ch102) │ │ (ch103) │
   └─────────┘ └─────────┘ └─────────┘ └─────────┘
```

### Canales de Comunicación
| Sistema      | Canal | Descripcion |
|--------------|-------|-------------|
| Central      | 100   | Ping/Pong general |
| Nuclear      | 101   | Control de lanzamiento |
| Mensajeria   | 102   | Mensajes encriptados |
| Documentos   | 103   | Documentos clasificados |

### Estados del Sistema Nuclear
- STANDBY: Sistema inactivo
- ARMED: Sistema armado, listo para lanzamiento
- LAUNCHING: Secuencia de lanzamiento activa
- ABORTED: Operacion abortada

---

## 📋 PROMPTS Y WORKFLOW

### Prompt Base para Nuevos Sistemas
```
[SISTEMA]
Eres un desarrollador senior de sistemas embebidos para CC: Tweaked (Lua).
Conoces profundamente la API de CC: Tweaked 1.20.1, periféricos, red,
sistema de archivos y eventos.
[/SISTEMA]

[CONTEXTO]
Proyecto: CERBERUS OPS - Red Presidencial Minecraft
Version: 2.3.0
Stack: CC: Tweaked 1.20.1
Nivel de seguridad: Variable según sistema (1-4)
[/CONTEXTO]

[TAREA]
[NOMBRE_DEL_SISTEMA] para CERBERUS OPS:
- Función: [DESCRIPCIÓN]
- Nivel de seguridad: [1-4]
- Requiere periféricos: [LISTA]
- Conexión a: [SISTEMAS_DEPENDIENTES]
[/TAREA]

[REGLAS]
- Seguir convenciones Lua de docs/PROJECT_CONTEXT.md
- Usar paleta de colores consistente (C = {...})
- Documentar funciones con comentarios
- Implementar manejo de errores
- Usar APIs de docs/SKILL.md
[/REGLAS]

[SALIDA]
Generar código Lua funcional listo para copiar al juego.
[/SALIDA]
```

### Proceso de Desarrollo

```
1. ANÁLISIS
   - Definir propósito del sistema
   - Identificar dependencias (canal de modem)
   - Determinar nivel de seguridad

2. DISEÑO
   - Crear spec en docs/
   - Definir API del módulo
   - Planificar pruebas

3. IMPLEMENTACIÓN
   - Crear archivo en cerberus/presidential/
   - Seguir convenciones Lua
   - Usar paleta de colores consistente
   - Documentar funciones

4. INTEGRACIÓN
   - Actualizar GUIA.md
   - Actualizar install.lua si es necesario
   - Probar en juego

5. VALIDACIÓN
   - Verificar seguridad
   - Testear límites
   - Documentar uso
```

---

## 🔧 APIS Y MÓDULOS

### API de Cifrado (secure_msg.lua)
```lua
local SecureMsg = dofile("/cerberus/presidential/secure_msg")

-- Encriptar mensaje para un destinatario
local encoded, envelope = SecureMsg:encrypt(content, recipient_id)

-- Desencriptar mensaje recibido
local decrypted = SecureMsg:decrypt(encoded, envelope)
```

### API de Documentos (secure_docs.lua)
```lua
local SecureDocs = dofile("/cerberus/presidential/secure_docs")

-- Inicializar (carga indices y claves)
SecureDocs:init()

-- Login de usuario
SecureDocs:login()

-- CRUD de documentos
local doc_id = SecureDocs:create_document(title, content, sec_level)
local content, doc = SecureDocs:read_document(doc_id)
SecureDocs:delete_document(doc_id)
```

### API de Nuclear (nuclear_control.lua)
```lua
local NuclearControl = dofile("/cerberus/presidential/nuclear_control")

-- Flujo de operación
NuclearControl:request_auth()    -- Solicitar autorizacion
NuclearControl:arm_system()      -- Armar sistema
NuclearControl:initiate_launch() -- Lanzar
NuclearControl:abort()           -- Abortar
```

---

## 📊 METRICAS Y MONITOREO

### Logs del Sistema (Sentinel HUD)
- Ubicación visual en el panel
- Actualización cada 15 segundos
- Estados: NOMINAL, ALERTA, ESCANEO

### Métricas de Salud
- CPU: Tiempo de ejecución (os.clock())
- Memoria: No hay API nativa, usar con precaución
- Red: Ping/Pong entre sistemas
- Errores: Alertas en panel

---

## 🚀 DESPLIEGUE

### Flujo de Instalación en Juego
1. Colocar computadora central
2. Conectar Disk Drive con Floppy Disk
3. Conectar modem para comunicación
4. Opcional: conectar monitor para mejor interfaz
5. Descargar e instalar con install.lua

### Comandos de Red
```lua
-- Identificar ID de computadoras
os.computerID()

-- Ver periféricos disponibles
peripheral.getNames()

-- Obtener tipo de periférico
peripheral.getType("top")
```

---

## 📌 NOTAS IMPORTANTES

1. **NUNCA** usar passwords reales en commits
2. **SIEMPRE** documentar funciones con comentarios
3. **RESPETAR** jerarquía de seguridad (niveles 1-4)
4. **MANTENER** consistencia en paleta de colores
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
   wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install.lua install.lua
   install
   ```
4. El disco se renombra automaticamente a **CERBERUS-OPS 2.2.0**
5. Usar el disco en cualquier computadora

### Estructura del Disco

```
CERBERUS-OPS 2.2.0/
└── cerberus/
    ├── init.lua              # Boot principal
    ├── diag.lua              # Diagnostico
    └── presidential/         # Sistemas presidenciales
        ├── sentinel_hud.lua
        ├── nuclear_control.lua
        ├── secure_msg.lua
        └── secure_docs.lua
```

### Configurar repositorio propio

Cuando subas a tu propio repositorio, cambia la URL en install.lua:
```lua
BASE_URL = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/cerberus"
```

---

*Última actualización: 2026-04-08*
*Versión del documento: 2.1*