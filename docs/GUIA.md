# GUIA.md
## Guía de Implementación - CERBERUS OPS

Sistema de red presidencial para Minecraft Forge 1.20.1 + CC: Tweaked.

**Modo de juego:** Creativo

---

## 🚀 INSTALACIÓN RÁPIDA (2 minutos)

### Paso 1: Colocar Computadora

```
1. Craftea Computadora Avanzada:
   - 3x Redstone, 2x Diamond, 1x Iron Ingot, 1x Glass
   
2. Colócala en tu base.

3. Click derecho para abrir terminal.
```

### Paso 2: Instalar

En la terminal:

```bash
wget https://raw.githubusercontent.com/AncientDarkFire/CERBERUS-OPS/main/install.lua install.lua
install
```

### Paso 3: Reiniciar

```bash
reboot
```

¡Listo!

---

## 📁 ESTRUCTURA DEL SISTEMA

```
/cerberus/
├── init.lua                    # Boot principal
├── diag.lua                    # Script de diagnostico
├── core/
│   ├── logger.lua             # Logs
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
├── logs/                      # Logs del sistema
└── docs/                      # Documentos guardados
```

---

## 🎮 EJECUTAR SISTEMAS

### Menu Principal

Despues de `reboot`, escribe:
```bash
hud        -- Panel SENTINEL
nuclear    -- Control Nuclear
msg        -- Mensajeria Segura
docs       -- Documentos
```

### Ejecutar Directamente

```bash
lua /cerberus/presidential/sentinel_hud
lua /cerberus/presidential/nuclear_control
lua /cerberus/presidential/secure_msg
lua /cerberus/presidential/secure_docs
```

### Diagnostico

```bash
lua /cerberus/diag
```

---

## 🔧 CONFIGURACIÓN

### Conectar Periféricos

```
Monitor:    Colocar adyacente a la computadora
Modem:      Colocar adyacente para red cableada
Redstone:   Conectar al lado "back" para control fisico
```

### Canales de Red

| Canal | Sistema |
|-------|---------|
| 100 | Red Principal |
| 101 | Control Nuclear |
| 102 | Mensajería Segura |
| 103 | Documentos |

---

## ⚠️ SOLUCIÓN DE PROBLEMAS

| Problema | Solución |
|----------|----------|
| "HTTP request failed" | Verificar conexión a internet |
| Periférico no detectado | Verificar que esté tocando directamente |
| Red no funciona | Verificar cables entre módems |

**Consultar siempre:** https://tweaked.cc

---

## 📚 REFERENCIAS

- Wiki CC: Tweaked: https://tweaked.cc/

*Última actualización: 2026-04-06*
