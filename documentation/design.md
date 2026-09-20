# Design — KinTree

Dokumen desain teknis & UX yang menjabarkan *bagaimana* requirement diwujudkan. Diturunkan dari SDD bagian arsitektur, model data, dan algoritma tata letak.

---

## 1. Desain Arsitektur Komponen

```
Presentation (Screens/Widgets/Painters)
        │  watch / read
        ▼
Riverpod Providers
   ├─ membersStreamProvider / relationshipsStreamProvider  (baca dari Drift)
   ├─ _memberSyncProvider / _relationshipSyncProvider       (Supabase .stream() → Drift)
   ├─ familyGraphProvider (FamilyGraph)  →  treeLayoutProvider (TreeLayout)
        │
        ▼
Repositories (Auth / Family / Member / Relationship / Cache)
        │
        ├──► Supabase (Auth · PostgreSQL/RLS · Storage · Realtime)
        └──► SQLite lokal (Drift) — sumber baca UI
```

- **UI baca dari cache:** kanvas & layar membaca dari **Drift** (lewat `CacheRepository`), bukan langsung jaringan → mulus & tahan luring.
- **Sinkron server → cache:** `_memberSyncProvider`/`_relationshipSyncProvider` berlangganan `client.from(...).stream(...)` lalu menulis snapshot ke Drift (server-wins).
- **Write-through:** setiap tulis (tambah/edit/hapus) → Supabase **lalu langsung ke Drift** → UI ter-update seketika tanpa menunggu Realtime.
- **Umpan balik:** `showAppSnack()` (messenger global di `main.dart`) menampilkan notifikasi sukses/gagal lintas-navigasi.
- **Pemisahan tanggung jawab:** transformasi graf (`FamilyGraph` + `LayoutService`) terpisah dari akses data.

---

## 2. Desain Data & Pemetaan ke Objek Lokal

Saat sebuah `family_id` aktif, baris `members` & `relationships` dipetakan ke `MemberModel`/`RelationshipModel`, lalu dibungkus oleh entity **`FamilyGraph`** (tanpa kelas node/edge terpisah):

```dart
class FamilyGraph {
  final List<MemberModel> members;
  final List<RelationshipModel> relationships;

  MemberModel? memberById(String id);
  List<String> childrenOf(String parentId);   // PARENT_* dari parentId
  List<String> spousesOf(String memberId);    // SPOUSE
  List<MemberModel> get roots;                 // tanpa orang tua
}
```

`LayoutService.build(graph)` menghasilkan `TreeLayout` (posisi tiap node, generasi, ukuran kanvas) yang siap dirender painter & kartu node.

---

## 3. Algoritma Tata Letak Simpul (Layouting Strategy)

Karena adanya relasi menyamping (`SPOUSE`), tata letak bukan pohon hierarki murni:

1. **Generasi Axis (Y):** akar (tanpa orang tua) di generasi 0; tiap anak = generasi orang tua + 1. `y = generasi × stepY`.
2. **Pasangan Axis (X):** pasangan `SPOUSE` ditempatkan bersebelahan; orang tua dipusatkan di atas rentang anak-anaknya.
3. **Penurunan Anak (Branching):** garis kurva-S dari sisi bawah node orang tua ke sisi atas node anak.

**Implementasi nyata:** `LayoutService` melakukan penempatan **rekursif (DFS)** sendiri — anak ditempatkan lebih dulu, orang tua dipusatkan, pasangan ditaruh di sebelah; bukan paket `graphview` maupun algoritma *Buchheim-Walker*. Rendering memakai `CustomPainter` (`TreeEdgePainter` untuk garis, `TreeBandPainter` untuk pita generasi) + widget `NodeCard` ber-`Positioned`, semua di dalam `InteractiveViewer`.

**Garis turunan = palang silsilah klasik.** `TreeEdgePainter` mengelompokkan anak berdasarkan **set orang tua**. Untuk tiap kelompok: batang turun dari **titik tengah garis pernikahan** pasangan (atau bawah node orang tua tunggal) ke **palang horizontal**, lalu "tetesan" ke tiap anak. Satu anak yang punya dua orang tua → **satu** garis turunan (bukan dua). Anak dari satu pasangan yang sama otomatis menggantung pada palang yang sama (saudara terlihat sebagai satu kelompok).

---

## 4. Penanganan Kasus Khusus (Desain Visual & Struktural)

| Kasus | Struktur Data | Representasi Visual |
|-------|---------------|---------------------|
| **Poligami / Nikah Berulang** | Dua+ baris `SPOUSE` dengan `marriage_order` 1,2,… | Beberapa cabang pasangan dari satu node. |
| **Perceraian** | `status: DIVORCED` pada baris `SPOUSE` | Garis horizontal pudar + label "Cerai"; anak tetap terhubung. |
| **Anak Angkat** | `type: PARENT_ADOPTIVE` | Garis putus-putus / warna berbeda dari `PARENT_BIOLOGICAL`; node anak tetap di pohon utama. |

> Kunci desain: anak merujuk ke **baris orang tua individu** (via `from_member_id`), bukan ke entitas pernikahan tunggal — sehingga perceraian/perubahan pasangan tidak memutus garis keturunan.

**Anak ke pasangan & saudara (tanpa ubah skema):** anak tetap disimpan sebagai dua edge `PARENT` (ke tiap orang tua). Form menambah anak menyediakan pilihan "orang tua kedua" agar kedua edge dibuat sekaligus; `TreeEdgePainter` lalu menggambar **satu** turunan (palang) dari titik tengah pasangan. **Saudara** tidak disimpan sebagai edge khusus — `RelationshipRepository.siblingEdgesFrom` menyalin edge orang tua anggota acuan ke saudara baru, sehingga keduanya berbagi orang tua dan otomatis menggantung pada palang yang sama.

---

## 5. Desain UX / Alur Layar

### 5.1 Peta Layar
1. **Auth Gate** (`auth_gate.dart`) → cek sesi Supabase.
2. **Login / Register** → **Email/Password** (judul serif, toggle lihat sandi; tanpa Google).
3. **Family Hub** → kartu grup (avatar inisial) + **kode undangan bergaya tiket** dengan tombol salin; dialog logout.
4. **Tree Canvas (utama)** → kanvas pohon + search pill + tombol kode, **pita generasi sticky**, **minimap**, **tombol zoom**, **legenda**.
5. **Member Detail** → avatar solid, kartu Lahir/Wafat, **chip hubungan tap**, aksi edit/hapus (dialog konfirmasi) + FAB tambah relasi.
6. **Member Form** → tambah/edit anggota (foto + kompresi, **toggle gender**, tanggal, switch hidup); dialog "Tambah anggota baru?".
7. **Relationship Form** → jenis: **Pasangan / Anak (kandung) / Anak (angkat) / Orang tua (kandung) / Orang tua (angkat) / Saudara**. Hubungan bisa ditambah dari arah mana pun (orang tua→anak **atau** anak→orang tua). Untuk *Anak/Orang tua*, ada pilihan **"orang tua kedua (pasangan)"** sehingga anak langsung terhubung ke kedua orang tua. *Saudara* = menyalin orang tua anggota acuan; `marriage_order` otomatis untuk pasangan.

### 5.2 Interaksi Kanvas
- **Pinch-to-zoom**, **drag-to-pan**, tombol **+/−/fokus** (kanan bawah, di atas FAB).
- **Search** nama → kamera memusat ke node target (sorot border hijau).
- **Pita generasi "GEN I/II/III"** menempel di tepi kiri layar (overlay), selalu terlihat saat pan/zoom.
- **Minimap** (kiri bawah) + **kotak viewport** yang bergerak.
- Tap node → buka Member Detail.

### 5.3 Komponen UI Kunci
- **NodeCard** (`node_card.dart`): kartu putih + border (terpilih = hijau); avatar lingkaran solid warna gender + inisial putih (atau foto); wafat = avatar teredam + tag "Alm.".
- **TreeEdgePainter**: pasangan menikah solid (ochre), cerai pudar putus-putus + label "CERAI"; turunan = **palang** (batang+palang+tetesan) — kandung solid, adopsi putus-putus (taupe). Menerima `FamilyGraph` (pakai `parentEdgesOf`/`areSpouses`).
- **TreeBandPainter** + **TreeGenLabels** (sticky), **TreeMinimap**, **TreeLegend** (bottom sheet).
- **confirm_dialog.dart**: dialog konfirmasi (badge ikon, judul serif, body rich, tombol Batal + aksi) untuk tambah/hapus/logout.
- **app_snackbar.dart**: notifikasi global (login, logout, tambah/edit/hapus, error ramah).

---

## 6. Pertimbangan Desain Non-Fungsional

- **Offline-first:** UI membaca dari cache SQLite (Drift); penulisan write-through ke cache → tampil seketika; Realtime/restart merekonsiliasi (server-wins).
- **Performa:** `RepaintBoundary` pada lapisan garis (`isComplex`) & tiap kartu node agar pan/zoom tidak memicu repaint global; target 60fps untuk >100 node (TC-005: 200 node < 1 detik dari cache).
- **Hemat kuota:** kompresi foto sisi klien (400px, JPEG 75%) sebelum unggah; baca dari cache lokal untuk menekan bandwidth.
- **Privasi:** seluruh akses tunduk pada Row Level Security (RLS) PostgreSQL; tidak ada data lintas-grup.

---

## 7. Desain Keamanan

Lihat policy RLS lengkap di [tech.md](tech.md) §5. Prinsip:
- Hanya pengguna terautentikasi yang dapat mengakses.
- Akses data dibatasi pada keanggotaan grup keluarga via tabel `family_members` (fungsi `is_family_member`).
- Kolaborasi multi-user sudah tertangani by design: setiap anggota yang join via invite code masuk ke `family_members` sehingga RLS mengizinkannya membaca/menulis data grup.
