// Test fitur: helper graf orang tua/pasangan + "tambah saudara" (berbagi ortu).

import 'package:flutter_test/flutter_test.dart';

import 'package:kintree/core/constants/enums.dart';
import 'package:kintree/data/models/member_model.dart';
import 'package:kintree/data/models/relationship_model.dart';
import 'package:kintree/data/repositories/relationship_repository.dart';
import 'package:kintree/domain/entities/family_graph.dart';

MemberModel _m(String id, {Gender g = Gender.male}) =>
    MemberModel(id: id, familyId: 'F', firstName: id, gender: g);

RelationshipModel _parent(String parent, String child,
        {RelationshipType type = RelationshipType.parentBiological}) =>
    RelationshipModel(
      id: '$parent>$child',
      familyId: 'F',
      fromMemberId: parent,
      toMemberId: child,
      type: type,
    );

const _spouse = RelationshipModel(
  id: 's1',
  familyId: 'F',
  fromMemberId: 'ayah',
  toMemberId: 'ibu',
  type: RelationshipType.spouse,
  status: RelationshipStatus.married,
  marriageOrder: 1,
);

void main() {
  group('FamilyGraph helper', () {
    final graph = FamilyGraph(
      [_m('ayah'), _m('ibu', g: Gender.female), _m('anak')],
      [_spouse, _parent('ayah', 'anak'), _parent('ibu', 'anak')],
    );

    test('parentsOf & parentEdgesOf', () {
      expect(graph.parentsOf('anak')..sort(), ['ayah', 'ibu']);
      expect(graph.parentEdgesOf('anak').length, 2);
    });

    test('areSpouses simetris', () {
      expect(graph.areSpouses('ayah', 'ibu'), isTrue);
      expect(graph.areSpouses('ibu', 'ayah'), isTrue);
      expect(graph.areSpouses('ayah', 'anak'), isFalse);
    });
  });

  group('siblingEdgesFrom (berbagi orang tua)', () {
    test('menyalin tiap orang tua ke saudara baru dengan tipe sama', () {
      final refParentEdges = [
        _parent('ayah', 'anak'),
        _parent('ibu', 'anak', type: RelationshipType.parentAdoptive),
      ];
      final edges = RelationshipRepository.siblingEdgesFrom(
        referenceParentEdges: refParentEdges,
        familyId: 'F',
        targetId: 'adik',
      );
      expect(edges.length, 2);
      expect(edges.every((e) => e.toMemberId == 'adik'), isTrue);
      expect(edges.map((e) => e.fromMemberId).toList()..sort(), ['ayah', 'ibu']);
      // tipe dipertahankan per orang tua
      expect(edges.firstWhere((e) => e.fromMemberId == 'ibu').type,
          RelationshipType.parentAdoptive);
    });

    test('mengabaikan edge SPOUSE', () {
      final edges = RelationshipRepository.siblingEdgesFrom(
        referenceParentEdges: [_spouse, _parent('ayah', 'anak')],
        familyId: 'F',
        targetId: 'adik',
      );
      expect(edges.length, 1);
      expect(edges.single.fromMemberId, 'ayah');
    });
  });
}
