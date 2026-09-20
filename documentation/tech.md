# Technology Stack — KinTree

Dokumen ini merangkum keputusan teknologi, dependensi, dan konvensi teknis KinTree. Backend menggunakan **Supabase Free Tier (100% gratis, tanpa kartu kredit)**.

---

## 1. Arsitektur Tingkat Tinggi

Arsitektur **Client-Server hibrida** memanfaatkan ekosistem Supabase (Backend-as-a-Service open-source di atas PostgreSQL) untuk memotong jalur pengembangan backend tradisional.

```
+-------------------------------------------------------------+
|                      FLUTTER CLIENT                         |
|  [Presentation Layer] -> [State Management (Riverpod 3)]    |
|  [Graph Rendering]    -> [LayoutService + CustomPainter]    |
|  [Local Cache]        -> [SQLite (Drift) — sumber baca UI]  |
+-------------------------------------------------------------+
                              |
                   HTTPS (REST/PostgREST) + WSS (Realtime)
                              |
+-------------------------------------------------------------+
|                      SUPABASE BACKEND                       |
|  [Auth]      -> Supabase Auth (GoTrue)                      |
|  [Database]  -> PostgreSQL (Relasional) + Row Level Security|
|  [Storage]   -> Supabase Storage (Foto Profil)             |
|  [Realtime]  -> Realtime subscriptions (sinkronisasi live)  |
+-------------------------------------------------------------+
```

---

## 2. Frontend (Flutter Stack)

| Aspek | Pilihan | Alasan |
|-------|---------|--------|
| Framework | **Flutter** | Multiplatform (Android/iOS) dari satu basis kode. |
| Bahasa | **Dart** | Native Flutter. |
| State Management | **Riverpod 3** | Reaktif terhadap stream cache/Realtime, *testable*. |
| Graph Rendering | **CustomPainter** + tata letak sendiri | `LayoutService` (penempatan DFS) + painter untuk node/garis/pita. _(paket `graphview` ada di pubspec namun tidak dipakai — layout dibuat sendiri.)_ |
| Backend Client | **supabase_flutter** | SDK resmi (Auth, Postgres, Storage, Realtime). |
| Local Cache / Offline | **Drift** (SQLite) via `drift_flutter` | Supabase tidak punya offline persistence bawaan → cache lokal. |
| Tipografi | **google_fonts** | Spectral (serif) + Plus Jakarta Sans (UI). |
| Konfigurasi | **flutter_dotenv** | Baca kredensial Supabase dari `.env`. |
| Kompresi Gambar | **flutter_image_compress** | Memperkecil foto sebelum unggah. |
| Format tanggal | **intl** | Tanggal Bahasa Indonesia (locale `id`). |

### Dependensi Utama (`pubspec.yaml`)
- `supabase_flutter` — Auth + Postgres + Storage + Realtime
- `flutter_riverpod` (v3)
- `drift` + `drift_flutter` (cache offline; dev: `drift_dev`, `build_runner`)
- `google_fonts` — Spectral & Plus Jakarta Sans
- `flutter_dotenv` — kredensial via `.env`
- `flutter_image_compress`, `image_picker`
- `intl` — format tanggal locale `id`
- `graphview` — terpasang tetapi **tidak digunakan** (layout custom)
- dev: `flutter_launcher_icons` (ikon aplikasi), `flutter_lints`

### Sistem Desain (tema "Warm Heritage")
- **Warna** (`core/theme/app_colors.dart`): krem `#FCF8F0`, tinta `#2B2117`, hijau hutan `#3C6B53`, ochre `#B07B3E`, biru-abu (pria) `#5E7E8C`, mauve (wanita) `#A8746F`, terracotta (danger) `#BB4A3F`.
- **Font** (`core/theme/app_theme.dart`): `AppTheme.serif()` = Spectral (nama/judul), `AppTheme.sans()` = Plus Jakarta Sans (UI).

---

## 3. Backend & Cloud (Supabase Free Tier)

| Layanan | Peran |
|---------|-------|
| **Supabase Auth (GoTrue)** | Autentikasi pengguna (**Email/Password**). |
| **PostgreSQL** | Database relasional utama; tabel `families`, `family_members`, `members`, `relationships`. |
| **Supabase Storage** | Menyimpan foto profil (dengan kompresi sisi klien). |
| **Realtime** | Sinkronisasi perubahan live antar perangkat dalam grup (perlu diaktifkan manual per tabel). |

### Batas Free Tier (gratis, tanpa kartu kredit)
| Sumber Daya | Batas Gratis |
|-------------|--------------|
| Database PostgreSQL | **500 MB** |
| Storage (file) | **1 GB** |
| Bandwidth | 5 GB/bulan |
| Monthly Active Users (Auth) | 50.000 |
| Realtime | 200 koneksi concurrent, 2 juta pesan/bulan |

> ⚠️ **Catatan penting Free Tier:** Proyek Supabase gratis **otomatis di-*pause* setelah 7 hari tanpa aktivitas**. Cukup buka dashboard / pakai aplikasi sesekali agar tetap aktif. Untuk skala KinTree (internal keluarga) batas-batas di atas sangat memadai dan biaya tetap **Rp 0**.

### Optimasi
- **Kompresi gambar:** maks lebar **400px**, **JPEG kualitas 75%** sebelum unggah → jaga Storage jauh di bawah 1 GB.
- **Cache lokal (Drift):** kueri silsilah dibaca dari SQLite lokal lebih dulu, jaringan hanya untuk sinkronisasi delta → hemat bandwidth & cepat saat luring.

---

## 4. Model Data (PostgreSQL Relasional)

Struktur silsilah (graf nodes & edges) dimodelkan ke tabel relasional. Tabel `family_members` ditambahkan untuk mendukung kolaborasi multi-user (memecahkan masalah keanggotaan yang sebelumnya tidak tertangani).

```sql
-- Tabel: families
create table families (
  id            uuid primary key default gen_random_uuid(),
  family_name   text not null,
  invite_code   text unique not null,
  created_by    uuid references auth.users(id),
  created_at    timestamptz default now()
);

-- Tabel: family_members (keanggotaan grup → kolaborasi)
create table family_members (
  family_id  uuid references families(id) on delete cascade,
  user_id    uuid references auth.users(id) on delete cascade,
  role       text default 'editor',          -- 'owner' | 'editor'
  joined_at  timestamptz default now(),
  primary key (family_id, user_id)
);

-- Tabel: members (Nodes)
create table members (
  id          uuid primary key default gen_random_uuid(),
  family_id   uuid references families(id) on delete cascade,
  first_name  text not null,
  last_name   text,
  nickname    text,
  gender      text check (gender in ('MALE','FEMALE')),
  birth_place text,
  birth_date  date,
  is_alive    boolean default true,
  death_date  date,
  photo_url   text,
  notes       text,
  updated_at  timestamptz default now()
);

-- Tabel: relationships (Edges)
create table relationships (
  id              uuid primary key default gen_random_uuid(),
  family_id       uuid references families(id) on delete cascade,
  from_member_id  uuid references members(id) on delete cascade,
  to_member_id    uuid references members(id) on delete cascade,
  type            text check (type in ('SPOUSE','PARENT_BIOLOGICAL','PARENT_ADOPTIVE')),
  status          text check (status in ('MARRIED','DIVORCED')),
  marriage_order  int,
  created_at      timestamptz default now()
);
```

- **Enum `gender`:** `MALE` | `FEMALE`
- **Enum `type`:** `SPOUSE` | `PARENT_BIOLOGICAL` | `PARENT_ADOPTIVE`
- **Enum `status`:** `MARRIED` | `DIVORCED` *(hanya untuk `SPOUSE`)*
- **`marriage_order`:** integer, urutan pernikahan ke-N.

> Constraint relasional (foreign key) menjamin integritas: hapus anggota → relasinya ikut terhapus (`on delete cascade`).

---

## 5. Keamanan (Row Level Security / RLS)

Pengganti Firestore Security Rules. RLS diaktifkan per tabel; akses dibatasi pada anggota grup yang sah (lewat tabel `family_members`).

```sql
-- Aktifkan RLS
alter table families         enable row level security;
alter table family_members   enable row level security;
alter table members          enable row level security;
alter table relationships    enable row level security;

-- Helper: apakah user anggota suatu family
create or replace function is_family_member(fam uuid)
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from family_members
    where family_id = fam and user_id = auth.uid()
  );
$$;

-- families: anggota boleh baca; siapa pun login boleh buat
create policy "read own families"   on families for select using (is_family_member(id));
create policy "create families"      on families for insert with check (auth.uid() = created_by);
create policy "owner update/delete"  on families for update using (created_by = auth.uid());

-- members & relationships: hanya anggota grup
create policy "members rw" on members
  for all using (is_family_member(family_id)) with check (is_family_member(family_id));

create policy "relationships rw" on relationships
  for all using (is_family_member(family_id)) with check (is_family_member(family_id));

-- family_members: user lihat keanggotaannya, join via invite ditangani lewat RPC
create policy "see my memberships" on family_members for select using (user_id = auth.uid());
```

> **Join via invite code** lewat **Postgres function (RPC)** `join_family(invite_code)` yang menyisipkan baris ke `family_members` setelah memvalidasi kode — agar logika validasi aman di sisi server. Pembuatan grup juga via RPC `create_family` (keduanya `SECURITY DEFINER` untuk menghindari masalah chicken-egg RLS).

### 5.1 Hardening (Fase 8 — `migrations/0002_security_hardening.sql`)

- **`SET search_path = public`** pada semua fungsi `SECURITY DEFINER` (`is_family_member`, `create_family`, `join_family`) — mencegah serangan injeksi objek lewat manipulasi `search_path`.
- **Storage RLS** pada bucket `member-photos`: insert/update/delete/select dibatasi ke anggota grup berdasarkan folder pertama path (`<familyId>/...`).
- **Visibilitas keanggotaan** diperluas: anggota dapat melihat seluruh anggota grup yang diikutinya (`for select using (is_family_member(family_id))`).
- Validasi server-side: `create_family` menolak nama kosong; `join_family` menormalkan & memvalidasi kode undangan.

Prosedur uji lengkap (impersonasi user via JWT claims) ada di [`supabase/SECURITY.md`](../supabase/SECURITY.md).

> **Catatan privasi foto:** bila bucket `member-photos` di-set *Public*, pembacaan foto via URL tetap terbuka (dilayani CDN, di luar RLS). Path memakai UUID acak sehingga sulit ditebak. Untuk privasi penuh (NFR-2), set bucket *Private* dan gunakan signed URL di aplikasi.

---

## 6. Realtime, Offline & Write-Through

Arsitektur data: **UI selalu membaca dari cache Drift**, bukan langsung dari jaringan.

- **Sumber baca:** `membersStreamProvider`/`relationshipsStreamProvider` → `CacheRepository.watchMembers/...` → Drift `.watch()` (reaktif).
- **Sinkronisasi server → cache:** provider `_memberSyncProvider`/`_relationshipSyncProvider` berlangganan `client.from('...').stream(...)` Supabase dan menulis snapshot ke Drift (`replaceMembers`/`replaceRelationships`, server-wins).
- **Write-through (penting):** setiap penulisan (tambah/edit/hapus anggota & relasi) menulis ke Supabase **lalu langsung ke cache Drift** (`upsertMember`/`deleteMember`/`upsertRelationship`/...). Akibatnya UI ter-update **seketika tanpa menunggu Realtime**.
- **Offline:** saat luring, kanvas tetap membaca dari SQLite; saat daring, snapshot/Realtime merekonsiliasi.

> ⚠️ **Realtime perlu diaktifkan manual** di Supabase (Database → Replication, atau Table Editor → Realtime ON) untuk tabel `members` & `relationships` agar perubahan tersinkron **antar perangkat**. Tanpa itu, write-through tetap membuat perubahan tampil di perangkat sendiri, tetapi perangkat lain baru melihatnya saat membuka ulang aplikasi.

> **Batasan diketahui:** penulisan tetap butuh koneksi (read-offline, write-online); belum ada antrian mutasi offline.

---

## 7. Algoritma Tata Letak (Layouting)

Visualisasi bukan pohon biner murni karena relasi menyamping (`SPOUSE`):
1. **Generasi (Y-Axis):** urutkan dari leluhur tertua (Gen 0) ke bawah; `birth_date` sebagai validator urutan.
2. **Pasangan (X-Axis):** node `SPOUSE` bersebelahan horizontal pada Y sama; `DIVORCED` diberi jarak renggang.
3. **Anak (Branching):** garis vertikal dari titik tengah pasangan ke baris generasi di bawah, lalu bercabang horizontal ke tiap anak.

---

## 8. Lingkungan Pengembangan

1. **Flutter SDK** (stable, diuji 3.41 / Dart 3.11) + **Dart SDK**.
2. **Akun Supabase** (gratis) → buat project, salin `Project URL` & `anon key` (Project Settings → API).
3. **Kredensial via `.env`** (dibaca `flutter_dotenv`):
   ```env
   SUPABASE_URL=https://xxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGci...
   ```
   `.env` di-`.gitignore`; alternatif `--dart-define`. Dimuat di `main.dart` sebelum `Supabase.initialize(...)`.
4. **SQL Editor** → jalankan berurutan: `supabase/migrations/0001_init.sql` (tabel, RLS, RPC) lalu `0002_security_hardening.sql` (hardening + Storage RLS).
5. **Storage bucket** `member-photos` + (kompresi sisi klien sudah otomatis).
6. **Realtime** → aktifkan untuk tabel `members` & `relationships` bila ingin sinkronisasi antar perangkat (lihat §6).
7. **Ikon aplikasi**: `dart run flutter_launcher_icons` (sumber di `assets/icon/`).
8. **Izin INTERNET (Android release):** `android/app/src/main/AndroidManifest.xml` wajib memuat `<uses-permission android:name="android.permission.INTERNET"/>` — Flutter hanya menambahkannya otomatis pada build debug.
9. Build target: Android (APK/AAB) dan iOS. Build rilis: `flutter build apk --release`.

> Jalankan: `flutter pub get` → `dart run build_runner build` (Drift codegen) → `flutter run`.

### 8.1 Library native sqlite3 (penting untuk build)

Paket `sqlite3` (via Drift) secara default **mengunduh** `libsqlite3.<abi>.android.so` dari GitHub saat build — sering gagal pada jaringan tidak stabil (`HttpException: Connection closed`). KinTree mematikan unduhan itu lewat `pubspec.yaml`:
```yaml
hooks:
  user_defines:
    sqlite3:
      source: system   # pakai libsqlite3 bundel sqlite3_flutter_libs, tanpa unduh
      name: sqlite3
```
- **Android/iOS app:** library disuplai `sqlite3_flutter_libs` (sudah jadi dependensi) → build tidak butuh jaringan untuk sqlite3.
- **`flutter test` (host):** Windows perlu `sqlite3.dll` ditemukan di direktori kerja/PATH. Salin satu (mis. dari `…\Python\…\DLLs\sqlite3.dll`) ke root project (file di-`.gitignore`). Linux/macOS umumnya sudah punya `libsqlite3` sistem.
