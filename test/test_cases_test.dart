// Otomasi skenario uji dari SDD §5 (TC-002, TC-003, TC-004) pada level
// domain/logika — tidak membutuhkan jaringan/Supabase.

import 'package:flutter_test/flutter_test.dart';

import 'package:kintree/core/constants/enums.dart';
import 'package:kintree/data/models/member_model.dart';
import 'package:kintree/data/models/relationship_model.dart';
import 'package:kintree/data/repositories/relationship_repository.dart';
import 'package:kintree/domain/entities/family_graph.dart';
import 'package:kintree/domain/services/layout_service.dart';

MemberModel _m(String id, {Gender g = Gender.male}) =>
    MemberModel(id: id, familyId: 'F', firstName: id, gender: g);

RelationshipModel _rel(
  String id,
  String from,
  String to,
  RelationshipType type, {
  RelationshipStatus? status,
  int? order,
}) =>
    RelationshipModel(
      id: id,
      familyId: 'F',
      fromMemberId: from,
      toMemberId: to,
      type: type,
      status: status,
      marriageOrder: order,
    );

void main() {
  group('TC-002 — Anak angkat (adopsi) tanpa merusak pohon', () {
    test('anak adopsi tetap menjadi anak & berada di generasi bawah', () {
      final members = [_m('ayah'), _m('anakKandung'), _m('anakAngkat')];
      final rels = [
        _rel('r1', 'ayah', 'anakKandung', RelationshipType.parentBiological),
        _rel('r2', 'ayah', 'anakAngkat', RelationshipType.parentAdoptive),
      ];
      final graph = FamilyGraph(members, rels);

      // Keduanya terhitung sebagai anak.
      expect(graph.childrenOf('ayah'), containsAll(['anakKandung', 'anakAngkat']));
      // Anak adopsi punya orang tua → bukan akar pohon.
      expect(graph.roots.map((e) => e.id), isNot(contains('anakAngkat')));

      final layout = LayoutService().build(graph);
      // Pohon tidak rusak: semua node mendapat posisi.
      expect(layout.positions.length, 3);
      expect(layout.generations['anakAngkat'],
          equals(layout.generations['ayah']! + 1));
    });
  });

  group('TC-003 — Pernikahan kedua (poligami)', () {
    test('marriage_order bertambah dari 1 ke 2', () {
      final existing = [
        _rel('r1', 'suami', 'istri1', RelationshipType.spouse,
            status: RelationshipStatus.married, order: 1),
      ];
      expect(
          RelationshipRepository.computeNextMarriageOrder(const [], 'suami'), 1);
      expect(RelationshipRepository.computeNextMarriageOrder(existing, 'suami'),
          2);
    });

    test('dua relasi SPOUSE → dua cabang istri pada generasi yang sama', () {
      final members = [
        _m('suami'),
        _m('istri1', g: Gender.female),
        _m('istri2', g: Gender.female),
      ];
      final rels = [
        _rel('r1', 'suami', 'istri1', RelationshipType.spouse,
            status: RelationshipStatus.married, order: 1),
        _rel('r2', 'suami', 'istri2', RelationshipType.spouse,
            status: RelationshipStatus.married, order: 2),
      ];
      final graph = FamilyGraph(members, rels);

      expect(graph.spousesOf('suami'), containsAll(['istri1', 'istri2']));

      final layout = LayoutService().build(graph);
      // Suami & kedua istri di generasi yang sama (berdampingan).
      expect(layout.generations['istri1'], layout.generations['suami']);
      expect(layout.generations['istri2'], layout.generations['suami']);
    });
  });

  group('TC-004 — Perceraian: anak tetap terhubung', () {
    test('status DIVORCED tidak memutus relasi anak', () {
      final members = [
        _m('ayah'),
        _m('ibu', g: Gender.female),
        _m('anak'),
      ];
      final rels = [
        _rel('r1', 'ayah', 'ibu', RelationshipType.spouse,
            status: RelationshipStatus.divorced, order: 1),
        _rel('r2', 'ayah', 'anak', RelationshipType.parentBiological),
        _rel('r3', 'ibu', 'anak', RelationshipType.parentBiological),
      ];
      final graph = FamilyGraph(members, rels);

      // Meski bercerai, anak tetap anak dari kedua orang tua.
      expect(graph.childrenOf('ayah'), contains('anak'));
      expect(graph.childrenOf('ibu'), contains('anak'));

      // Relasi pasangan menyimpan status DIVORCED (untuk digambar pudar+label).
      final spouse =
          rels.firstWhere((r) => r.type == RelationshipType.spouse);
      expect(spouse.status, RelationshipStatus.divorced);
    });
  });
}
