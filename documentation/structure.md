# Project Structure — KinTree

Konvensi organisasi kode untuk aplikasi Flutter KinTree. Mengikuti pemisahan layer (presentation / domain / data) yang selaras dengan state management reaktif dan stream Supabase Realtime.

---

## 1. Struktur Direktori (Usulan)

```
KinTree/
├── documentation/              # Spec-driven docs (product, requirement, tech, structure, design, task)
├── lib/
│   ├── main.dart               # Init dotenv + locale 'id' + Supabase + ProviderScope; messenger global
│   │
│   ├── core/
│   │   ├── config/             # supabase_config.dart (URL & anon key dari .env / --dart-define)
│   │   ├── constants/          # enums.dart (Gender, RelationshipType, RelationshipStatus)
│   │   ├── theme/              # app_colors.dart (palet Warm Heritage), app_theme.dart (Spectral/Jakarta)
│   │   └── utils/              # app_snackbar.dart (messenger global), error_message.dart (friendlyError)
│   │
│   ├── data/
│   │   ├── local/              # app_database.dart (Drift) + app_database.g.dart (generated)
│   │   ├── models/             # family_model, member_model, relationship_model (fromMap/toInsertMap)
│   │   └── repositories/       # auth, family, member, relationship + cache_repository (Drift↔model, write-through)
│   │
│   ├── domain/
│   │   ├── entities/           # family_graph.dart (FamilyGraph: members+relationships+adjacency)
│   │   └── services/           # layout_service.dart (penempatan generasi/pasangan/anak)
│   │
│   ├── providers/              # supabase_providers, family_providers, graph_providers (sync + write-through)
│   │
│   └── presentation/
│       ├── auth/               # auth_gate, login_screen, register_screen
│       ├── family/             # family_hub_screen (kartu grup + tiket invite)
│       ├── member/             # member_form_screen, member_detail_screen (chip hubungan)
│       ├── relationship/       # relationship_form_screen
│       ├── tree/               # tree_screen, tree_edge_painter, tree_band_painter,
│       │                       #   tree_gen_labels (sticky), tree_minimap, tree_legend
│       └── widgets/            # node_card, async_button, confirm_dialog
│
├── assets/icon/                # icon_full.png, icon_foreground.png (flutter_launcher_icons)
├── supabase/                   # migrations/0001_init.sql, 0002_security_hardening.sql, SECURITY.md
├── test/                       # Unit & widget test
├── .env                        # Kredensial Supabase (gitignored) — .env.example sebagai template
├── pubspec.yaml
└── README.md
```

---

## 2. Pemetaan Layer

| Layer | Tanggung Jawab | Contoh |
|-------|----------------|--------|
| **Presentation** | Tampilan & interaksi pengguna | Screens, widgets, painter kanvas |
| **Providers (State)** | Jembatan reaktif UI ↔ data + sinkronisasi | `membersStreamProvider`, `treeLayoutProvider`, `_memberSyncProvider` |
| **Domain** | Logika murni & transformasi graf | `FamilyGraph` (entity), `LayoutService` |
| **Data** | Akses Supabase + cache Drift | Repositories, models, `AppDatabase`, `CacheRepository` |

**Aliran baca:** Supabase `.stream()` → `CacheRepository` (Drift) → Provider → UI (UI selalu baca dari Drift).
**Aliran tulis:** UI → Repository → Supabase **lalu write-through** → `CacheRepository` (Drift) → UI ter-update seketika.

---

## 3. Konvensi Penamaan

| Elemen | Konvensi | Contoh |
|--------|----------|--------|
| File Dart | `snake_case.dart` | `member_repository.dart` |
| Kelas | `PascalCase` | `MemberModel`, `FamilyGraph`, `LayoutService` |
| Variabel/fungsi | `camelCase` | `marriageOrder`, `buildGraph()` |
| Konstanta/enum | `PascalCase` enum, `UPPER_CASE` nilai sesuai data | `RelationshipType.spouse` ↔ `"SPOUSE"` |
| Provider | akhiran `Provider` | `familyMembersProvider` |
| Kolom DB | `snake_case` | `from_member_id`, `marriage_order` |
| Primary key | `uuid` (`gen_random_uuid()`) | `id` |

---

## 4. Pemetaan Tabel PostgreSQL ke Kode

| Tabel Supabase | Model (data) | Cache Drift |
|----------------|--------------|-------------|
| `families` | `FamilyModel` | — |
| `family_members` | _(dikelola via RPC; tak ada model khusus)_ | — |
| `members` | `MemberModel` | `CachedMembers` |
| `relationships` | `RelationshipModel` | `CachedRelationships` |

> Tidak ada kelas `MemberNode`/`RelationshipEdge` terpisah — `FamilyGraph` (domain) membungkus `MemberModel`/`RelationshipModel` langsung dan menyediakan helper (`childrenOf`, `spousesOf`, `roots`); `LayoutService` menghitung posisi.

---

## 5. Prinsip Organisasi

- **Feature-first di presentation, layer-first di data/domain** — UI dikelompokkan per fitur; logika & data dikelompokkan per tanggung jawab teknis.
- **Single source of truth** — PostgreSQL (Supabase) adalah sumber kebenaran; SQLite lokal hanya cache; UI tidak menyimpan state ganda.
- **Repository abstraksi Supabase** — UI/Provider tidak memanggil SupabaseClient langsung, selalu lewat repository agar *testable*.
- **Test mirror** — struktur `test/` mengikuti `lib/`.
