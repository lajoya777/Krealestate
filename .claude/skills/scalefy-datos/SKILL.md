---
name: scalefy-datos
description: Diseña schemas Supabase con RLS y genera migraciones SQL. Invocar cuando una fase requiere crear tablas, agregar columnas, o diseñar relaciones. Usa el template `schema.sql.tpl` y garantiza RLS habilitada en toda tabla nueva.
---

# Skill: scalefy-datos

## Regla inviolable

**Toda tabla pública DEBE tener Row Level Security habilitada y al menos una policy.** Sin excepción.

## Proceso para schema inicial

### Paso 1 — Leer contexto

Leé `docs/IDEA.md` y `docs/PLAN.md` para saber: entidad principal, campos inferidos, método auth.

### Paso 2 — Usar template

Leé `.claude/templates/schema.sql.tpl`. Reemplazá:

- `{{NOMBRE_PROYECTO}}` — del IDEA.md
- `{{ENTIDAD_TABLE}}` — nombre snake_case plural (ej: `invoices`, `tasks`, `posts`)
- `{{CAMPOS_ENTIDAD_SQL}}` — columnas SQL de la entidad. Una por línea, separadas por coma.

Ejemplo campos para `invoices`:
```sql
client_name text not null,
client_email text,
amount numeric(10,2) not null,
status text not null default 'pending' check (status in ('pending', 'paid', 'overdue')),
due_date date,
notes text
```

### Paso 3 — Escribir migración

`Write` a `supabase/migrations/0001_initial_schema.sql`.

Si ya existen migraciones previas, numerar correlativo (`0002_...`, `0003_...`).

### Paso 4 — Instrucciones al usuario

NO ejecutes SQL automáticamente. Mostrá al usuario:

```
Migración SQL lista en: supabase/migrations/0001_initial_schema.sql

Para aplicarla, elegí una opción:

Opción A (recomendada para principiantes) — SQL Editor de Supabase:
1. Abrí https://supabase.com/dashboard/project/_/sql/new
2. Copiá el contenido del archivo SQL
3. Pegá y presioná "Run"

Opción B — Supabase CLI (si lo tenés instalado):
   supabase db push

Decime cuando esté aplicado para continuar con la siguiente fase.
```

## Proceso para agregar tabla nueva (feature)

1. Crear archivo `supabase/migrations/000X_agregar_<tabla>.sql`.
2. Escribir `create table` + `alter table ... enable row level security`.
3. Agregar policies usando `.claude/templates/rls.sql.tpl` como base.
4. Mostrar instrucciones de aplicación.

## Patrones comunes

### Tabla con owner (user_id)

```sql
create table public.items (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users on delete cascade,
  -- ... campos ...
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index items_user_id_idx on public.items(user_id);

alter table public.items enable row level security;

create policy "items_select_own" on public.items for select using (auth.uid() = user_id);
create policy "items_insert_own" on public.items for insert with check (auth.uid() = user_id);
create policy "items_update_own" on public.items for update using (auth.uid() = user_id);
create policy "items_delete_own" on public.items for delete using (auth.uid() = user_id);
```

### Tabla compartida (ej: roles, tags globales)

```sql
create table public.tags (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  created_at timestamptz not null default now()
);

alter table public.tags enable row level security;

-- Lectura pública, escritura solo admin (ajustar según app)
create policy "tags_select_all" on public.tags for select using (true);
-- No policies de insert/update/delete = nadie puede desde el cliente. Usar service_role key si hace falta.
```

### Relación many-to-many

```sql
create table public.item_tags (
  item_id uuid not null references public.items on delete cascade,
  tag_id uuid not null references public.tags on delete cascade,
  primary key (item_id, tag_id)
);

alter table public.item_tags enable row level security;

create policy "item_tags_select_own" on public.item_tags for select
  using (exists (select 1 from public.items where items.id = item_id and items.user_id = auth.uid()));
```

### Índices

- Agregar índice en toda FK que se use para filtrar (`user_id`).
- Índice en campos que aparezcan en `where` frecuente.
- No sobre-indexar (cada índice cuesta en writes).

## Reglas

- **RLS siempre habilitada.**
- **Policies específicas** (select/insert/update/delete separadas cuando aplique).
- **`on delete cascade`** en FKs a `auth.users` si los datos son del usuario (al borrar cuenta → borra data).
- **`timestamptz` no `timestamp`.** Siempre con timezone.
- **`uuid` no `serial`.** Mejor para distribución y seguridad (no enumerable).
- **`check` constraints** para enums simples (status, role, etc).
- **No borrar columnas** en migraciones — marcar deprecated y migrar datos primero.
