# CERBERUS OPS

Sistema de Red Presidencial para Minecraft con CC: Tweaked.

## Arquitectura Cliente-Servidor

```
+-------------------+       +-------------------+
|   PENTAGON        |       |   CLIENTES        |
|   (Servidor)      |<----->|   (Cerberus)     |
|                   |       |                   |
| ID central        |       | - Sentinel HUD   |
| Gestor clientes   |       | - Nuclear        |
| Auth central      |       | - Secure Msg     |
| Centro de red     |       | - Secure Docs    |
+-------------------+       +-------------------+
```

## Version 1.0.0 (definida en init.lua del servidor)

## Instalacion

### Cliente (CERBERUS)
```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install.lua install.lua
install
```

### Servidor (PENTAGON)
```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install_server.lua install_server.lua
install_server
```

## Caracteristicas del Cliente

- **SENTINEL HUD** - Panel de control central
- **NUCLEAR CONTROL** - Sistema de lanzamiento nuclear
- **SECURE MSG** - Mensajeria encriptada
- **SECURE DOCS** - Documentos clasificados (4 niveles)

## Requisitos

- Minecraft Forge 1.20.1 + CC: Tweaked 1.20.1
- Disk Drive + Floppy Disk
- Modem (requerido para comunicacion)
- Monitor (opcional)

## Canales de Comunicacion

| Sistema      | Canal |
|--------------|-------|
| Central      | 100   |
| Nuclear      | 101   |
| Mensajeria   | 102   |
| Documentos   | 103   |

## Documentacion

Ver `docs/GUIA.md` para instrucciones detalladas.

## Mas Info

- Wiki CC: Tweaked: https://tweaked.cc/