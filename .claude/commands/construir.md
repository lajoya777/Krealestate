---
description: Ejecuta la próxima fase pendiente del plan.
---

Invocá la skill `scalefy-construir`.

La skill busca la próxima fase con `[ ]` en `docs/PLAN.md`, la ejecuta dispatchando a las skills especialistas correspondientes (frontend, backend, datos), corre el agente revisor para verificar calidad, y marca la fase como completa. NO ejecuta múltiples fases sin confirmación del usuario.
