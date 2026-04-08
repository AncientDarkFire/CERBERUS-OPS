# GUIA.md
## Guia de Implementacion - CERBERUS OPS

Sistema de red presidencial para Minecraft Forge 1.20.1 + CC: Tweaked.

---

## ARQUITECTURA DEL SISTEMA

CERBERUS OPS utiliza una arquitectura cliente-servidor:

```
+-------------------+       +-------------------+
|   PENTAGON        |       |   CLIENTES        |
|   (Servidor)      |<----->|   (Cerberus)     |
|                   |       |                   |
| - Gestor clientes |       | - Sentinel HUD   |
| - Auth central   |       | - Nuclear        |
| - Centro de red  |       | - Secure Msg     |
| - Panel control  |       | - Secure Docs    |
+-------------------+       +-------------------+
```

**Canales de comunicacion:**
- Canal 100: Central
- Canal 101: Nuclear
- Canal 102: Mensajeria
- Canal 103: Documentos

---

## REQUISITOS

- Computadora Avanzada de CC: Tweaked
- Disk Drive conectado a la computadora
- Floppy Disk (vacio o con datos, se reformateara)
- Conexion a internet en el juego (para descargar archivos)
- Monitor (opcional, para interfaz grafica mejorada)
- Modem (requerido para comunicacion entre sistemas)

---

## INSTALACION EN DISCO (Metodo Recomendado)

### Cliente (CERBERUS)

1. Coloca un **Disk Drive** junto a la computadora
2. Inserta un **Floppy Disk** en el Disk Drive
3. Abre la terminal de la computadora

```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install.lua install.lua
install
```

El script:
- Detectara el Disk Drive automaticamente
- Renombrara el disco a **CERBERUS-OPS**
- Descargara todos los archivos al disco
- Reiniciara la computadora

### Servidor (PENTAGON)

```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install_server.lua install_server.lua
install_server
```

El script:
- Detectara el Disk Drive automaticamente
- Renombrara el disco a **PENTAGON-SRV**
- Descargara los archivos del servidor
- Reiniciara la computadora

---

## ESTRUCTURA EN EL DISCO

```
CERBERUS-OPS (Floppy Disk)
└── cerberus/
    ├── init.lua         # Boot principal (contiene version del sistema)
    ├── diag.lua         # Diagnostico
    └── presidential/
        ├── sentinel_hud.lua       # Panel central
        ├── nuclear_control.lua    # Control Nuclear
        ├── secure_msg.lua         # Mensajeria Segura
        └── secure_docs.lua        # Documentos Clasificados
```

---

## COMANDOS DEL SISTEMA

Despues de bootear desde el disco:

```
help        - Mostrar ayuda
status      - Estado del sistema
clear       - Limpiar pantalla
reboot      - Reiniciar
shutdown    - Apagar

hud         - Panel SENTINEL (Panel de control central)
nuclear     - Control Nuclear (Sistema de lanzamiento)
msg         - Mensajeria Segura (Mensajeria encriptada)
docs        - Documentos Clasificados (Almacenamiento seguro)
diag        - Diagnostico rapido
peri        - Ver perifericos
```

---

## SISTEMAS PRESIDENCIALES

### SENTINEL HUD (Panel Central)
- Panel de control que monitorea todos los sistemas
- Muestra estado de conectividad en tiempo real
- Escaneo automatico cada 15 segundos
- Atajos: [1]Nuclear [2]Mensajeria [3]Docs [R]Scan [Q]Salir

### CONTROL NUCLEAR
- Sistema de lanzamiento nuclear simulado
- Flujo: STANDBY -> AUTORIZADO -> ARMADO -> LANZAMIENTO
- Autenticacion requerida desde Central
- Controles: [1]Solicitar [2]Armar [3]Lanzar [4]Abortar [5]Estado Red

### MENSAJERIA SEGURA
- Mensajeria encriptada punto a punto
- Cifrado: XOR + Base64 con clave por destinatario
- Bandeja de entrada con paginacion
- Controles: [N]Nuevo [Enter]Leer [D]Borrar [R]Responder

### DOCUMENTOS CLASIFICADOS
- Almacenamiento cifrado de documentos
- 4 niveles de seguridad: VERDE, AMARILLO, ROJO, NEGRO
- Autenticacion de usuarios
- Controles: [N]Nuevo [Enter]Ver [D]Borrar [/]Buscar

---

## INSTALACION MANUAL EN COMPUTADORA

Si prefieres instalar directamente en la computadora (sin disco):

### Paso 1: Crear estructura

```bash
mkdir /cerberus
mkdir /cerberus/presidential
```

### Paso 2: Descargar archivos

```bash
# Boot principal
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main/cerberus/init.lua /cerberus/init.lua

# Sistemas Presidenciales
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main/cerberus/presidential/sentinel_hud.lua /cerberus/presidential/sentinel_hud.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main/cerberus/presidential/nuclear_control.lua /cerberus/presidential/nuclear_control.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main/cerberus/presidential/secure_msg.lua /cerberus/presidential/secure_msg.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/refs/heads/main/cerberus/presidential/secure_docs.lua /cerberus/presidential/secure_docs.lua
```

### Paso 3: Reiniciar

```bash
reboot
```

---

## INSTALACION DEL SERVIDOR (PENTAGON)

### Paso 1: Ejecutar instalador

```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install_server.lua install_server.lua
install_server
```

### Estructura del servidor

```
PENTAGON-SRV (Floppy Disk)
└── pentagon/
    ├── init.lua            # Boot del servidor
    ├── client_manager.lua  # Gestor de clientes
    ├── auth_server.lua     # Servidor de autenticacion
    ├── network_hub.lua     # Centro de red
    └── server_hud.lua      # Panel de control
```

### Comandos del servidor

```
help        - Mostrar ayuda
status      - Estado del servidor
clear       - Limpiar pantalla
clients     - Ver clientes conectados
auth        - Ver autorizaciones pendientes
network     - Estado de red
hud         - Panel de control
reboot      - Reiniciar servidor
shutdown    - Apagar servidor
```

---

## CANALES DE COMUNICACION

| Sistema      | Canal |
|--------------|-------|
| Central      | 100   |
| Nuclear      | 101   |
| Mensajeria   | 102   |
| Documentos   | 103   |

---

## SOLUCION DE PROBLEMAS

| Problema | Solucion |
|----------|----------|
| "No se encontro Disk Drive" | Conectar Disk Drive a la computadora |
| "No hay disco" | Insertar Floppy Disk en el Disk Drive |
| "HTTP request failed" | Verificar conexion a internet |
| Disco no bootea | Escribir `lua /cerberus/init` manualmente |
| Sin modem | Conectar modem para funcionalidad de red completa |

---

## MAS INFORMACION

Wiki CC: Tweaked: https://tweaked.cc/

---

*Ultima actualizacion: 2026-04-08*
*Version: 2.3.0*