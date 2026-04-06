# CERBERUS OPS - Red Presidencial Minecraft

Sistema centralizado de control para servidores Minecraft Forge 1.20.1 con CC: Tweaked, CC:C Bridge y Create.

## Stack Tecnológico

| Mod | Versión | Propósito |
|-----|---------|-----------|
| Minecraft Forge | 1.20.1 | Base del servidor |
| CC: Tweaked | 1.20.1 | Computadoras y periféricos Lua |
| CC:C Bridge | Compatible | Bridge entre CC y Create |
| Create | Latest | Automatización y mecánica |

## Módulos del Sistema

### 🏛️ Red Presidencial
- **NUCLEAR_CONTROL** - Panel de lanzamiento nuclear
- **SECURE_DOCS** - Almacenamiento de documentos clasificados
- **SECURE_MSG** - Sistema de mensajería encriptada
- **SENTINEL_HUD** - Panel de control central (HUD)

### ⚙️ Módulos Core
- **AUTH** - Sistema de autenticación y permisos
- **ENCRYPT** - Cifrado de datos y comunicaciones
- **LOGGER** - Registro de eventos del sistema
- **NETWORK** - Comunicación entre sistemas

## Estructura del Proyecto

```
CERBERUS OPS/
├── docs/               # Documentación del proyecto
├── src/
│   ├── core/          # Sistemas centrales
│   ├── presidential/   # Módulos de la red presidencial
│   ├── templates/     # Templates reutilizables
│   └── scripts/       # Scripts de utilidad
├── config/            # Configuraciones
└── tests/            # Pruebas de sistemas
```

## Inicio Rápido

1. Consulta `docs/GUIA.md` para implementar sistemas en el juego
2. Revisa `docs/SKILL.md` para conocer las capacidades de la IA
3. Consulta `docs/PROJECT_CONTEXT.md` para las reglas del proyecto

## Comandos de Computadora

```lua
-- Boot básico
bios.call("login")
```

## Estado del Proyecto

🚧 **EN DESARROLLO** - Fase de arquitectura base
