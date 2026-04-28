---
name: scalefy-construir
description: Ejecuta la próxima fase pendiente del `docs/PLAN.md`. Dispatcha a skills especialistas (frontend, backend, datos) según tipo de fase. Al terminar corre el agente revisor. Invocar con `/construir` o cuando el usuario diga "seguí con el plan", "construí la siguiente fase".
---

# Skill: scalefy-construir

Tu objetivo: ejecutar UNA fase del plan — no todas. Mantené al usuario en control.

## Proceso

### Paso 1 — Verificar precondición

- Si no existe `docs/PLAN.md` → sugerir `/plan`. Stop.
- Leé el plan y encontrá la primera fase con estado `[ ]`.
- Si todas están `[x]` → el MVP está hecho. Sugerir `/deploy` o `/feature`.

### Paso 2 — Marcar fase en progreso

Edit `docs/PLAN.md`: cambiá `[ ]` de la fase objetivo a `[~]`.

### Paso 3 — Clasificar fase y dispatchar

Según contenido de la fase:

| Tipo fase | Keywords típicos | Skill a invocar |
|-----------|------------------|-----------------|
| DB schema / migración | "schema", "migración", "RLS", "tabla" | `scalefy-datos` |
| Auth / login / signup | "autenticación", "login", "signup" | `scalefy-backend` |
| Server Actions / API | "actions.ts", "route.ts", "endpoint" | `scalefy-backend` |
| UI / páginas / componentes | "page.tsx", "layout.tsx", "componente" | `scalefy-frontend` |
| CRUD (mixto) | listado + form + actions | `scalefy-backend` primero (actions + schema si aplica), luego `scalefy-frontend` (UI) |
| Landing | "landing", "hero", "features" | `scalefy-frontend` |
| Deploy | "deploy", "Vercel" | `scalefy-deploy` |

**Invocá la skill con `Skill` tool**, pasando como contexto la descripción completa de la fase.

Si la fase mezcla varios tipos (ej: CRUD completo), dispatchá en secuencia:
1. `scalefy-datos` (si hay schema nuevo)
2. `scalefy-backend` (actions)
3. `scalefy-frontend` (UI)

### Paso 4 — Verificar (agente revisor)

Terminada la fase, invocá el agente `revisor` (`Agent` tool con `subagent_type: "revisor"`):

> "Revisá los cambios de la fase '{{NOMBRE_FASE}}'. Verificá: typecheck (`npm run typecheck`), lint (`npm run lint`), build (`npm run build`). Si hay migraciones SQL nuevas, verificá que tengan RLS habilitada. Reportá OK o lista de problemas específicos."

Si el revisor reporta problemas: corregí antes de avanzar. Si no puede arreglarse en 1-2 intentos, pedí input al usuario.

### Paso 5 — Commitear

Si hay `git` disponible en el repo (chequeá con `git status`), creá un commit atómico:

```bash
git add <archivos_de_la_fase>
git commit -m "feat: {{descripción corta de la fase}}"
```

Si no hay git init, saltá este paso silenciosamente.

### Paso 6 — Marcar fase completa

Edit `docs/PLAN.md`: `[~]` → `[x]`.

### Paso 7 — Reportar al usuario

Formato corto:

```
Fase "{{nombre}}" completa.
- Archivos: X (lista breve)
- Verificación: build OK, lint OK, typecheck OK
- Próxima fase: {{nombre siguiente}}

¿Seguir? /construir
```

NO auto-ejecutar la siguiente fase. El usuario decide.

## Reglas

- **Una fase por invocación.** Nunca ejecutar varias sin el OK del usuario entre medio.
- **Si una fase tiene "aplicar migración SQL"**, el usuario tiene que correrlo manualmente en Supabase (o via CLI si lo tiene). Mostrá el SQL y las instrucciones. NO intentes conectarte a la DB sin permiso.
- **Si un paso requiere `.env.local`** (ej: Supabase keys), verificá antes que existan las vars. Si no, pedí al usuario que las cargue siguiendo README.
- **No uses `any` en TypeScript.** Si una tipo es complejo, definilo bien.
- **Commits atómicos.** Un commit por fase.
