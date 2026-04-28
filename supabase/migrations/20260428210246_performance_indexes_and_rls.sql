-- Performance F0.4:
-- 1. Índice en FK profile_id de human_agents (mejora joins y on delete set null).
-- 2. Wrappear auth.uid() en (select auth.uid()) — Postgres lo evalúa una vez por query
--    en lugar de una vez por row.

create index human_agents_profile_id_idx on public.human_agents (profile_id);

-- Replace policies de profiles con versión optimizada
drop policy "profiles_select_self_or_owner" on public.profiles;
drop policy "profiles_update_self_or_owner" on public.profiles;

create policy "profiles_select_self_or_owner"
  on public.profiles for select
  to authenticated
  using (id = (select auth.uid()) or public.is_owner());

create policy "profiles_update_self_or_owner"
  on public.profiles for update
  to authenticated
  using (id = (select auth.uid()) or public.is_owner())
  with check (id = (select auth.uid()) or public.is_owner());
