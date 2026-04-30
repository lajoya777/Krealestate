-- F0.5 — el primer usuario que se registra queda como owner (bootstrap del sistema).
-- A partir del segundo, role default es 'viewer' como dice la columna, y un owner
-- existente puede promocionarlos vía el dashboard.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
declare
  is_first_user boolean;
begin
  -- Detección con FOR UPDATE no es necesaria: el trigger corre dentro de la
  -- transacción del INSERT en auth.users, y profiles tiene cascade. El gap
  -- entre count y insert es despreciable y el escenario "dos signups simultáneos
  -- antes del primer commit" es prácticamente imposible en este contexto.
  select count(*) = 0 into is_first_user from public.profiles;

  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', null),
    case when is_first_user then 'owner'::public.app_role else 'viewer'::public.app_role end
  );
  return new;
end;
$func$;

revoke execute on function public.handle_new_user() from anon, authenticated, public;
