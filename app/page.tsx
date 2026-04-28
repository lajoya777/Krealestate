export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-6 p-8">
      <div className="max-w-2xl text-center space-y-4">
        <h1 className="text-4xl font-bold tracking-tight">
          Inicializador Scalefy
        </h1>
        <p className="text-muted-foreground text-lg">
          Tu app arranca desde aquí. Abrí Claude Code y escribí{" "}
          <code className="rounded bg-muted px-2 py-1 font-mono text-sm">
            /idea
          </code>{" "}
          seguido de tu idea en una frase.
        </p>
        <p className="text-sm text-muted-foreground">
          Ejemplo:{" "}
          <code className="rounded bg-muted px-2 py-1 font-mono text-sm">
            /idea una app para que freelancers facturen a sus clientes
          </code>
        </p>
      </div>
    </main>
  );
}
