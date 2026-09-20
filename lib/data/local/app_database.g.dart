// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedMembersTable extends CachedMembers
    with TableInfo<$CachedMembersTable, CachedMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthPlaceMeta = const VerificationMeta(
    'birthPlace',
  );
  @override
  late final GeneratedColumn<String> birthPlace = GeneratedColumn<String>(
    'birth_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAliveMeta = const VerificationMeta(
    'isAlive',
  );
  @override
  late final GeneratedColumn<bool> isAlive = GeneratedColumn<bool>(
    'is_alive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_alive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deathDateMeta = const VerificationMeta(
    'deathDate',
  );
  @override
  late final GeneratedColumn<String> deathDate = GeneratedColumn<String>(
    'death_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    firstName,
    lastName,
    nickname,
    gender,
    birthPlace,
    birthDate,
    isAlive,
    deathDate,
    photoUrl,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('birth_place')) {
      context.handle(
        _birthPlaceMeta,
        birthPlace.isAcceptableOrUnknown(data['birth_place']!, _birthPlaceMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('is_alive')) {
      context.handle(
        _isAliveMeta,
        isAlive.isAcceptableOrUnknown(data['is_alive']!, _isAliveMeta),
      );
    }
    if (data.containsKey('death_date')) {
      context.handle(
        _deathDateMeta,
        deathDate.isAcceptableOrUnknown(data['death_date']!, _deathDateMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      birthPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_place'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_date'],
      ),
      isAlive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_alive'],
      )!,
      deathDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}death_date'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CachedMembersTable createAlias(String alias) {
    return $CachedMembersTable(attachedDatabase, alias);
  }
}

class CachedMember extends DataClass implements Insertable<CachedMember> {
  final String id;
  final String familyId;
  final String firstName;
  final String? lastName;
  final String? nickname;
  final String gender;
  final String? birthPlace;
  final String? birthDate;
  final bool isAlive;
  final String? deathDate;
  final String? photoUrl;
  final String? notes;
  const CachedMember({
    required this.id,
    required this.familyId,
    required this.firstName,
    this.lastName,
    this.nickname,
    required this.gender,
    this.birthPlace,
    this.birthDate,
    required this.isAlive,
    this.deathDate,
    this.photoUrl,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || birthPlace != null) {
      map['birth_place'] = Variable<String>(birthPlace);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    map['is_alive'] = Variable<bool>(isAlive);
    if (!nullToAbsent || deathDate != null) {
      map['death_date'] = Variable<String>(deathDate);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CachedMembersCompanion toCompanion(bool nullToAbsent) {
    return CachedMembersCompanion(
      id: Value(id),
      familyId: Value(familyId),
      firstName: Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      gender: Value(gender),
      birthPlace: birthPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(birthPlace),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      isAlive: Value(isAlive),
      deathDate: deathDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deathDate),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CachedMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMember(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['familyId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      gender: serializer.fromJson<String>(json['gender']),
      birthPlace: serializer.fromJson<String?>(json['birthPlace']),
      birthDate: serializer.fromJson<String?>(json['birthDate']),
      isAlive: serializer.fromJson<bool>(json['isAlive']),
      deathDate: serializer.fromJson<String?>(json['deathDate']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String>(familyId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'nickname': serializer.toJson<String?>(nickname),
      'gender': serializer.toJson<String>(gender),
      'birthPlace': serializer.toJson<String?>(birthPlace),
      'birthDate': serializer.toJson<String?>(birthDate),
      'isAlive': serializer.toJson<bool>(isAlive),
      'deathDate': serializer.toJson<String?>(deathDate),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CachedMember copyWith({
    String? id,
    String? familyId,
    String? firstName,
    Value<String?> lastName = const Value.absent(),
    Value<String?> nickname = const Value.absent(),
    String? gender,
    Value<String?> birthPlace = const Value.absent(),
    Value<String?> birthDate = const Value.absent(),
    bool? isAlive,
    Value<String?> deathDate = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => CachedMember(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    firstName: firstName ?? this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    nickname: nickname.present ? nickname.value : this.nickname,
    gender: gender ?? this.gender,
    birthPlace: birthPlace.present ? birthPlace.value : this.birthPlace,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    isAlive: isAlive ?? this.isAlive,
    deathDate: deathDate.present ? deathDate.value : this.deathDate,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    notes: notes.present ? notes.value : this.notes,
  );
  CachedMember copyWithCompanion(CachedMembersCompanion data) {
    return CachedMember(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthPlace: data.birthPlace.present
          ? data.birthPlace.value
          : this.birthPlace,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      isAlive: data.isAlive.present ? data.isAlive.value : this.isAlive,
      deathDate: data.deathDate.present ? data.deathDate.value : this.deathDate,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMember(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('nickname: $nickname, ')
          ..write('gender: $gender, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('birthDate: $birthDate, ')
          ..write('isAlive: $isAlive, ')
          ..write('deathDate: $deathDate, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    firstName,
    lastName,
    nickname,
    gender,
    birthPlace,
    birthDate,
    isAlive,
    deathDate,
    photoUrl,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMember &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.nickname == this.nickname &&
          other.gender == this.gender &&
          other.birthPlace == this.birthPlace &&
          other.birthDate == this.birthDate &&
          other.isAlive == this.isAlive &&
          other.deathDate == this.deathDate &&
          other.photoUrl == this.photoUrl &&
          other.notes == this.notes);
}

class CachedMembersCompanion extends UpdateCompanion<CachedMember> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<String> firstName;
  final Value<String?> lastName;
  final Value<String?> nickname;
  final Value<String> gender;
  final Value<String?> birthPlace;
  final Value<String?> birthDate;
  final Value<bool> isAlive;
  final Value<String?> deathDate;
  final Value<String?> photoUrl;
  final Value<String?> notes;
  final Value<int> rowid;
  const CachedMembersCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.nickname = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMembersCompanion.insert({
    required String id,
    required String familyId,
    required String firstName,
    this.lastName = const Value.absent(),
    this.nickname = const Value.absent(),
    required String gender,
    this.birthPlace = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       firstName = Value(firstName),
       gender = Value(gender);
  static Insertable<CachedMember> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? nickname,
    Expression<String>? gender,
    Expression<String>? birthPlace,
    Expression<String>? birthDate,
    Expression<bool>? isAlive,
    Expression<String>? deathDate,
    Expression<String>? photoUrl,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (nickname != null) 'nickname': nickname,
      if (gender != null) 'gender': gender,
      if (birthPlace != null) 'birth_place': birthPlace,
      if (birthDate != null) 'birth_date': birthDate,
      if (isAlive != null) 'is_alive': isAlive,
      if (deathDate != null) 'death_date': deathDate,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<String>? firstName,
    Value<String?>? lastName,
    Value<String?>? nickname,
    Value<String>? gender,
    Value<String?>? birthPlace,
    Value<String?>? birthDate,
    Value<bool>? isAlive,
    Value<String?>? deathDate,
    Value<String?>? photoUrl,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return CachedMembersCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      isAlive: isAlive ?? this.isAlive,
      deathDate: deathDate ?? this.deathDate,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthPlace.present) {
      map['birth_place'] = Variable<String>(birthPlace.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (isAlive.present) {
      map['is_alive'] = Variable<bool>(isAlive.value);
    }
    if (deathDate.present) {
      map['death_date'] = Variable<String>(deathDate.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMembersCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('nickname: $nickname, ')
          ..write('gender: $gender, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('birthDate: $birthDate, ')
          ..write('isAlive: $isAlive, ')
          ..write('deathDate: $deathDate, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRelationshipsTable extends CachedRelationships
    with TableInfo<$CachedRelationshipsTable, CachedRelationship> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromMemberIdMeta = const VerificationMeta(
    'fromMemberId',
  );
  @override
  late final GeneratedColumn<String> fromMemberId = GeneratedColumn<String>(
    'from_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toMemberIdMeta = const VerificationMeta(
    'toMemberId',
  );
  @override
  late final GeneratedColumn<String> toMemberId = GeneratedColumn<String>(
    'to_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _marriageOrderMeta = const VerificationMeta(
    'marriageOrder',
  );
  @override
  late final GeneratedColumn<int> marriageOrder = GeneratedColumn<int>(
    'marriage_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    fromMemberId,
    toMemberId,
    type,
    status,
    marriageOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRelationship> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('from_member_id')) {
      context.handle(
        _fromMemberIdMeta,
        fromMemberId.isAcceptableOrUnknown(
          data['from_member_id']!,
          _fromMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromMemberIdMeta);
    }
    if (data.containsKey('to_member_id')) {
      context.handle(
        _toMemberIdMeta,
        toMemberId.isAcceptableOrUnknown(
          data['to_member_id']!,
          _toMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toMemberIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('marriage_order')) {
      context.handle(
        _marriageOrderMeta,
        marriageOrder.isAcceptableOrUnknown(
          data['marriage_order']!,
          _marriageOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRelationship map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRelationship(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      fromMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_member_id'],
      )!,
      toMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_member_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      marriageOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}marriage_order'],
      ),
    );
  }

  @override
  $CachedRelationshipsTable createAlias(String alias) {
    return $CachedRelationshipsTable(attachedDatabase, alias);
  }
}

class CachedRelationship extends DataClass
    implements Insertable<CachedRelationship> {
  final String id;
  final String familyId;
  final String fromMemberId;
  final String toMemberId;
  final String type;
  final String? status;
  final int? marriageOrder;
  const CachedRelationship({
    required this.id,
    required this.familyId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.type,
    this.status,
    this.marriageOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    map['from_member_id'] = Variable<String>(fromMemberId);
    map['to_member_id'] = Variable<String>(toMemberId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || marriageOrder != null) {
      map['marriage_order'] = Variable<int>(marriageOrder);
    }
    return map;
  }

  CachedRelationshipsCompanion toCompanion(bool nullToAbsent) {
    return CachedRelationshipsCompanion(
      id: Value(id),
      familyId: Value(familyId),
      fromMemberId: Value(fromMemberId),
      toMemberId: Value(toMemberId),
      type: Value(type),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      marriageOrder: marriageOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(marriageOrder),
    );
  }

  factory CachedRelationship.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRelationship(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['familyId']),
      fromMemberId: serializer.fromJson<String>(json['fromMemberId']),
      toMemberId: serializer.fromJson<String>(json['toMemberId']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String?>(json['status']),
      marriageOrder: serializer.fromJson<int?>(json['marriageOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String>(familyId),
      'fromMemberId': serializer.toJson<String>(fromMemberId),
      'toMemberId': serializer.toJson<String>(toMemberId),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String?>(status),
      'marriageOrder': serializer.toJson<int?>(marriageOrder),
    };
  }

  CachedRelationship copyWith({
    String? id,
    String? familyId,
    String? fromMemberId,
    String? toMemberId,
    String? type,
    Value<String?> status = const Value.absent(),
    Value<int?> marriageOrder = const Value.absent(),
  }) => CachedRelationship(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    fromMemberId: fromMemberId ?? this.fromMemberId,
    toMemberId: toMemberId ?? this.toMemberId,
    type: type ?? this.type,
    status: status.present ? status.value : this.status,
    marriageOrder: marriageOrder.present
        ? marriageOrder.value
        : this.marriageOrder,
  );
  CachedRelationship copyWithCompanion(CachedRelationshipsCompanion data) {
    return CachedRelationship(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      fromMemberId: data.fromMemberId.present
          ? data.fromMemberId.value
          : this.fromMemberId,
      toMemberId: data.toMemberId.present
          ? data.toMemberId.value
          : this.toMemberId,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      marriageOrder: data.marriageOrder.present
          ? data.marriageOrder.value
          : this.marriageOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRelationship(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('fromMemberId: $fromMemberId, ')
          ..write('toMemberId: $toMemberId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('marriageOrder: $marriageOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    fromMemberId,
    toMemberId,
    type,
    status,
    marriageOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRelationship &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.fromMemberId == this.fromMemberId &&
          other.toMemberId == this.toMemberId &&
          other.type == this.type &&
          other.status == this.status &&
          other.marriageOrder == this.marriageOrder);
}

class CachedRelationshipsCompanion extends UpdateCompanion<CachedRelationship> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<String> fromMemberId;
  final Value<String> toMemberId;
  final Value<String> type;
  final Value<String?> status;
  final Value<int?> marriageOrder;
  final Value<int> rowid;
  const CachedRelationshipsCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.fromMemberId = const Value.absent(),
    this.toMemberId = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.marriageOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRelationshipsCompanion.insert({
    required String id,
    required String familyId,
    required String fromMemberId,
    required String toMemberId,
    required String type,
    this.status = const Value.absent(),
    this.marriageOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       fromMemberId = Value(fromMemberId),
       toMemberId = Value(toMemberId),
       type = Value(type);
  static Insertable<CachedRelationship> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? fromMemberId,
    Expression<String>? toMemberId,
    Expression<String>? type,
    Expression<String>? status,
    Expression<int>? marriageOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (fromMemberId != null) 'from_member_id': fromMemberId,
      if (toMemberId != null) 'to_member_id': toMemberId,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (marriageOrder != null) 'marriage_order': marriageOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRelationshipsCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<String>? fromMemberId,
    Value<String>? toMemberId,
    Value<String>? type,
    Value<String?>? status,
    Value<int?>? marriageOrder,
    Value<int>? rowid,
  }) {
    return CachedRelationshipsCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      type: type ?? this.type,
      status: status ?? this.status,
      marriageOrder: marriageOrder ?? this.marriageOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (fromMemberId.present) {
      map['from_member_id'] = Variable<String>(fromMemberId.value);
    }
    if (toMemberId.present) {
      map['to_member_id'] = Variable<String>(toMemberId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (marriageOrder.present) {
      map['marriage_order'] = Variable<int>(marriageOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('fromMemberId: $fromMemberId, ')
          ..write('toMemberId: $toMemberId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('marriageOrder: $marriageOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedMembersTable cachedMembers = $CachedMembersTable(this);
  late final $CachedRelationshipsTable cachedRelationships =
      $CachedRelationshipsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedMembers,
    cachedRelationships,
  ];
}

typedef $$CachedMembersTableCreateCompanionBuilder =
    CachedMembersCompanion Function({
      required String id,
      required String familyId,
      required String firstName,
      Value<String?> lastName,
      Value<String?> nickname,
      required String gender,
      Value<String?> birthPlace,
      Value<String?> birthDate,
      Value<bool> isAlive,
      Value<String?> deathDate,
      Value<String?> photoUrl,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$CachedMembersTableUpdateCompanionBuilder =
    CachedMembersCompanion Function({
      Value<String> id,
      Value<String> familyId,
      Value<String> firstName,
      Value<String?> lastName,
      Value<String?> nickname,
      Value<String> gender,
      Value<String?> birthPlace,
      Value<String?> birthDate,
      Value<bool> isAlive,
      Value<String?> deathDate,
      Value<String?> photoUrl,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$CachedMembersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMembersTable> {
  $$CachedMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deathDate => $composableBuilder(
    column: $table.deathDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMembersTable> {
  $$CachedMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlive => $composableBuilder(
    column: $table.isAlive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deathDate => $composableBuilder(
    column: $table.deathDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMembersTable> {
  $$CachedMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<bool> get isAlive =>
      $composableBuilder(column: $table.isAlive, builder: (column) => column);

  GeneratedColumn<String> get deathDate =>
      $composableBuilder(column: $table.deathDate, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$CachedMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMembersTable,
          CachedMember,
          $$CachedMembersTableFilterComposer,
          $$CachedMembersTableOrderingComposer,
          $$CachedMembersTableAnnotationComposer,
          $$CachedMembersTableCreateCompanionBuilder,
          $$CachedMembersTableUpdateCompanionBuilder,
          (
            CachedMember,
            BaseReferences<_$AppDatabase, $CachedMembersTable, CachedMember>,
          ),
          CachedMember,
          PrefetchHooks Function()
        > {
  $$CachedMembersTableTableManager(_$AppDatabase db, $CachedMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<String?> deathDate = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMembersCompanion(
                id: id,
                familyId: familyId,
                firstName: firstName,
                lastName: lastName,
                nickname: nickname,
                gender: gender,
                birthPlace: birthPlace,
                birthDate: birthDate,
                isAlive: isAlive,
                deathDate: deathDate,
                photoUrl: photoUrl,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                required String firstName,
                Value<String?> lastName = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                required String gender,
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<bool> isAlive = const Value.absent(),
                Value<String?> deathDate = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMembersCompanion.insert(
                id: id,
                familyId: familyId,
                firstName: firstName,
                lastName: lastName,
                nickname: nickname,
                gender: gender,
                birthPlace: birthPlace,
                birthDate: birthDate,
                isAlive: isAlive,
                deathDate: deathDate,
                photoUrl: photoUrl,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedMembersTable,
      CachedMember,
      $$CachedMembersTableFilterComposer,
      $$CachedMembersTableOrderingComposer,
      $$CachedMembersTableAnnotationComposer,
      $$CachedMembersTableCreateCompanionBuilder,
      $$CachedMembersTableUpdateCompanionBuilder,
      (
        CachedMember,
        BaseReferences<_$AppDatabase, $CachedMembersTable, CachedMember>,
      ),
      CachedMember,
      PrefetchHooks Function()
    >;
typedef $$CachedRelationshipsTableCreateCompanionBuilder =
    CachedRelationshipsCompanion Function({
      required String id,
      required String familyId,
      required String fromMemberId,
      required String toMemberId,
      required String type,
      Value<String?> status,
      Value<int?> marriageOrder,
      Value<int> rowid,
    });
typedef $$CachedRelationshipsTableUpdateCompanionBuilder =
    CachedRelationshipsCompanion Function({
      Value<String> id,
      Value<String> familyId,
      Value<String> fromMemberId,
      Value<String> toMemberId,
      Value<String> type,
      Value<String?> status,
      Value<int?> marriageOrder,
      Value<int> rowid,
    });

class $$CachedRelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRelationshipsTable> {
  $$CachedRelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromMemberId => $composableBuilder(
    column: $table.fromMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toMemberId => $composableBuilder(
    column: $table.toMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get marriageOrder => $composableBuilder(
    column: $table.marriageOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRelationshipsTable> {
  $$CachedRelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromMemberId => $composableBuilder(
    column: $table.fromMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toMemberId => $composableBuilder(
    column: $table.toMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marriageOrder => $composableBuilder(
    column: $table.marriageOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRelationshipsTable> {
  $$CachedRelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get fromMemberId => $composableBuilder(
    column: $table.fromMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toMemberId => $composableBuilder(
    column: $table.toMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get marriageOrder => $composableBuilder(
    column: $table.marriageOrder,
    builder: (column) => column,
  );
}

class $$CachedRelationshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRelationshipsTable,
          CachedRelationship,
          $$CachedRelationshipsTableFilterComposer,
          $$CachedRelationshipsTableOrderingComposer,
          $$CachedRelationshipsTableAnnotationComposer,
          $$CachedRelationshipsTableCreateCompanionBuilder,
          $$CachedRelationshipsTableUpdateCompanionBuilder,
          (
            CachedRelationship,
            BaseReferences<
              _$AppDatabase,
              $CachedRelationshipsTable,
              CachedRelationship
            >,
          ),
          CachedRelationship,
          PrefetchHooks Function()
        > {
  $$CachedRelationshipsTableTableManager(
    _$AppDatabase db,
    $CachedRelationshipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRelationshipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedRelationshipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> fromMemberId = const Value.absent(),
                Value<String> toMemberId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int?> marriageOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRelationshipsCompanion(
                id: id,
                familyId: familyId,
                fromMemberId: fromMemberId,
                toMemberId: toMemberId,
                type: type,
                status: status,
                marriageOrder: marriageOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                required String fromMemberId,
                required String toMemberId,
                required String type,
                Value<String?> status = const Value.absent(),
                Value<int?> marriageOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRelationshipsCompanion.insert(
                id: id,
                familyId: familyId,
                fromMemberId: fromMemberId,
                toMemberId: toMemberId,
                type: type,
                status: status,
                marriageOrder: marriageOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedRelationshipsTable,
      CachedRelationship,
      $$CachedRelationshipsTableFilterComposer,
      $$CachedRelationshipsTableOrderingComposer,
      $$CachedRelationshipsTableAnnotationComposer,
      $$CachedRelationshipsTableCreateCompanionBuilder,
      $$CachedRelationshipsTableUpdateCompanionBuilder,
      (
        CachedRelationship,
        BaseReferences<
          _$AppDatabase,
          $CachedRelationshipsTable,
          CachedRelationship
        >,
      ),
      CachedRelationship,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedMembersTableTableManager get cachedMembers =>
      $$CachedMembersTableTableManager(_db, _db.cachedMembers);
  $$CachedRelationshipsTableTableManager get cachedRelationships =>
      $$CachedRelationshipsTableTableManager(_db, _db.cachedRelationships);
}
