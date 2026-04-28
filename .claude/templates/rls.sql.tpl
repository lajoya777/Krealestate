-- Plantilla RLS para tabla nueva — {{NOMBRE_TABLA}}
-- Patrón estándar: usuario solo accede a sus propios registros.
-- Ajustar según caso (ej: shared resources, admins, roles).

alter table public.{{NOMBRE_TABLA}} enable row level security;

create policy "{{NOMBRE_TABLA}}_select_own"
  on public.{{NOMBRE_TABLA}} for select
  using (auth.uid() = user_id);

create policy "{{NOMBRE_TABLA}}_insert_own"
  on public.{{NOMBRE_TABLA}} for insert
  with check (auth.uid() = user_id);

create policy "{{NOMBRE_TABLA}}_update_own"
  on public.{{NOMBRE_TABLA}} for update
  using (auth.uid() = user_id);

create policy "{{NOMBRE_TABLA}}_delete_own"
  on public.{{NOMBRE_TABLA}} for delete
  using (auth.uid() = user_id);
