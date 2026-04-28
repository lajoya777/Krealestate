---
name: scalefy-arreglar
description: Debug sistemático y fix rápido de bugs o errores. Invocar con `/arreglar [descripción o error]` o cuando el usuario reporte "esto no funciona", "da error", "salta X mensaje". Reproduce, diagnostica la causa raíz, aplica fix mínimo y verifica.
---

# Skill: scalefy-arreglar

## Proceso

### Paso 1 — Capturar síntoma

Del mensaje del usuario o el `/arreglar [texto]`, extraer:
- ¿Es error en consola, en runtime, en UI, en build, en typecheck?
- ¿Mensaje exacto? Si el usuario no lo puso, pedir que lo pegue.
- ¿Cuándo ocurre? (al hacer X, al cargar Y, siempre, a veces)

Si hay stack trace, leelo entero antes de teorizar.

### Paso 2 — Reproducir (mental o real)

Localizar el archivo/línea del stack trace. Leer.

Si el bug es UI y tenés `npm run dev` corriendo en background, verificá el comportamiento.

### Paso 3 — Hipótesis de causa raíz

Preguntate: ¿por qué pasa esto? Listá 2-3 hipótesis mentales.

Descartá por evidencia (código, tipos, logs) — no por intuición.

**Causas comunes en este stack:**

| Síntoma | Causa probable |
|---------|---------------|
| "RLS violation" / "permission denied" | Falta policy o `user_id` mal seteado |
| "cookies can only be modified in a Server Action..." | Llamaste `supabase.auth.setSession` fuera de Server Action/Route Handler |
| Hydration mismatch | Diferencia SSR vs client (fecha `new Date()`, `Math.random()`) |
| "Cannot read properties of undefined" en server | Env var faltante o data null no chequeada |
| Build falla typecheck | Probablemente `any` implícito o prop mal tipada |
| Form submit no hace nada | Falta `action={...}` o olvidás marcar `"use server"` |
| 404 en ruta nueva | Archivo mal nombrado (debe ser `page.tsx`, no `Page.tsx`) |
| `auth.getUser()` retorna null en cliente | Usá `createBrowserClient`, no el de servidor |

### Paso 4 — Fix mínimo

Aplicar el cambio más chico que resuelve la causa raíz. NO:
- refactorizar código no relacionado
- agregar defensive programming "por si acaso"
- cambiar estilo/formato

### Paso 5 — Verificar

- Corré `npm run typecheck` si tocaste código TS.
- Si era bug de UI, decile al usuario que refresque y confirme.
- Si era bug de DB/RLS, correr la query que fallaba.

### Paso 6 — Reportar

Formato:

```
Causa: [una línea]
Fix: [qué cambiaste, en qué archivo]
Verificación: [qué corriste / qué chequear]
```

Si el usuario tiene `git`, commit:

```bash
git add <archivos>
git commit -m "fix: [descripción corta]"
```

## Reglas

- **Causa raíz antes que fix.** Si no sabés por qué, no apliques cambio.
- **No silenciar errores** (ej: agregar `try/catch` vacío). Fijá la causa.
- **No deshabilitar lints/checks** para hacer pasar. Arreglá lo que los dispara.
- **No hacer cambios grandes.** Si el bug revela mala arquitectura, decilo pero no refactorices sin pedir permiso.
- **Si no podés reproducir**, preguntá al usuario pasos exactos antes de tirar fixes especulativos.
