-- F0.4 — Schema base K Real Estate.
-- Singleton tenant_config (instance-per-client), profiles (extiende auth.users),
-- human_agents (equipo del cliente), enums de roles/estado/idioma,
-- helpers RLS con security definer, policies por rol, trigger anti self-escalation.

-- Extensiones
create extension if not exists "uuid-ossp";

-- Enums
create type public.app_role as enum ('owner', 'agent_operator', 'viewer');
create type public.human_agent_status as enum ('active', 'on_leave', 'inactive');
create type public.language_code as enum ('es', 'pt', 'en');

-- tenant_config: 1 sola fila garantizada
create table public.tenant_config (
  id uuid primary key default uuid_generate_v4(),
  client_name text not null,
  agent_name text,
  team_emails text[] not null default '{}',
  operative_zones jsonb not null default '[]',
  visit_priority_weights jsonb not null default '{}',
  followup_cadences jsonb not null default '{}',
  is_singleton boolean generated always as (true) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (is_singleton)
);

comment on table public.tenant_config is 'Configuración del tenant (1 fila). Parametriza nombre del cliente, agente IA, equipo, zonas, pesos de coordinación.';

-- profiles: extiende auth.users
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  role public.app_role not null default 'viewer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is 'Perfiles de usuarios del dashboard. 1:1 con auth.users.';

-- Auto-crear profile cuando se crea un auth user
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', null));
  return new;
end;
$func$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- human_agents: equipo de K, no necesariamente loguean al dashboard
create table public.human_agents (
  id uuid primary key default uuid_generate_v4(),
  full_name text not null,
  email text,
  phone text,
  whatsapp text,
  profile_id uuid references public.profiles(id) on delete set null,
  role_label text,
  languages public.language_code[] not null default '{es}',
  specialties text[] not null default '{}',
  status public.human_agent_status not null default 'active',
  vacation_starts date,
  vacation_ends date,
  is_default_fallback boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.human_agents is 'Equipo del cliente que recibe derivaciones. profile_id opcional cuando la persona también opera el dashboard.';

-- Helpers RLS — security definer evita recursión al consultar profiles desde policies
create function public.current_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
as $func$
  select role from public.profiles where id = auth.uid()
$func$;

create function public.is_owner()
returns boolean
language sql
stable
security definer
set search_path = public
as $func$
  select coalesce(public.current_role() = 'owner', false)
$func$;

create function public.is_operator_or_above()
returns boolean
language sql
stable
security definer
set search_path = public
as $func$
  select coalesce(public.current_role() in ('owner', 'agent_operator'), false)
$func$;

-- Trigger updated_at genérico
create function public.set_updated_at()
returns trigger
language plpgsql
as $func$
begin
  new.updated_at = now();
  return new;
end;
$func$;

create trigger trg_tenant_config_updated_at
  before update on public.tenant_config
  for each row execute function public.set_updated_at();

create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger trg_human_agents_updated_at
  before update on public.human_agents
  for each row execute function public.set_updated_at();

-- Anti self-escalation: nadie puede cambiar su propio role salvo el owner
create function public.prevent_role_self_escalation()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
begin
  if new.role is distinct from old.role then
    if not public.is_owner() then
      raise exception 'No autorizado: solo owner puede cambiar role.' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$func$;

create trigger trg_profiles_prevent_role_escalation
  before update on public.profiles
  for each row execute function public.prevent_role_self_escalation();

-- RLS ON
alter table public.tenant_config enable row level security;
alter table public.profiles enable row level security;
alter table public.human_agents enable row level security;

-- Policies tenant_config: read autenticados, write solo owner
create policy "tenant_config_select_authenticated"
  on public.tenant_config for select
  to authenticated
  using (true);

create policy "tenant_config_insert_owner"
  on public.tenant_config for insert
  to authenticated
  with check (public.is_owner());

create policy "tenant_config_update_owner"
  on public.tenant_config for update
  to authenticated
  using (public.is_owner())
  with check (public.is_owner());

create policy "tenant_config_delete_owner"
  on public.tenant_config for delete
  to authenticated
  using (public.is_owner());

-- Policies profiles
create policy "profiles_select_self_or_owner"
  on public.profiles for select
  to authenticated
  using (id = auth.uid() or public.is_owner());

create policy "profiles_update_self_or_owner"
  on public.profiles for update
  to authenticated
  using (id = auth.uid() or public.is_owner())
  with check (id = auth.uid() or public.is_owner());

create policy "profiles_insert_owner"
  on public.profiles for insert
  to authenticated
  with check (public.is_owner());

create policy "profiles_delete_owner"
  on public.profiles for delete
  to authenticated
  using (public.is_owner());

-- Policies human_agents: read operator+, write solo owner
create policy "human_agents_select_operator"
  on public.human_agents for select
  to authenticated
  using (public.is_operator_or_above());

create policy "human_agents_insert_owner"
  on public.human_agents for insert
  to authenticated
  with check (public.is_owner());

create policy "human_agents_update_owner"
  on public.human_agents for update
  to authenticated
  using (public.is_owner())
  with check (public.is_owner());

create policy "human_agents_delete_owner"
  on public.human_agents for delete
  to authenticated
  using (public.is_owner());

-- Seed mínimo: 1 row de tenant_config (resto queda configurable desde el dashboard)
insert into public.tenant_config (client_name) values ('K Real Estate');
