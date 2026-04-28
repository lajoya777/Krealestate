---
name: scalefy-backend
description: Construye la capa backend con Next.js Server Actions, Route Handlers y Supabase. Invocar cuando una fase requiere auth, Server Actions, Route Handlers, o lógica servidor. Prefiere Server Actions sobre Route Handlers.
---

# Skill: scalefy-backend

## Patrones por defecto

### Server Action (mutación)

Siempre para CREATE/UPDATE/DELETE. No crees Route Handlers para esto.

```ts
// app/dashboard/items/actions.ts
"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function createItem(formData: FormData) {
  const name = formData.get("name") as string;

  if (!name || name.trim().length === 0) {
    return { error: "El nombre es requerido" };
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { error } = await supabase
    .from("items")
    .insert({ name: name.trim(), user_id: user.id });

  if (error) return { error: error.message };

  revalidatePath("/dashboard/items");
  redirect("/dashboard/items");
}
```

### Auth — Signup + Login con Server Actions

```ts
// app/(auth)/actions.ts
"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function login(formData: FormData) {
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) return { error: "Credenciales inválidas" };

  revalidatePath("/", "layout");
  redirect("/dashboard");
}

export async function signup(formData: FormData) {
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;

  const supabase = await createClient();
  const { error } = await supabase.auth.signUp({
    email,
    password,
    options: { emailRedirectTo: `${process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"}/auth/callback` },
  });

  if (error) return { error: error.message };

  return { success: "Revisá tu email para confirmar la cuenta" };
}

export async function logout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  revalidatePath("/", "layout");
  redirect("/");
}
```

### Callback OAuth / Magic Link (Route Handler)

```ts
// app/(auth)/callback/route.ts
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/dashboard";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) return NextResponse.redirect(`${origin}${next}`);
  }

  return NextResponse.redirect(`${origin}/login?error=auth_callback_failed`);
}
```

### Route Handler (solo cuando hace falta: webhooks, API pública)

```ts
// app/api/webhook/route.ts
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const body = await request.json();
  // validar firma, procesar, etc.
  return NextResponse.json({ ok: true });
}
```

## Reglas

- **Server Actions > Route Handlers.** Para mutaciones de UI, siempre Server Action.
- **Validación mínima en Server Action.** Zod solo si hay forma compleja. Para forms simples, check básico + error string.
- **Nunca confiar en `formData`.** Validar todo.
- **`auth.getUser()` para chequear sesión** (no `auth.getSession()` en server — inseguro).
- **Redirect después de mutación exitosa** + `revalidatePath`.
- **Errores en retorno estructurado** (`{ error: string }` o `{ success: string }`), no `throw` salvo bug real.
- **Nunca exponer `SUPABASE_SERVICE_ROLE_KEY`.** Si hace falta operación privilegiada, crear cliente server-side con esa key en archivo no tocable por frontend.

## Antipatrones

- `fetch('/api/...')` desde el propio Next cuando podés usar Server Action.
- `useEffect` para cargar data (usá Server Components).
- Middleware para lógica de negocio (solo para auth refresh).
- Store de estado global para data server (usá SSR + revalidate).
