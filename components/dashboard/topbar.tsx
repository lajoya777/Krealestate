import { logoutAction } from "@/app/(auth)/actions";
import { Button } from "@/components/ui/button";
import { LogOut } from "lucide-react";

export function Topbar({ email, role }: { email: string; role: string }) {
  return (
    <header className="flex h-14 items-center justify-between gap-4 border-b bg-card px-4 md:px-6">
      <div className="flex items-center gap-3">
        <span className="text-sm font-medium">Panel</span>
      </div>

      <div className="flex items-center gap-3">
        <div className="hidden text-right sm:block">
          <p className="text-sm font-medium leading-tight">{email}</p>
          <p className="text-xs leading-tight text-muted-foreground capitalize">{role.replace("_", " ")}</p>
        </div>
        <form action={logoutAction}>
          <Button type="submit" variant="ghost" size="sm" className="gap-2">
            <LogOut className="h-4 w-4" />
            <span className="hidden sm:inline">Salir</span>
          </Button>
        </form>
      </div>
    </header>
  );
}
