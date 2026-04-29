import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * Handler del email confirmation flow de Supabase Auth.
 * El email de confirmación apunta acá con un `code` query param.
 * Lo intercambiamos por sesión y redirigimos al dashboard.
 */
export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") || "/dashboard";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(`${origin}${next.startsWith("/") ? next : "/dashboard"}`);
    }
  }

  return NextResponse.redirect(`${origin}/login?error=callback`);
}
