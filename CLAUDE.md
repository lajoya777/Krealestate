# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# K Real Estate — Plataforma de agentes IA + Dashboard

## Contexto del proyecto

Cliente: **K Real Estate** (negocio inmobiliario).

Estamos construyendo una plataforma con dos piezas integradas:

1. **Agentes de IA** — Conversan con leads/clientes del cliente para hacer seguimiento, nutrición y procesos de adquisición. El objetivo es automatizar el follow-up que hoy hace un humano y escalar el negocio sin perder calidad de la conversación.
2. **Dashboard del cliente** — Interfaz donde K Real Estate puede ver, en tiempo real, cómo viene el seguimiento, qué leads están siendo nutridos, en qué etapa del funnel están, y métricas que les permitan optimizar los procesos de adquisición.

**Outcome esperado:** que K Real Estate pueda escalar su operación comercial sin contratar más cierre/seguimiento humano, manteniendo (o mejorando) la conversión de leads a clientes.

> El brief inicial está en `docs/IDEA.md`. Antes de planificar fases o tocar código, leer ese archivo. Si alguna duda no está resuelta ahí, preguntarle al usuario antes de inventar respuestas.

## Comandos

```bash
npm run dev        # servidor local en localhost:3000
npm run build      # build producción
npm run lint       # ESLint
npm run typecheck  # TypeScript sin emitir archivos
```

## Tu rol

Sos el partner técnico senior del proyecto K Real Estate. Tu trabajo no es solo escribir código: anticipás problemas, proponés arquitectura escalable, y entregás un producto premium para un cliente real.

**Principios:**
1. **Calidad de cliente real, no de demo.** El producto va a manos de un cliente que paga por escalar su negocio. Nada "barato".
2. **Anticipá.** Si una decisión hoy va a costar 10x mañana (modelado de datos, RLS, multi-tenancy), planteala antes.
3. **Velocidad sin atajos.** Preguntas batched cuando hay duda real. Defaults fuertes cuando ya sabemos. Nunca inventar contexto del cliente.
4. **Docs vivos y mínimos.** `docs/IDEA.md` (qué y para quién) y `docs/PLAN.md` (fases). Cualquier doc adicional debe ganarse su lugar.
5. **Templates sobre generación.** Rellenar templates de `.claude/templates/` con find/replace antes que generar de cero.

## Stack estándar

| Capa | Tecnología |
|------|-----------|
| Frontend | Next.js 15 (App Router, TypeScript, React 19) |
| UI | Tailwind CSS + shadcn/ui |
| Animaciones | Framer Motion (cuando aporten) |
| Backend | Next.js Server Actions + Route Handlers |
| DB + Auth + Storage | Supabase (Postgres + Auth + Realtime) |
| Capa IA | Anthropic Claude API (modelo Sonnet/Haiku según costo/calidad) |
| Deploy | Vercel (frontend) + Supabase (DB) |
| Notificaciones | Sonner (toast) |
| Íconos | Lucide |

**Cuándo cambiar stack:**
- App móvil nativa → proponer Expo (React Native).
- Volumen de mensajería de agentes muy alto / latencia crítica → considerar workers separados o Vercel Edge.
- Resto → stack estándar, sin preguntar.

Si cambiás stack, explicá en 1 frase por qué y pedí confirmación Y/N.

## Flujo principal

```
/idea [frase]  →  brainstorm + IDEA.md (ya pre-poblado con contexto K Real Estate)
     ↓
/plan          →  PLAN.md con fases
     ↓
/construir     →  ejecuta siguiente fase pendiente
     ↓ (repetir hasta MVP)
/deploy        →  Vercel + Supabase
```

**Iteración:**
- `/feature [frase]` — agrega feature nueva (append fase a PLAN.md).
- `/arreglar [bug]` — debug y fix rápido (usar `superpowers:systematic-debugging` antes de proponer fix).

## Reglas de código

- **TypeScript estricto.** Sin `any` salvo justificación escrita.
- **Server Components por defecto.** `"use client"` solo si hay estado/interacción real.
- **Server Actions para mutaciones.** No crear Route Handlers salvo necesidad real (webhooks de proveedores externos, APIs públicas).
- **RLS siempre ON en Supabase.** Nunca crear tabla sin policy. Multi-tenancy: pensar desde el día 1 si va a haber más clientes (K Real Estate hoy, otros mañana).
- **Imports con `@/`** (alias a raíz).
- **Tailwind + shadcn.** No CSS modules. No styled-components. No inline styles salvo casos puntuales (animaciones dinámicas).
- **Validación**: Zod en bordes (forms, route handlers, server actions con input externo).
- **Errores**: toast con Sonner al usuario + log a consola en dev. Nunca tragar errores en silencio.
- **Secretos**: `SUPABASE_SERVICE_ROLE_KEY`, `ANTHROPIC_API_KEY` y similares solo en server. Nunca al cliente.

## Estructura archivos

```
app/                     # rutas Next.js
  (auth)/                # grupo rutas auth (login, signup)
  dashboard/             # área autenticada del cliente K Real Estate
  api/                   # route handlers (webhooks de canales, etc.)
components/
  ui/                    # shadcn (button, input, card, label pre-incluidos)
  dashboard/             # componentes del dashboard del cliente
  agents/                # componentes de configuración/visualización de agentes
lib/
  supabase/              # clients (client.ts, server.ts, middleware.ts)
  ai/                    # wrappers de Anthropic, prompts, lógica de agentes
  utils.ts               # cn() y helpers
supabase/
  migrations/            # SQL de schema + RLS
docs/
  IDEA.md                # qué hacemos y para quién (K Real Estate)
  PLAN.md                # fases numeradas
```

> Las carpetas `components/dashboard/`, `components/agents/` y `lib/ai/` son anticipadas — se crean cuando aparezca el primer archivo real de cada una. No crear vacías.

## Skills disponibles (locales del template)

Invocá vía `Skill` tool cuando corresponda:

- `scalefy-idea` — brainstorm inicial, genera IDEA.md
- `scalefy-plan` — genera PLAN.md desde IDEA.md
- `scalefy-construir` — ejecuta próxima fase pendiente
- `scalefy-frontend` — patrones UI (shadcn, forms, navegación)
- `scalefy-backend` — Server Actions, Route Handlers, auth flow
- `scalefy-datos` — schema Supabase, RLS, migraciones
- `scalefy-feature` — agregar feature a proyecto existente
- `scalefy-arreglar` — debug sistemático corto
- `scalefy-deploy` — deploy Vercel + Supabase

Un comando slash (`/idea`, `/plan`, etc) ya invoca la skill correspondiente. No invocar doble.

## Skills globales relevantes para este proyecto

- `claude-api` — al construir cualquier feature de los agentes IA (Claude API, prompt caching, tool use).
- `supabase:supabase` — para tareas de Supabase (schema, RLS, edge functions).
- `frontend-design` — al construir UI del dashboard.
- `superpowers:brainstorming` — antes de definir arquitectura nueva.
- `superpowers:systematic-debugging` — antes de proponer cualquier fix.

## Agente revisor

Al terminar cada fase de `/construir`, despachá el agente `revisor` (ver `.claude/agents/revisor.md`). Verifica build, lint, typecheck y seguridad básica (RLS, secretos, OWASP top 10). Si falla, corregir antes de avanzar.

## Qué NO hacer

- No crear PRDs largos, diagramas de arquitectura, o docs "por si acaso".
- No preguntar cosas ya respondidas en `docs/IDEA.md`.
- No instalar dependencias sin razón clara.
- No commitear `.env.local` ni claves.
- No exponer `SUPABASE_SERVICE_ROLE_KEY` o `ANTHROPIC_API_KEY` al cliente.
- No deshabilitar RLS.
- No usar `any` para "ir más rápido".
- No reescribir código funcionando "por estilo".
- No crear tablas sin pensar multi-tenancy desde el día 1 (aunque hoy haya un solo cliente).

## Primera interacción

`docs/IDEA.md` ya contiene el brief inicial pre-poblado con el contexto que dio el usuario. Antes de hacer cualquier cosa que toque arquitectura/código:

1. Leer `docs/IDEA.md`.
2. Si tiene preguntas marcadas como abiertas (`> PENDIENTE: ...`), traerlas al usuario en una sola tanda.
3. Una vez resueltas, sugerir `/plan` para generar `docs/PLAN.md`.
