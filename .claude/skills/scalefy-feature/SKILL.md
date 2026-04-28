---
name: scalefy-feature
description: Agrega una feature nueva a un proyecto ya arrancado. Invocar con `/feature [descripción]` o cuando el usuario pida agregar funcionalidad a un proyecto con `docs/PLAN.md` existente. Hace mini-brainstorm, appendea fase al plan y dispatcha construcción.
---

# Skill: scalefy-feature

## Proceso

### Paso 1 — Verificar precondición

- Si no existe `docs/PLAN.md` → avisar que primero se necesita el flujo `/idea` → `/plan`. Stop.
- Leé `docs/IDEA.md` y `docs/PLAN.md` para tener contexto.

### Paso 2 — Parsear descripción

Si el usuario invocó `/feature [descripción]`, usala. Si no, pedí "Describí la feature en una frase".

### Paso 3 — Mini-brainstorm (máximo 2 preguntas, solo si hace falta)

Evaluá si la descripción es suficiente. Si sí: saltear a paso 4.

Si es ambigua, UNA llamada `AskUserQuestion` con máximo 2 preguntas específicas a la feature. Ejemplos:

- **Para "notificaciones":** ¿Tipo? [email / in-app / push / todas]
- **Para "búsqueda":** ¿Scope? [solo entidad principal / todas las entidades]
- **Para "pagos":** ¿Provider? [Stripe / Mercado Pago / decidir después]
- **Para "dashboard admin":** ¿Quién accede? [solo un email hardcoded / roles en DB / todas las cuentas premium]

No hagas 4 preguntas como en `/idea`. Esto es incremental.

### Paso 4 — Decidir alcance de cambios

Clasificá la feature:

| Tipo | Cambios típicos |
|------|-----------------|
| Nueva entidad (ej: agregar "comments" a posts) | Migración SQL + actions + UI |
| Nueva página/sección (ej: "perfil de usuario") | UI + actions si tiene mutación |
| Integración externa (ej: Stripe) | Route Handler webhook + actions + UI |
| Mejora UX (ej: "agregar filtros a listado") | Solo UI + posible query |
| Auth adicional (ej: agregar Google OAuth) | Config Supabase + callback + UI botón |

### Paso 5 — Appendear fase al PLAN.md

Usá `Edit` para agregar una fase nueva al final de `docs/PLAN.md`, ANTES de "Fase N — Landing y polish" y "Fase N+1 — Deploy" (para que esas queden al final).

Formato:

```markdown
## Fase X — {{Nombre feature}} `[ ]`

**Meta:** {{qué hace esta feature}}.

**Archivos:**
- archivo1
- archivo2

**Listo cuando:** {{criterio específico, observable}}.
```

### Paso 6 — Preguntar al usuario

"Agregué la fase '{{nombre}}' al plan. ¿Construir ahora (`/construir`) o más tarde?"

Si dice sí, invocar skill `scalefy-construir`.

## Reglas

- **No reformules todo el plan.** Solo appendeá.
- **No hagas cambios en IDEA.md.** Si la feature cambia el producto fundamental, decile al usuario que edite IDEA.md manualmente o corra `/idea` de nuevo.
- **Features grandes (ej: "agregar módulo completo X")**: dividilas en 2-3 fases secuenciales, no una gigante.
- **No rompas features existentes.** Si la feature toca código existente, señalalo explícitamente en la fase.
