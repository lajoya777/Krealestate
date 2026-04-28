---
name: scalefy-idea
description: Brainstorming rápido y estructurado para arrancar un proyecto desde una idea en una frase. Invocar cuando el usuario escribe `/idea`, o cuando menciona que quiere crear/construir/hacer algo nuevo y aún no existe `docs/IDEA.md`. Genera `docs/IDEA.md` en 2 minutos con 1 turno de preguntas.
---

# Skill: scalefy-idea

Tu objetivo: en **máximo 2 minutos y 1 turno de preguntas**, convertir una idea en una frase en `docs/IDEA.md` listo para planificar.

## Proceso exacto

### Paso 1 — Parsear idea

Si el usuario invocó `/idea [frase]`, usá esa frase como idea base.
Si no, pedí "Describí tu idea en una frase" y esperá.

### Paso 2 — Detectar stack

Keywords en la idea → stack recomendado:

| Keyword | Stack propuesto |
|---------|-----------------|
| "app móvil", "iOS", "Android", "mobile nativa" | Expo (React Native) + Supabase |
| "entrenar modelo", "ML training", "fine-tuning", "pipeline de datos" | FastAPI Python backend + Next.js frontend + Supabase |
| cualquier otra cosa | **Estándar Scalefy** (Next.js + Supabase + Vercel) |

Si es estándar: seguir sin preguntar.
Si detectás alternativo: mencionarlo en UNA frase y seguir con el estándar igual (simplifica). El usuario puede corregir después.

### Paso 3 — Inferir entidad principal

De la idea, extraé la entidad principal que los usuarios van a crear/manejar.

Ejemplos:
- "app para facturar a clientes" → entidad = `invoice` (factura)
- "lista de tareas" → entidad = `task`
- "blog personal" → entidad = `post`
- "catálogo de productos" → entidad = `product`

Si es ambiguo, la primera pregunta de la batched clarifica.

### Paso 4 — UNA sola llamada a `AskUserQuestion` con 4 preguntas batched

**Preguntas estándar** (adaptar labels según idea):

1. **Usuario objetivo** (`multiSelect: false`)
   - Consumidores finales (B2C)
   - Empresas / profesionales (B2B)
   - Uso interno / personal
   - Desarrolladores / técnicos

2. **Método de autenticación** (`multiSelect: false`)
   - Email + contraseña (Recomendado)
   - Magic link (sin contraseña, solo email)
   - Google OAuth
   - Sin autenticación (app pública)

3. **Confirmá la entidad principal** (`multiSelect: false`)
   - Si inferiste bien, opción A es lo que inferiste. Opciones B/C son alternativas cercanas. Opción D = "Otra (especificar)".

4. **Monetización** (`multiSelect: false`)
   - Gratis (sin monetización por ahora)
   - Suscripción mensual/anual
   - Pago único
   - Decidir después

### Paso 5 — Rellenar template

Leé `.claude/templates/IDEA.md.tpl`. Reemplazá los `{{placeholders}}`:

- `{{NOMBRE_PROYECTO}}` → derivá un nombre corto de la idea, o usá "Mi App"
- `{{DESCRIPCION_UNA_FRASE}}` → la idea original del usuario, pulida
- `{{USUARIO_OBJETIVO}}` → respuesta pregunta 1 + 1 frase de detalle
- `{{PROBLEMA}}` → qué problema resuelve, en 1-2 frases inferidas de la idea
- `{{LISTA_FEATURES_MVP}}` → 3-5 bullets mínimos para ser útil (CRUD entidad + auth + vista listado mínimo)
- `{{LISTA_NO_FEATURES}}` → 2-3 cosas explícitamente fuera del MVP (ej: notificaciones push, pagos complejos, admin panel)
- `{{ENTIDAD}}` → respuesta pregunta 3
- `{{METODO_AUTH}}` → respuesta pregunta 2
- `{{MONETIZACION}}` → respuesta pregunta 4 (si "decidir después", poner "Por definir")
- `{{STACK_FRONTEND}}` → `Next.js 15 (App Router, TypeScript) + Tailwind + shadcn/ui`
- `{{STACK_BACKEND}}` → `Next.js Server Actions + Route Handlers`
- `{{STACK_DB}}` → `Supabase (PostgreSQL + Auth + Storage)`
- `{{STACK_DEPLOY}}` → `Vercel (frontend) + Supabase (backend)`
- `{{NOTA_STACK_ALTERNATIVO}}` → vacío si estándar. Si alternativo: breve nota explicando por qué.
- `{{FECHA}}` → fecha ISO actual

Escribí el resultado a `docs/IDEA.md` con `Write`.

### Paso 6 — Confirmar al usuario

Mostrá un resumen de 3-4 líneas: nombre, para quién, entidad principal, auth. Ofrecé: "Siguiente paso: `/plan` para generar el plan de fases. ¿Algo que quieras ajustar en IDEA.md antes?"

## Reglas

- **No hagas preguntas abiertas.** Usá `AskUserQuestion` con opciones.
- **No generes docs adicionales.** Solo IDEA.md.
- **Si el usuario da mucho contexto en el `/idea` inicial**, usalo para pre-rellenar respuestas e incluso saltear preguntas obvias.
- **Si falla una pregunta** (usuario responde "Other"), adaptá al input libre.
- **No inventes features.** MVP mínimo real. El usuario puede agregar después con `/feature`.
