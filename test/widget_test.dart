import 'package:flutter_test/flutter_test.dart';

import 'package:kintree/core/constants/enums.dart';
import 'package:kintree/data/models/member_model.dart';
import 'package:kintree/data/models/relationship_model.dart';
import 'package:kintree/domain/entities/family_graph.dart';
import 'package:kintree/domain/services/layout_service.dart';

void main() {
  group('Enum mapping', () {
    test('Gender round-trip', () {
      expect(Gender.fromValue('FEMALE'), Gender.female);
      expect(Gender.male.value, 'MALE');
    });

    test('RelationshipType round-trip', () {
      expect(RelationshipType.fromValue('PARENT_ADOPTIVE'),
          RelationshipType.parentAdoptive);
    });
  });

  group('FamilyGraph + LayoutService', () {
    MemberModel m(String id, {Gender g = Gender.male}) => MemberModel(
          id: id,
          familyId: 'F',
          firstName: id,
          gender: g,
        );

    test('roots, children, dan layout dasar', () {
      final members = [m('opa'), m('oma', g: Gender.female), m('anak')];
      final rels = [
        const RelationshipModel(
          id: 'r1',
          familyId: 'F',
          fromMemberId: 'opa',
          toMemberId: 'oma',
          type: RelationshipType.spouse,
          status: RelationshipStatus.married,
          marriageOrder: 1,
        ),
        const RelationshipModel(
          id: 'r2',
          familyId: 'F',
          fromMemberId: 'opa',
          toMemberId: 'anak',
          type: RelationshipType.parentBiological,
        ),
      ];
      final graph = FamilyGraph(members, rels);

      expect(graph.childrenOf('opa'), contains('anak'));
      expect(graph.spousesOf('opa'), contains('oma'));
      expect(graph.roots.map((e) => e.id), isNot(contains('anak')));

      final layout = LayoutService().build(graph);
      expect(layout.positions.length, 3);
      // Anak berada satu generasi di bawah orang tua.
      expect(layout.generations['anak'], greaterThan(layout.generations['opa']!));
    });
  });
}
