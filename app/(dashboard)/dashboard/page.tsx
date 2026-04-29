import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { createClient } from "@/lib/supabase/server";
import type { Tables } from "@/lib/supabase/database.types";

type TenantSummary = Pick<Tables<"tenant_config">, "client_name" | "agent_name">;

export default async function DashboardHome() {
  const supabase = await createClient();
  const { data } = await supabase.from("tenant_config").select("client_name, agent_name").maybeSingle();
  const tenant = data as TenantSummary | null;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Bienvenido</h1>
        <p className="text-sm text-muted-foreground">
          Estás en el panel de {tenant?.client_name ?? "K Real Estate"}.
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Conversaciones activas</CardTitle>
            <CardDescription>Próximamente.</CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-semibold tabular-nums text-muted-foreground">—</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Propiedades publicadas</CardTitle>
            <CardDescription>Próximamente.</CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-semibold tabular-nums text-muted-foreground">—</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Visitas coordinadas</CardTitle>
            <CardDescription>Próximamente.</CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-semibold tabular-nums text-muted-foreground">—</p>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Estado del sistema</CardTitle>
          <CardDescription>
            Fase actual: <strong>F0.5 — Dashboard scaffold</strong>. Próxima: F1 — Ecosistema de información.
          </CardDescription>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground">
          {tenant?.agent_name
            ? <>Agente IA configurado: <strong>{tenant.agent_name}</strong>.</>
            : <>Falta configurar el nombre del agente IA en <code className="rounded bg-muted px-1.5 py-0.5">tenant_config</code>.</>}
        </CardContent>
      </Card>
    </div>
  );
}
