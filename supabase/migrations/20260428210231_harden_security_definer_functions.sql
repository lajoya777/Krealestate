-- Hardening F0.4: revocar EXECUTE público de helpers SECURITY DEFINER
-- y fijar search_path en set_updated_at.
-- Estas funciones solo deben ser invocadas por:
--   - El planner de RLS (corre como postgres / role propietario)
--   - Los triggers internos (mismo)
-- Nadie las debe llamar vía /rest/v1/rpc/.

-- Fix search_path mutable en set_updated_at
alter function public.set_updated_at() set search_path = public;

-- Revocar EXECUTE público de funciones internas
revoke execute on function public.current_role() from anon, authenticated, public;
revoke execute on function public.is_owner() from anon, authenticated, public;
revoke execute on function public.is_operator_or_above() from anon, authenticated, public;
revoke execute on function public.handle_new_user() from anon, authenticated, public;
revoke execute on function public.prevent_role_self_escalation() from anon, authenticated, public;
revoke execute on function public.set_updated_at() from anon, authenticated, public;
