import type { ReactNode } from "react";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Sidebar } from "@/components/dashboard/sidebar";
import { Topbar } from "@/components/dashboard/topbar";
import type { Tables } from "@/lib/supabase/database.types";

type ProfileSummary = Pick<Tables<"profiles">, "role" | "email" | "full_name">;

export default async function DashboardLayout({ children }: { children: ReactNode }) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data } = await supabase
    .from("profiles")
    .select("role, email, full_name")
    .eq("id", user.id)
    .maybeSingle();
  const profile = data as ProfileSummary | null;

  const email = profile?.email ?? user.email ?? "";
  const role = profile?.role ?? "viewer";

  return (
    <div className="flex min-h-screen bg-muted/20">
      <Sidebar />
      <div className="flex min-h-screen flex-1 flex-col">
        <Topbar email={email} role={role} />
        <main className="flex-1 p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
