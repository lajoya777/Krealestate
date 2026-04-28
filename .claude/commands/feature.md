---
description: Agrega feature nueva a un proyecto ya arrancado.
argument-hint: [descripción de la feature en una frase]
---

El usuario quiere agregar una feature al proyecto existente. Descripción:

**$ARGUMENTS**

Invocá la skill `scalefy-feature` con esta descripción. La skill appendea una fase nueva al `docs/PLAN.md` y, si el usuario acepta, invoca `scalefy-construir` para ejecutarla.

Si el argumento está vacío, pedí al usuario que describa la feature en una frase.
