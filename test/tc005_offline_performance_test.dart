// TC-005 — Memuat silsilah >150 anggota dari cache lokal (luring) harus cepat
// (< 1 detik) tanpa kueri jaringan. Menggunakan Drift in-memory.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kintree/core/constants/enums.dart';
import 'package:kintree/data/local/app_database.dart';
import 'package:kintree/data/models/member_model.dart';
import 'package:kintree/data/models/relationship_model.dart';
import 'package:kintree/data/repositories/cache_repository.dart';
import 'package:kintree/domain/entities/family_graph.dart';
import 'package:kintree/domain/services/layout_service.dart';

void main() {
  late AppDatabase db;
  late CacheRepository cache;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cache = CacheRepository(db);
  });

  tearDown(() async => db.close());

  test('memuat 200 anggota dari cache < 1 detik (tanpa jaringan)', () async {
    const familyId = 'F';
    // 200 anggota: rantai sederhana orang tua → anak antar generasi.
    final members = List.generate(
      200,
      (i) => MemberModel(
        id: 'm$i',
        familyId: familyId,
        firstName: 'Orang $i',
        gender: i.isEven ? Gender.male : Gender.female,
      ),
    );
    final rels = List.generate(
      199,
      (i) => RelationshipModel(
        id: 'r$i',
        familyId: familyId,
        fromMemberId: 'm$i',
        toMemberId: 'm${i + 1}',
        type: RelationshipType.parentBiological,
      ),
    );

    await cache.replaceMembers(familyId, members);
    await cache.replaceRelationships(familyId, rels);

    final sw = Stopwatch()..start();
    final loadedMembers = await cache.watchMembers(familyId).first;
    final loadedRels = await cache.watchRelationships(familyId).first;
    final graph = FamilyGraph(loadedMembers, loadedRels);
    final layout = LayoutService().build(graph);
    sw.stop();

    expect(loadedMembers.length, 200);
    expect(layout.positions.length, 200);
    expect(sw.elapsedMilliseconds, lessThan(1000),
        reason: 'Baca cache + bangun layout harus < 1 detik');
  });
}
