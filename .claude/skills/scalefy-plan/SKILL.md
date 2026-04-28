---
name: scalefy-plan
description: Genera `docs/PLAN.md` con fases ejecutables a partir de `docs/IDEA.md`. Invocar cuando el usuario escribe `/plan`, o cuando IDEA.md existe pero PLAN.md no. Rellena el template de plan con la entidad y features del MVP.
---

# Skill: scalefy-plan

Tu objetivo: leer `docs/IDEA.md` y generar `docs/PLAN.md` en menos de 1 minuto, sin preguntas salvo ambigüedad grave.

## Proceso

### Paso 1 — Verificar precondición

- Si no existe `docs/IDEA.md` → avisar al usuario y sugerir `/idea [tu idea]`. Stop.
- Si existe `docs/PLAN.md` → preguntar: "Ya hay un plan. ¿Regenerarlo (pierde progreso) o agregar feature con `/feature`?"

### Paso 2 — Leer IDEA.md

Extraé:
- Nombre proyecto
- Entidad principal
- Método auth
- Features del MVP
- Stack

### Paso 3 — Inferir campos de la entidad

De las features del MVP y la descripción, inferí 3-6 campos típicos de la entidad:

Ejemplos:
- Entidad `invoice`: `client_name text`, `amount numeric`, `status text`, `due_date date`, `notes text`
- Entidad `task`: `title text not null`, `description text`, `completed boolean default false`, `due_date date`
- Entidad `post`: `title text not null`, `content text`, `slug text unique`, `published boolean default false`
- Entidad `product`: `name text not null`, `description text`, `price numeric`, `sku text`, `in_stock boolean default true`

Si la idea es muy específica, adaptá.

### Paso 4 — Rellenar template

Leé `.claude/templates/PLAN.md.tpl`. Reemplazá:

- `{{NOMBRE_PROYECTO}}` → del IDEA.md
- `{{ENTIDAD}}` → nombre entidad singular (ej: "invoice")
- `{{ENTIDAD_TABLE}}` → nombre tabla en snake_case plural (ej: "invoices")
- `{{ENTIDAD_PLURAL}}` → forma plural para URLs (ej: "invoices")
- `{{CAMPOS_ENTIDAD}}` → lista bullet de campos inferidos, legible
- `{{METODO_AUTH}}` → del IDEA.md
- `{{FASES_FEATURES_ADICIONALES}}` → si hay features MVP que no encajan en CRUD básico, agregá 1 fase por feature extra. Si no hay, dejá vacío.
- `{{FECHA}}` → fecha ISO actual

### Paso 5 — Auto-ajustar fases según auth

- Si `{{METODO_AUTH}}` es "Sin autenticación": eliminá Fase 2 (Auth) y Fase 3 (Dashboard). Ajustá Fase 4 para no requerir user_id en la tabla.
- Si es "Magic link" u "OAuth": agregá en Fase 2 referencia al archivo `callback/route.ts`.

### Paso 6 — Escribir

`Write` a `docs/PLAN.md`.

### Paso 7 — Mostrar resumen

Listá las fases en 1 línea cada una al usuario. Preguntá: "¿Arrancamos con `/construir`?".

## Reglas

- **Fases atómicas.** Cada una = una unidad de trabajo claramente terminable.
- **Máximo 6-8 fases** para el MVP. Features extra se agregan después con `/feature`.
- **No agregues fases de "testing" separadas.** El agente `revisor` verifica al final de cada fase.
- **No agregues fases de "documentación".** El código se auto-documenta con comentarios cuando aplique.
- **No agregues fases de "CI/CD".** El `/deploy` lo maneja.
