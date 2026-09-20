import '../../core/constants/enums.dart';
import '../../data/models/member_model.dart';
import '../../data/models/relationship_model.dart';

/// Struktur graf lokal hasil resolusi `members` + `relationships`.
///
/// Konvensi arah relasi:
/// - PARENT_*: `fromMemberId` = orang tua, `toMemberId` = anak.
/// - SPOUSE:   pasangan `fromMemberId` ↔ `toMemberId`.
class FamilyGraph {
  final List<MemberModel> members;
  final List<RelationshipModel> relationships;
  final Map<String, MemberModel> _byId;

  FamilyGraph(this.members, this.relationships)
      : _byId = {for (final m in members) m.id: m};

  MemberModel? memberById(String id) => _byId[id];

  /// Anak-anak (kandung & angkat) dari seorang anggota.
  List<String> childrenOf(String parentId) => relationships
      .where((r) =>
          r.type != RelationshipType.spouse && r.fromMemberId == parentId)
      .map((r) => r.toMemberId)
      .toList();

  /// Pasangan-pasangan dari seorang anggota.
  List<String> spousesOf(String memberId) => relationships
      .where((r) =>
          r.type == RelationshipType.spouse &&
          (r.fromMemberId == memberId || r.toMemberId == memberId))
      .map((r) => r.fromMemberId == memberId ? r.toMemberId : r.fromMemberId)
      .toList();

  /// Edge orang tua → anak untuk seorang anak (1–2 edge).
  List<RelationshipModel> parentEdgesOf(String childId) => relationships
      .where((r) =>
          r.type != RelationshipType.spouse && r.toMemberId == childId)
      .toList();

  /// ID orang tua dari seorang anak.
  List<String> parentsOf(String childId) =>
      parentEdgesOf(childId).map((r) => r.fromMemberId).toList();

  /// Apakah dua anggota berpasangan (ada edge SPOUSE di antara mereka).
  bool areSpouses(String a, String b) => relationships.any((r) =>
      r.type == RelationshipType.spouse &&
      ((r.fromMemberId == a && r.toMemberId == b) ||
          (r.fromMemberId == b && r.toMemberId == a)));

  /// Anggota tanpa orang tua (akar pohon).
  List<MemberModel> get roots {
    final hasParent = relationships
        .where((r) => r.type != RelationshipType.spouse)
        .map((r) => r.toMemberId)
        .toSet();
    return members.where((m) => !hasParent.contains(m.id)).toList();
  }

  bool get isEmpty => members.isEmpty;
}
