"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  MessagesSquare,
  Building2,
  Hammer,
  Users,
  Settings,
  type LucideIcon,
} from "lucide-react";
import { cn } from "@/lib/utils";

type NavItem = {
  href: string;
  label: string;
  icon: LucideIcon;
  enabled: boolean;
};

const NAV_ITEMS: NavItem[] = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard, enabled: true },
  { href: "/dashboard/conversaciones", label: "Conversaciones", icon: MessagesSquare, enabled: false },
  { href: "/dashboard/propiedades", label: "Propiedades", icon: Building2, enabled: false },
  { href: "/dashboard/proyectos", label: "Proyectos", icon: Hammer, enabled: false },
  { href: "/dashboard/equipo", label: "Equipo", icon: Users, enabled: false },
  { href: "/dashboard/configuracion", label: "Configuración", icon: Settings, enabled: false },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="hidden w-60 shrink-0 border-r bg-card md:flex md:flex-col">
      <div className="flex h-14 items-center gap-3 border-b px-4">
        <div className="flex h-8 w-8 items-center justify-center rounded-md bg-foreground text-background">
          <span className="text-base font-bold">K</span>
        </div>
        <span className="text-sm font-medium">K Real Estate</span>
      </div>

      <nav className="flex-1 space-y-1 p-3">
        {NAV_ITEMS.map(({ href, label, icon: Icon, enabled }) => {
          const active = pathname === href;
          const className = cn(
            "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
            active && "bg-foreground/5 font-medium text-foreground",
            !active && enabled && "text-muted-foreground hover:bg-foreground/5 hover:text-foreground",
            !enabled && "cursor-not-allowed text-muted-foreground/50"
          );

          if (!enabled) {
            return (
              <span key={href} className={className} aria-disabled="true">
                <Icon className="h-4 w-4" />
                {label}
                <span className="ml-auto text-[10px] uppercase tracking-wider">Próx.</span>
              </span>
            );
          }

          return (
            <Link key={href} href={href} className={className}>
              <Icon className="h-4 w-4" />
              {label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t p-3 text-xs text-muted-foreground">
        <p>v0 · Fundación</p>
      </div>
    </aside>
  );
}
