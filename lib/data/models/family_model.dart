/// Merepresentasikan satu baris tabel `families`.
class FamilyModel {
  final String id;
  final String familyName;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;

  const FamilyModel({
    required this.id,
    required this.familyName,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
  });

  factory FamilyModel.fromMap(Map<String, dynamic> map) => FamilyModel(
        id: map['id'] as String,
        familyName: map['family_name'] as String,
        inviteCode: map['invite_code'] as String,
        createdBy: map['created_by'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
