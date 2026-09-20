# Product Overview — KinTree

## Ringkasan Produk

**KinTree** adalah aplikasi silsilah keluarga (family tree) digital, kolaboratif, dan privat yang dirancang khusus untuk internal keluarga besar. Aplikasi memungkinkan anggota keluarga mendokumentasikan, melacak, dan menjaga sejarah serta hubungan kekerabatan tetap hidup dan dapat diakses kapan saja secara bersama-sama.

Dibangun di atas **Flutter** (multiplatform) dan **Supabase Free Tier** (100% gratis, tanpa kartu kredit), KinTree fokus pada visualisasi pohon (graf) interaktif dan manajemen relasi keluarga yang adaptif terhadap kasus-kasus kompleks (poligami, perceraian, adopsi).

Tampilan mengusung tema visual **"Warm Heritage"** — nuansa kertas/arsip keluarga (krem hangat, tinta cokelat, aksen hijau hutan) dengan font serif **Spectral** untuk nama/judul dan **Plus Jakarta Sans** untuk UI.

## Visi Produk

Menjadi repositori digital keluarga yang intim, mudah digunakan, dan mampu merekam sejarah keluarga secara akurat tanpa kehilangan detail hubungan yang kompleks.

## Masalah yang Diselesaikan

- Sejarah dan hubungan kekerabatan keluarga besar sering terlupakan generasi penerus.
- Dokumentasi konvensional berbasis kertas rentan rusak dan sulit diakses bersama.
- Tidak ada solusi digital privat yang mampu memetakan hubungan keluarga non-linier (poligami, cerai, adopsi) sekaligus.

## Target Pengguna & Persona

| Persona | Deskripsi | Kebutuhan Utama |
|---------|-----------|-----------------|
| **The Historian** (Representatif Keluarga) | Generasi tua/paruh baya yang memiliki catatan fisik silsilah kuno. | Mendigitalisasikan catatan, menjadi sumber kebenaran data. |
| **The Connector** (Generasi Penerus) | Generasi muda yang ingin tahu hubungannya dengan kerabat. | Menelusuri silsilah, menemukan koneksi keluarga. |

## Prinsip & Aturan Bisnis

- **Skala Internal/Tertutup:** Bukan untuk konsumsi publik luas, hanya untuk kluster keluarga besar. Akses melalui *invite code*.
- **Kolaborasi Multi-User Real-Time:** Anggota yang diberi akses dapat menambah/menyunting data silsilah secara *real-time*.
- **Efisiensi Biaya:** Memanfaatkan infrastruktur cloud gratis (Supabase Free Tier, tanpa kartu kredit) untuk meniadakan biaya operasional keluarga.
- **Privasi Mutlak:** Data keluarga sangat sensitif dan tidak boleh diakses pengguna di luar Grup Keluarga yang sah.

## Fitur Inti (sudah diimplementasikan)

1. **Manajemen Pengguna & Hak Akses** — Login/Registrasi **Email & Password** (Supabase Auth); buat/gabung Grup Keluarga via *invite code* (ditampilkan bergaya tiket).
2. **Manajemen Anggota Keluarga (Nodes)** — Profil: nama, panggilan, jenis kelamin, tempat/tanggal lahir, status hidup (+ tanggal wafat), foto (dikompres), catatan. Tambah/edit/hapus disertai dialog konfirmasi & notifikasi (snackbar).
3. **Manajemen Hubungan Kompleks (Edges)** — Pernikahan ganda/poligami (`marriage_order`), perceraian (status `DIVORCED`), adopsi (kandung vs angkat).
4. **Visualisasi Pohon Interaktif** — Kanvas dengan pinch-to-zoom, drag-to-pan, tombol zoom, **minimap**, **pita generasi (GEN I/II/III) yang selalu terlihat**, **legenda**, dan pencarian yang memusatkan kamera ke node.
5. **Detail & Profil** — Halaman profil dengan kartu Lahir/Wafat dan **chip hubungan yang bisa diketuk** (lompat antar anggota).
6. **Berbagi & Kolaborasi Data** — Perubahan langsung tampil di perangkat sendiri (write-through cache lokal); sinkronisasi real-time antar perangkat aktif bila Realtime diaktifkan di Supabase.

## Metrik Keberhasilan

- Sebuah keluarga dapat memetakan silsilah hingga 5 generasi (>100 node) tanpa kehilangan akurasi relasi.
- Kasus khusus (poligami, cerai, adopsi) terepresentasi dengan benar secara visual dan struktural.
- Biaya operasional tetap Rp 0 dalam batas Supabase Free Tier.

## Batasan (Out of Scope MVP)

- Distribusi/registrasi publik terbuka.
- Monetisasi atau tier berbayar.
- Integrasi ke layanan genealogi pihak ketiga.
