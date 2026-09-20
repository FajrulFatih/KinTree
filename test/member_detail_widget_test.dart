// Regresi untuk bug "detail anggota kosong": dulu _DateCards memakai
// Row(crossAxisAlignment: stretch) di dalam ListView → exception layout
// "BoxConstraints forces an infinite height" → body blank.
// Test ini memastikan body MemberDetailScreen ter-render penuh.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:kintree/core/constants/enums.dart';
import 'package:kintree/core/theme/app_theme.dart';
import 'package:kintree/data/models/member_model.dart';
import 'package:kintree/data/models/relationship_model.dart';
import 'package:kintree/domain/entities/family_graph.dart';
import 'package:kintree/providers/graph_providers.dart';
import 'package:kintree/presentation/member/member_detail_screen.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('id', null));

  final fadibah = MemberModel(
    id: 'm1',
    familyId: 'F',
    firstName: 'Fadibah',
    lastName: 'Setiawan',
    gender: Gender.male,
    birthDate: DateTime(1979, 5, 10),
    isAlive: true,
  );
  final wiwik = MemberModel(
    id: 'm2',
    familyId: 'F',
    firstName: 'Wiwik',
    lastName: 'Istihanah',
    gender: Gender.female,
    birthDate: DateTime(1979, 8, 2),
    isAlive: true,
  );
  const spouse = RelationshipModel(
    id: 'r1',
    familyId: 'F',
    fromMemberId: 'm1',
    toMemberId: 'm2',
    type: RelationshipType.spouse,
    status: RelationshipStatus.married,
    marriageOrder: 1,
  );

  Widget harness(String memberId, FamilyGraph graph) => ProviderScope(
        overrides: [familyGraphProvider.overrideWithValue(graph)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: MemberDetailScreen(memberId: memberId),
        ),
      );

  testWidgets('body detail ter-render penuh (tidak kosong)', (tester) async {
    await tester.pumpWidget(
      harness('m1', FamilyGraph([fadibah, wiwik], [spouse])),
    );
    await tester.pump();

    // Nama, kartu tanggal, heading hubungan, dan chip pasangan tampil.
    expect(find.text('Fadibah Setiawan'), findsOneWidget);
    expect(find.text('LAHIR'), findsOneWidget);
    // "Hubungan" muncul 2×: heading section + label FAB.
    expect(find.text('Hubungan'), findsNWidgets(2));
    expect(find.text('Wiwik Istihanah'), findsOneWidget); // chip pasangan

    // Tidak ada exception layout selama frame (mis. infinite height).
    expect(tester.takeException(), isNull);
  });

  testWidgets('anggota wafat menampilkan kartu Wafat & tag Alm.',
      (tester) async {
    final alm = MemberModel(
      id: 'm3',
      familyId: 'F',
      firstName: 'Sastro',
      lastName: 'Wijoyo',
      gender: Gender.male,
      birthDate: DateTime(1940, 3, 12),
      isAlive: false,
      deathDate: DateTime(2015, 1, 3),
    );
    await tester.pumpWidget(harness('m3', FamilyGraph([alm], const [])));
    await tester.pump();

    expect(find.text('Sastro Wijoyo'), findsOneWidget);
    expect(find.text('LAHIR'), findsOneWidget);
    expect(find.text('WAFAT'), findsOneWidget);
    expect(find.text('Alm.'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
