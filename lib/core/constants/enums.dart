// Enum domain KinTree. Nilai string sengaja UPPER_CASE agar konsisten
// dengan constraint di PostgreSQL (lihat supabase/migrations/0001_init.sql).

enum Gender {
  male('MALE'),
  female('FEMALE');

  final String value;
  const Gender(this.value);

  static Gender fromValue(String? v) =>
      Gender.values.firstWhere((e) => e.value == v, orElse: () => Gender.male);

  String get label => this == Gender.male ? 'Laki-laki' : 'Perempuan';
}

enum RelationshipType {
  spouse('SPOUSE'),
  parentBiological('PARENT_BIOLOGICAL'),
  parentAdoptive('PARENT_ADOPTIVE');

  final String value;
  const RelationshipType(this.value);

  static RelationshipType fromValue(String v) => RelationshipType.values
      .firstWhere((e) => e.value == v, orElse: () => RelationshipType.spouse);

  String get label => switch (this) {
        RelationshipType.spouse => 'Pasangan',
        RelationshipType.parentBiological => 'Orang Tua (Kandung)',
        RelationshipType.parentAdoptive => 'Orang Tua (Angkat)',
      };
}

enum RelationshipStatus {
  married('MARRIED'),
  divorced('DIVORCED');

  final String value;
  const RelationshipStatus(this.value);

  static RelationshipStatus? fromValue(String? v) {
    if (v == null) return null;
    return RelationshipStatus.values
        .where((e) => e.value == v)
        .cast<RelationshipStatus?>()
        .firstWhere((e) => true, orElse: () => null);
  }

  String get label => this == RelationshipStatus.married ? 'Menikah' : 'Cerai';
}
