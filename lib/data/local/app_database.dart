import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Cache lokal anggota (mirror tabel `members` Supabase).
@DataClassName('CachedMember')
class CachedMembers extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  TextColumn get nickname => text().nullable()();
  TextColumn get gender => text()();
  TextColumn get birthPlace => text().nullable()();
  TextColumn get birthDate => text().nullable()(); // ISO yyyy-MM-dd
  BoolColumn get isAlive => boolean().withDefault(const Constant(true))();
  TextColumn get deathDate => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cache lokal relasi (mirror tabel `relationships` Supabase).
@DataClassName('CachedRelationship')
class CachedRelationships extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text()();
  TextColumn get fromMemberId => text()();
  TextColumn get toMemberId => text()();
  TextColumn get type => text()();
  TextColumn get status => text().nullable()();
  IntColumn get marriageOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CachedMembers, CachedRelationships])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'kintree'));

  /// Konstruktor untuk pengujian (mis. in-memory `NativeDatabase.memory()`).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Stream<List<CachedMember>> watchMembers(String familyId) =>
      (select(cachedMembers)..where((t) => t.familyId.equals(familyId)))
          .watch();

  Stream<List<CachedRelationship>> watchRelationships(String familyId) =>
      (select(cachedRelationships)..where((t) => t.familyId.equals(familyId)))
          .watch();

  /// Ganti seluruh cache anggota satu grup dengan snapshot server (server-wins).
  Future<void> replaceMembers(
      String familyId, List<CachedMembersCompanion> rows) {
    return batch((b) {
      b.deleteWhere(cachedMembers, (t) => t.familyId.equals(familyId));
      b.insertAll(cachedMembers, rows, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> replaceRelationships(
      String familyId, List<CachedRelationshipsCompanion> rows) {
    return batch((b) {
      b.deleteWhere(cachedRelationships, (t) => t.familyId.equals(familyId));
      b.insertAll(cachedRelationships, rows, mode: InsertMode.insertOrReplace);
    });
  }

  // --- Write-through satu baris (agar UI update seketika tanpa menunggu
  //     Realtime; dipanggil setelah berhasil menulis ke Supabase). ---

  Future<void> upsertMember(CachedMembersCompanion row) =>
      into(cachedMembers).insertOnConflictUpdate(row);

  Future<void> deleteMemberById(String id) =>
      (delete(cachedMembers)..where((t) => t.id.equals(id))).go();

  Future<void> upsertRelationship(CachedRelationshipsCompanion row) =>
      into(cachedRelationships).insertOnConflictUpdate(row);

  Future<void> deleteRelationshipById(String id) =>
      (delete(cachedRelationships)..where((t) => t.id.equals(id))).go();

  /// Hapus semua relasi yang menyebut anggota (saat anggota dihapus).
  Future<void> deleteRelationshipsOfMember(String memberId) =>
      (delete(cachedRelationships)
            ..where((t) =>
                t.fromMemberId.equals(memberId) |
                t.toMemberId.equals(memberId)))
          .go();
}
