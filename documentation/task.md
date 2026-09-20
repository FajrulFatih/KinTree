# Implementation Plan — KinTree

Daftar tugas implementasi bertahap, diturunkan dari [requirement.md](requirement.md) dan [design.md](design.md). Setiap tugas mereferensikan requirement terkait. Tandai `[x]` saat selesai.

> **Status (per 2026-06-27):** Seluruh Fase 0–10 (MVP) rampung, **plus** Fase 11 (ikon & distribusi), Fase 12 (redesign v2 "Warm Heritage"), dan Fase 13 (perbaikan pasca-uji di perangkat). `flutter analyze` bersih; **18 test** hijau. Kredensial via `.env` (flutter_dotenv). Auth **Email/Password saja** (Google Sign-In dihapus). Offline: UI baca dari Drift + **write-through** saat menulis. Hardening RLS/RPC + Storage (`migrations/0002`). Catatan operasional: aktifkan **Realtime** di Supabase untuk sinkron antar-perangkat; manifest Android wajib punya izin **INTERNET** untuk build release.

---

## Fase 0 — Setup Proyek & Fondasi

- [x] 0.1 Inisialisasi proyek Flutter (`flutter create`) + struktur direktori sesuai [structure.md](structure.md).
- [x] 0.2 Dependensi `pubspec.yaml`: supabase_flutter, flutter_riverpod, drift + drift_flutter, google_fonts, flutter_dotenv, flutter_image_compress, image_picker, intl. _(graphview terpasang tapi tak dipakai; google_sign_in tidak jadi dipakai.)_
- [x] 0.3 Buat project Supabase (gratis); salin `Project URL` & `anon key` → `supabase_config.dart` (via `--dart-define`).
- [x] 0.4 Jalankan skema SQL (tabel `families`, `family_members`, `members`, `relationships`) + policy RLS + RPC `join_family` di SQL Editor Supabase. _(NFR-2)_
- [x] 0.5 Init `main.dart`: `Supabase.initialize(...)`, setup Drift (SQLite) untuk cache, bungkus dengan `ProviderScope`. _(NFR-1)_
- [x] 0.6 Definisikan enum di `core/constants` (Gender, RelationshipType, RelationshipStatus) + tema dasar.

## Fase 1 — Autentikasi & Hak Akses _(FR-1)_

- [x] 1.1 `AuthRepository` di atas Supabase Auth (Email/Password, sign-out, `onAuthStateChange` stream).
- [x] 1.2 `authStateProvider` + auth gate untuk routing splash → login/home.
- [x] 1.3 UI Login & Register + validasi & penanganan error.
- [x] 1.4 ~~Integrasi Google OAuth~~ — **dihapus** (tidak berfungsi andal; auth Email/Password saja).

## Fase 2 — Grup Keluarga & Invite Code _(FR-2)_

- [x] 2.1 Buat `FamilyModel` + `FamilyRepository` (create family + daftarkan owner ke `family_members`; join via RPC `join_family`).
- [x] 2.2 Generator invite code unik (`core/utils`).
- [x] 2.3 UI Family Hub: buat grup baru / gabung grup. _(TC-001)_
- [x] 2.4 Simpan `family_id` aktif + provider grup aktif.

## Fase 3 — Manajemen Anggota (Nodes) _(FR-3)_

- [x] 3.1 Buat `MemberModel` (+ fromJson/toJson) sesuai skema tabel `members`.
- [x] 3.2 Buat `MemberRepository` (CRUD members + Realtime stream + tulis cache Drift).
- [x] 3.3 `membersStreamProvider` (Supabase Realtime) untuk grup aktif.
- [x] 3.4 UI Member Form (tambah/edit): nama, gender, tempat/tanggal lahir, status hidup, catatan.
- [x] 3.5 Upload foto: image_picker + kompresi (`flutter_image_compress`, 400px/JPEG 75%) → Supabase Storage bucket `member-photos`. _(NFR-4)_
- [x] 3.6 UI Member Detail (profil + aksi).

## Fase 4 — Manajemen Hubungan (Edges) _(FR-4 … FR-7)_

- [x] 4.1 Buat `RelationshipModel` + `RelationshipRepository` (CRUD + Realtime stream + cache Drift).
- [x] 4.2 `relationshipsStreamProvider` (Supabase Realtime) untuk grup aktif.
- [x] 4.3 UI Relationship Form: pilih tipe (SPOUSE / PARENT_BIOLOGICAL / PARENT_ADOPTIVE).
- [x] 4.4 Logika pernikahan ganda: buat dokumen SPOUSE terpisah + `marriageOrder`. _(FR-5, TC-003)_
- [x] 4.5 Logika perceraian: ubah `status` → `DIVORCED` tanpa memutus relasi anak. _(FR-6, TC-004)_
- [x] 4.6 Logika adopsi: `type: PARENT_ADOPTIVE` mempertahankan node di pohon utama. _(FR-7, TC-002)_

## Fase 5 — Graph Builder & Layout _(FR-8)_

- [x] 5.1 Entity `FamilyGraph` (membungkus `MemberModel`/`RelationshipModel` + helper `childrenOf`/`spousesOf`/`roots`). _(pengganti rencana awal `MemberNode`/`RelationshipEdge`.)_
- [x] 5.2 `familyGraphProvider` menggabungkan members + relationships dari cache menjadi `FamilyGraph`. _(pengganti `GraphBuilderService`.)_
- [x] 5.3 `LayoutService`: penempatan DFS — generasi (Y), penjajaran pasangan (X), percabangan anak. _(SDD §3.2)_

## Fase 6 — Visualisasi Pohon Interaktif _(FR-8)_

- [x] 6.1 Kanvas pohon (`CustomPainter` + `InteractiveViewer`) dengan `NodeCard`.
- [x] 6.2 `TreeEdgePainter`: garis kurva — kandung solid, adopsi putus-putus, pasangan ochre, cerai pudar + label "CERAI".
- [x] 6.3 Gestur pinch-to-zoom & drag-to-pan.
- [x] 6.4 Search bar → animasi kamera memusat ke node.

## Fase 7 — Kolaborasi & Sinkronisasi _(FR-9)_

- [x] 7.1 Provider sync (`_memberSyncProvider`, `_relationshipSyncProvider`) berlangganan Realtime → tulis ke Drift; UI baca dari Drift (`cache_repository.dart`).
- [x] 7.2 Rekonsiliasi server-wins: snapshot Realtime mengganti cache grup (`replaceMembers`/`replaceRelationships`); Realtime auto-reconnect saat kembali daring.

## Fase 8 — Keamanan & Optimasi Free Tier _(NFR-2, NFR-4)_

- [x] 8.1 RLS untuk semua tabel + hardening `search_path` pada fungsi `SECURITY DEFINER` + Storage RLS (`migrations/0002_security_hardening.sql`). Prosedur uji: `supabase/SECURITY.md` §2.
- [x] 8.2 RPC `create_family`/`join_family` divalidasi server-side (nama kosong ditolak, invite code dinormalkan/divalidasi). Prosedur uji: `supabase/SECURITY.md` §3.
- [x] 8.3 Panduan verifikasi NFR-4 (cache offline, kompresi, ukuran DB/bandwidth): `supabase/SECURITY.md` §5. _Eksekusi angka aktual menunggu deploy + data nyata._

## Fase 9 — Pengujian _(Test Cases SDD §5)_

- [x] 9.1 TC-001 — Auth + buat grup & isolasi RLS diverifikasi via `supabase/SECURITY.md` §2–3 (dijalankan pada DB live: **PASS - terisolasi**).
- [x] 9.2 TC-002 — Anak adopsi (`PARENT_ADOPTIVE`) tetap anak & di generasi bawah tanpa merusak pohon. `test/test_cases_test.dart`.
- [x] 9.3 TC-003 — Poligami: `computeNextMarriageOrder` 1→2 + dua cabang istri segenerasi. `test/test_cases_test.dart`.
- [x] 9.4 TC-004 — `DIVORCED` tidak memutus relasi anak; status tersimpan untuk gaya garis. `test/test_cases_test.dart`.
- [x] 9.5 TC-005 — 200 anggota dibaca dari cache Drift + bangun layout < 1 detik. `test/tc005_offline_performance_test.dart`.
- [x] 9.6 Unit test domain/cache + widget test `LoginScreen` (render + validasi). Total 13 test hijau.

## Fase 10 — Finalisasi

- [x] 10.1 Optimasi rendering: `RepaintBoundary` pada lapisan garis (`isComplex`) & tiap kartu node → pan/zoom tak memicu repaint global. _Pengukuran 60fps di device fisik direkomendasikan via DevTools._
- [x] 10.2 Polish: helper `friendlyError` (pesan ramah + deteksi luring) di auth/family/member/relationship; label aplikasi "KinTree" (Android/iOS/Web); deskripsi pubspec.
- [x] 10.3 README lengkap (`README.md`). Build debug terverifikasi (artifact `build/app/` + dijalankan di device). Build **release** gagal di sesi otomatis ini karena batasan environment (`Gradle: Unable to establish loopback connection`) — bukan cacat kode; jalankan `flutter build apk --release` di mesin lokal.

## Fase 11 — Ikon & Distribusi

- [x] 11.1 Ikon aplikasi "pohon keluarga bersimpul + hati" → `assets/icon/` + `flutter_launcher_icons` (Android adaptive, iOS, Web). Label app "KinTree".
- [x] 11.2 Panduan distribusi tanpa Play Store (APK via Drive/WhatsApp) di README; izin **INTERNET** ditambahkan ke manifest untuk build release.

## Fase 12 — Redesign v2 "Warm Heritage"

- [x] 12.1 Sistem tema baru: `app_colors.dart` (palet earthy) + `app_theme.dart` (Spectral serif + Plus Jakarta Sans via `google_fonts`).
- [x] 12.2 Reskin Login/Register, Family Hub (tiket undangan), Member Form (toggle gender), Member Detail (kartu Lahir/Wafat + chip hubungan).
- [x] 12.3 NodeCard foto-forward (avatar solid + inisial; wafat teredam + "Alm."; kartu selalu tampil, terpilih border hijau).
- [x] 12.4 Kanvas: garis kurva, **pita generasi GEN sticky** (`tree_gen_labels.dart`), **minimap** (`tree_minimap.dart`), tombol zoom, **legenda** (`tree_legend.dart`).
- [x] 12.5 Dialog konfirmasi gaya v2 (`confirm_dialog.dart`) untuk tambah/hapus/logout.

## Fase 13 — Perbaikan pasca-uji (di perangkat)

- [x] 13.1 **Detail anggota blank** → `_DateCards` dibungkus `IntrinsicHeight` (Row `stretch` di `ListView` melempar "infinite height"). Regresi: `member_detail_widget_test.dart`.
- [x] 13.2 **Add/Edit/Hapus tidak reflektif** → write-through ke cache Drift (`upsertMember`/`deleteMember`/`upsertRelationship`). Regresi: `cache_repository_test.dart`.
- [x] 13.3 **Snackbar global** (`app_snackbar.dart` + `scaffoldMessengerKey`): login, logout, tambah/edit/hapus anggota, tambah hubungan, error ramah.
- [x] 13.4 Tombol zoom dinaikkan agar tak tertutup FAB; tombol Google dihapus.
- [x] 13.5 Diagnosa lapangan terdokumentasi: error DNS (proyek paused/Realtime) & izin **INTERNET** pada release.

---

### Ringkasan Ketertelusuran

| Fase | Requirement | Test Case |
|------|-------------|-----------|
| 1 | FR-1 | — |
| 2 | FR-2 | TC-001 |
| 3 | FR-3 | — |
| 4 | FR-4..FR-7 | TC-002, TC-003, TC-004 |
| 5–6 | FR-8 | — |
| 7 | FR-9 | — |
| 8 | NFR-2, NFR-4 | — |
| 9–10 | NFR-3 + semua | TC-005 |
