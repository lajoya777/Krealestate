# K Real Estate — Plan de fases

> Plan de implementación del sistema agéntico de K Real Estate.
> Documento vivo: cada fase puede subdividirse o reordenarse según hallazgos.
> Fuente de verdad sobre comportamiento del agente: `K_RealEstate_Agente_IA_Especificacion_v1.0.docx`.

---

## Convención de estados

- ⬜ Pendiente
- 🟦 En progreso
- ✅ Completada
- 🚫 Bloqueada (esperando input externo)

---

## Fase 0 — Fundación técnica ⬜

**Objetivo:** dejar el repo, infra y conectividad listos para que cualquier dev (humano o agente IA) pueda implementar features sin fricción.

### F0.1 — Repo y dependencias ⬜
- [x] `npm install` ejecutado.
- [ ] `git remote add origin https://github.com/lajoya777/Krealestate.git`
- [ ] Primer commit del scaffold + docs.
- [ ] `git push -u origin main`.
- [ ] Invitar al socio como collaborator en GitHub.

### F0.2 — Cuentas e infraestructura del cliente 🚫
**Bloqueante: requiere acción del cliente.**
- [ ] Supabase: cuenta + Organization + proyecto en región `sa-east-1` + invitación a Franco como Administrator.
- [ ] Vercel: cuenta + Team + invitación a Franco + GitHub repo conectado.
- [ ] Anthropic: cuenta + API key generada.
- [ ] Kommo: API token + subdomain.
- [ ] Google Cloud: service account con acceso a `info@eko-realestate.com` Calendar + Maps Distance Matrix API habilitada.
- [ ] OpenWeather: API key.

### F0.3 — MCP Supabase + variables de entorno 🟦
- [x] Configurar MCP de Supabase en `.mcp.json` (scope project). Apunta solo al proyecto del cliente.
- [x] `.env.local` cargado con todas las credenciales (manual, fuera del sandbox de Claude Code).
- [ ] Vercel: env vars cargadas en producción y preview.

### F0.4 — Schema base ✅
- [x] Migration inicial: `tenant_config` (1 fila, parametriza nombre/equipo/zonas/agente), `profiles` (extiende `auth.users` con role enum), `human_agents`.
- [x] Trigger `handle_new_user` auto-crea profile al crear auth user.
- [x] Trigger `prevent_role_self_escalation` cierra el agujero del self-update de role.
- [x] RLS habilitada en todas las tablas.
- [x] Helpers RLS (`current_role`, `is_owner`, `is_operator_or_above`) con `security definer` y `EXECUTE` revocado.
- [x] Policies por operación y por rol (`owner`, `agent_operator`, `viewer`).
- [x] `auth.uid()` envuelto en `(select auth.uid())` para evitar reevaluación por row.
- [x] TS types generados en `lib/supabase/database.types.ts`.
- [x] Clientes Supabase tipados con `<Database>` genérico.
- [x] Advisors de seguridad: 0 warnings.

### F0.5 — Dashboard scaffold ⬜
- [ ] Layout autenticado (`app/(dashboard)/`).
- [ ] Login + signup (Supabase Auth + middleware).
- [ ] Navegación lateral.
- [ ] Tema: paleta inspirada en la K limpia/minimalista de la marca.
- [ ] Deploy inicial a Vercel funcionando.

**Salida de F0:** dashboard vacío pero deployado en producción, login funcional, schema base con RLS, MCP de Supabase activo, integraciones listas para configurar.

---

## Fase 1 — Ecosistema de información (el cerebro) ⬜

**Objetivo:** construir el database que el agente va a consultar en tiempo real (Parte 9 del spec). Sin este componente el agente no puede operar con criterio comercial real.

### F1.1 — Schema de propiedades (Bloques A–F del spec)
- [ ] `properties` con todos los bloques: descriptivos, operativos, comerciales internos, de proyecto, configuración del agente, estado.
- [ ] `property_photos`, `property_videos`, `property_documents` (Storage de Supabase).
- [ ] `property_status_history` para histórico de cambios de precio y estado.

### F1.2 — Schema de proyectos
- [ ] `projects` (info general, desarrollador, etapa de obra, fechas).
- [ ] `project_units` (unidades dentro del proyecto, precios, planos).
- [ ] `project_payment_schemes`.

### F1.3 — Schema de objeciones
- [ ] `objections_general` (catálogo transversal con respuestas y argumentos).
- [ ] `objections_property` (vinculadas a `property_id`).
- [ ] `objections_unanswered` (capturadas para nutrir el sistema).

### F1.4 — Schema de búsquedas persistentes
- [ ] `search_profiles` (criterios estructurados por lead).
- [ ] `search_matches` (registro de notificaciones enviadas para evitar duplicados).

### F1.5 — Schema de derivaciones y equipo
- [ ] `human_agents` (con campos: nombre, rol, idiomas, especialidades, estado activo, vacaciones).
- [ ] `routing_rules` (configurable: qué tipo de lead va a qué humano, con responsable de respaldo).

### F1.6 — Apartado teórico Uruguay
- [ ] `knowledge_articles` (categorías: garantías, financiación, marco normativo, casos especiales).
- [ ] UI para que el equipo agregue/edite artículos.

### F1.7 — UI CRUD en dashboard
- [ ] Listado y detalle de propiedades.
- [ ] Form de alta/edición de propiedad (con todos los bloques).
- [ ] Listado y detalle de proyectos.
- [ ] Listado y edición de objeciones.
- [ ] Listado de búsquedas persistentes.
- [ ] Configuración de equipo y derivaciones.

### F1.8 — Carga inicial
- [ ] Migración manual de las primeras 5–10 propiedades activas de K (taller con Diego/Rafael).
- [ ] Carga de objeciones generales típicas del rubro.
- [ ] Carga inicial del apartado teórico (garantías Uruguay, bancos hipotecarios principales).

**Salida de F1:** dashboard usable por el equipo de K para gestionar propiedades, proyectos, objeciones y configuración de equipo. El agente todavía no responde — pero ya tiene el cerebro listo.

---

## Fase 2 — Agente conversacional MVP en español ⬜

**Objetivo:** agente Claude que recibe mensajes desde Kommo, identifica el tipo de lead, responde con criterio según el database de F1, y persiste todo. **MVP en español. Sin coordinación de visitas todavía.**

### F2.1 — Integración entrante Kommo → nosotros
- [ ] Route Handler `POST /api/webhooks/kommo` con validación de `KOMMO_WEBHOOK_SECRET`.
- [ ] Sincronización de leads: alta automática del lead en nuestro Supabase (con `lead_id_kommo`).
- [ ] Persistencia de mensajes entrantes en `messages`.

### F2.2 — Integración saliente nosotros → Kommo
- [ ] Wrapper de la API Kommo (auth, rate limiting, retries).
- [ ] Función `sendMessageToKommo(lead_id, content)` que enruta la respuesta del agente al chat de Kommo.
- [ ] Actualización de campos custom del lead en Kommo (etapa, idioma, presupuesto inferido).

### F2.3 — Agente Claude
- [ ] Wrapper de Anthropic SDK con prompt caching habilitado (system prompt + database context cacheado).
- [ ] System prompt construido dinámicamente desde `tenant_config` + spec del cliente (Partes 1–2: identidad, tono, reglas de transparencia, manejo de emojis).
- [ ] Tool use: `get_property(id)`, `search_properties(criteria)`, `get_project(id)`, `get_objection_response(...)`, `get_knowledge_article(topic)`, `escalate_to_human(reason, target)`, `register_search_profile(criteria)`, `register_unanswered_objection(text)`.
- [ ] Loop de procesamiento: recibir mensaje → cargar contexto del lead + history → llamar Claude → ejecutar tool calls → persistir → responder.

### F2.4 — Identificación de categoría de interés (C.1–C.6)
- [ ] El agente clasifica el lead en una de las 6 categorías + general/abierta.
- [ ] Cada categoría dispara un flujo distinto siguiendo Parte 4 del spec.
- [ ] Captura progresiva de datos (Parte 2.6): nunca preguntar info personal sensible.

### F2.5 — Persistencia y auditoría
- [ ] `conversations` y `messages` con metadata completa (modelo usado, tokens, tool calls, latency).
- [ ] Vista del hilo de conversación en el dashboard.
- [ ] Logs accesibles para debugging.

### F2.6 — Filtrado básico
- [ ] Detección rudimentaria de spam (mensajes repetidos, links sospechosos).
- [ ] Respuesta a saludos comunes.
- [ ] Manejo del rebranding EKO → K (línea oficial del spec, sin filtrar la razón legal).

**Bloqueante parcial:** estructura final de Kommo (pipelines, etapas, custom fields) está en reformulación interna del cliente. F2 puede arrancar con estructura mínima y completarse cuando el cliente termine.

**Salida de F2:** un lead escribe a WhatsApp de K, recibe respuesta del agente en segundos, la conversación queda registrada en Supabase + Kommo, el equipo la ve en el dashboard.

---

## Fase 3 — Detección proactiva + escalamiento ⬜

**Objetivo:** implementar el Principio 3 del spec — detección de señales y disparo de acciones internas.

### F3.1 — Detección de idioma
- [ ] Detectar idioma del mensaje entrante.
- [ ] Continuar la conversación en el idioma detectado (ES/PT/EN).
- [ ] Notificación interna a Diego para PT, al equipo para EN.
- [ ] Pregunta al cliente si es otro idioma.

### F3.2 — Detección de inversor sofisticado
- [ ] Heurísticas + clasificación con Claude: rentabilidad, plusvalía, portfolio, montos altos.
- [ ] Notificación a Rafael.

### F3.3 — Detección de referidos
- [ ] El agente detecta menciones de referente.
- [ ] Registra al referente en una tabla `referrals` para reconocimiento.
- [ ] Notifica al equipo.

### F3.4 — Filtro de spam, insultos, mensajes inapropiados
- [ ] Clasificador (Claude Haiku para velocidad).
- [ ] Respuestas predefinidas para spam.
- [ ] Botón de pánico: notificación urgente al equipo (email + dashboard alert) para amenazas / situaciones legales.
- [ ] Marcado especial en CRM para listas de exclusión de Meta Ads.

### F3.5 — Mecanismo de takeover humano
- [ ] Flag `human_takeover` en el lead.
- [ ] UI en el dashboard para tomar/liberar control.
- [ ] Sincronización con Kommo (cambio de responsable).
- [ ] El agente deja de generar respuestas mientras el flag esté activo.
- [ ] Liberación manual o automática tras X horas de inactividad.

### F3.6 — Notificaciones internas
- [ ] Tabla `notifications` con tipos: idioma_no_es, inversor_detectado, referido, spam, takeover_solicitado, panic, objection_unanswered, info_missing.
- [ ] UI de inbox de notificaciones en el dashboard.
- [ ] Email a destinatario configurado (Resend o equivalente).

**Salida de F3:** el agente reconoce señales valiosas y dispara acciones internas. El equipo de K ve notificaciones priorizadas en el dashboard.

---

## Fase 4 — Coordinación de visitas multifactorial ⬜

**Objetivo:** implementar los 11 factores de coordinación (Parte 3.4 del spec).

### F4.1 — Integración Google Calendar
- [ ] OAuth / service account para `info@eko-realestate.com`.
- [ ] Lectura de disponibilidad de cada `human_agent`.
- [ ] Creación/modificación/cancelación de eventos.

### F4.2 — Integración Google Maps Distance Matrix
- [ ] Cálculo de tiempos de traslado entre direcciones de propiedades.
- [ ] Cache de resultados frecuentes.

### F4.3 — Integración OpenWeather
- [ ] Consulta diaria del pronóstico de Montevideo + Ciudad de la Costa.
- [ ] Caché en Supabase con TTL diario.

### F4.4 — Lógica de los 11 factores
- [ ] Función `proposeVisitSlots(lead, property)` que retorna 3–4 opciones óptimas.
- [ ] Pesos configurables en `tenant_config.visit_priority_weights` (factores: agente asignado, disponibilidad propiedad, traslado, visitas dobles, luminosidad, clima, día de la semana, prioridad, velocidad, ventana mínima, visitas ya programadas).
- [ ] Frase de invitación a "sumarse a visita ya programada" cuando corresponda.

### F4.5 — Flujo de confirmación bilateral
- [ ] Agente propone → cliente elige → agente confirma → registra en Calendar y Kommo.
- [ ] Recordatorio al cliente N horas antes de la visita (configurable).

### F4.6 — Manejo de mal clima
- [ ] Frase del spec sobre "ver propiedad en día de lluvia es buen test".
- [ ] Aviso si el cliente insiste en día con mal pronóstico.

**Salida de F4:** el agente coordina visitas reales, las inserta en Google Calendar de los agentes humanos, y notifica al cliente con confirmación.

---

## Fase 5 — Seguimiento + matching automático ⬜

**Objetivo:** Parte 8 del spec + sección 4.7 (matching automático).

### F5.1 — Cron de seguimientos contextuales
- [ ] Vercel Cron job (cada hora).
- [ ] Cadencia diferenciada por tipo de lead (carga desde `tenant_config.followup_cadences`).
- [ ] Respeta horario laboral, feriados uruguayos, vacaciones (enero, julio).
- [ ] Prioriza días de lluvia (mejor tasa de respuesta según spec).

### F5.2 — Seguimiento post-visita
- [ ] Trigger automático 2h después de la hora programada.
- [ ] Mensaje contextualizado (no genérico).

### F5.3 — Notificaciones de cambios en propiedades
- [ ] Trigger en cambio de precio → notificar a leads que consultaron y no descartaron explícitamente.
- [ ] Trigger en cambio de estado (negociación, reservada, vendida) → respuesta adaptada en próximas consultas.

### F5.4 — Matching automático lead ↔ propiedad nueva
- [ ] Trigger en alta de propiedad nueva → comparar con `search_profiles` activos.
- [ ] Si hay match → notificar al lead con la propiedad nueva.
- [ ] Anti-spam: no enviar más de N notificaciones por lead por semana (configurable).

### F5.5 — Reactivación manual de leads viejos
- [ ] UI en dashboard para crear "campaña de reactivación" sobre filtro de leads.
- [ ] Aprobación manual antes de disparar.

### F5.6 — Diferenciación lead frío vs lead basura
- [ ] Marcado en CRM para listas de exclusión de Meta Ads.
- [ ] Export de CSV de leads basura para upload a Meta.

**Salida de F5:** sistema vivo de seguimiento que recupera leads y matchea oportunidades automáticamente.

---

## Fase 6 — Dashboard completo de tracking ⬜

**Objetivo:** convertir el dashboard de F0/F1 en una herramienta operativa real para el equipo.

### F6.1 — Bandeja de conversaciones en vivo
- [ ] Listado de leads con última interacción, etapa, urgencia.
- [ ] Filtros: estado, agente humano asignado, idioma, fuente.
- [ ] Búsqueda por nombre/teléfono.
- [ ] Realtime con Supabase (Postgres Changes).

### F6.2 — Vista de hilo de conversación
- [ ] Timeline de mensajes con timestamps.
- [ ] Diferenciación visual: cliente, agente IA, humano (post-takeover).
- [ ] Anotaciones internas (no visibles al cliente).

### F6.3 — Métricas por agente IA
- [ ] # conversaciones manejadas, tasa de primera respuesta, tiempo promedio de respuesta.
- [ ] Tasa de avance: contactado → calificado → visita coordinada → visita realizada → cierre.
- [ ] Comparativa por período.

### F6.4 — Timeline de actividad reciente
- [ ] Stream de eventos del sistema (lead nuevo, visita coordinada, baja de precio, escalamiento).

### F6.5 — Configuración del agente IA
- [ ] Editor de prompt base (override por tipo de operación).
- [ ] Toggle de features (idiomas activos, detección proactiva, etc).
- [ ] Configuración de pesos de los 11 factores.

### F6.6 — Configuración de propiedades / proyectos / objeciones
- [ ] CRUD pulido de F1 con UX mejorada.
- [ ] Bulk operations (cambio de precio masivo, etc.).

**Salida de F6:** el equipo de K opera el sistema sin tocar código.

---

## Fase 7 — Multilingüismo robusto + nutrición del sistema ⬜

**Objetivo:** Principio 2 del spec — el agente nutre al sistema.

### F7.1 — PT y EN afinados
- [ ] System prompts traducidos / adaptados por idioma.
- [ ] Pruebas de calidad en cada idioma.

### F7.2 — Captura de objeciones no respondidas
- [ ] UI tipo "inbox de aprendizaje" donde el equipo ve objeciones que el agente no supo responder.
- [ ] Botón "agregar respuesta" → carga directa a `objections_general` o `objections_property`.

### F7.3 — Captura de info faltante
- [ ] Cuando el agente no tiene info sobre una propiedad y deriva, se registra qué info faltó.
- [ ] UI para que el equipo cargue la info y la próxima vez el agente responda directo.

### F7.4 — Loop de mejora continua
- [ ] Métricas de calidad: tasa de derivación a humano, tasa de objeciones no respondidas, NPS implícito (sentiment del cliente).
- [ ] Reporte semanal automático al equipo.

**Salida de F7:** sistema que mejora con el uso, no requiere reconfiguraciones masivas.

---

## Bloqueadores transversales

Items que pueden bloquear cualquier fase y dependen del cliente:

- 🚫 Reformulación de Kommo terminada (etapas, etiquetas, custom fields) — bloquea F2 al 100%.
- 🚫 Definición de éxito del MVP — bloquea métricas de F6.
- 🚫 Nombre del agente — necesario para F2 (system prompt).
- 🚫 Mapa operativo de zonas — bloquea descarte amable correcto.
- 🚫 PDFs institucionales de venta y alquiler — bloquea flujos C.2 y C.3 (los entrega K).
- 🚫 Ejercicio práctico de prioridades de coordinación con Diego/Rafael — bloquea F4.4 con calidad real.

---

## Próximo paso

Ejecutar F0.1 (commit + push) y enviar al cliente el mensaje para crear cuentas Supabase + Vercel + Anthropic + Kommo + Google + OpenWeather, en paralelo F1 puede arrancar con schema + UI mock data.
