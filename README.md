# K Real Estate — Plataforma de agentes IA + Dashboard

Sistema agéntico para K Real Estate (inmobiliaria boutique en Montevideo). Agentes de IA conversacionales que atienden leads vía WhatsApp + dashboard de tracking para el equipo interno.

> **Repo privado.** El código no se distribuye públicamente. Para colaborar pedir invitación.

---

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | Next.js 15 (App Router) + React 19 + TypeScript |
| UI | Tailwind CSS + shadcn/ui |
| Backend | Server Actions + Route Handlers (webhooks Kommo) |
| DB / Auth / Storage | Supabase (Postgres + Auth + Realtime) — región `sa-east-1` |
| IA | Anthropic Claude (Sonnet/Haiku) |
| CRM | Kommo (WhatsApp Business + leads del cliente) |
| Integraciones | Google Calendar, Google Maps Distance Matrix, OpenWeather |
| Deploy | Vercel (auto-deploy desde GitHub) |

---

## Documentación crítica

Antes de tocar código, leer en este orden:

1. **`CLAUDE.md`** — guía operativa para Claude Code y para todo dev nuevo.
2. **`docs/IDEA.md`** — qué construimos, para quién, arquitectura general.
3. **`docs/PLAN.md`** — fases de desarrollo y orden de ejecución.
4. **`K_RealEstate_Agente_IA_Especificacion_v1.0.docx`** — documento del cliente (15 páginas) con el comportamiento esperado del agente. Vive fuera del repo, fuente de verdad sobre cómo conversa el agente.

---

## Setup local

### Requisitos

- Node.js 20+
- Git
- Acceso al proyecto Supabase de K Real Estate (pedir a Franco)
- Acceso al Vercel team de K Real Estate (pedir a Franco)
- API token de Kommo (pedir a Franco)
- API key de Anthropic (pedir a Franco)

### Instalación

```bash
git clone https://github.com/lajoya777/Krealestate.git
cd Krealestate
npm install
cp .env.example .env.local
```

Editar `.env.local` con las credenciales reales (ver sección "Variables de entorno" abajo).

### Levantar dev

```bash
npm run dev
```

Abre `http://localhost:3000`.

### Comandos útiles

```bash
npm run dev        # servidor local
npm run build      # build producción
npm run lint       # ESLint
npm run typecheck  # TypeScript check (no emite archivos)
```

---

## Variables de entorno

Todas las variables están documentadas en `.env.example`. Resumen rápido:

| Variable | Propósito | Quién la provee |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | URL del proyecto Supabase | Cuenta del cliente |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Anon key (browser-safe) | Cuenta del cliente |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role (solo server) | Cuenta del cliente |
| `ANTHROPIC_API_KEY` | Claude API | Cuenta del cliente |
| `ANTHROPIC_DEFAULT_MODEL` | Modelo por defecto | `claude-sonnet-4-6` |
| `KOMMO_SUBDOMAIN` | Subdomain Kommo | Cliente |
| `KOMMO_LONG_LIVED_TOKEN` | API token Kommo | Cliente |
| `KOMMO_WEBHOOK_SECRET` | Validación webhooks | Lo generamos |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | Acceso a Google Calendar | Cliente (`info@eko-realestate.com`) |
| `GOOGLE_MAPS_API_KEY` | Distance Matrix | Cliente |
| `OPENWEATHER_API_KEY` | Pronóstico para coordinación de visitas | Cliente |

> **Nunca commitear `.env.local`.** Está en `.gitignore`. Si necesitás compartir credenciales con un colaborador, usar canal seguro (1Password, Bitwarden, mensaje cifrado).

---

## Flujo de trabajo con Git

### Branches

- **`main`** — siempre deployable a producción. **No se pushea directo.**
- **`feature/<descripción-corta>`** — ramas de trabajo. Una por feature/fix.
- **`fix/<descripción-corta>`** — bugfixes urgentes.

### Commits — Conventional Commits

```
<tipo>(<scope opcional>): <descripción corta>

[body opcional]
```

Tipos: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`.

Ejemplos:
```
feat(agent): integrar webhook entrante de Kommo
fix(dashboard): corregir filtro de leads por etapa
chore: bump dependencias menores
docs: actualizar PLAN.md con fase 4
```

### Pull Requests

1. Branch desde `main`: `git checkout -b feature/mi-feature`.
2. Trabajar, commitear con mensajes claros.
3. Push: `git push -u origin feature/mi-feature`.
4. Abrir PR en GitHub → revisar preview deployment de Vercel.
5. Auto-merge a `main` cuando pase review.
6. Vercel auto-deploya `main` a producción.

### Deploys

- **Push a `main`** → Vercel deploya a producción automáticamente.
- **Push a cualquier otra branch** → Vercel genera preview deployment con URL única (visible en el PR de GitHub).

---

## Colaboradores

- **Franco Michelena** ([@lajoya777](https://github.com/lajoya777)) — owner del repo, lead técnico.
- **Socio** — agregado como collaborator vía invitación de GitHub. Pushes desde su entorno se reflejan automáticamente en Vercel.

---

## Convenciones de código

Resumen — el detalle vive en `CLAUDE.md`.

- TypeScript estricto. Sin `any`.
- Server Components por defecto. `"use client"` solo cuando hay estado/interacción real.
- Server Actions para mutaciones. Route Handlers solo para webhooks externos.
- RLS siempre ON en Supabase. Nunca crear tabla sin policy.
- Imports con alias `@/` (raíz).
- Tailwind + shadcn. Sin CSS modules ni styled-components.
- Validación con Zod en bordes.
- Errores: toast con Sonner al usuario + log en dev. Nunca tragar errores en silencio.
- Secretos solo en server. Nunca al cliente.

---

## Seguridad

- `.env.local` y todos los `.env*` (excepto `.env.example`) están en `.gitignore`.
- Secretos del cliente nunca se commitean ni se pegan en chats.
- Service role keys, API tokens (Kommo, Anthropic, Google) nunca con prefijo `NEXT_PUBLIC_`.
- RLS habilitada en toda tabla de Supabase desde la primera migración.
- Webhooks de Kommo validados con `KOMMO_WEBHOOK_SECRET`.
- Datos personales de leads tratados según Ley 18.331 de Uruguay (URCDP).

---

## Licencia

Privado — propiedad de K Real Estate (EKO REAL ESTATE SAS) y de la agencia desarrolladora. No redistribuir.
