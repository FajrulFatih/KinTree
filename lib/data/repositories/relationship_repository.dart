import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/enums.dart';
import '../models/relationship_model.dart';

/// CRUD hubungan + stream realtime. Menyimpan logika kasus khusus
/// (poligami via marriage_order, cerai via status).
class RelationshipRepository {
  final SupabaseClient _client;
  RelationshipRepository(this._client);

  Stream<List<RelationshipModel>> watchRelationships(String familyId) => _client
      .from('relationships')
      .stream(primaryKey: ['id'])
      .eq('family_id', familyId)
      .map((rows) => rows.map(RelationshipModel.fromMap).toList());

  Future<RelationshipModel> create(RelationshipModel rel) async {
    final row = await _client
        .from('relationships')
        .insert(rel.toInsertMap())
        .select()
        .single();
    return RelationshipModel.fromMap(row);
  }

  Future<void> updateStatus(String id, RelationshipStatus status) =>
      _client.from('relationships').update({'status': status.value}).eq('id', id);

  Future<void> delete(String id) =>
      _client.from('relationships').delete().eq('id', id);

  /// Hitung urutan pernikahan berikutnya untuk satu anggota (poligami).
  Future<int> nextMarriageOrder(String familyId, String memberId) async {
    final rows = await _client
        .from('relationships')
        .select()
        .eq('family_id', familyId)
        .eq('type', RelationshipType.spouse.value);
    final rels = (rows as List)
        .map((e) => RelationshipModel.fromMap(e as Map<String, dynamic>))
        .toList();
    return computeNextMarriageOrder(rels, memberId);
  }

  /// Logika murni urutan pernikahan ke-N (di-extract agar dapat diuji
  /// tanpa jaringan). Mengembalikan max(marriage_order untuk memberId) + 1.
  static int computeNextMarriageOrder(
      Iterable<RelationshipModel> rels, String memberId) {
    var maxOrder = 0;
    for (final r in rels) {
      if (r.type != RelationshipType.spouse) continue;
      final involves =
          r.fromMemberId == memberId || r.toMemberId == memberId;
      if (involves && (r.marriageOrder ?? 0) > maxOrder) {
        maxOrder = r.marriageOrder ?? 0;
      }
    }
    return maxOrder + 1;
  }

  /// Logika murni "tambah saudara": dari edge orang tua milik anggota acuan,
  /// hasilkan edge yang menautkan tiap orang tua yang sama ke [targetId]
  /// dengan tipe yang sama. Saudara = berbagi orang tua.
  static List<RelationshipModel> siblingEdgesFrom({
    required Iterable<RelationshipModel> referenceParentEdges,
    required String familyId,
    required String targetId,
  }) {
    return referenceParentEdges
        .where((e) => e.type != RelationshipType.spouse)
        .map((e) => RelationshipModel(
              id: '',
              familyId: familyId,
              fromMemberId: e.fromMemberId, // orang tua yang sama
              toMemberId: targetId, // saudara baru
              type: e.type,
            ))
        .toList();
  }
}
