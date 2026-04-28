# Plan — {{NOMBRE_PROYECTO}}

Fases para llegar del bootstrap al MVP deployado. Cada fase es una unidad atómica: se completa, se verifica, se commitea.

**Leyenda estado:** `[ ]` pendiente · `[~]` en progreso · `[x]` completa

---

## Fase 1 — Schema de base de datos `[ ]`

**Meta:** crear tablas, relaciones y RLS para `{{ENTIDAD}}`.

**Archivos:**
- `supabase/migrations/0001_initial_schema.sql`

**Contenido:**
- Tabla `profiles` (extensión de `auth.users`, con nombre, avatar).
- Tabla `{{ENTIDAD_TABLE}}` con campos: {{CAMPOS_ENTIDAD}}.
- RLS habilitada en ambas.
- Policies: usuarios solo ven/editan sus propios datos.
- Trigger `handle_new_user` para crear profile al registrarse.

**Listo cuando:** migración aplicada en Supabase, tablas visibles en dashboard.

---

## Fase 2 — Autenticación `[ ]`

**Meta:** registro, login y logout funcionando con `{{METODO_AUTH}}`.

**Archivos:**
- `app/(auth)/login/page.tsx`
- `app/(auth)/signup/page.tsx`
- `app/(auth)/actions.ts` (Server Actions)
- `app/(auth)/callback/route.ts` (para OAuth/magic link si aplica)
- `components/auth/auth-form.tsx`

**Listo cuando:** usuario puede registrarse, iniciar sesión, cerrar sesión. Redirect a `/dashboard` post-login.

---

## Fase 3 — Dashboard autenticado `[ ]`

**Meta:** shell protegido donde vive el producto.

**Archivos:**
- `app/dashboard/layout.tsx` (verifica auth, redirige a login si no hay user)
- `app/dashboard/page.tsx` (vista principal)
- `components/dashboard/nav.tsx`
- `components/dashboard/user-menu.tsx` (logout)

**Listo cuando:** sin login redirige a `/login`; con login muestra dashboard vacío.

---

## Fase 4 — CRUD de `{{ENTIDAD}}` `[ ]`

**Meta:** crear, leer, actualizar, borrar `{{ENTIDAD}}`.

**Archivos:**
- `app/dashboard/{{ENTIDAD_PLURAL}}/page.tsx` (listado)
- `app/dashboard/{{ENTIDAD_PLURAL}}/new/page.tsx` (crear)
- `app/dashboard/{{ENTIDAD_PLURAL}}/[id]/page.tsx` (editar)
- `app/dashboard/{{ENTIDAD_PLURAL}}/actions.ts` (Server Actions)
- `components/{{ENTIDAD_PLURAL}}/list.tsx`
- `components/{{ENTIDAD_PLURAL}}/form.tsx`

**Listo cuando:** usuario puede crear, editar, borrar sus `{{ENTIDAD}}`. RLS asegura que solo ve los suyos.

---

{{FASES_FEATURES_ADICIONALES}}

---

## Fase N — Landing y polish `[ ]`

**Meta:** página pública (`/`) con valor claro y CTA a registrarse.

**Archivos:**
- `app/page.tsx` (reemplaza landing placeholder)
- `components/landing/hero.tsx`
- `components/landing/features.tsx`
- `components/landing/cta.tsx`

**Listo cuando:** visitante entiende en 5 segundos qué es la app y cómo empezar.

---

## Fase N+1 — Deploy `[ ]`

**Meta:** app online en Vercel con Supabase conectado.

**Pasos** (el comando `/deploy` los ejecuta):
1. Conectar repo a Vercel (`vercel link`).
2. Configurar env vars en Vercel dashboard.
3. Aplicar migraciones SQL en Supabase producción.
4. Deploy: `vercel --prod`.
5. Verificar en la URL pública.

**Listo cuando:** URL pública funciona, registro + login OK, CRUD persiste.

---

_Generado por `/plan` en {{FECHA}}. El comando `/construir` ejecuta la próxima fase con `[ ]`._
