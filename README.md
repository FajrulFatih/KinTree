# 🌳 KinTree

Aplikasi **silsilah keluarga** yang kolaboratif, privat, dan offline-first untuk internal keluarga besar. Dibangun dengan **Flutter** + **Supabase Free Tier** (tanpa biaya, tanpa kartu kredit).

KinTree mampu memetakan hubungan keluarga yang kompleks — **poligami/pernikahan berulang**, **perceraian**, dan **anak angkat (adopsi)** — tanpa kehilangan akurasi garis keturunan.

---

## ✨ Fitur

- 🔐 **Autentikasi** Email & Password (Supabase Auth)
- 👨‍👩‍👧‍👦 **Grup Keluarga** dengan *invite code* untuk kolaborasi multi-user
- 🧑 **Profil anggota** lengkap + foto (dikompres otomatis)
- 🔗 **Relasi kompleks**: pasangan (poligami), orang tua kandung/angkat, status cerai
- 🌲 **Kanvas pohon interaktif**: pinch-to-zoom, drag-to-pan, pencarian fokus kamera
- 📡 **Sinkronisasi real-time** antar perangkat (Supabase Realtime)
- 📴 **Offline-first**: silsilah tetap terbaca tanpa koneksi (cache SQLite/Drift)

---

## 🏗️ Arsitektur

```
Flutter (Riverpod)
  ├─ presentation/   UI per fitur (auth, family, member, relationship, tree)
  ├─ providers/      state + stream (Supabase Realtime → Drift)
  ├─ domain/         FamilyGraph + LayoutService (algoritma tata letak)
  └─ data/
       ├─ models/        DTO ↔ PostgreSQL
       ├─ local/         Drift (SQLite) — cache offline
       └─ repositories/  Auth / Family / Member / Relationship / Cache
              │
              ▼
Supabase: Auth · PostgreSQL (RLS) · Storage · Realtime
```

Detail lengkap ada di folder [`documentation/`](documentation/) (product, requirement, tech, structure, design, task).

---

## 🚀 Menjalankan

### 1. Prasyarat
- Flutter SDK (stable) — diuji pada Flutter 3.41 / Dart 3.11
- Akun [Supabase](https://supabase.com) (gratis)

### 2. Siapkan backend Supabase
1. Buat project baru → salin **Project URL** & **anon key** (Project Settings → API).
2. Buka **SQL Editor**, jalankan berurutan:
   - [`supabase/migrations/0001_init.sql`](supabase/migrations/0001_init.sql) — tabel, RLS, RPC
   - [`supabase/migrations/0002_security_hardening.sql`](supabase/migrations/0002_security_hardening.sql) — hardening + Storage RLS
3. Buat **Storage bucket** bernama `member-photos`.
4. (Disarankan) aktifkan **Realtime** untuk tabel `members` & `relationships` (Database → Replication) agar tersinkron antar perangkat.

### 3. Konfigurasi kredensial
Salin template lalu isi:
```bash
cp .env.example .env
```
```env
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```
> `.env` di-`.gitignore` — jangan commit. Alternatif: `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

### 4. Jalankan
```bash
flutter pub get
flutter run
```
> Setelah mengubah `.env`, lakukan **full restart** (bukan hot reload).

---

## 🧪 Pengujian

```bash
flutter analyze          # statis, harus bersih
flutter test             # 18 test: domain, cache offline, test case SDD, widget
```

Pemetaan ke test case SDD §5 (TC-002…005) ada di [`test/`](test/). Verifikasi keamanan RLS (TC-001) di [`supabase/SECURITY.md`](supabase/SECURITY.md).

---

## 📦 Build rilis

```bash
flutter build apk --release          # Android
flutter build appbundle --release    # Android (Play Store)
flutter build ios --release          # iOS (perlu macOS/Xcode)
```

---

## 💰 Catatan Free Tier

- Foto dikompres (≤400px, JPEG 75%) → hemat Storage (batas 1 GB).
- UI baca dari cache lokal → hemat bandwidth (batas 5 GB/bulan) & kuota.
- ⚠️ Project Supabase gratis **pause setelah 7 hari tanpa aktivitas** — cukup buka sesekali.

## ⚠️ Batasan yang diketahui (MVP)
- **Penulisan butuh online** (read-offline, write-online); belum ada antrian mutasi offline.
- **Web** butuh setup worker WASM sqlite3 untuk Drift; target utama Android/iOS.
- **Foto** publik via URL bila bucket di-set Public (path UUID acak); untuk privasi penuh, set bucket Private + signed URL.
