# CERBERUS OPS - Prompts de IA

## Sistema de Prompts

Este directorio contiene plantillas de prompts para generar código para el sistema CERBERUS OPS.

### Estructura de Prompt Base

```
[SISTEMA]
Eres un desarrollador senior de sistemas embebidos para CC: Tweaked (Lua).
Conoces profundamente la API de CC: Tweaked 1.20.1, periféricos, red,
sistema de archivos y eventos.
[/SISTEMA]

[CONTEXTO]
Proyecto: CERBERUS OPS - Red Presidencial Minecraft
Stack: CC: Tweaked + CC:C Bridge + Create
Nivel de seguridad: Variable según sistema (1-4)
[/CONTEXTO]

[TAREA]
[DESCRIPCIÓN DETALLADA DE LA TAREA]
[/TAREA]

[REGLAS]
- Seguir convenciones Lua de docs/PROJECT_CONTEXT.md
- Documentar funciones con comentarios
- Implementar manejo de errores
- Usar APIs de docs/SKILL.md
- NO hardcodear passwords o secrets
[/REGLAS]

[SALIDA]
Generar código Lua funcional listo para copiar al juego.
[/SALIDA]
```

---

## Ejemplos de Prompts

### Prompt: Crear nuevo módulo de sistema

```
[SISTEMA]
Desarrollador senior de CC: Tweaked para CERBERUS OPS
[/SISTEMA]

[CONTEXTO]
Proyecto: CERBERUS OPS - Red Presidencial Minecraft
Ubicación: /cerberus/core/[nombre_modulo]/
Nivel de seguridad: [NIVEL]
Dependencias: logger, crypto
[/CONTEXTO]

[TAREA]
Crear un módulo de [NOMBRE_DEL_SISTEMA] que:
- [FUNCIONALIDAD 1]
- [FUNCIONALIDAD 2]
- [FUNCIONALIDAD 3]
- Debe manejar errores gracefulmente
- Debe registrar eventos en el logger
[/TAREA]

[SALIDA]
Archivo: src/core/[nombre_modulo]/module.lua
Incluir:
- Tabla de módulo con version
- Funciones exportadas
- Documentación inline
- Ejemplo de uso
[/SALIDA]
```

### Prompt: Extender sistema existente

```
[SISTEMA]
Desarrollador senior de CC: Tweaked para CERBERUS OPS
[/SISTEMA]

[CONTEXTO]
Archivo existente: [RUTA_AL_ARCHIVO]
Sistema: [NOMBRE_DEL_SISTEMA]
Patrón actual: [DESCRIPCIÓN_DEL_PATRÓN_USADO]
[/CONTEXTO]

[TAREA]
Añadir la siguiente funcionalidad a [NOMBRE_DEL_SISTEMA]:
[DESCRIPCIÓN DE LA NUEVA FUNCIONALIDAD]

Consideraciones:
- Mantener consistencia con el código existente
- No romper funcionalidad actual
- Actualizar GUIA.md si es necesario
[/TAREA]

[SALIDA]
Código modificado con la nueva funcionalidad
Resaltar cambios principales
[/SALIDA]
```

### Prompt: Integración Create/CC:C Bridge

```
[SISTEMA]
Desarrollador de sistemas de automatización con CC: Tweaked + Create
[/SISTURA]

[CONTEXTO]
Sistema a integrar: [NOMBRE]
Tipo de integración: [sensor/encoder/depot/station/stream]
Objetivo: [QUÉ SE QUIERE LOGRAR]
[/CONTEXTO]

[TAREA]
Crear el código necesario para integrar [SISTEMA_CREATE] con CERBERUS OPS:
- Detección automática del periférico
- Lectura/escritura de datos
- Manejo de eventos
- Interfaz con el sistema principal
[/TAREA]

[SALIDA]
Código Lua funcional + instrucciones de instalación en docs/GUIA.md
[/SALIDA]
```

### Prompt: Panel de interfaz

```
[SISTEMA]
Desarrollador UI/UX para CC: Tweaked
[/SISTEMA]

[CONTEXTO]
Sistema: [NOMBRE]
Periféricos disponibles: [LISTA]
Resolución objetivo: [TAMAÑO DE PANTALLA]
Nivel de seguridad: [NIVEL]
[/CONTEXTO]

[TAREA]
Crear una interfaz de usuario para [SISTEMA] que incluya:
- Menú principal con navegación
- Estados visuates (normal, warning, error)
- Indicadores de estado en tiempo real
- Manejo de input del usuario
[/TAREA]

[SALIDA]
Código UI completo con:
- Componentes reutilizables de templates/ui/
- Estados visuales
- Loop principal de eventos
- Documentación de uso
[/SALIDA]
```

---

## Notas para uso con IA

1. **Sé específico**: Cuanto más detalle, mejor el resultado
2. **Incluye contexto**: Siempre referencia PROJECT_CONTEXT.md
3. **Especifica periféricos**: Indica qué periféricos se usarán
4. **Nivel de seguridad**: Indica el nivel para saber qué encriptación usar
5. **Dependencias**: Lista qué módulos existentes necesitas

## Próximos prompts a documentar

- [ ] Sistema de autenticación biométrica
- [ ] Panel de control de lanzamiento nuclear
- [ ] Integración con sistemas Create existentes
- [ ] Dashboard de métricas en tiempo real
