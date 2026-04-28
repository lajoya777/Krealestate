---
name: scalefy-frontend
description: Construye UI con Next.js 15 App Router, Tailwind y shadcn/ui. Invocar cuando una fase requiere crear páginas, componentes, formularios o landing. Usa Server Components por defecto y Client Components solo si hay estado/interacción.
---

# Skill: scalefy-frontend

## Patrones por defecto

### Server Component vs Client Component

- **Server Component (default):** todo lo que renderiza data estática/fetched.
- **Client Component (`"use client"`):** solo si hay `useState`, `useEffect`, `onClick`, `onChange`, o libs que requieran browser.

### Estructura de página típica

```tsx
// app/dashboard/items/page.tsx (Server Component)
import { createClient } from "@/lib/supabase/server";
import { ItemsList } from "@/components/items/list";

export default async function ItemsPage() {
  const supabase = await createClient();
  const { data: items } = await supabase.from("items").select("*").order("created_at", { ascending: false });

  return (
    <div className="container py-8">
      <h1 className="text-2xl font-bold mb-6">Mis items</h1>
      <ItemsList items={items ?? []} />
    </div>
  );
}
```

### Formulario con Server Action

```tsx
// app/dashboard/items/new/page.tsx
import { createItem } from "../actions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export default function NewItemPage() {
  return (
    <form action={createItem} className="max-w-md space-y-4">
      <div className="space-y-2">
        <Label htmlFor="name">Nombre</Label>
        <Input id="name" name="name" required />
      </div>
      <Button type="submit">Crear</Button>
    </form>
  );
}
```

### Client Component con estado

```tsx
"use client";
import { useState } from "react";
import { Button } from "@/components/ui/button";

export function Counter() {
  const [count, setCount] = useState(0);
  return <Button onClick={() => setCount(count + 1)}>Clicks: {count}</Button>;
}
```

### Layout protegido (dashboard)

```tsx
// app/dashboard/layout.tsx
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  return <div className="min-h-screen">{children}</div>;
}
```

## Reglas

- **Tailwind + shadcn siempre.** No CSS modules, no styled-components.
- **Imports con `@/`.**
- **Accesibilidad mínima:**
  - `<Label htmlFor>` + `<Input id>` matching
  - `aria-label` en botones sin texto
  - Contraste suficiente (usá tokens de shadcn)
- **Responsive por default.** Usá clases `sm:`, `md:`, `lg:`.
- **Loading / error states:** usá `loading.tsx`, `error.tsx` de Next.js. No construyas sistemas custom.
- **Forms:** prefiriendo Server Actions. Client state solo si hay UX que lo requiera (multi-step, validación en vivo compleja).
- **Toast:** `import { toast } from "sonner"` para feedback rápido al usuario.

## Agregar componente shadcn nuevo

Si necesitás un componente shadcn que no está (ej: dialog, dropdown, form, select):

```bash
npx shadcn@latest add <componente>
```

Componentes pre-incluidos: `button`, `input`, `label`, `card`.

## Antipatrones a evitar

- **No `useEffect` para fetching server-side.** Usá Server Components.
- **No pegar estilos inline.** Siempre Tailwind classes.
- **No crear contextos React** salvo necesidad real (auth/theme).
- **No libs de routing.** Usá Next.js App Router.
- **No Redux / MobX.** Estado local + Server Actions alcanza para MVP.
