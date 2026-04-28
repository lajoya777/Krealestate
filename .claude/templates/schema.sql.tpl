-- Migración inicial — {{NOMBRE_PROYECTO}}
-- Generada por skill scalefy-datos. Editá antes de aplicar si hace falta.

-- ============================================================
-- Extensiones
-- ============================================================
create extension if not exists "uuid-ossp";

-- ============================================================
-- Tabla profiles (extensión de auth.users)
-- ============================================================
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text unique,
  full_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Policies profiles
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id);

create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Trigger: crear profile al registrarse
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- Tabla {{ENTIDAD_TABLE}}
-- ============================================================
create table if not exists public.{{ENTIDAD_TABLE}} (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users on delete cascade,
  {{CAMPOS_ENTIDAD_SQL}},
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists {{ENTIDAD_TABLE}}_user_id_idx on public.{{ENTIDAD_TABLE}}(user_id);

alter table public.{{ENTIDAD_TABLE}} enable row level security;

-- Policies: usuario solo accede a sus propios registros
create policy "{{ENTIDAD_TABLE}}_select_own"
  on public.{{ENTIDAD_TABLE}} for select
  using (auth.uid() = user_id);

create policy "{{ENTIDAD_TABLE}}_insert_own"
  on public.{{ENTIDAD_TABLE}} for insert
  with check (auth.uid() = user_id);

create policy "{{ENTIDAD_TABLE}}_update_own"
  on public.{{ENTIDAD_TABLE}} for update
  using (auth.uid() = user_id);

create policy "{{ENTIDAD_TABLE}}_delete_own"
  on public.{{ENTIDAD_TABLE}} for delete
  using (auth.uid() = user_id);

-- ============================================================
-- Trigger genérico de updated_at
-- ============================================================
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_updated_at_profiles
  before update on public.profiles
  for each row execute procedure public.set_updated_at();

create trigger set_updated_at_{{ENTIDAD_TABLE}}
  before update on public.{{ENTIDAD_TABLE}}
  for each row execute procedure public.set_updated_at();
