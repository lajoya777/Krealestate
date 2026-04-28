---
name: scalefy-deploy
description: Guía al usuario para publicar su app en Vercel con Supabase como backend. Invocar con `/deploy` o cuando el MVP esté completo. No ejecuta nada irreversible sin confirmación del usuario.
---

# Skill: scalefy-deploy

Deploy semi-automatizado. Algunos pasos requieren intervención del usuario (autenticación en CLIs externos).

## Proceso

### Paso 1 — Checklist pre-deploy

Verificá:

- [ ] `docs/PLAN.md` existe y tiene fases completas (al menos Auth + CRUD + Landing).
- [ ] `.env.local` tiene `NEXT_PUBLIC_SUPABASE_URL` y `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
- [ ] `npm run build` corre sin errores localmente.
- [ ] `npm run typecheck` OK.
- [ ] Migraciones SQL aplicadas en Supabase.

Si algún check falla, avisar al usuario y detener hasta resolver.

### Paso 2 — Inicializar git si hace falta

```bash
git status
```

Si "not a git repository":

```
Tu proyecto necesita estar en Git para deployar. Te guío:

1. git init
2. git add .
3. git commit -m "Initial commit"
4. Creá un repo vacío en GitHub (https://github.com/new)
5. git remote add origin https://github.com/TU-USUARIO/TU-REPO.git
6. git push -u origin main

Después seguimos con el deploy. Avisame cuando esté.
```

### Paso 3 — Deploy a Vercel

Proponé 2 opciones al usuario:

**Opción A (recomendada) — Interfaz web Vercel:**

```
1. Entrá a https://vercel.com/new
2. Importá tu repo de GitHub.
3. En "Environment Variables", agregá:
   - NEXT_PUBLIC_SUPABASE_URL = (tu URL de Supabase)
   - NEXT_PUBLIC_SUPABASE_ANON_KEY = (tu anon key)
4. Click "Deploy".
5. Vercel te da una URL tipo tu-app.vercel.app.

Decime la URL cuando deploye.
```

**Opción B — Vercel CLI:**

```
Necesitás el CLI de Vercel:

1. npm i -g vercel
2. vercel login (abre navegador, autorizá)
3. vercel (primera vez: te hace preguntas, aceptá defaults)
4. Configurar env vars:
   vercel env add NEXT_PUBLIC_SUPABASE_URL
   vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
5. vercel --prod

Listo.
```

### Paso 4 — Configurar Supabase para producción

1. En el dashboard Supabase → **Authentication** → **URL Configuration**.
2. Agregar la URL de Vercel en **Site URL** y **Redirect URLs**.
3. Si usás OAuth (Google), verificar callback URLs en ambos lados (Google Console + Supabase).

### Paso 5 — Smoke test post-deploy

Pedile al usuario que:
- Abra la URL pública.
- Intente registrarse con un email real.
- Confirme email (si aplica).
- Haga login.
- Cree un registro (`{{entidad}}`).
- Cierre sesión.

Si algo falla, invocar `scalefy-arreglar` con el error específico.

### Paso 6 — Siguiente pasos

Ofrecer al usuario:

```
Deploy completo. Tu app está en: [URL]

Posibles siguientes pasos:
- /feature [idea] — agregar funcionalidad nueva
- Configurar dominio custom en Vercel
- Activar analytics (Vercel Analytics, Plausible, PostHog)
- Configurar email transaccional (Resend, Postmark) si la app manda mails
```

## Reglas

- **Nunca hacer `git push --force`** sin preguntar.
- **Nunca compartir env vars** en chat o commits.
- **No automatizar login de Vercel/Supabase CLI.** Usuario autoriza manual.
- **Confirmar antes de cualquier acción irreversible** (borrar proyecto, cambiar prod URL).
