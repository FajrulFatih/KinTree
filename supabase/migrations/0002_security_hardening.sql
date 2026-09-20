-- KinTree — Hardening keamanan (Fase 8)
-- Jalankan SETELAH 0001_init.sql di Supabase SQL Editor.
-- Mencakup: search_path terkunci pada SECURITY DEFINER, Storage RLS,
-- dan perluasan visibilitas keanggotaan grup.

-- =====================================================================
-- 1. KUNCI search_path PADA FUNGSI SECURITY DEFINER
--    Mencegah serangan di mana penyerang menyisipkan objek bernama sama
--    di skema lain yang lebih awal di search_path.
-- =====================================================================

create or replace function is_family_member(fam uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from family_members
    where family_id = fam and user_id = auth.uid()
  );
$$;

create or replace function create_family(p_name text, p_invite_code text)
returns families
language plpgsql
security definer
set search_path = public
as $$
declare
  v_family families;
begin
  if auth.uid() is null then
    raise exception 'Tidak terautentikasi';
  end if;
  if coalesce(trim(p_name), '') = '' then
    raise exception 'Nama keluarga wajib diisi';
  end if;

  insert into families (family_name, invite_code, created_by)
  values (trim(p_name), p_invite_code, auth.uid())
  returning * into v_family;

  insert into family_members (family_id, user_id, role)
  values (v_family.id, auth.uid(), 'owner');

  return v_family;
end;
$$;

create or replace function join_family(p_invite_code text)
returns families
language plpgsql
security definer
set search_path = public
as $$
declare
  v_family families;
begin
  if auth.uid() is null then
    raise exception 'Tidak terautentikasi';
  end if;

  select * into v_family from families
    where invite_code = upper(trim(p_invite_code));
  if v_family.id is null then
    raise exception 'Kode undangan tidak valid';
  end if;

  insert into family_members (family_id, user_id, role)
  values (v_family.id, auth.uid(), 'editor')
  on conflict (family_id, user_id) do nothing;

  return v_family;
end;
$$;

-- =====================================================================
-- 2. PERLUAS VISIBILITAS KEANGGOTAAN
--    Anggota boleh melihat seluruh anggota grup yang ia ikuti
--    (berguna untuk daftar anggota), bukan hanya baris miliknya.
-- =====================================================================

drop policy if exists "see my memberships" on family_members;
create policy "see family memberships" on family_members
  for select using (is_family_member(family_id));

-- =====================================================================
-- 3. STORAGE RLS — bucket 'member-photos'
--    Folder pertama pada path = familyId (lihat MemberRepository.uploadPhoto:
--    path = '<familyId>/<memberId>.jpg'). Hanya anggota grup boleh
--    menulis/menimpa/menghapus foto di folder grupnya.
--
--    CATATAN: jika bucket di-set Public, BACA foto via URL publik tetap
--    terbuka (dilayani CDN, di luar RLS). Path memakai UUID acak sehingga
--    sulit ditebak. Untuk privasi penuh, set bucket Private lalu pakai
--    signed URL di aplikasi (lihat documentation/tech.md §5).
-- =====================================================================

drop policy if exists "member upload photos" on storage.objects;
create policy "member upload photos" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'member-photos'
    and is_family_member(((storage.foldername(name))[1])::uuid)
  );

drop policy if exists "member update photos" on storage.objects;
create policy "member update photos" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'member-photos'
    and is_family_member(((storage.foldername(name))[1])::uuid)
  );

drop policy if exists "member delete photos" on storage.objects;
create policy "member delete photos" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'member-photos'
    and is_family_member(((storage.foldername(name))[1])::uuid)
  );

drop policy if exists "member read photos" on storage.objects;
create policy "member read photos" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'member-photos'
    and is_family_member(((storage.foldername(name))[1])::uuid)
  );
