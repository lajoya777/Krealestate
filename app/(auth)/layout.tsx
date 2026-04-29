import type { ReactNode } from "react";

export default function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <main className="flex min-h-screen items-center justify-center bg-muted/30 p-4">
      <div className="w-full max-w-md">
        <div className="mb-8 flex flex-col items-center gap-2">
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-foreground text-background">
            <span className="text-2xl font-bold tracking-tight">K</span>
          </div>
          <p className="text-sm text-muted-foreground">K Real Estate · Plataforma interna</p>
        </div>
        {children}
      </div>
    </main>
  );
}
