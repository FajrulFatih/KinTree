import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kintree/core/constants/enums.dart';
import 'package:kintree/data/local/app_database.dart';
import 'package:kintree/data/models/member_model.dart';
import 'package:kintree/data/models/relationship_model.dart';
import 'package:kintree/data/repositories/cache_repository.dart';

void main() {
  late AppDatabase db;
  late CacheRepository cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = CacheRepository(db);
  });

  tearDown(() async => db.close());

  test('upsertMember menambah & memperbarui (fix add/edit reflektif)',
      () async {
    // Tambah baru → langsung muncul.
    await cache.upsertMember(MemberModel(
        id: 'm1', familyId: 'F', firstName: 'Budi', gender: Gender.male));
    var loaded = await cache.watchMembers('F').first;
    expect(loaded.length, 1);
    expect(loaded.first.firstName, 'Budi');

    // Edit → perubahan langsung terlihat (id sama).
    await cache.upsertMember(MemberModel(
        id: 'm1', familyId: 'F', firstName: 'Budiman', gender: Gender.male));
    loaded = await cache.watchMembers('F').first;
    expect(loaded.length, 1);
    expect(loaded.first.firstName, 'Budiman');
  });

  test('deleteMember menghapus anggota & relasinya', () async {
    await cache.upsertMember(MemberModel(
        id: 'm1', familyId: 'F', firstName: 'A', gender: Gender.male));
    await cache.upsertMember(MemberModel(
        id: 'm2', familyId: 'F', firstName: 'B', gender: Gender.female));
    await cache.upsertRelationship(const RelationshipModel(
      id: 'r1',
      familyId: 'F',
      fromMemberId: 'm1',
      toMemberId: 'm2',
      type: RelationshipType.spouse,
      status: RelationshipStatus.married,
      marriageOrder: 1,
    ));

    await cache.deleteMember('m1');
    final members = await cache.watchMembers('F').first;
    final rels = await cache.watchRelationships('F').first;
    expect(members.map((m) => m.id), ['m2']);
    expect(rels, isEmpty); // relasi yang menyebut m1 ikut terhapus
  });

  test('replaceMembers lalu watchMembers mengembalikan data yang sama',
      () async {
    final members = [
      MemberModel(
        id: 'm1',
        familyId: 'F',
        firstName: 'Ahmad',
        lastName: 'Dahlan',
        gender: Gender.male,
        birthDate: DateTime(1955, 2, 26),
        isAlive: true,
      ),
    ];

    await cache.replaceMembers('F', members);
    final loaded = await cache.watchMembers('F').first;

    expect(loaded.length, 1);
    expect(loaded.first.fullName, 'Ahmad Dahlan');
    expect(loaded.first.gender, Gender.male);
    expect(loaded.first.birthDate?.year, 1955);
  });

  test('replace bersifat server-wins (snapshot mengganti cache lama)',
      () async {
    await cache.replaceMembers('F', [
      MemberModel(id: 'm1', familyId: 'F', firstName: 'Lama', gender: Gender.male),
      MemberModel(id: 'm2', familyId: 'F', firstName: 'Hapus', gender: Gender.male),
    ]);
    // Snapshot baru hanya berisi m1 (m2 dihapus di server).
    await cache.replaceMembers('F', [
      MemberModel(id: 'm1', familyId: 'F', firstName: 'Baru', gender: Gender.male),
    ]);

    final loaded = await cache.watchMembers('F').first;
    expect(loaded.length, 1);
    expect(loaded.first.firstName, 'Baru');
  });

  test('relationships round-trip dengan status & marriage order', () async {
    await cache.replaceRelationships('F', [
      const RelationshipModel(
        id: 'r1',
        familyId: 'F',
        fromMemberId: 'm1',
        toMemberId: 'm2',
        type: RelationshipType.spouse,
        status: RelationshipStatus.divorced,
        marriageOrder: 2,
      ),
    ]);

    final loaded = await cache.watchRelationships('F').first;
    expect(loaded.first.type, RelationshipType.spouse);
    expect(loaded.first.status, RelationshipStatus.divorced);
    expect(loaded.first.marriageOrder, 2);
  });
}
