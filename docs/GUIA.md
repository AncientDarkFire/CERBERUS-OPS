# GUIA.md
## Guia de Implementacion - CERBERUS OPS

Sistema de red presidencial para Minecraft Forge 1.20.1 + CC: Tweaked.

---

## REQUISITOS

- Computadora Avanzada de CC: Tweaked
- Disk Drive conectado a la computadora
- Floppy Disk (vacio o con datos, se reformateara)
- Conexion a internet en el juego (para descargar archivos)

---

## INSTALACION EN DISCO (Metodo Recomendado)

### Paso 1: Preparar

1. Coloca un **Disk Drive** junto a la computadora
2. Inserta un **Floppy Disk** en el Disk Drive
3. Abre la terminal de la computadora

### Paso 2: Descargar Instalador

```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install.lua install.lua
```

### Paso 3: Ejecutar Instalador

```bash
install
```

El script:
- Detectara el Disk Drive automaticamente
- Renombrara el disco a **CERBERUS-OPS**
- Descargara todos los archivos al disco
- Creara el archivo autorun para boot automatico

### Paso 4: Usar el Disco

1. **Inserta el disco** en la computadora donde quieras usar CERBERUS OPS
2. **Reinicia** la computadora con `reboot`
3. El sistema iniciara automaticamente

O ejecuta manualmente:
```bash
lua /cerberus/init
```

---

## ESTRUCTURA EN EL DISCO

```
CERBERUS-OPS (Floppy Disk)
├── autorun.lua          # Ejecuta init.lua al insertar
└── cerberus/
    ├── init.lua         # Boot principal
    ├── diag.lua         # Diagnostico
    ├── core/
    │   ├── logger.lua
    │   ├── crypto.lua
    │   └── network.lua
    ├── lib/
    │   └── ui.lua
    ├── config/
    │   └── system.lua
    └── presidential/
        ├── sentinel_hud.lua
        ├── nuclear_control.lua
        ├── secure_msg.lua
        └── secure_docs.lua
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

hud         - Panel SENTINEL
nuclear     - Control Nuclear
msg         - Mensajeria Segura
docs        - Documentos Clasificados
diag        - Diagnostico rapido
peri        - Ver perifericos
```

---

## INSTALACION MANUAL EN COMPUTADORA

Si prefieres instalar directamente en la computadora (sin disco):

### Paso 1: Crear estructura

```bash
mkdir /cerberus/core
mkdir /cerberus/lib
mkdir /cerberus/presidential
mkdir /cerberus/config
```

### Paso 2: Descargar archivos

```bash
# Boot
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/init.lua /cerberus/init.lua

# Core
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/core/logger.lua /cerberus/core/logger.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/core/crypto.lua /cerberus/core/crypto.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/core/network.lua /cerberus/core/network.lua

# Templates
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/lib/ui.lua /cerberus/lib/ui.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/config/system.lua /cerberus/config/system.lua

# Presidential
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/presidential/sentinel_hud.lua /cerberus/presidential/sentinel_hud.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/presidential/nuclear_control.lua /cerberus/presidential/nuclear_control.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/presidential/secure_msg.lua /cerberus/presidential/secure_msg.lua
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/cerberus/presidential/secure_docs.lua /cerberus/presidential/secure_docs.lua
```

### Paso 3: Reiniciar

```bash
reboot
```

---

## SOLUCION DE PROBLEMAS

| Problema | Solucion |
|----------|----------|
| "No se encontro Disk Drive" | Conectar Disk Drive a la computadora |
| "No hay disco" | Insertar Floppy Disk en el Disk Drive |
| "HTTP request failed" | Verificar conexion a internet |
| Disco no bootea | Escribir `lua /cerberus/init` manualmente |

---

## MAS INFORMACION

Wiki CC: Tweaked: https://tweaked.cc/

---

*Ultima actualizacion: 2026-04-06*
*Version: 2.1.0*
