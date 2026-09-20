import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';
import '../data/models/member_model.dart';
import '../data/models/relationship_model.dart';
import '../data/repositories/cache_repository.dart';
import '../domain/entities/family_graph.dart';
import '../domain/services/layout_service.dart';
import 'family_providers.dart';
import 'supabase_providers.dart';

/// Database lokal (Drift) — cache offline.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return CacheRepository(ref.watch(databaseProvider));
});

/// Sinkronisasi server → cache untuk anggota.
///
/// Berlangganan stream Realtime Supabase dan menulis tiap snapshot ke Drift
/// (server-wins). Saat luring stream tak emit, tapi cache tetap utuh; saat
/// daring kembali, Realtime reconnect dan menimpa cache otomatis.
final _memberSyncProvider = Provider<void>((ref) {
  final familyId = ref.watch(activeFamilyProvider);
  if (familyId == null) return;
  final cache = ref.watch(cacheRepositoryProvider);
  final sub = ref
      .watch(memberRepositoryProvider)
      .watchMembers(familyId)
      .listen((members) => cache.replaceMembers(familyId, members));
  ref.onDispose(sub.cancel);
});

final _relationshipSyncProvider = Provider<void>((ref) {
  final familyId = ref.watch(activeFamilyProvider);
  if (familyId == null) return;
  final cache = ref.watch(cacheRepositoryProvider);
  final sub = ref
      .watch(relationshipRepositoryProvider)
      .watchRelationships(familyId)
      .listen((rels) => cache.replaceRelationships(familyId, rels));
  ref.onDispose(sub.cancel);
});

/// Stream anggota grup aktif — dibaca dari cache Drift (offline-first).
final membersStreamProvider = StreamProvider<List<MemberModel>>((ref) {
  final familyId = ref.watch(activeFamilyProvider);
  if (familyId == null) return Stream.value(const []);
  ref.watch(_memberSyncProvider); // aktifkan sinkronisasi server → cache
  return ref.watch(cacheRepositoryProvider).watchMembers(familyId);
});

/// Stream relasi grup aktif — dibaca dari cache Drift (offline-first).
final relationshipsStreamProvider =
    StreamProvider<List<RelationshipModel>>((ref) {
  final familyId = ref.watch(activeFamilyProvider);
  if (familyId == null) return Stream.value(const []);
  ref.watch(_relationshipSyncProvider);
  return ref.watch(cacheRepositoryProvider).watchRelationships(familyId);
});

/// Graf gabungan (members + relationships).
final familyGraphProvider = Provider<FamilyGraph>((ref) {
  final members = ref.watch(membersStreamProvider).asData?.value ?? const [];
  final rels =
      ref.watch(relationshipsStreamProvider).asData?.value ?? const [];
  return FamilyGraph(members, rels);
});

/// Tata letak siap-render.
final treeLayoutProvider = Provider<TreeLayout>((ref) {
  final graph = ref.watch(familyGraphProvider);
  return LayoutService().build(graph);
});
