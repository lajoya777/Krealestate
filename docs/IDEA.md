# K Real Estate — Plataforma de agentes IA + Dashboard

## Qué es

Sistema agéntico que combina **agentes de IA conversacionales** que atienden leads/clientes de K Real Estate por WhatsApp y un **dashboard de tracking** para que el equipo de K vea en tiempo real cómo viene la nutrición, en qué etapa del funnel está cada lead, y métricas para optimizar el proceso comercial.

El brief operativo completo (cómo conversa el agente, metodología, casuística, los 11 factores de coordinación de visitas, manejo de objeciones, escalamientos, principios rectores) vive en el documento **`K_RealEstate_Agente_IA_Especificacion_v1.0.docx`** (entregado por el cliente, 15 páginas). Ese documento es la fuente de verdad sobre comportamiento del agente. Este `IDEA.md` resume el alcance técnico-comercial.

## Para quién

**Cliente:** K Real Estate (razón social: EKO REAL ESTATE SAS) — inmobiliaria boutique en Montevideo, Uruguay. Co-directores: Rafael Pereyra (sistemas, inversores, desarrolladores) y Diego Sánchez (comercial, lusoparlante).

**Usuarios del dashboard:** equipo interno de K (socios + asistente Biansi + agentes inmobiliarios asignados). Necesitan visibilidad de cada lead, monitoreo de los agentes IA, y capacidad de tomar control de una conversación cuando lo amerita.

**Usuarios "implícitos":** los leads finales que conversan con los agentes IA por WhatsApp. Pueden venir de portales (Mercado Libre, Infocasas, Gallito, Casas+), Meta Ads, Instagram orgánico (redirigido a WhatsApp), referidos, o consultas en frío.

## Problema que resuelve

K hace seguimiento manual hoy. No escala, se pierden leads por falta de respuesta a tiempo, no hay visibilidad agregada del funnel. La plataforma automatiza el follow-up inteligente y le da al equipo un panel único de decisiones.

## Modelo de negocio (importante para arquitectura)

Esto **no es SaaS multi-tenant**. Es un **producto agéntico instanciado por cliente**: cada cliente que contrate este sistema tiene su propia instancia desplegada (su propio Supabase, su propio Vercel, sus propios agentes configurados). El código base es **template reutilizable** — la lógica de agente, schema, dashboard sirven para cualquier inmobiliaria. Las particularidades de cada cliente viven en data (tabla `tenant_config`, propiedades, equipo, zonas, prompts parametrizados), no en código.

K Real Estate es la primera instancia. El código queda diseñado para clonarse y configurarse para futuros clientes con un playbook de onboarding.

## Arquitectura técnica de alto nivel

```
┌─────────────────────────────────────────────────────────────┐
│ Lead (WhatsApp / Instagram redirigido / portal)             │
└─────────────────────────────┬───────────────────────────────┘
                              ▼
                   ┌──────────────────────┐
                   │  Kommo  (CRM)        │ ← fuente de verdad de leads,
                   │  WhatsApp Business   │   pipelines, asignaciones,
                   │                      │   históricos
                   └──────────┬───────────┘
                              │ webhook / API
                              ▼
                   ┌──────────────────────┐
                   │ Next.js API routes   │ ← nuestro sistema
                   │ (Vercel)             │
                   └──────────┬───────────┘
                              ▼
                   ┌──────────────────────┐
                   │ Anthropic Claude     │ ← system prompt construido
                   │ (Sonnet/Haiku)       │   desde DB en tiempo real
                   └──────────┬───────────┘
                              ▼
                   ┌──────────────────────┐
                   │ Supabase             │ ← cerebro del agente:
                   │ (Postgres + RLS)     │   propiedades, proyectos,
                   │                      │   objeciones, búsquedas,
                   │                      │   apartado teórico,
                   │                      │   conversaciones, leads
                   └──────────────────────┘
```

**División de responsabilidades Kommo / Supabase:**

| Sistema | Es fuente de verdad de |
|---|---|
| **Kommo** | Leads, pipelines, asignación a asesores humanos, conversaciones WhatsApp, históricos CRM |
| **Supabase (nuestro)** | Propiedades, proyectos, objeciones, perfiles de búsqueda, apartado teórico, derivaciones, logs del agente, métricas |
| **Sincronización** | Webhook Kommo → nuestro endpoint (mensaje entrante). API Kommo ← nosotros (respuesta + actualización de campos custom). `lead_id_kommo` como llave foránea en cada lead nuestro. |

## Features del MVP (ordenadas por fase, ver `PLAN.md`)

1. **Auth + dashboard scaffold** — login del equipo K, RLS por rol (`owner`, `agent_operator`, `viewer`).
2. **Ecosistema de información** (Parte 9 del spec) — schema rico de propiedades (Bloques A–F), proyectos, objeciones, búsquedas persistentes, derivaciones, apartado teórico de Uruguay. UI CRUD en dashboard.
3. **Agente conversacional MVP en español** — webhook entrante de Kommo, agente Claude con system prompt construido desde el spec, identificación de categoría de interés (C.1–C.6), respuesta vía API Kommo, persistencia.
4. **Detección proactiva + escalamiento** — PT → Diego, inversor → Rafael, referido → registro, spam → filtro + botón de pánico, takeover humano.
5. **Coordinación de visitas multifactorial** — 11 factores con pesos configurables (Google Calendar + Maps + OpenWeather).
6. **Seguimiento + matching automático** — cron de seguimientos contextuales, post-visita 2h, baja de precio → notificación, matching nueva propiedad ↔ búsquedas persistentes.
7. **Dashboard completo** — bandeja de conversaciones en vivo, hilos, métricas por agente, timeline, configuración.
8. **Multilingüismo robusto + nutrición del sistema** — PT/EN afinados, captura de objeciones no respondidas, loop de mejora.

**Fuera del MVP:** app móvil nativa, panel de billing al cliente final, integración con CRMs externos diferentes a Kommo, voice agents, BI custom.

## Entidades principales

`Tenant` (1 fila — config de la inmobiliaria), `Property`, `Project`, `ProjectUnit`, `Lead`, `Conversation`, `Message`, `Agent` (config del agente IA), `HumanAgent` (referente del equipo), `Objection`, `SearchProfile`, `Visit`, `Notification`.

## Autenticación y seguridad

- **Supabase Auth** email + password. Roles: `owner`, `agent_operator`, `viewer`.
- **RLS habilitada en todas las tablas** desde la primera migración.
- Service role key solo del lado servidor.
- API tokens de Kommo, Anthropic, Google, OpenWeather → solo en server, nunca al cliente.
- Validación con Zod en bordes (forms, route handlers, server actions con input externo).
- Webhooks de Kommo validados con signature secret.

## Stack confirmado

| Capa | Tech |
|---|---|
| Frontend | Next.js 15 App Router + React 19 + TypeScript + Tailwind + shadcn/ui |
| Animaciones | Framer Motion (cuando aporten) |
| Backend | Server Actions + Route Handlers (webhooks Kommo) |
| DB / Auth / Storage | Supabase (Postgres + Auth + Realtime) — región **sa-east-1 (São Paulo)** |
| Capa IA | Anthropic Claude (Sonnet por defecto, Haiku para tareas livianas/rápidas) |
| CRM | Kommo (cliente lo tiene contratado) |
| Calendario | Google Calendar API (cuenta `info@eko-realestate.com`) |
| Mapas / traslados | Google Maps Distance Matrix API |
| Clima | OpenWeather API (caché diario) |
| Notificaciones UI | Sonner (toast) |
| Íconos | Lucide |
| Deploy | Vercel + Supabase |

## Infraestructura — modelo de propiedad

- **Supabase**: cuenta del cliente. Nosotros entramos como Administrators. MCP vinculado en `.claude/settings.local.json` (gitignored), scope solo este repo.
- **Vercel**: cuenta del cliente. Nosotros como members.
- **Anthropic**: cuenta del cliente. API key gestionada por ellos.
- **GitHub**: repo `lajoya777/Krealestate` (privado, cuenta de Franco). Socio agregado como collaborator. Push a `main` → Vercel auto-deploy a producción. Push a otras branches → preview deployment.
- **Kommo, Google APIs, OpenWeather**: cuentas del cliente.

## Las 5 preguntas iniciales — estado de resolución

1. ✅ **Canales** — WhatsApp Business vía Kommo (principal). Instagram orgánico se redirige a WhatsApp. Meta Ads, portales (Mercado Libre, Infocasas, Gallito, Casas+) entran por el mismo embudo. Google Ads y TikTok Ads en roadmap futuro.
2. ⚠️ **Funnel / etapas Kommo** — pendiente. K está reformulando Kommo basándose en análisis del histórico de conversaciones. Parte 7 del spec queda abierta hasta que termine ese análisis. **Bloqueante de F2.**
3. ✅ **Datos existentes** — histórico de leads en Kommo (en análisis interno). Propiedades NO están centralizadas hoy (planillas, docs, portales). Migración manual de propiedades hacia nuestro Supabase.
4. ✅ **Multi-tenancy** — descartado. Modelo es instance-per-client (ver "Modelo de negocio" arriba).
5. ⚠️ **Definición de éxito del MVP** — pendiente. Pedirle a Diego/Rafael métricas concretas (# conversaciones/día manejadas por agente, tiempo de primera respuesta, % de leads que avanzan a visita, % de visitas concretadas, etc.).

## Bloqueadores activos (necesitan input del cliente)

- Cuenta Supabase + Vercel + Anthropic creadas (mensaje al cliente listo).
- API token de Kommo + subdomain.
- Service account de Google con acceso a `info@eko-realestate.com`.
- Reformulación de Kommo terminada (etapas, etiquetas, custom fields).
- Definición de éxito del MVP.
- Nombre del agente (sección 2.1 del spec — pendiente entre socios).
- Mapa operativo de zonas (sección 1.7 — formato y contenido).
- PDFs institucionales de venta y alquiler (los produce K).

## Reglas de confidencialidad

- **Rebranding EKO → K**: comunicar al cliente como "rebranding hacia identidad más limpia y minimalista". El motivo legal de fondo (propiedad intelectual) es **estrictamente interno**. El agente nunca lo menciona, sugiere ni reconoce, ni siquiera ante preguntas insistentes.

---

_Versión actualizada: 2026-04-28 — incorpora análisis del spec del cliente y decisiones de arquitectura (Kommo+Supabase, instance-per-client, infra del cliente)._
