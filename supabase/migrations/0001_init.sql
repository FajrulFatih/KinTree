-- KinTree — Skema awal (Fase 0.4)
-- Jalankan di Supabase SQL Editor. Mencakup: tabel, RLS, dan RPC.

-- =====================================================================
-- 1. TABEL
-- =====================================================================

create table if not exists families (
  id          uuid primary key default gen_random_uuid(),
  family_name text not null,
  invite_code text unique not null,
  created_by  uuid not null references auth.users(id),
  created_at  timestamptz not null default now()
);

create table if not exists family_members (
  family_id uuid not null references families(id) on delete cascade,
  user_id   uuid not null references auth.users(id) on delete cascade,
  role      text not null default 'editor' check (role in ('owner','editor')),
  joined_at timestamptz not null default now(),
  primary key (family_id, user_id)
);

create table if not exists members (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid not null references families(id) on delete cascade,
  first_name  text not null,
  last_name   text,
  nickname    text,
  gender      text check (gender in ('MALE','FEMALE')),
  birth_place text,
  birth_date  date,
  is_alive    boolean not null default true,
  death_date  date,
  photo_url   text,
  notes       text,
  updated_at  timestamptz not null default now()
);

create table if not exists relationships (
  id             uuid primary key default gen_random_uuid(),
  family_id      uuid not null references families(id) on delete cascade,
  from_member_id uuid not null references members(id) on delete cascade,
  to_member_id   uuid not null references members(id) on delete cascade,
  type           text not null check (type in ('SPOUSE','PARENT_BIOLOGICAL','PARENT_ADOPTIVE')),
  status         text check (status in ('MARRIED','DIVORCED')),
  marriage_order int,
  created_at     timestamptz not null default now()
);

create index if not exists idx_members_family on members(family_id);
create index if not exists idx_relationships_family on relationships(family_id);

-- =====================================================================
-- 2. HELPER (security definer untuk hindari rekursi RLS)
-- =====================================================================

create or replace function is_family_member(fam uuid)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from family_members
    where family_id = fam and user_id = auth.uid()
  );
$$;

-- =====================================================================
-- 3. ROW LEVEL SECURITY
-- =====================================================================

alter table families       enable row level security;
alter table family_members enable row level security;
alter table members        enable row level security;
alter table relationships  enable row level security;

drop policy if exists "read own families" on families;
create policy "read own families" on families
  for select using (is_family_member(id));

drop policy if exists "owner update families" on families;
create policy "owner update families" on families
  for update using (created_by = auth.uid());

drop policy if exists "owner delete families" on families;
create policy "owner delete families" on families
  for delete using (created_by = auth.uid());

drop policy if exists "see my memberships" on family_members;
create policy "see my memberships" on family_members
  for select using (user_id = auth.uid());

drop policy if exists "members rw" on members;
create policy "members rw" on members
  for all using (is_family_member(family_id)) with check (is_family_member(family_id));

drop policy if exists "relationships rw" on relationships;
create policy "relationships rw" on relationships
  for all using (is_family_member(family_id)) with check (is_family_member(family_id));

-- =====================================================================
-- 4. RPC (security definer — buat & gabung grup tanpa masalah chicken-egg RLS)
-- =====================================================================

-- Buat grup baru + daftarkan pembuat sebagai owner
create or replace function create_family(p_name text, p_invite_code text)
returns families
language plpgsql
security definer
as $$
declare
  v_family families;
begin
  if auth.uid() is null then
    raise exception 'Tidak terautentikasi';
  end if;

  insert into families (family_name, invite_code, created_by)
  values (p_name, p_invite_code, auth.uid())
  returning * into v_family;

  insert into family_members (family_id, user_id, role)
  values (v_family.id, auth.uid(), 'owner');

  return v_family;
end;
$$;

-- Gabung grup via invite code → tambahkan sebagai editor
create or replace function join_family(p_invite_code text)
returns families
language plpgsql
security definer
as $$
declare
  v_family families;
begin
  if auth.uid() is null then
    raise exception 'Tidak terautentikasi';
  end if;

  select * into v_family from families where invite_code = p_invite_code;
  if v_family.id is null then
    raise exception 'Kode undangan tidak valid';
  end if;

  insert into family_members (family_id, user_id, role)
  values (v_family.id, auth.uid(), 'editor')
  on conflict (family_id, user_id) do nothing;

  return v_family;
end;
$$;
