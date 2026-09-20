# Requirements — KinTree

Dokumen ini menjabarkan kebutuhan fungsional (FR) dan non-fungsional (NFR) aplikasi KinTree, diturunkan dari PRD & SDD. Format menggunakan user story + kriteria penerimaan (EARS-style) agar dapat diuji.

---

## 1. Kebutuhan Fungsional (Functional Requirements)

### FR-1 — Autentikasi & Manajemen Akun

**User Story:** Sebagai anggota keluarga, saya ingin masuk dengan akun saya, agar data keluarga hanya dapat diakses pihak yang sah.

**Kriteria Penerimaan:**
- KETIKA pengguna mendaftar/masuk, SISTEM HARUS mendukung **Email & Password** (Supabase Auth). _(Catatan: Google Sign-In sempat dirancang namun **dihapus** dari implementasi.)_
- KETIKA autentikasi berhasil, SISTEM HARUS membuat/menggunakan sesi pengguna berbasis Supabase Auth dan menampilkan notifikasi "Berhasil masuk".
- KETIKA pengguna keluar (logout), SISTEM HARUS mengakhiri sesi dan menampilkan notifikasi "Berhasil keluar".
- JIKA kredensial tidak valid, MAKA SISTEM HARUS menolak akses dan menampilkan pesan kesalahan yang ramah (mendeteksi kondisi luring).

### FR-2 — Grup Keluarga & Invite Code

**User Story:** Sebagai Historian, saya ingin membuat Grup Keluarga dan mengundang kerabat, agar kami dapat berkolaborasi.

**Kriteria Penerimaan:**
- KETIKA pengguna membuat Grup Keluarga baru, SISTEM HARUS menyisipkan baris di tabel `families` dengan `created_by` = UID pengguna, dan mendaftarkannya ke `family_members` sebagai `owner`.
- KETIKA Grup dibuat, SISTEM HARUS menghasilkan *invite code* unik.
- KETIKA pengguna memasukkan *invite code* valid, SISTEM HARUS menambahkannya ke `family_members` (via RPC `join_family`) dengan hak akses tulis.
- JIKA *invite code* tidak valid, MAKA SISTEM HARUS menolak permintaan bergabung.

### FR-3 — Manajemen Anggota Keluarga (Nodes)

**User Story:** Sebagai anggota, saya ingin mencatat data individu keluarga, agar profil setiap orang terdokumentasi.

**Kriteria Penerimaan:**
- SISTEM HARUS menyimpan field: Nama Lengkap, Nama Panggilan, Jenis Kelamin (`MALE`/`FEMALE`), Tempat Lahir, Tanggal Lahir, Status Hidup (`isAlive`), Tanggal Wafat (opsional), Foto Profil, Catatan.
- KETIKA `isAlive` = false, SISTEM HARUS mengizinkan pengisian `deathDate`.
- KETIKA data anggota disimpan, SISTEM HARUS menulis ke tabel `members` (dengan `family_id`), memperbarui `updated_at`, dan **menulis-balik ke cache lokal (write-through)** agar pohon ter-update seketika.
- KETIKA menambah anggota baru, SISTEM HARUS menampilkan dialog konfirmasi lalu notifikasi sukses; KETIKA mengedit/menghapus, SISTEM HARUS menampilkan notifikasi sukses yang sesuai.

### FR-4 — Manajemen Hubungan (Edges)

**User Story:** Sebagai anggota, saya ingin menghubungkan individu, agar struktur silsilah terbentuk.

**Kriteria Penerimaan:**
- SISTEM HARUS mendukung `type`: `SPOUSE`, `PARENT_BIOLOGICAL`, `PARENT_ADOPTIVE`.
- SISTEM HARUS menyimpan relasi di tabel `relationships` dengan `from_member_id`, `to_member_id`, `type`.
- SISTEM HARUS bisa menambah hubungan dari **arah mana pun**: menambah **anak** dari orang tua, **atau** menambah **orang tua** dari anak (edge `PARENT` tetap orang tua→anak).
- KETIKA menambah **anak/orang tua**, SISTEM HARUS menyediakan pilihan **orang tua kedua (pasangan)**; jika dipilih, SISTEM HARUS membuat edge `PARENT` ke **kedua** orang tua sekaligus.
- KETIKA anak terhubung ke pasangan, UI HARUS menggambar **satu garis turunan** (palang silsilah) dari titik tengah pasangan — bukan dua garis terpisah.

### FR-5 — Pernikahan Ganda / Poligami / Pernikahan Berulang

**User Story:** Sebagai Historian, saya ingin mencatat lebih dari satu pasangan untuk satu orang, agar realita keluarga terekam.

**Kriteria Penerimaan:**
- KETIKA satu individu menikah lebih dari sekali, SISTEM HARUS membuat baris `SPOUSE` terpisah untuk tiap pasangan.
- SISTEM HARUS menyimpan `marriage_order` (integer) yang menunjukkan urutan pernikahan ke-N.
- UI HARUS menampilkan setiap pasangan sebagai cabang terpisah.

### FR-6 — Perceraian

**User Story:** Sebagai anggota, saya ingin menandai pasangan yang bercerai, tanpa menghapus relasi anak.

**Kriteria Penerimaan:**
- KETIKA status pasangan bercerai, SISTEM HARUS mengubah `status` baris `SPOUSE` dari `MARRIED` menjadi `DIVORCED`.
- SISTEM HARUS mempertahankan relasi anak (karena anak merujuk ke orang tua individu, bukan ke entitas pernikahan).
- UI HARUS menggambar garis relasi pasangan bercerai dengan gaya berbeda (pudar) + label "Cerai".

### FR-7 — Anak Angkat / Adopsi

**User Story:** Sebagai anggota, saya ingin membedakan anak kandung dan anak angkat, agar garis keturunan tetap akurat.

**Kriteria Penerimaan:**
- KETIKA anak adalah hasil adopsi, SISTEM HARUS menggunakan `type: PARENT_ADOPTIVE`.
- UI HARUS menggambar garis adopsi berbeda (mis. putus-putus / warna berbeda) dari `PARENT_BIOLOGICAL`.
- SISTEM HARUS tetap mempertahankan node anak dalam pohon keturunan utama.

### FR-8 — Visualisasi Pohon Interaktif

**User Story:** Sebagai Connector, saya ingin menjelajah pohon silsilah secara visual, agar mudah memahami hubungan.

**Kriteria Penerimaan:**
- SISTEM HARUS menyediakan kanvas yang mendukung *pinch-to-zoom*, *drag-to-pan*, dan tombol zoom (+/−/fokus).
- KETIKA pengguna mencari nama, SISTEM HARUS memusatkan kamera kanvas ke node yang bersangkutan.
- SISTEM HARUS menata simpul berdasarkan generasi (Y-axis), pasangan (X-axis), dan percabangan anak.
- SISTEM HARUS menampilkan **label generasi (GEN I/II/III) yang selalu terlihat** di tepi kiri layar, **minimap**, dan **legenda** simbol garis/gender.

### FR-9 — Kolaborasi & Sinkronisasi

**User Story:** Sebagai anggota, saya ingin perubahanku langsung tampil dan, bila memungkinkan, perubahan kerabat lain ikut muncul.

**Kriteria Penerimaan:**
- KETIKA pengguna menulis data, SISTEM HARUS langsung memperbarui tampilan lokal melalui write-through ke cache (tidak menunggu jaringan/Realtime).
- KETIKA Supabase Realtime **diaktifkan** pada tabel `members`/`relationships`, SISTEM HARUS menyinkronkan perubahan ke perangkat anggota lain yang aktif. _(Realtime perlu diaktifkan manual di dashboard Supabase; tanpa itu, perangkat lain melihat perubahan saat membuka ulang aplikasi.)_

### FR-10 — Hubungan Saudara (berbagi orang tua)

**User Story:** Sebagai anggota, saya ingin menautkan dua orang sebagai saudara, agar mereka tersusun di bawah orang tua yang sama.

**Kriteria Penerimaan:**
- KETIKA pengguna menambah **saudara** dari anggota acuan X, SISTEM HARUS **menyalin** semua edge orang tua X (dengan tipe yang sama) ke saudara baru — saudara = berbagi orang tua, bukan tipe relasi tersendiri.
- JIKA X belum punya orang tua tercatat, MAKA SISTEM HARUS memberi tahu dan menolak (minta menambah orang tua dulu).
- HASIL: saudara otomatis menggantung pada palang turunan yang sama di pohon.

---

## 2. Kebutuhan Non-Fungsional (Non-Functional Requirements)

### NFR-1 — Ketersediaan Data (Offline)
- SISTEM HARUS menyimpan salinan silsilah ke cache lokal SQLite (Drift) sehingga silsilah tetap dapat dibaca saat sinyal buruk/tanpa jaringan.
- UI HARUS membaca dari cache lokal sebagai sumber tampilan; penulisan menulis-balik ke cache (write-through) dan Realtime/restart melakukan rekonsiliasi (server-wins).

### NFR-2 — Keamanan & Privasi
- SISTEM HARUS menerapkan Row Level Security (RLS) PostgreSQL sehingga data hanya bisa diakses anggota grup yang sah (lewat tabel `family_members`).
- Pengguna di luar Grup Keluarga TIDAK BOLEH membaca atau menulis data grup tersebut.

### NFR-3 — Performa Rendering
- Rendering pohon HARUS mulus (target 60fps) pada perangkat Android/iOS kelas menengah untuk silsilah hingga 5 generasi (>100 node).

### NFR-4 — Efisiensi Free Tier (Supabase, tanpa kartu kredit)
- SISTEM HARUS membaca dari cache lokal SQLite lebih dulu dan hanya menyinkronkan delta untuk menekan bandwidth (batas 5 GB/bulan).
- SISTEM HARUS mengompres foto profil di sisi klien (maks lebar 400px, JPEG kualitas 75%) sebelum unggah agar tetap di bawah batas 1 GB Storage.
- Penggunaan HARUS menjaga ukuran database di bawah 500 MB dan menghindari *pause* proyek (akses berkala) sesuai batas Free Tier.

---

## 3. Ketertelusuran (Traceability)

| Req | Sumber PRD/SDD | Test (file) |
|-----|----------------|-------------|
| FR-1 | PRD §3.1 | `login_screen_widget_test.dart`; RLS via `supabase/SECURITY.md` (TC-001) |
| FR-2 | PRD §3.1 | `supabase/SECURITY.md` §2–3 (TC-001) |
| FR-3 | PRD §3.2 | `member_detail_widget_test.dart`, `cache_repository_test.dart` (write-through add/edit/delete) |
| FR-7 | PRD §3.3, SDD §2.4 | `test_cases_test.dart` (TC-002) |
| FR-5 | PRD §3.3, SDD §2.4 | `test_cases_test.dart` (TC-003) |
| FR-6 | PRD §3.3, SDD §2.4 | `test_cases_test.dart` (TC-004) |
| FR-8 | PRD §3.4, SDD §3.2 | `tree_screen_widget_test.dart`, `widget_test.dart` (layout) |
| NFR-1, NFR-3, NFR-4 | PRD §4, SDD §4.1 | `tc005_offline_performance_test.dart` (TC-005) |

> Total **18 test** hijau (`flutter test`); `flutter analyze` tanpa isu.
