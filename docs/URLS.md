# URLS.md
## URLs de Descarga - CERBERUS OPS

---

## 📋 ÍNDICE

1. [Métodos de Descarga](#métodos-de-descarga)
2. [Script de Instalación](#script-de-instalación)
3. [Archivos Individuales](#archivos-individuales)
4. [Pastebin Codes](#pastebin-codes)

---

## MÉTODOS DE DESCARGA

### Método 1: Pastebin (Recomendado)

```bash
pastebin get <codigo> <nombre_archivo>
```

**Ventajas:** Rápido, no requiere servidor externo

### Método 2: HTTP/WGET

```bash
wget <url_completa>
```

**Ventajas:** Directo desde GitHub

### Método 3: GitHub Raw

```bash
wget https://raw.githubusercontent.com/USUARIO/CERBERUS-OPS/main/<ruta>
```

---

## SCRIPT DE INSTALACIÓN

### Opción A: Pastebin
```bash
pastebin get [CODIGO_INSTALL] install.lua
install
```

### Opción B: GitHub
```bash
wget https://raw.githubusercontent.com/USUARIO/CERBERUS-OPS/main/install.lua
install
```

---

## ARCHIVOS INDIVIDUALES

### Sistema Core

| Archivo | Pastebin | GitHub Raw |
|---------|----------|------------|
| install.lua | `PASTEBIN_CODE` | `URL_GITHUB/install.lua` |
| /cerberus/core/systems/logger.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/core/systems/logger.lua` |
| /cerberus/core/systems/crypto.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/core/systems/crypto.lua` |
| /cerberus/core/systems/network.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/core/systems/network.lua` |

### Sistema Presidencial

| Archivo | Pastebin | GitHub Raw |
|---------|----------|------------|
| /cerberus/presidential/control/nuclear_control.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/presidential/control/nuclear_control.lua` |
| /cerberus/presidential/control/secure_msg.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/presidential/control/secure_msg.lua` |
| /cerberus/presidential/control/secure_docs.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/presidential/control/secure_docs.lua` |
| /cerberus/presidential/control/sentinel_hud.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/presidential/control/sentinel_hud.lua` |

### Templates y UI

| Archivo | Pastebin | GitHub Raw |
|---------|----------|------------|
| /cerberus/templates/ui/components.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/templates/ui/components.lua` |
| /cerberus/init.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/templates/boot/init.lua` |
| /cerberus/config/system.lua | `PASTEBIN_CODE` | `URL_GITHUB/src/templates/config/system.lua` |

---

## PASTEBIN CODES

> ⚠️ **NOTA:** Los códigos de Pastebin deben ser reemplazados con los códigos reales después de subir los archivos.

```
┌─────────────────────────────────────┬────────────────────┐
│ ARCHIVO                             │ PASTEBIN CODE      │
├─────────────────────────────────────┼────────────────────┤
│ install.lua                         │ XXXXXXXXX          │
├─────────────────────────────────────┼────────────────────┤
│ /cerberus/core/systems/logger.lua   │ XXXXXXXXX          │
│ /cerberus/core/systems/crypto.lua   │ XXXXXXXXX          │
│ /cerberus/core/systems/network.lua │ XXXXXXXXX          │
├─────────────────────────────────────┼────────────────────┤
│ /cerberus/presidential/control/    │                    │
│   nuclear_control.lua               │ XXXXXXXXX          │
│   secure_msg.lua                    │ XXXXXXXXX          │
│   secure_docs.lua                   │ XXXXXXXXX          │
│   sentinel_hud.lua                  │ XXXXXXXXX          │
├─────────────────────────────────────┼────────────────────┤
│ /cerberus/templates/ui/components   │ XXXXXXXXX          │
│ /cerberus/init.lua                  │ XXXXXXXXX          │
│ /cerberus/config/system.lua         │ XXXXXXXXX          │
└─────────────────────────────────────┴────────────────────┘
```

---

## GUÍA RÁPIDA DE INSTALACIÓN

### Paso 1: Descargar script de instalación

En la terminal de CC: Tweaked:
```bash
pastebin get XXXXXXXXX install.lua
```

### Paso 2: Ejecutar instalador
```bash
install
```

### Paso 3: Seleccionar tipo de instalación
```
[1] Automática (recomendado)
[2] Manual (muestra URLs)
[3] Solo crear estructura
```

### Paso 4: Reiniciar
```bash
reboot
```

---

## SOLUCIÓN DE PROBLEMAS

### Error: "HTTP request failed"

El servidor no está disponible o no tienes conexión HTTP. Usa Pastebin en su lugar.

### Error: "Too long without yielding"

El archivo es muy grande. Divide la descarga o usa un servicio de compresión.

### Error: "Not enough memory"

La computadora no tiene suficiente RAM. Cierra otros programas o usa una Computadora Avanzada.

---

*Última actualización: 2026-04-05*
