# Product Requirements Document (PRD) & Software Design Document (SDD)
## Proyek: Aplikasi Silsilah Keluarga (KinTree)

Dokumen ini menggabungkan **Product Requirements Document (PRD)** dan **Software Design Document (SDD)** dengan pendekatan *Spec-Driven Development*. Fokus utama aplikasi adalah pencatatan silsilah keluarga besar secara kolaboratif, aman, dan mampu menangani berbagai kompleksitas hubungan keluarga menggunakan teknologi **Flutter** dan **Firebase (Free Tier)**.

---

# BAGIAN 1: PRODUCT REQUIREMENTS DOCUMENT (PRD)

## 1. Pendahuluan & Latar Belakang

Seiring berjalannya waktu, sejarah dan hubungan kekerabatan dalam sebuah keluarga besar sering kali terlupakan oleh generasi penerus. Dokumentasi konvensional berbasis kertas sangat rentan rusak dan sulit diakses secara bersama-sama. Aplikasi **KinTree** hadir sebagai solusi digital interaktif yang dirancang khusus untuk internal keluarga agar dapat mendokumentasikan, melacak, dan menjaga silsilah keluarga tetap hidup dan dapat diakses kapan saja secara kolaboratif.

### 1.1 Visi Produk

Menjadi repositori digital keluarga yang intim, mudah digunakan, dan mampu merekam sejarah keluarga secara akurat tanpa kehilangan detail hubungan yang kompleks.

### 1.2 Aturan Bisnis & Batasan Pengguna

- **Skala Internal:** Aplikasi ini tidak ditujukan untuk konsumsi publik secara luas, melainkan untuk kluster-kluster keluarga besar saja.
- **Kolaborasi Multi-User:** Anggota keluarga yang diberi akses dapat ikut serta menambahkan atau menyunting data silsilah secara *real-time*.
- **Efisiensi Biaya:** Memanfaatkan infrastruktur cloud gratisan (*Free Tier*) yang andal untuk meminimalkan biaya operasional keluarga.

---

## 2. Target Pengguna & Persona

1. **Representatif Keluarga (The Historian):** Anggota keluarga (biasanya generasi tua atau paruh baya) yang memiliki catatan fisik silsilah kuno dan ingin mendigitalisasikannya.
2. **Generasi Penerus (The Connector):** Generasi muda yang ingin mengetahui hubungan kekerabatan mereka dengan sepupu, paman, atau leluhur yang belum pernah mereka temui.

---

## 3. Lingkup Produk (Scope & MVP Features)

Aplikasi ini berfokus pada visualisasi pohon (graf) dan manajemen data relasi yang adaptif. Fitur utama yang wajib ada pada fase MVP meliputi:

### 3.1 Manajemen Pengguna & Hak Akses (Akses Tertutup)

- Login/Registrasi berbasis Email & Password atau Google Sign-In.
- Pembuatan "Grup Keluarga" baru atau bergabung ke "Grup Keluarga" yang sudah ada menggunakan kode undangan unik (*Invite Code*).

### 3.2 Manajemen Data Anggota Keluarga (Nodes)

- Pencatatan profil dasar: Nama Lengkap, Nama Panggilan, Jenis Kelamin, Tempat & Tanggal Lahir, Status Hidup (Jika meninggal: Tanggal Wafat), Foto Profil, dan Kontak/Catatan Ringkas.

### 3.3 Manajemen Hubungan Kompleks (Edges & Kasus Khusus)

Aplikasi harus dapat memetakan hubungan non-linier berikut:

- **Pernikahan Ganda / Poligami / Poliandri / Pernikahan Berulang:** Seorang individu dapat memiliki lebih dari satu pasangan (aktif maupun cerai).
- **Parsial/Perceraian:** Menandai status hubungan antar pasangan tanpa menghapus relasi anak-anak dari pernikahan tersebut.
- **Anak Angkat / Adopsi:** Membedakan secara visual dan struktural antara anak kandung (biologis) dan anak angkat/asuh, namun tetap mempertahankan garis keturunan dalam pohon silsilah.

### 3.4 Visualisasi Pohon Interaktif

- Kanvas interaktif yang mendukung gestur *Pinch-to-Zoom* dan *Drag-to-Pan*.
- Pencarian cepat nama anggota keluarga langsung memusatkan fokus kamera kanvas ke simpul (*node*) yang bersangkutan.

### 3.5 Berbagi & Kolaborasi Data

- Sinkronisasi data otomatis antar perangkat anggota keluarga yang berada dalam satu Grup Keluarga yang sama menggunakan database cloud.

---

## 4. Kebutuhan Non-Fungsional (Non-Functional Requirements)

- **Ketersediaan Data:** Menggunakan mekanisme penyimpanan lokal (*offline persistence*) sehingga silsilah tetap dapat dibaca saat sinyal buruk.
- **Keamanan & Privasi:** Data keluarga bersifat sangat sensitif. Data tidak boleh dapat diakses oleh pengguna di luar Grup Keluarga yang sah.
- **Performa Rendering:** Rendering pohon silsilah harus mulus (minimal 60fps) pada perangkat Android/iOS kelas menengah untuk silsilah hingga 5 generasi (>100 nodes).

---
---

# BAGIAN 2: SOFTWARE DESIGN DOCUMENT (SDD)

## 1. Arsitektur Sistem & Komponen Utama

Aplikasi dibangun menggunakan arsitektur *Client-Server* hibrida memanfaatkan ekosistem Firebase untuk memotong jalur pengembangan backend tradisional.

```
+-------------------------------------------------------------+
|                      FLUTTER CLIENT                         |
|  [Presentation Layer] -> [State Management (Riverpod)]      |
|  [Graph Rendering]    -> [GraphView / Custom Painter]       |
+-------------------------------------------------------------+
                              |
                     HTTPS / WSS (Stream)
                              |
+-------------------------------------------------------------+
|                      FIREBASE BACKEND                       |
|  [Auth]      -> Firebase Authentication                     |
|  [Database]  -> Cloud Firestore (NoSQL Document Store)      |
|  [Storage]   -> Firebase Storage (Foto Profil)              |
+-------------------------------------------------------------+
```

### 1.1 Frontend (Flutter Stack)

- **State Management:** Riverpod atau BLoC (untuk manajemen state yang terisolasi, *testable*, dan reaktif terhadap data stream Firestore).
- **Graph Rendering:** `GraphView` package atau implementasi `CustomPainter` berbasis algoritma *Buchheim-Walker* untuk tata letak pohon yang rapi.
- **Local Storage:** Bawaan `Firestore Offline Persistence` untuk caching data silsilah secara otomatis.

### 1.2 Backend & Cloud (Firebase Free Tier Configuration)

- **Firebase Authentication:** Mengelola autentikasi pengguna secara aman.
- **Cloud Firestore:** Database NoSQL utama dengan skema dokumen terstruktur untuk merepresentasikan struktur *Graph*.
- **Firebase Storage:** Menyimpan aset foto profil anggota keluarga dengan kompresi gambar otomatis di sisi klien sebelum diunggah untuk menghemat kuota gratis.

---

## 2. Model Data & Skema Database NoSQL (Cloud Firestore)

Karena struktur silsilah keluarga dengan kasus khusus (perceraian, adopsi, pernikahan ganda) tidak dapat direpresentasikan dengan struktur hierarki pohon biner biasa, database akan dirancang menggunakan pendekatan **Graf (Nodes & Edges)** yang dimodelkan ke dalam koleksi dokumen NoSQL.

### 2.1 Koleksi: `families`

Menyimpan data kelompok silsilah besar.

```json
// Path: /families/{familyId}
{
  "familyId": "FAM_98231_XYZ",
  "familyName": "Bani Sastro Wardoyo",
  "createdAt": "2026-06-24T12:00:00Z",
  "createdBy": "USER_UID_123"
}
```

### 2.2 Koleksi: `members`

Menyimpan data individu (Nodes) yang tergabung dalam suatu keluarga.

```json
// Path: /families/{familyId}/members/{memberId}
{
  "memberId": "MEM_001",
  "firstName": "Ahmad",
  "lastName": "Dahlan",
  "gender": "MALE",
  "birthPlace": "Surabaya",
  "birthDate": "1955-02-26",
  "isAlive": true,
  "deathDate": null,
  "photoUrl": "https://firebasestorage.googleapis.com/.../mem_001.jpg",
  "notes": "Sesepuh keluarga yang memegang catatan fisik awal.",
  "updatedAt": "2026-06-24T13:15:00Z"
}
```

> **Enum `gender`:** `MALE` | `FEMALE`

### 2.3 Koleksi: `relationships`

Menyimpan semua bentuk keterhubungan antar individu (Edges). Koleksi ini adalah kunci penyelesaian kasus khusus.

```json
// Path: /families/{familyId}/relationships/{relationshipId}
{
  "relationshipId": "REL_001",
  "fromMemberId": "MEM_001",
  "toMemberId": "MEM_002",
  "type": "SPOUSE",
  "status": "MARRIED",
  "marriageOrder": 1,
  "createdAt": "2026-06-24T13:20:00Z"
}
```

> **Enum `type`:** `SPOUSE` | `PARENT_BIOLOGICAL` | `PARENT_ADOPTIVE`  
> **Enum `status`:** `MARRIED` | `DIVORCED` *(hanya berlaku untuk `type: SPOUSE`)*  
> **`marriageOrder`:** Integer, menunjukkan urutan pernikahan ke-N pada entitas yang sama.

### 2.4 Penanganan Kasus Khusus dalam Skema Data

**Pernikahan Ganda (Poligami / Pernikahan Berulang)**

Jika `MEM_001` menikah dua kali, terbentuk dua dokumen relasi dengan `type: "SPOUSE"`:
- Dokumen 1 → `toMemberId: "MEM_002"`, `marriageOrder: 1`
- Dokumen 2 → `toMemberId: "MEM_003"`, `marriageOrder: 2`

**Perceraian**

Pada dokumen relasi ber-`type: "SPOUSE"`, field `status` diubah dari `"MARRIED"` menjadi `"DIVORCED"`. Relasi anak-anak tetap terjaga karena merujuk langsung ke entitas orang tua secara individu, bukan ke entitas pernikahan tunggal.

**Anak Angkat**

Menggunakan `type: "PARENT_ADOPTIVE"`. Algoritma rendering graf di Flutter akan membaca tipe ini dan menggambar garis putus-putus atau warna berbeda untuk membedakannya dari hubungan biologis (`PARENT_BIOLOGICAL`).

---

## 3. Spesifikasi Logika Bisnis & Algoritma Tata Letak UI

### 3.1 Resolusi Data untuk Rendering UI (Graph Builder)

Aplikasi melakukan kueri seluruh data dari sub-koleksi `members` dan `relationships` di bawah `familyId` yang aktif. Data kemudian dipetakan ke dalam struktur data objek lokal di Flutter:

```dart
class MemberNode {
  final String memberId;
  final String fullName;
  final String gender;
  // properti profil lainnya...
}

class RelationshipEdge {
  final String fromId;
  final String toId;
  final String type;   // SPOUSE | PARENT_BIOLOGICAL | PARENT_ADOPTIVE
  final String status; // MARRIED | DIVORCED
}
```

### 3.2 Algoritma Peletakan Simpul (Layouting Strategy)

Visualisasi silsilah tidak menggunakan struktur pohon hierarki murni karena adanya relasi menyamping (`SPOUSE`). Aturan penyusunan koordinat simpul pada layar:

1. **Generasi Axis (Y-Axis):** Urutkan anggota keluarga berdasarkan tingkat generasi dari leluhur tertua (Generasi 0) ke bawah (Generasi 1, 2, dst.). Tanggal lahir digunakan sebagai validator urutan internal generasi.
2. **Pasangan Axis (X-Axis Penjajaran):** Anggota dengan relasi `SPOUSE` diletakkan bersebelahan secara horizontal pada koordinat Y yang sama. Jika status `DIVORCED`, pasangan masa lalu diletakkan dengan jarak renggang tambahan.
3. **Penurunan Anak (Children Branching):** Garis vertikal ditarik dari titik tengah pasangan (`SPOUSE`) ke baris koordinat Y generasi di bawahnya, kemudian bercabang secara horizontal menuju masing-masing simpul anak.

---

## 4. Spesifikasi Keamanan & Batasan Firestore (Firebase Security Rules)

Untuk menjamin privasi data dan mencegah penyalahgunaan kuota *Free Tier*, aturan keamanan Firebase dikonfigurasi secara ketat. Pengguna hanya bisa membaca dan menulis data jika `familyId` mereka terdaftar dan memiliki hak akses grup yang sesuai.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /families/{familyId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null &&
        resource.data.createdBy == request.auth.uid;

      match /members/{memberId} {
        allow read, write: if request.auth != null &&
          exists(/databases/$(database)/documents/families/$(familyId));
      }

      match /relationships/{relationshipId} {
        allow read, write: if request.auth != null &&
          exists(/databases/$(database)/documents/families/$(familyId));
      }
    }
  }
}
```

### 4.1 Optimalisasi Free Tier (Mencegah Read/Write Berlebih)

- **Firestore Caching:** Aktifkan `cacheSizeBytes = FirestoreCacheSettings.CACHE_SIZE_UNLIMITED` pada inisialisasi SDK Flutter Firebase. Ini memastikan pembacaan ulang data yang tidak berubah tidak memakan kuota *Daily Read Limit* (50.000 baca/hari).
- **Kompresi Gambar Lokal:** Sebelum foto profil diunggah ke Firebase Storage, Flutter wajib melakukan kompresi menggunakan package `flutter_image_compress` menjadi maksimal lebar **400px** dengan format **JPEG kualitas 75%**. Ini menjaga penggunaan ruang penyimpanan di bawah batas gratis **5 GB**.

---

## 5. Rencana Pengujian Spek (Spec-Driven Test Cases)

| ID Tes | Komponen | Deskripsi Skenario Pengujian | Hasil yang Diharapkan |
|--------|----------|------------------------------|-----------------------|
| TC-001 | Auth | Registrasi user baru dan membuat kode undangan keluarga baru. | Dokumen baru terbentuk di koleksi `families`; user mendapatkan hak akses tulis. |
| TC-002 | Data | Input data anggota keluarga dengan status Adopsi. | Data tersimpan dengan `type: "PARENT_ADOPTIVE"` tanpa merusak pohon keturunan utama. |
| TC-003 | Data | Input pernikahan kedua (Poligami) pada entitas suami yang sama. | Terbentuk dua relasi `SPOUSE` dengan `marriageOrder` 1 dan 2; UI menampilkan dua cabang istri. |
| TC-004 | UI | Memasukkan status `DIVORCED` pada hubungan pasangan. | Garis relasi horizontal berubah style menjadi pudar dengan label "Cerai"; anak-anak tetap terhubung. |
| TC-005 | Performance | Memuat data silsilah dengan jumlah anggota > 150 orang secara luring. | Aplikasi memuat data dari cache lokal < 1 detik tanpa memicu kuota baca jaringan Firestore berlebih. |
