import 'package:drift/drift.dart';

import '../../core/constants/enums.dart';
import '../local/app_database.dart';
import '../models/member_model.dart';
import '../models/relationship_model.dart';

/// Membungkus [AppDatabase] dan menjembatani baris Drift ↔ model domain.
/// Inilah sumber data yang dibaca UI agar silsilah tetap tampil saat luring.
class CacheRepository {
  final AppDatabase _db;
  CacheRepository(this._db);

  // ----- Anggota -----

  Stream<List<MemberModel>> watchMembers(String familyId) =>
      _db.watchMembers(familyId).map((rows) => rows.map(_toMember).toList());

  Future<void> replaceMembers(String familyId, List<MemberModel> members) =>
      _db.replaceMembers(
          familyId, members.map(_toMemberCompanion).toList());

  /// Write-through satu anggota (UI langsung ter-update).
  Future<void> upsertMember(MemberModel m) =>
      _db.upsertMember(_toMemberCompanion(m));

  Future<void> deleteMember(String id) async {
    await _db.deleteMemberById(id);
    await _db.deleteRelationshipsOfMember(id);
  }

  // ----- Relasi -----

  Stream<List<RelationshipModel>> watchRelationships(String familyId) => _db
      .watchRelationships(familyId)
      .map((rows) => rows.map(_toRelationship).toList());

  Future<void> replaceRelationships(
          String familyId, List<RelationshipModel> rels) =>
      _db.replaceRelationships(
          familyId, rels.map(_toRelationshipCompanion).toList());

  Future<void> upsertRelationship(RelationshipModel r) =>
      _db.upsertRelationship(_toRelationshipCompanion(r));

  Future<void> deleteRelationship(String id) => _db.deleteRelationshipById(id);

  // ----- Mapper -----

  MemberModel _toMember(CachedMember r) => MemberModel(
        id: r.id,
        familyId: r.familyId,
        firstName: r.firstName,
        lastName: r.lastName,
        nickname: r.nickname,
        gender: Gender.fromValue(r.gender),
        birthPlace: r.birthPlace,
        birthDate: r.birthDate == null ? null : DateTime.tryParse(r.birthDate!),
        isAlive: r.isAlive,
        deathDate: r.deathDate == null ? null : DateTime.tryParse(r.deathDate!),
        photoUrl: r.photoUrl,
        notes: r.notes,
      );

  CachedMembersCompanion _toMemberCompanion(MemberModel m) =>
      CachedMembersCompanion(
        id: Value(m.id),
        familyId: Value(m.familyId),
        firstName: Value(m.firstName),
        lastName: Value(m.lastName),
        nickname: Value(m.nickname),
        gender: Value(m.gender.value),
        birthPlace: Value(m.birthPlace),
        birthDate: Value(m.birthDate?.toIso8601String().split('T').first),
        isAlive: Value(m.isAlive),
        deathDate: Value(m.deathDate?.toIso8601String().split('T').first),
        photoUrl: Value(m.photoUrl),
        notes: Value(m.notes),
      );

  RelationshipModel _toRelationship(CachedRelationship r) => RelationshipModel(
        id: r.id,
        familyId: r.familyId,
        fromMemberId: r.fromMemberId,
        toMemberId: r.toMemberId,
        type: RelationshipType.fromValue(r.type),
        status: RelationshipStatus.fromValue(r.status),
        marriageOrder: r.marriageOrder,
      );

  CachedRelationshipsCompanion _toRelationshipCompanion(RelationshipModel r) =>
      CachedRelationshipsCompanion(
        id: Value(r.id),
        familyId: Value(r.familyId),
        fromMemberId: Value(r.fromMemberId),
        toMemberId: Value(r.toMemberId),
        type: Value(r.type.value),
        status: Value(r.status?.value),
        marriageOrder: Value(r.marriageOrder),
      );
}
