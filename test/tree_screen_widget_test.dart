// Smoke test kanvas pohon: memastikan node (kartu), label GEN sticky, minimap,
// dan painter ter-render tanpa exception layout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:kintree/core/constants/enums.dart';
import 'package:kintree/core/theme/app_theme.dart';
import 'package:kintree/data/models/family_model.dart';
import 'package:kintree/data/models/member_model.dart';
import 'package:kintree/data/models/relationship_model.dart';
import 'package:kintree/providers/graph_providers.dart';
import 'package:kintree/presentation/tree/tree_screen.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('id', null));

  final family = FamilyModel(
    id: 'F',
    familyName: 'Bani Test',
    inviteCode: 'ABC123',
    createdBy: 'u1',
    createdAt: DateTime(2026, 1, 1),
  );
  final opa = MemberModel(
      id: 'm1',
      familyId: 'F',
      firstName: 'Opa',
      gender: Gender.male,
      birthDate: DateTime(1950));
  final oma = MemberModel(
      id: 'm2',
      familyId: 'F',
      firstName: 'Oma',
      gender: Gender.female,
      birthDate: DateTime(1953));
  const spouse = RelationshipModel(
    id: 'r1',
    familyId: 'F',
    fromMemberId: 'm1',
    toMemberId: 'm2',
    type: RelationshipType.spouse,
    status: RelationshipStatus.married,
    marriageOrder: 1,
  );

  testWidgets('kanvas menampilkan node & label GEN tanpa error',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        membersStreamProvider.overrideWith((ref) => Stream.value([opa, oma])),
        relationshipsStreamProvider
            .overrideWith((ref) => Stream.value([spouse])),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: TreeScreen(family: family),
      ),
    ));
    // Biarkan stream emit & frame ter-render.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Opa'), findsOneWidget);
    expect(find.text('Oma'), findsOneWidget);
    expect(find.text('GEN I'), findsOneWidget); // label generasi sticky
    expect(tester.takeException(), isNull);
  });

  testWidgets('palang silsilah: pasangan + 2 anak render tanpa error',
      (tester) async {
    final c1 = MemberModel(
        id: 'c1', familyId: 'F', firstName: 'Anak1', gender: Gender.male);
    final c2 = MemberModel(
        id: 'c2', familyId: 'F', firstName: 'Anak2', gender: Gender.female);
    // Tiap anak terhubung ke KEDUA orang tua (pasangan).
    final rels = [
      spouse,
      for (final c in ['c1', 'c2']) ...[
        RelationshipModel(
            id: 'm1>$c',
            familyId: 'F',
            fromMemberId: 'm1',
            toMemberId: c,
            type: RelationshipType.parentBiological),
        RelationshipModel(
            id: 'm2>$c',
            familyId: 'F',
            fromMemberId: 'm2',
            toMemberId: c,
            type: RelationshipType.parentBiological),
      ],
    ];

    await tester.pumpWidget(ProviderScope(
      overrides: [
        membersStreamProvider
            .overrideWith((ref) => Stream.value([opa, oma, c1, c2])),
        relationshipsStreamProvider.overrideWith((ref) => Stream.value(rels)),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: TreeScreen(family: family),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Anak1'), findsOneWidget);
    expect(find.text('Anak2'), findsOneWidget);
    expect(find.text('GEN II'), findsOneWidget); // anak di generasi 2
    expect(tester.takeException(), isNull);
  });
}
