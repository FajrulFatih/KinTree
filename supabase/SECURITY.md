# Verifikasi Keamanan KinTree (Fase 8)

Panduan menguji bahwa Row Level Security (RLS), RPC, dan Storage policy benar-benar mengisolasi data antar grup keluarga. Jalankan setelah menerapkan `migrations/0001_init.sql` dan `migrations/0002_security_hardening.sql`.

---

## 1. Prasyarat

Buat dua akun uji lewat aplikasi atau Dashboard → Authentication → Users:
- **User A** → `usera@test.com`
- **User B** → `userb@test.com`

Catat UID masing-masing (kolom di tabel Users).

---

## 2. Uji RLS via SQL Editor (impersonasi user)

Supabase SQL Editor berjalan sebagai `postgres` (bypass RLS). Untuk menguji RLS,
impersonasikan user dengan menyetel peran & klaim JWT di dalam transaksi:

```sql
-- Jalankan sebagai User A
begin;
  select set_config('role', 'authenticated', true);
  select set_config('request.jwt.claims',
    json_build_object('sub', '<UID_USER_A>', 'role', 'authenticated')::text, true);

  -- A membuat grup → harus berhasil
  select create_family('Keluarga A', 'AAA111');

  -- A melihat grupnya → harus muncul 1 baris
  select id, family_name from families;
commit;
```

```sql
-- Jalankan sebagai User B
begin;
  select set_config('role', 'authenticated', true);
  select set_config('request.jwt.claims',
    json_build_object('sub', '<UID_USER_B>', 'role', 'authenticated')::text, true);

  -- B TIDAK boleh melihat grup milik A → harus 0 baris
  select id, family_name from families;            -- EXPECT: kosong

  -- B mencoba membaca anggota grup A → harus 0 baris
  select * from members where family_id = '<FAMILY_ID_A>';  -- EXPECT: kosong

  -- B mencoba menyisipkan anggota ke grup A → harus DITOLAK
  insert into members (family_id, first_name, gender)
  values ('<FAMILY_ID_A>', 'Penyusup', 'MALE');    -- EXPECT: error RLS
rollback;
```

### Hasil yang diharapkan (TC terkait)
| Skenario | Hasil benar |
|----------|-------------|
| B membaca `families` milik A | 0 baris |
| B membaca `members`/`relationships` grup A | 0 baris |
| B `insert` ke grup A | Ditolak (`new row violates row-level security`) |
| A membaca grupnya sendiri | Tampil |

---

## 3. Uji RPC `join_family` (8.2)

```sql
-- Sebagai User B, gabung ke grup A pakai invite code yang benar
begin;
  select set_config('role', 'authenticated', true);
  select set_config('request.jwt.claims',
    json_build_object('sub', '<UID_USER_B>', 'role', 'authenticated')::text, true);

  select join_family('AAA111');   -- EXPECT: mengembalikan baris grup A

  -- Setelah join, B kini boleh melihat anggota grup A
  select count(*) from members where family_id = '<FAMILY_ID_A>';  -- EXPECT: >= 0 tanpa error
commit;
```

```sql
-- Kode salah harus gagal
select join_family('SALAH9');     -- EXPECT: error 'Kode undangan tidak valid'
```

---

## 4. Uji Storage policy (foto)

- Bucket `member-photos`, path foto = `<familyId>/<memberId>.jpg`.
- **Tulis:** dari aplikasi, login sebagai anggota grup → unggah foto berhasil; login sebagai non-anggota lalu coba unggah ke folder grup lain → ditolak.
- **Baca:** jika bucket **Private**, hanya anggota yang bisa mengakses (signed URL); jika **Public**, baca via URL terbuka (lihat catatan di `0002_security_hardening.sql`).

---

## 5. Verifikasi Optimasi Free Tier (NFR-4)

| Aspek | Cara verifikasi | Target |
|-------|-----------------|--------|
| **Pembacaan jaringan ditekan** | Buka grup → matikan jaringan → silsilah tetap tampil (dibaca dari Drift). | Tidak ada kueri jaringan untuk membaca ulang. |
| **Kompresi foto** | Unggah foto besar → cek ukuran objek di Storage. | ≤ ~50–100 KB (lebar 400px, JPEG 75%). |
| **Ukuran DB** | Dashboard → Database → Usage. | < 500 MB (jauh untuk skala keluarga). |
| **Bandwidth** | Dashboard → Usage. | < 5 GB/bulan. |

---

## 6. Checklist ringkas

- [ ] `0002_security_hardening.sql` diterapkan tanpa error.
- [ ] User B tidak dapat membaca/menulis data grup A (bagian 2).
- [ ] `join_family` menolak kode salah, menerima kode benar (bagian 3).
- [ ] Non-anggota tidak dapat mengunggah foto ke folder grup lain (bagian 4).
- [ ] Silsilah tetap terbaca saat luring (bagian 5).
