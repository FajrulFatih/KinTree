import '../../core/constants/enums.dart';

/// Merepresentasikan satu baris tabel `members` (Node silsilah).
class MemberModel {
  final String id;
  final String familyId;
  final String firstName;
  final String? lastName;
  final String? nickname;
  final Gender gender;
  final String? birthPlace;
  final DateTime? birthDate;
  final bool isAlive;
  final DateTime? deathDate;
  final String? photoUrl;
  final String? notes;

  const MemberModel({
    required this.id,
    required this.familyId,
    required this.firstName,
    this.lastName,
    this.nickname,
    required this.gender,
    this.birthPlace,
    this.birthDate,
    this.isAlive = true,
    this.deathDate,
    this.photoUrl,
    this.notes,
  });

  String get fullName =>
      [firstName, if (lastName != null && lastName!.isNotEmpty) lastName].join(' ');

  factory MemberModel.fromMap(Map<String, dynamic> map) => MemberModel(
        id: map['id'] as String,
        familyId: map['family_id'] as String,
        firstName: map['first_name'] as String,
        lastName: map['last_name'] as String?,
        nickname: map['nickname'] as String?,
        gender: Gender.fromValue(map['gender'] as String?),
        birthPlace: map['birth_place'] as String?,
        birthDate: _date(map['birth_date']),
        isAlive: (map['is_alive'] as bool?) ?? true,
        deathDate: _date(map['death_date']),
        photoUrl: map['photo_url'] as String?,
        notes: map['notes'] as String?,
      );

  /// Payload untuk insert/update (tanpa `id`/`updated_at` yang dikelola DB).
  Map<String, dynamic> toInsertMap() => {
        'family_id': familyId,
        'first_name': firstName,
        'last_name': lastName,
        'nickname': nickname,
        'gender': gender.value,
        'birth_place': birthPlace,
        'birth_date': birthDate?.toIso8601String().split('T').first,
        'is_alive': isAlive,
        'death_date': deathDate?.toIso8601String().split('T').first,
        'photo_url': photoUrl,
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      };

  static DateTime? _date(dynamic v) =>
      (v == null) ? null : DateTime.tryParse(v as String);
}
