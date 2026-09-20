import '../../core/constants/enums.dart';

/// Merepresentasikan satu baris tabel `relationships` (Edge silsilah).
class RelationshipModel {
  final String id;
  final String familyId;
  final String fromMemberId;
  final String toMemberId;
  final RelationshipType type;
  final RelationshipStatus? status;
  final int? marriageOrder;

  const RelationshipModel({
    required this.id,
    required this.familyId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.type,
    this.status,
    this.marriageOrder,
  });

  factory RelationshipModel.fromMap(Map<String, dynamic> map) =>
      RelationshipModel(
        id: map['id'] as String,
        familyId: map['family_id'] as String,
        fromMemberId: map['from_member_id'] as String,
        toMemberId: map['to_member_id'] as String,
        type: RelationshipType.fromValue(map['type'] as String),
        status: RelationshipStatus.fromValue(map['status'] as String?),
        marriageOrder: map['marriage_order'] as int?,
      );

  Map<String, dynamic> toInsertMap() => {
        'family_id': familyId,
        'from_member_id': fromMemberId,
        'to_member_id': toMemberId,
        'type': type.value,
        'status': status?.value,
        'marriage_order': marriageOrder,
      };
}
