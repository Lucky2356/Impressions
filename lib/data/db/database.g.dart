// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('myPrimary'),
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
  static const VerificationMeta _avatarAttachmentIdMeta =
      const VerificationMeta('avatarAttachmentId');
  @override
  late final GeneratedColumn<String> avatarAttachmentId =
      GeneratedColumn<String>(
        'avatar_attachment_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileVersionMeta = const VerificationMeta(
    'profileVersion',
  );
  @override
  late final GeneratedColumn<int> profileVersion = GeneratedColumn<int>(
    'profile_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _retransmitModeMeta = const VerificationMeta(
    'retransmitMode',
  );
  @override
  late final GeneratedColumn<String> retransmitMode = GeneratedColumn<String>(
    'retransmit_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('allowed'),
  );
  static const VerificationMeta _currentRevisionIdMeta = const VerificationMeta(
    'currentRevisionId',
  );
  @override
  late final GeneratedColumn<String> currentRevisionId =
      GeneratedColumn<String>(
        'current_revision_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    firstName,
    lastName,
    nickname,
    avatarAttachmentId,
    color,
    bio,
    publicKey,
    fingerprint,
    profileVersion,
    retransmitMode,
    currentRevisionId,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
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
    if (data.containsKey('avatar_attachment_id')) {
      context.handle(
        _avatarAttachmentIdMeta,
        avatarAttachmentId.isAcceptableOrUnknown(
          data['avatar_attachment_id']!,
          _avatarAttachmentIdMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    }
    if (data.containsKey('profile_version')) {
      context.handle(
        _profileVersionMeta,
        profileVersion.isAcceptableOrUnknown(
          data['profile_version']!,
          _profileVersionMeta,
        ),
      );
    }
    if (data.containsKey('retransmit_mode')) {
      context.handle(
        _retransmitModeMeta,
        retransmitMode.isAcceptableOrUnknown(
          data['retransmit_mode']!,
          _retransmitModeMeta,
        ),
      );
    }
    if (data.containsKey('current_revision_id')) {
      context.handle(
        _currentRevisionIdMeta,
        currentRevisionId.isAcceptableOrUnknown(
          data['current_revision_id']!,
          _currentRevisionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
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
      avatarAttachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_attachment_id'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      ),
      profileVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_version'],
      )!,
      retransmitMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retransmit_mode'],
      )!,
      currentRevisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_revision_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String id;
  final String type;
  final String firstName;
  final String? lastName;
  final String? nickname;
  final String? avatarAttachmentId;
  final int? color;
  final String? bio;
  final String? publicKey;
  final String? fingerprint;
  final int profileVersion;

  /// Режим повторной передачи: allowed | discouraged | forbidden.
  final String retransmitMode;
  final String? currentRevisionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const ProfileRow({
    required this.id,
    required this.type,
    required this.firstName,
    this.lastName,
    this.nickname,
    this.avatarAttachmentId,
    this.color,
    this.bio,
    this.publicKey,
    this.fingerprint,
    required this.profileVersion,
    required this.retransmitMode,
    this.currentRevisionId,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || avatarAttachmentId != null) {
      map['avatar_attachment_id'] = Variable<String>(avatarAttachmentId);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    if (!nullToAbsent || fingerprint != null) {
      map['fingerprint'] = Variable<String>(fingerprint);
    }
    map['profile_version'] = Variable<int>(profileVersion);
    map['retransmit_mode'] = Variable<String>(retransmitMode);
    if (!nullToAbsent || currentRevisionId != null) {
      map['current_revision_id'] = Variable<String>(currentRevisionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      type: Value(type),
      firstName: Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      avatarAttachmentId: avatarAttachmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarAttachmentId),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
      fingerprint: fingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(fingerprint),
      profileVersion: Value(profileVersion),
      retransmitMode: Value(retransmitMode),
      currentRevisionId: currentRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentRevisionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      avatarAttachmentId: serializer.fromJson<String?>(
        json['avatarAttachmentId'],
      ),
      color: serializer.fromJson<int?>(json['color']),
      bio: serializer.fromJson<String?>(json['bio']),
      publicKey: serializer.fromJson<String?>(json['publicKey']),
      fingerprint: serializer.fromJson<String?>(json['fingerprint']),
      profileVersion: serializer.fromJson<int>(json['profileVersion']),
      retransmitMode: serializer.fromJson<String>(json['retransmitMode']),
      currentRevisionId: serializer.fromJson<String?>(
        json['currentRevisionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'nickname': serializer.toJson<String?>(nickname),
      'avatarAttachmentId': serializer.toJson<String?>(avatarAttachmentId),
      'color': serializer.toJson<int?>(color),
      'bio': serializer.toJson<String?>(bio),
      'publicKey': serializer.toJson<String?>(publicKey),
      'fingerprint': serializer.toJson<String?>(fingerprint),
      'profileVersion': serializer.toJson<int>(profileVersion),
      'retransmitMode': serializer.toJson<String>(retransmitMode),
      'currentRevisionId': serializer.toJson<String?>(currentRevisionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ProfileRow copyWith({
    String? id,
    String? type,
    String? firstName,
    Value<String?> lastName = const Value.absent(),
    Value<String?> nickname = const Value.absent(),
    Value<String?> avatarAttachmentId = const Value.absent(),
    Value<int?> color = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    Value<String?> publicKey = const Value.absent(),
    Value<String?> fingerprint = const Value.absent(),
    int? profileVersion,
    String? retransmitMode,
    Value<String?> currentRevisionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ProfileRow(
    id: id ?? this.id,
    type: type ?? this.type,
    firstName: firstName ?? this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    nickname: nickname.present ? nickname.value : this.nickname,
    avatarAttachmentId: avatarAttachmentId.present
        ? avatarAttachmentId.value
        : this.avatarAttachmentId,
    color: color.present ? color.value : this.color,
    bio: bio.present ? bio.value : this.bio,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    fingerprint: fingerprint.present ? fingerprint.value : this.fingerprint,
    profileVersion: profileVersion ?? this.profileVersion,
    retransmitMode: retransmitMode ?? this.retransmitMode,
    currentRevisionId: currentRevisionId.present
        ? currentRevisionId.value
        : this.currentRevisionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatarAttachmentId: data.avatarAttachmentId.present
          ? data.avatarAttachmentId.value
          : this.avatarAttachmentId,
      color: data.color.present ? data.color.value : this.color,
      bio: data.bio.present ? data.bio.value : this.bio,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      profileVersion: data.profileVersion.present
          ? data.profileVersion.value
          : this.profileVersion,
      retransmitMode: data.retransmitMode.present
          ? data.retransmitMode.value
          : this.retransmitMode,
      currentRevisionId: data.currentRevisionId.present
          ? data.currentRevisionId.value
          : this.currentRevisionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('nickname: $nickname, ')
          ..write('avatarAttachmentId: $avatarAttachmentId, ')
          ..write('color: $color, ')
          ..write('bio: $bio, ')
          ..write('publicKey: $publicKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('profileVersion: $profileVersion, ')
          ..write('retransmitMode: $retransmitMode, ')
          ..write('currentRevisionId: $currentRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    firstName,
    lastName,
    nickname,
    avatarAttachmentId,
    color,
    bio,
    publicKey,
    fingerprint,
    profileVersion,
    retransmitMode,
    currentRevisionId,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.nickname == this.nickname &&
          other.avatarAttachmentId == this.avatarAttachmentId &&
          other.color == this.color &&
          other.bio == this.bio &&
          other.publicKey == this.publicKey &&
          other.fingerprint == this.fingerprint &&
          other.profileVersion == this.profileVersion &&
          other.retransmitMode == this.retransmitMode &&
          other.currentRevisionId == this.currentRevisionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> firstName;
  final Value<String?> lastName;
  final Value<String?> nickname;
  final Value<String?> avatarAttachmentId;
  final Value<int?> color;
  final Value<String?> bio;
  final Value<String?> publicKey;
  final Value<String?> fingerprint;
  final Value<int> profileVersion;
  final Value<String> retransmitMode;
  final Value<String?> currentRevisionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarAttachmentId = const Value.absent(),
    this.color = const Value.absent(),
    this.bio = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.profileVersion = const Value.absent(),
    this.retransmitMode = const Value.absent(),
    this.currentRevisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    this.type = const Value.absent(),
    required String firstName,
    this.lastName = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarAttachmentId = const Value.absent(),
    this.color = const Value.absent(),
    this.bio = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.profileVersion = const Value.absent(),
    this.retransmitMode = const Value.absent(),
    this.currentRevisionId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       firstName = Value(firstName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? nickname,
    Expression<String>? avatarAttachmentId,
    Expression<int>? color,
    Expression<String>? bio,
    Expression<String>? publicKey,
    Expression<String>? fingerprint,
    Expression<int>? profileVersion,
    Expression<String>? retransmitMode,
    Expression<String>? currentRevisionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (nickname != null) 'nickname': nickname,
      if (avatarAttachmentId != null)
        'avatar_attachment_id': avatarAttachmentId,
      if (color != null) 'color': color,
      if (bio != null) 'bio': bio,
      if (publicKey != null) 'public_key': publicKey,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (profileVersion != null) 'profile_version': profileVersion,
      if (retransmitMode != null) 'retransmit_mode': retransmitMode,
      if (currentRevisionId != null) 'current_revision_id': currentRevisionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? firstName,
    Value<String?>? lastName,
    Value<String?>? nickname,
    Value<String?>? avatarAttachmentId,
    Value<int?>? color,
    Value<String?>? bio,
    Value<String?>? publicKey,
    Value<String?>? fingerprint,
    Value<int>? profileVersion,
    Value<String>? retransmitMode,
    Value<String?>? currentRevisionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      avatarAttachmentId: avatarAttachmentId ?? this.avatarAttachmentId,
      color: color ?? this.color,
      bio: bio ?? this.bio,
      publicKey: publicKey ?? this.publicKey,
      fingerprint: fingerprint ?? this.fingerprint,
      profileVersion: profileVersion ?? this.profileVersion,
      retransmitMode: retransmitMode ?? this.retransmitMode,
      currentRevisionId: currentRevisionId ?? this.currentRevisionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
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
    if (avatarAttachmentId.present) {
      map['avatar_attachment_id'] = Variable<String>(avatarAttachmentId.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (profileVersion.present) {
      map['profile_version'] = Variable<int>(profileVersion.value);
    }
    if (retransmitMode.present) {
      map['retransmit_mode'] = Variable<String>(retransmitMode.value);
    }
    if (currentRevisionId.present) {
      map['current_revision_id'] = Variable<String>(currentRevisionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('nickname: $nickname, ')
          ..write('avatarAttachmentId: $avatarAttachmentId, ')
          ..write('color: $color, ')
          ..write('bio: $bio, ')
          ..write('publicKey: $publicKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('profileVersion: $profileVersion, ')
          ..write('retransmitMode: $retransmitMode, ')
          ..write('currentRevisionId: $currentRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileDevicesTable extends ProfileDevices
    with TableInfo<$ProfileDevicesTable, ProfileDeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceTypeMeta = const VerificationMeta(
    'deviceType',
  );
  @override
  late final GeneratedColumn<String> deviceType = GeneratedColumn<String>(
    'device_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _osMeta = const VerificationMeta('os');
  @override
  late final GeneratedColumn<String> os = GeneratedColumn<String>(
    'os',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registeredAtMeta = const VerificationMeta(
    'registeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
    'registered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastExportAtMeta = const VerificationMeta(
    'lastExportAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastExportAt = GeneratedColumn<DateTime>(
    'last_export_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastImportAtMeta = const VerificationMeta(
    'lastImportAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastImportAt = GeneratedColumn<DateTime>(
    'last_import_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trustedMeta = const VerificationMeta(
    'trusted',
  );
  @override
  late final GeneratedColumn<bool> trusted = GeneratedColumn<bool>(
    'trusted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("trusted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    deviceType,
    model,
    os,
    registeredAt,
    lastExportAt,
    lastImportAt,
    trusted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileDeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('device_type')) {
      context.handle(
        _deviceTypeMeta,
        deviceType.isAcceptableOrUnknown(data['device_type']!, _deviceTypeMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('os')) {
      context.handle(_osMeta, os.isAcceptableOrUnknown(data['os']!, _osMeta));
    }
    if (data.containsKey('registered_at')) {
      context.handle(
        _registeredAtMeta,
        registeredAt.isAcceptableOrUnknown(
          data['registered_at']!,
          _registeredAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registeredAtMeta);
    }
    if (data.containsKey('last_export_at')) {
      context.handle(
        _lastExportAtMeta,
        lastExportAt.isAcceptableOrUnknown(
          data['last_export_at']!,
          _lastExportAtMeta,
        ),
      );
    }
    if (data.containsKey('last_import_at')) {
      context.handle(
        _lastImportAtMeta,
        lastImportAt.isAcceptableOrUnknown(
          data['last_import_at']!,
          _lastImportAtMeta,
        ),
      );
    }
    if (data.containsKey('trusted')) {
      context.handle(
        _trustedMeta,
        trusted.isAcceptableOrUnknown(data['trusted']!, _trustedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileDeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileDeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      deviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_type'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      os: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}os'],
      ),
      registeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registered_at'],
      )!,
      lastExportAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_export_at'],
      ),
      lastImportAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_import_at'],
      ),
      trusted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}trusted'],
      )!,
    );
  }

  @override
  $ProfileDevicesTable createAlias(String alias) {
    return $ProfileDevicesTable(attachedDatabase, alias);
  }
}

class ProfileDeviceRow extends DataClass
    implements Insertable<ProfileDeviceRow> {
  final String id;
  final String profileId;
  final String name;
  final String? deviceType;
  final String? model;
  final String? os;
  final DateTime registeredAt;
  final DateTime? lastExportAt;
  final DateTime? lastImportAt;
  final bool trusted;
  const ProfileDeviceRow({
    required this.id,
    required this.profileId,
    required this.name,
    this.deviceType,
    this.model,
    this.os,
    required this.registeredAt,
    this.lastExportAt,
    this.lastImportAt,
    required this.trusted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || deviceType != null) {
      map['device_type'] = Variable<String>(deviceType);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || os != null) {
      map['os'] = Variable<String>(os);
    }
    map['registered_at'] = Variable<DateTime>(registeredAt);
    if (!nullToAbsent || lastExportAt != null) {
      map['last_export_at'] = Variable<DateTime>(lastExportAt);
    }
    if (!nullToAbsent || lastImportAt != null) {
      map['last_import_at'] = Variable<DateTime>(lastImportAt);
    }
    map['trusted'] = Variable<bool>(trusted);
    return map;
  }

  ProfileDevicesCompanion toCompanion(bool nullToAbsent) {
    return ProfileDevicesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      deviceType: deviceType == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceType),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      os: os == null && nullToAbsent ? const Value.absent() : Value(os),
      registeredAt: Value(registeredAt),
      lastExportAt: lastExportAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExportAt),
      lastImportAt: lastImportAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastImportAt),
      trusted: Value(trusted),
    );
  }

  factory ProfileDeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileDeviceRow(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      deviceType: serializer.fromJson<String?>(json['deviceType']),
      model: serializer.fromJson<String?>(json['model']),
      os: serializer.fromJson<String?>(json['os']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
      lastExportAt: serializer.fromJson<DateTime?>(json['lastExportAt']),
      lastImportAt: serializer.fromJson<DateTime?>(json['lastImportAt']),
      trusted: serializer.fromJson<bool>(json['trusted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'deviceType': serializer.toJson<String?>(deviceType),
      'model': serializer.toJson<String?>(model),
      'os': serializer.toJson<String?>(os),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
      'lastExportAt': serializer.toJson<DateTime?>(lastExportAt),
      'lastImportAt': serializer.toJson<DateTime?>(lastImportAt),
      'trusted': serializer.toJson<bool>(trusted),
    };
  }

  ProfileDeviceRow copyWith({
    String? id,
    String? profileId,
    String? name,
    Value<String?> deviceType = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> os = const Value.absent(),
    DateTime? registeredAt,
    Value<DateTime?> lastExportAt = const Value.absent(),
    Value<DateTime?> lastImportAt = const Value.absent(),
    bool? trusted,
  }) => ProfileDeviceRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    deviceType: deviceType.present ? deviceType.value : this.deviceType,
    model: model.present ? model.value : this.model,
    os: os.present ? os.value : this.os,
    registeredAt: registeredAt ?? this.registeredAt,
    lastExportAt: lastExportAt.present ? lastExportAt.value : this.lastExportAt,
    lastImportAt: lastImportAt.present ? lastImportAt.value : this.lastImportAt,
    trusted: trusted ?? this.trusted,
  );
  ProfileDeviceRow copyWithCompanion(ProfileDevicesCompanion data) {
    return ProfileDeviceRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      deviceType: data.deviceType.present
          ? data.deviceType.value
          : this.deviceType,
      model: data.model.present ? data.model.value : this.model,
      os: data.os.present ? data.os.value : this.os,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
      lastExportAt: data.lastExportAt.present
          ? data.lastExportAt.value
          : this.lastExportAt,
      lastImportAt: data.lastImportAt.present
          ? data.lastImportAt.value
          : this.lastImportAt,
      trusted: data.trusted.present ? data.trusted.value : this.trusted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileDeviceRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('deviceType: $deviceType, ')
          ..write('model: $model, ')
          ..write('os: $os, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('lastExportAt: $lastExportAt, ')
          ..write('lastImportAt: $lastImportAt, ')
          ..write('trusted: $trusted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    deviceType,
    model,
    os,
    registeredAt,
    lastExportAt,
    lastImportAt,
    trusted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileDeviceRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.deviceType == this.deviceType &&
          other.model == this.model &&
          other.os == this.os &&
          other.registeredAt == this.registeredAt &&
          other.lastExportAt == this.lastExportAt &&
          other.lastImportAt == this.lastImportAt &&
          other.trusted == this.trusted);
}

class ProfileDevicesCompanion extends UpdateCompanion<ProfileDeviceRow> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String?> deviceType;
  final Value<String?> model;
  final Value<String?> os;
  final Value<DateTime> registeredAt;
  final Value<DateTime?> lastExportAt;
  final Value<DateTime?> lastImportAt;
  final Value<bool> trusted;
  final Value<int> rowid;
  const ProfileDevicesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.deviceType = const Value.absent(),
    this.model = const Value.absent(),
    this.os = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.lastExportAt = const Value.absent(),
    this.lastImportAt = const Value.absent(),
    this.trusted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileDevicesCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    this.deviceType = const Value.absent(),
    this.model = const Value.absent(),
    this.os = const Value.absent(),
    required DateTime registeredAt,
    this.lastExportAt = const Value.absent(),
    this.lastImportAt = const Value.absent(),
    this.trusted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       registeredAt = Value(registeredAt);
  static Insertable<ProfileDeviceRow> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? deviceType,
    Expression<String>? model,
    Expression<String>? os,
    Expression<DateTime>? registeredAt,
    Expression<DateTime>? lastExportAt,
    Expression<DateTime>? lastImportAt,
    Expression<bool>? trusted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (deviceType != null) 'device_type': deviceType,
      if (model != null) 'model': model,
      if (os != null) 'os': os,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (lastExportAt != null) 'last_export_at': lastExportAt,
      if (lastImportAt != null) 'last_import_at': lastImportAt,
      if (trusted != null) 'trusted': trusted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileDevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String?>? deviceType,
    Value<String?>? model,
    Value<String?>? os,
    Value<DateTime>? registeredAt,
    Value<DateTime?>? lastExportAt,
    Value<DateTime?>? lastImportAt,
    Value<bool>? trusted,
    Value<int>? rowid,
  }) {
    return ProfileDevicesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      model: model ?? this.model,
      os: os ?? this.os,
      registeredAt: registeredAt ?? this.registeredAt,
      lastExportAt: lastExportAt ?? this.lastExportAt,
      lastImportAt: lastImportAt ?? this.lastImportAt,
      trusted: trusted ?? this.trusted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (deviceType.present) {
      map['device_type'] = Variable<String>(deviceType.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (os.present) {
      map['os'] = Variable<String>(os.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (lastExportAt.present) {
      map['last_export_at'] = Variable<DateTime>(lastExportAt.value);
    }
    if (lastImportAt.present) {
      map['last_import_at'] = Variable<DateTime>(lastImportAt.value);
    }
    if (trusted.present) {
      map['trusted'] = Variable<bool>(trusted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileDevicesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('deviceType: $deviceType, ')
          ..write('model: $model, ')
          ..write('os: $os, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('lastExportAt: $lastExportAt, ')
          ..write('lastImportAt: $lastImportAt, ')
          ..write('trusted: $trusted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileLocalSettingsTable extends ProfileLocalSettings
    with TableInfo<$ProfileLocalSettingsTable, ProfileLocalSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileLocalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _localNameMeta = const VerificationMeta(
    'localName',
  );
  @override
  late final GeneratedColumn<String> localName = GeneratedColumn<String>(
    'local_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localNoteMeta = const VerificationMeta(
    'localNote',
  );
  @override
  late final GeneratedColumn<String> localNote = GeneratedColumn<String>(
    'local_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _displayColorMeta = const VerificationMeta(
    'displayColor',
  );
  @override
  late final GeneratedColumn<int> displayColor = GeneratedColumn<int>(
    'display_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _showOnHomeMeta = const VerificationMeta(
    'showOnHome',
  );
  @override
  late final GeneratedColumn<bool> showOnHome = GeneratedColumn<bool>(
    'show_on_home',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_on_home" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _trustedMeta = const VerificationMeta(
    'trusted',
  );
  @override
  late final GeneratedColumn<bool> trusted = GeneratedColumn<bool>(
    'trusted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("trusted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notifyUpdatesMeta = const VerificationMeta(
    'notifyUpdates',
  );
  @override
  late final GeneratedColumn<bool> notifyUpdates = GeneratedColumn<bool>(
    'notify_updates',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_updates" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastViewedAtMeta = const VerificationMeta(
    'lastViewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastViewedAt = GeneratedColumn<DateTime>(
    'last_viewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferModeMeta = const VerificationMeta(
    'transferMode',
  );
  @override
  late final GeneratedColumn<String> transferMode = GeneratedColumn<String>(
    'transfer_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('suggestMatch'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    localName,
    localNote,
    pinned,
    hidden,
    displayColor,
    showOnHome,
    trusted,
    notifyUpdates,
    lastViewedAt,
    transferMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_local_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileLocalSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('local_name')) {
      context.handle(
        _localNameMeta,
        localName.isAcceptableOrUnknown(data['local_name']!, _localNameMeta),
      );
    }
    if (data.containsKey('local_note')) {
      context.handle(
        _localNoteMeta,
        localNote.isAcceptableOrUnknown(data['local_note']!, _localNoteMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('display_color')) {
      context.handle(
        _displayColorMeta,
        displayColor.isAcceptableOrUnknown(
          data['display_color']!,
          _displayColorMeta,
        ),
      );
    }
    if (data.containsKey('show_on_home')) {
      context.handle(
        _showOnHomeMeta,
        showOnHome.isAcceptableOrUnknown(
          data['show_on_home']!,
          _showOnHomeMeta,
        ),
      );
    }
    if (data.containsKey('trusted')) {
      context.handle(
        _trustedMeta,
        trusted.isAcceptableOrUnknown(data['trusted']!, _trustedMeta),
      );
    }
    if (data.containsKey('notify_updates')) {
      context.handle(
        _notifyUpdatesMeta,
        notifyUpdates.isAcceptableOrUnknown(
          data['notify_updates']!,
          _notifyUpdatesMeta,
        ),
      );
    }
    if (data.containsKey('last_viewed_at')) {
      context.handle(
        _lastViewedAtMeta,
        lastViewedAt.isAcceptableOrUnknown(
          data['last_viewed_at']!,
          _lastViewedAtMeta,
        ),
      );
    }
    if (data.containsKey('transfer_mode')) {
      context.handle(
        _transferModeMeta,
        transferMode.isAcceptableOrUnknown(
          data['transfer_mode']!,
          _transferModeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileLocalSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileLocalSettingRow(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      localName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_name'],
      ),
      localNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_note'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      displayColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_color'],
      ),
      showOnHome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_on_home'],
      )!,
      trusted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}trusted'],
      )!,
      notifyUpdates: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_updates'],
      )!,
      lastViewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_viewed_at'],
      ),
      transferMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_mode'],
      )!,
    );
  }

  @override
  $ProfileLocalSettingsTable createAlias(String alias) {
    return $ProfileLocalSettingsTable(attachedDatabase, alias);
  }
}

class ProfileLocalSettingRow extends DataClass
    implements Insertable<ProfileLocalSettingRow> {
  final String profileId;
  final String? localName;
  final String? localNote;
  final bool pinned;
  final bool hidden;
  final int? displayColor;
  final bool showOnHome;
  final bool trusted;
  final bool notifyUpdates;
  final DateTime? lastViewedAt;

  /// Режим переноса записей (§7.4): suggestMatch | autoCreate | alwaysAsk |
  /// noCategory.
  final String transferMode;
  const ProfileLocalSettingRow({
    required this.profileId,
    this.localName,
    this.localNote,
    required this.pinned,
    required this.hidden,
    this.displayColor,
    required this.showOnHome,
    required this.trusted,
    required this.notifyUpdates,
    this.lastViewedAt,
    required this.transferMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || localName != null) {
      map['local_name'] = Variable<String>(localName);
    }
    if (!nullToAbsent || localNote != null) {
      map['local_note'] = Variable<String>(localNote);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['hidden'] = Variable<bool>(hidden);
    if (!nullToAbsent || displayColor != null) {
      map['display_color'] = Variable<int>(displayColor);
    }
    map['show_on_home'] = Variable<bool>(showOnHome);
    map['trusted'] = Variable<bool>(trusted);
    map['notify_updates'] = Variable<bool>(notifyUpdates);
    if (!nullToAbsent || lastViewedAt != null) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt);
    }
    map['transfer_mode'] = Variable<String>(transferMode);
    return map;
  }

  ProfileLocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return ProfileLocalSettingsCompanion(
      profileId: Value(profileId),
      localName: localName == null && nullToAbsent
          ? const Value.absent()
          : Value(localName),
      localNote: localNote == null && nullToAbsent
          ? const Value.absent()
          : Value(localNote),
      pinned: Value(pinned),
      hidden: Value(hidden),
      displayColor: displayColor == null && nullToAbsent
          ? const Value.absent()
          : Value(displayColor),
      showOnHome: Value(showOnHome),
      trusted: Value(trusted),
      notifyUpdates: Value(notifyUpdates),
      lastViewedAt: lastViewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastViewedAt),
      transferMode: Value(transferMode),
    );
  }

  factory ProfileLocalSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileLocalSettingRow(
      profileId: serializer.fromJson<String>(json['profileId']),
      localName: serializer.fromJson<String?>(json['localName']),
      localNote: serializer.fromJson<String?>(json['localNote']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      displayColor: serializer.fromJson<int?>(json['displayColor']),
      showOnHome: serializer.fromJson<bool>(json['showOnHome']),
      trusted: serializer.fromJson<bool>(json['trusted']),
      notifyUpdates: serializer.fromJson<bool>(json['notifyUpdates']),
      lastViewedAt: serializer.fromJson<DateTime?>(json['lastViewedAt']),
      transferMode: serializer.fromJson<String>(json['transferMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'localName': serializer.toJson<String?>(localName),
      'localNote': serializer.toJson<String?>(localNote),
      'pinned': serializer.toJson<bool>(pinned),
      'hidden': serializer.toJson<bool>(hidden),
      'displayColor': serializer.toJson<int?>(displayColor),
      'showOnHome': serializer.toJson<bool>(showOnHome),
      'trusted': serializer.toJson<bool>(trusted),
      'notifyUpdates': serializer.toJson<bool>(notifyUpdates),
      'lastViewedAt': serializer.toJson<DateTime?>(lastViewedAt),
      'transferMode': serializer.toJson<String>(transferMode),
    };
  }

  ProfileLocalSettingRow copyWith({
    String? profileId,
    Value<String?> localName = const Value.absent(),
    Value<String?> localNote = const Value.absent(),
    bool? pinned,
    bool? hidden,
    Value<int?> displayColor = const Value.absent(),
    bool? showOnHome,
    bool? trusted,
    bool? notifyUpdates,
    Value<DateTime?> lastViewedAt = const Value.absent(),
    String? transferMode,
  }) => ProfileLocalSettingRow(
    profileId: profileId ?? this.profileId,
    localName: localName.present ? localName.value : this.localName,
    localNote: localNote.present ? localNote.value : this.localNote,
    pinned: pinned ?? this.pinned,
    hidden: hidden ?? this.hidden,
    displayColor: displayColor.present ? displayColor.value : this.displayColor,
    showOnHome: showOnHome ?? this.showOnHome,
    trusted: trusted ?? this.trusted,
    notifyUpdates: notifyUpdates ?? this.notifyUpdates,
    lastViewedAt: lastViewedAt.present ? lastViewedAt.value : this.lastViewedAt,
    transferMode: transferMode ?? this.transferMode,
  );
  ProfileLocalSettingRow copyWithCompanion(ProfileLocalSettingsCompanion data) {
    return ProfileLocalSettingRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      localName: data.localName.present ? data.localName.value : this.localName,
      localNote: data.localNote.present ? data.localNote.value : this.localNote,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      displayColor: data.displayColor.present
          ? data.displayColor.value
          : this.displayColor,
      showOnHome: data.showOnHome.present
          ? data.showOnHome.value
          : this.showOnHome,
      trusted: data.trusted.present ? data.trusted.value : this.trusted,
      notifyUpdates: data.notifyUpdates.present
          ? data.notifyUpdates.value
          : this.notifyUpdates,
      lastViewedAt: data.lastViewedAt.present
          ? data.lastViewedAt.value
          : this.lastViewedAt,
      transferMode: data.transferMode.present
          ? data.transferMode.value
          : this.transferMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLocalSettingRow(')
          ..write('profileId: $profileId, ')
          ..write('localName: $localName, ')
          ..write('localNote: $localNote, ')
          ..write('pinned: $pinned, ')
          ..write('hidden: $hidden, ')
          ..write('displayColor: $displayColor, ')
          ..write('showOnHome: $showOnHome, ')
          ..write('trusted: $trusted, ')
          ..write('notifyUpdates: $notifyUpdates, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('transferMode: $transferMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    localName,
    localNote,
    pinned,
    hidden,
    displayColor,
    showOnHome,
    trusted,
    notifyUpdates,
    lastViewedAt,
    transferMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileLocalSettingRow &&
          other.profileId == this.profileId &&
          other.localName == this.localName &&
          other.localNote == this.localNote &&
          other.pinned == this.pinned &&
          other.hidden == this.hidden &&
          other.displayColor == this.displayColor &&
          other.showOnHome == this.showOnHome &&
          other.trusted == this.trusted &&
          other.notifyUpdates == this.notifyUpdates &&
          other.lastViewedAt == this.lastViewedAt &&
          other.transferMode == this.transferMode);
}

class ProfileLocalSettingsCompanion
    extends UpdateCompanion<ProfileLocalSettingRow> {
  final Value<String> profileId;
  final Value<String?> localName;
  final Value<String?> localNote;
  final Value<bool> pinned;
  final Value<bool> hidden;
  final Value<int?> displayColor;
  final Value<bool> showOnHome;
  final Value<bool> trusted;
  final Value<bool> notifyUpdates;
  final Value<DateTime?> lastViewedAt;
  final Value<String> transferMode;
  final Value<int> rowid;
  const ProfileLocalSettingsCompanion({
    this.profileId = const Value.absent(),
    this.localName = const Value.absent(),
    this.localNote = const Value.absent(),
    this.pinned = const Value.absent(),
    this.hidden = const Value.absent(),
    this.displayColor = const Value.absent(),
    this.showOnHome = const Value.absent(),
    this.trusted = const Value.absent(),
    this.notifyUpdates = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.transferMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileLocalSettingsCompanion.insert({
    required String profileId,
    this.localName = const Value.absent(),
    this.localNote = const Value.absent(),
    this.pinned = const Value.absent(),
    this.hidden = const Value.absent(),
    this.displayColor = const Value.absent(),
    this.showOnHome = const Value.absent(),
    this.trusted = const Value.absent(),
    this.notifyUpdates = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.transferMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId);
  static Insertable<ProfileLocalSettingRow> custom({
    Expression<String>? profileId,
    Expression<String>? localName,
    Expression<String>? localNote,
    Expression<bool>? pinned,
    Expression<bool>? hidden,
    Expression<int>? displayColor,
    Expression<bool>? showOnHome,
    Expression<bool>? trusted,
    Expression<bool>? notifyUpdates,
    Expression<DateTime>? lastViewedAt,
    Expression<String>? transferMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (localName != null) 'local_name': localName,
      if (localNote != null) 'local_note': localNote,
      if (pinned != null) 'pinned': pinned,
      if (hidden != null) 'hidden': hidden,
      if (displayColor != null) 'display_color': displayColor,
      if (showOnHome != null) 'show_on_home': showOnHome,
      if (trusted != null) 'trusted': trusted,
      if (notifyUpdates != null) 'notify_updates': notifyUpdates,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (transferMode != null) 'transfer_mode': transferMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileLocalSettingsCompanion copyWith({
    Value<String>? profileId,
    Value<String?>? localName,
    Value<String?>? localNote,
    Value<bool>? pinned,
    Value<bool>? hidden,
    Value<int?>? displayColor,
    Value<bool>? showOnHome,
    Value<bool>? trusted,
    Value<bool>? notifyUpdates,
    Value<DateTime?>? lastViewedAt,
    Value<String>? transferMode,
    Value<int>? rowid,
  }) {
    return ProfileLocalSettingsCompanion(
      profileId: profileId ?? this.profileId,
      localName: localName ?? this.localName,
      localNote: localNote ?? this.localNote,
      pinned: pinned ?? this.pinned,
      hidden: hidden ?? this.hidden,
      displayColor: displayColor ?? this.displayColor,
      showOnHome: showOnHome ?? this.showOnHome,
      trusted: trusted ?? this.trusted,
      notifyUpdates: notifyUpdates ?? this.notifyUpdates,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      transferMode: transferMode ?? this.transferMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (localName.present) {
      map['local_name'] = Variable<String>(localName.value);
    }
    if (localNote.present) {
      map['local_note'] = Variable<String>(localNote.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (displayColor.present) {
      map['display_color'] = Variable<int>(displayColor.value);
    }
    if (showOnHome.present) {
      map['show_on_home'] = Variable<bool>(showOnHome.value);
    }
    if (trusted.present) {
      map['trusted'] = Variable<bool>(trusted.value);
    }
    if (notifyUpdates.present) {
      map['notify_updates'] = Variable<bool>(notifyUpdates.value);
    }
    if (lastViewedAt.present) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt.value);
    }
    if (transferMode.present) {
      map['transfer_mode'] = Variable<String>(transferMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLocalSettingsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('localName: $localName, ')
          ..write('localNote: $localNote, ')
          ..write('pinned: $pinned, ')
          ..write('hidden: $hidden, ')
          ..write('displayColor: $displayColor, ')
          ..write('showOnHome: $showOnHome, ')
          ..write('trusted: $trusted, ')
          ..write('notifyUpdates: $notifyUpdates, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('transferMode: $transferMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileKeysTable extends ProfileKeys
    with TableInfo<$ProfileKeysTable, ProfileKeyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPrivateKeyMeta =
      const VerificationMeta('encryptedPrivateKey');
  @override
  late final GeneratedColumn<String> encryptedPrivateKey =
      GeneratedColumn<String>(
        'encrypted_private_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    publicKey,
    fingerprint,
    encryptedPrivateKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_keys';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileKeyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('encrypted_private_key')) {
      context.handle(
        _encryptedPrivateKeyMeta,
        encryptedPrivateKey.isAcceptableOrUnknown(
          data['encrypted_private_key']!,
          _encryptedPrivateKeyMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileKeyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileKeyRow(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      encryptedPrivateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_private_key'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProfileKeysTable createAlias(String alias) {
    return $ProfileKeysTable(attachedDatabase, alias);
  }
}

class ProfileKeyRow extends DataClass implements Insertable<ProfileKeyRow> {
  final String profileId;
  final String publicKey;
  final String fingerprint;

  /// Зашифрованный закрытый ключ (null для внешних профилей).
  final String? encryptedPrivateKey;
  final DateTime createdAt;
  const ProfileKeyRow({
    required this.profileId,
    required this.publicKey,
    required this.fingerprint,
    this.encryptedPrivateKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['public_key'] = Variable<String>(publicKey);
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || encryptedPrivateKey != null) {
      map['encrypted_private_key'] = Variable<String>(encryptedPrivateKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfileKeysCompanion toCompanion(bool nullToAbsent) {
    return ProfileKeysCompanion(
      profileId: Value(profileId),
      publicKey: Value(publicKey),
      fingerprint: Value(fingerprint),
      encryptedPrivateKey: encryptedPrivateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedPrivateKey),
      createdAt: Value(createdAt),
    );
  }

  factory ProfileKeyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileKeyRow(
      profileId: serializer.fromJson<String>(json['profileId']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      encryptedPrivateKey: serializer.fromJson<String?>(
        json['encryptedPrivateKey'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'publicKey': serializer.toJson<String>(publicKey),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'encryptedPrivateKey': serializer.toJson<String?>(encryptedPrivateKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProfileKeyRow copyWith({
    String? profileId,
    String? publicKey,
    String? fingerprint,
    Value<String?> encryptedPrivateKey = const Value.absent(),
    DateTime? createdAt,
  }) => ProfileKeyRow(
    profileId: profileId ?? this.profileId,
    publicKey: publicKey ?? this.publicKey,
    fingerprint: fingerprint ?? this.fingerprint,
    encryptedPrivateKey: encryptedPrivateKey.present
        ? encryptedPrivateKey.value
        : this.encryptedPrivateKey,
    createdAt: createdAt ?? this.createdAt,
  );
  ProfileKeyRow copyWithCompanion(ProfileKeysCompanion data) {
    return ProfileKeyRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      encryptedPrivateKey: data.encryptedPrivateKey.present
          ? data.encryptedPrivateKey.value
          : this.encryptedPrivateKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileKeyRow(')
          ..write('profileId: $profileId, ')
          ..write('publicKey: $publicKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('encryptedPrivateKey: $encryptedPrivateKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    publicKey,
    fingerprint,
    encryptedPrivateKey,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileKeyRow &&
          other.profileId == this.profileId &&
          other.publicKey == this.publicKey &&
          other.fingerprint == this.fingerprint &&
          other.encryptedPrivateKey == this.encryptedPrivateKey &&
          other.createdAt == this.createdAt);
}

class ProfileKeysCompanion extends UpdateCompanion<ProfileKeyRow> {
  final Value<String> profileId;
  final Value<String> publicKey;
  final Value<String> fingerprint;
  final Value<String?> encryptedPrivateKey;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProfileKeysCompanion({
    this.profileId = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.encryptedPrivateKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileKeysCompanion.insert({
    required String profileId,
    required String publicKey,
    required String fingerprint,
    this.encryptedPrivateKey = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       publicKey = Value(publicKey),
       fingerprint = Value(fingerprint),
       createdAt = Value(createdAt);
  static Insertable<ProfileKeyRow> custom({
    Expression<String>? profileId,
    Expression<String>? publicKey,
    Expression<String>? fingerprint,
    Expression<String>? encryptedPrivateKey,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (publicKey != null) 'public_key': publicKey,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (encryptedPrivateKey != null)
        'encrypted_private_key': encryptedPrivateKey,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileKeysCompanion copyWith({
    Value<String>? profileId,
    Value<String>? publicKey,
    Value<String>? fingerprint,
    Value<String?>? encryptedPrivateKey,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProfileKeysCompanion(
      profileId: profileId ?? this.profileId,
      publicKey: publicKey ?? this.publicKey,
      fingerprint: fingerprint ?? this.fingerprint,
      encryptedPrivateKey: encryptedPrivateKey ?? this.encryptedPrivateKey,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (encryptedPrivateKey.present) {
      map['encrypted_private_key'] = Variable<String>(
        encryptedPrivateKey.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileKeysCompanion(')
          ..write('profileId: $profileId, ')
          ..write('publicKey: $publicKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('encryptedPrivateKey: $encryptedPrivateKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObjectTypesTable extends ObjectTypes
    with TableInfo<$ObjectTypesTable, ObjectTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObjectTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta(
    'builtIn',
  );
  @override
  late final GeneratedColumn<bool> builtIn = GeneratedColumn<bool>(
    'built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fieldsSchemaMeta = const VerificationMeta(
    'fieldsSchema',
  );
  @override
  late final GeneratedColumn<String> fieldsSchema = GeneratedColumn<String>(
    'fields_schema',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    normalizedName,
    icon,
    color,
    sortOrder,
    builtIn,
    hidden,
    fieldsSchema,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'object_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObjectTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('built_in')) {
      context.handle(
        _builtInMeta,
        builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('fields_schema')) {
      context.handle(
        _fieldsSchemaMeta,
        fieldsSchema.isAcceptableOrUnknown(
          data['fields_schema']!,
          _fieldsSchemaMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObjectTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObjectTypeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      builtIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}built_in'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      fieldsSchema: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_schema'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ObjectTypesTable createAlias(String alias) {
    return $ObjectTypesTable(attachedDatabase, alias);
  }
}

class ObjectTypeRow extends DataClass implements Insertable<ObjectTypeRow> {
  final String id;
  final String profileId;
  final String name;
  final String normalizedName;
  final String? icon;
  final int? color;
  final int sortOrder;
  final bool builtIn;
  final bool hidden;

  /// JSON-схема пользовательских полей типа (§9).
  final String? fieldsSchema;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const ObjectTypeRow({
    required this.id,
    required this.profileId,
    required this.name,
    required this.normalizedName,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.builtIn,
    required this.hidden,
    this.fieldsSchema,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['built_in'] = Variable<bool>(builtIn);
    map['hidden'] = Variable<bool>(hidden);
    if (!nullToAbsent || fieldsSchema != null) {
      map['fields_schema'] = Variable<String>(fieldsSchema);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ObjectTypesCompanion toCompanion(bool nullToAbsent) {
    return ObjectTypesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      sortOrder: Value(sortOrder),
      builtIn: Value(builtIn),
      hidden: Value(hidden),
      fieldsSchema: fieldsSchema == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldsSchema),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ObjectTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObjectTypeRow(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<int?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      builtIn: serializer.fromJson<bool>(json['builtIn']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      fieldsSchema: serializer.fromJson<String?>(json['fieldsSchema']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<int?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'builtIn': serializer.toJson<bool>(builtIn),
      'hidden': serializer.toJson<bool>(hidden),
      'fieldsSchema': serializer.toJson<String?>(fieldsSchema),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ObjectTypeRow copyWith({
    String? id,
    String? profileId,
    String? name,
    String? normalizedName,
    Value<String?> icon = const Value.absent(),
    Value<int?> color = const Value.absent(),
    int? sortOrder,
    bool? builtIn,
    bool? hidden,
    Value<String?> fieldsSchema = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ObjectTypeRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    builtIn: builtIn ?? this.builtIn,
    hidden: hidden ?? this.hidden,
    fieldsSchema: fieldsSchema.present ? fieldsSchema.value : this.fieldsSchema,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ObjectTypeRow copyWithCompanion(ObjectTypesCompanion data) {
    return ObjectTypeRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      fieldsSchema: data.fieldsSchema.present
          ? data.fieldsSchema.value
          : this.fieldsSchema,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObjectTypeRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('builtIn: $builtIn, ')
          ..write('hidden: $hidden, ')
          ..write('fieldsSchema: $fieldsSchema, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    normalizedName,
    icon,
    color,
    sortOrder,
    builtIn,
    hidden,
    fieldsSchema,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObjectTypeRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.builtIn == this.builtIn &&
          other.hidden == this.hidden &&
          other.fieldsSchema == this.fieldsSchema &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class ObjectTypesCompanion extends UpdateCompanion<ObjectTypeRow> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String?> icon;
  final Value<int?> color;
  final Value<int> sortOrder;
  final Value<bool> builtIn;
  final Value<bool> hidden;
  final Value<String?> fieldsSchema;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ObjectTypesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.hidden = const Value.absent(),
    this.fieldsSchema = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObjectTypesCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    required String normalizedName,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.hidden = const Value.absent(),
    this.fieldsSchema = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       createdAt = Value(createdAt);
  static Insertable<ObjectTypeRow> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<bool>? builtIn,
    Expression<bool>? hidden,
    Expression<String>? fieldsSchema,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (builtIn != null) 'built_in': builtIn,
      if (hidden != null) 'hidden': hidden,
      if (fieldsSchema != null) 'fields_schema': fieldsSchema,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObjectTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String?>? icon,
    Value<int?>? color,
    Value<int>? sortOrder,
    Value<bool>? builtIn,
    Value<bool>? hidden,
    Value<String?>? fieldsSchema,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ObjectTypesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      builtIn: builtIn ?? this.builtIn,
      hidden: hidden ?? this.hidden,
      fieldsSchema: fieldsSchema ?? this.fieldsSchema,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<bool>(builtIn.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (fieldsSchema.present) {
      map['fields_schema'] = Variable<String>(fieldsSchema.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObjectTypesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('builtIn: $builtIn, ')
          ..write('hidden: $hidden, ')
          ..write('fieldsSchema: $fieldsSchema, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObjectsTable extends Objects with TableInfo<$ObjectsTable, ObjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<String> typeId = GeneratedColumn<String>(
    'type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES object_types (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTitleMeta = const VerificationMeta(
    'normalizedTitle',
  );
  @override
  late final GeneratedColumn<String> normalizedTitle = GeneratedColumn<String>(
    'normalized_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altTitleMeta = const VerificationMeta(
    'altTitle',
  );
  @override
  late final GeneratedColumn<String> altTitle = GeneratedColumn<String>(
    'alt_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedAltTitleMeta =
      const VerificationMeta('normalizedAltTitle');
  @override
  late final GeneratedColumn<String> normalizedAltTitle =
      GeneratedColumn<String>(
        'normalized_alt_title',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorMeta = const VerificationMeta(
    'creator',
  );
  @override
  late final GeneratedColumn<String> creator = GeneratedColumn<String>(
    'creator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customFieldsMeta = const VerificationMeta(
    'customFields',
  );
  @override
  late final GeneratedColumn<String> customFields = GeneratedColumn<String>(
    'custom_fields',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentRevisionIdMeta = const VerificationMeta(
    'currentRevisionId',
  );
  @override
  late final GeneratedColumn<String> currentRevisionId =
      GeneratedColumn<String>(
        'current_revision_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    typeId,
    title,
    normalizedTitle,
    altTitle,
    normalizedAltTitle,
    summary,
    creator,
    year,
    barcode,
    customFields,
    currentRevisionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'objects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_typeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('normalized_title')) {
      context.handle(
        _normalizedTitleMeta,
        normalizedTitle.isAcceptableOrUnknown(
          data['normalized_title']!,
          _normalizedTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedTitleMeta);
    }
    if (data.containsKey('alt_title')) {
      context.handle(
        _altTitleMeta,
        altTitle.isAcceptableOrUnknown(data['alt_title']!, _altTitleMeta),
      );
    }
    if (data.containsKey('normalized_alt_title')) {
      context.handle(
        _normalizedAltTitleMeta,
        normalizedAltTitle.isAcceptableOrUnknown(
          data['normalized_alt_title']!,
          _normalizedAltTitleMeta,
        ),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('creator')) {
      context.handle(
        _creatorMeta,
        creator.isAcceptableOrUnknown(data['creator']!, _creatorMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('custom_fields')) {
      context.handle(
        _customFieldsMeta,
        customFields.isAcceptableOrUnknown(
          data['custom_fields']!,
          _customFieldsMeta,
        ),
      );
    }
    if (data.containsKey('current_revision_id')) {
      context.handle(
        _currentRevisionIdMeta,
        currentRevisionId.isAcceptableOrUnknown(
          data['current_revision_id']!,
          _currentRevisionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObjectRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      normalizedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_title'],
      )!,
      altTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_title'],
      ),
      normalizedAltTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_alt_title'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      creator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      customFields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_fields'],
      ),
      currentRevisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_revision_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ObjectsTable createAlias(String alias) {
    return $ObjectsTable(attachedDatabase, alias);
  }
}

class ObjectRow extends DataClass implements Insertable<ObjectRow> {
  final String id;
  final String typeId;
  final String title;
  final String normalizedTitle;
  final String? altTitle;
  final String? normalizedAltTitle;
  final String? summary;

  /// Бренд/автор/режиссёр/исполнитель.
  final String? creator;
  final int? year;
  final String? barcode;

  /// JSON значений пользовательских полей.
  final String? customFields;
  final String? currentRevisionId;
  final DateTime createdAt;
  const ObjectRow({
    required this.id,
    required this.typeId,
    required this.title,
    required this.normalizedTitle,
    this.altTitle,
    this.normalizedAltTitle,
    this.summary,
    this.creator,
    this.year,
    this.barcode,
    this.customFields,
    this.currentRevisionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type_id'] = Variable<String>(typeId);
    map['title'] = Variable<String>(title);
    map['normalized_title'] = Variable<String>(normalizedTitle);
    if (!nullToAbsent || altTitle != null) {
      map['alt_title'] = Variable<String>(altTitle);
    }
    if (!nullToAbsent || normalizedAltTitle != null) {
      map['normalized_alt_title'] = Variable<String>(normalizedAltTitle);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || creator != null) {
      map['creator'] = Variable<String>(creator);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || customFields != null) {
      map['custom_fields'] = Variable<String>(customFields);
    }
    if (!nullToAbsent || currentRevisionId != null) {
      map['current_revision_id'] = Variable<String>(currentRevisionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ObjectsCompanion toCompanion(bool nullToAbsent) {
    return ObjectsCompanion(
      id: Value(id),
      typeId: Value(typeId),
      title: Value(title),
      normalizedTitle: Value(normalizedTitle),
      altTitle: altTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(altTitle),
      normalizedAltTitle: normalizedAltTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedAltTitle),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      creator: creator == null && nullToAbsent
          ? const Value.absent()
          : Value(creator),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      customFields: customFields == null && nullToAbsent
          ? const Value.absent()
          : Value(customFields),
      currentRevisionId: currentRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentRevisionId),
      createdAt: Value(createdAt),
    );
  }

  factory ObjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObjectRow(
      id: serializer.fromJson<String>(json['id']),
      typeId: serializer.fromJson<String>(json['typeId']),
      title: serializer.fromJson<String>(json['title']),
      normalizedTitle: serializer.fromJson<String>(json['normalizedTitle']),
      altTitle: serializer.fromJson<String?>(json['altTitle']),
      normalizedAltTitle: serializer.fromJson<String?>(
        json['normalizedAltTitle'],
      ),
      summary: serializer.fromJson<String?>(json['summary']),
      creator: serializer.fromJson<String?>(json['creator']),
      year: serializer.fromJson<int?>(json['year']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      customFields: serializer.fromJson<String?>(json['customFields']),
      currentRevisionId: serializer.fromJson<String?>(
        json['currentRevisionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'typeId': serializer.toJson<String>(typeId),
      'title': serializer.toJson<String>(title),
      'normalizedTitle': serializer.toJson<String>(normalizedTitle),
      'altTitle': serializer.toJson<String?>(altTitle),
      'normalizedAltTitle': serializer.toJson<String?>(normalizedAltTitle),
      'summary': serializer.toJson<String?>(summary),
      'creator': serializer.toJson<String?>(creator),
      'year': serializer.toJson<int?>(year),
      'barcode': serializer.toJson<String?>(barcode),
      'customFields': serializer.toJson<String?>(customFields),
      'currentRevisionId': serializer.toJson<String?>(currentRevisionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ObjectRow copyWith({
    String? id,
    String? typeId,
    String? title,
    String? normalizedTitle,
    Value<String?> altTitle = const Value.absent(),
    Value<String?> normalizedAltTitle = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> creator = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    Value<String?> customFields = const Value.absent(),
    Value<String?> currentRevisionId = const Value.absent(),
    DateTime? createdAt,
  }) => ObjectRow(
    id: id ?? this.id,
    typeId: typeId ?? this.typeId,
    title: title ?? this.title,
    normalizedTitle: normalizedTitle ?? this.normalizedTitle,
    altTitle: altTitle.present ? altTitle.value : this.altTitle,
    normalizedAltTitle: normalizedAltTitle.present
        ? normalizedAltTitle.value
        : this.normalizedAltTitle,
    summary: summary.present ? summary.value : this.summary,
    creator: creator.present ? creator.value : this.creator,
    year: year.present ? year.value : this.year,
    barcode: barcode.present ? barcode.value : this.barcode,
    customFields: customFields.present ? customFields.value : this.customFields,
    currentRevisionId: currentRevisionId.present
        ? currentRevisionId.value
        : this.currentRevisionId,
    createdAt: createdAt ?? this.createdAt,
  );
  ObjectRow copyWithCompanion(ObjectsCompanion data) {
    return ObjectRow(
      id: data.id.present ? data.id.value : this.id,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      title: data.title.present ? data.title.value : this.title,
      normalizedTitle: data.normalizedTitle.present
          ? data.normalizedTitle.value
          : this.normalizedTitle,
      altTitle: data.altTitle.present ? data.altTitle.value : this.altTitle,
      normalizedAltTitle: data.normalizedAltTitle.present
          ? data.normalizedAltTitle.value
          : this.normalizedAltTitle,
      summary: data.summary.present ? data.summary.value : this.summary,
      creator: data.creator.present ? data.creator.value : this.creator,
      year: data.year.present ? data.year.value : this.year,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      customFields: data.customFields.present
          ? data.customFields.value
          : this.customFields,
      currentRevisionId: data.currentRevisionId.present
          ? data.currentRevisionId.value
          : this.currentRevisionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObjectRow(')
          ..write('id: $id, ')
          ..write('typeId: $typeId, ')
          ..write('title: $title, ')
          ..write('normalizedTitle: $normalizedTitle, ')
          ..write('altTitle: $altTitle, ')
          ..write('normalizedAltTitle: $normalizedAltTitle, ')
          ..write('summary: $summary, ')
          ..write('creator: $creator, ')
          ..write('year: $year, ')
          ..write('barcode: $barcode, ')
          ..write('customFields: $customFields, ')
          ..write('currentRevisionId: $currentRevisionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    typeId,
    title,
    normalizedTitle,
    altTitle,
    normalizedAltTitle,
    summary,
    creator,
    year,
    barcode,
    customFields,
    currentRevisionId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObjectRow &&
          other.id == this.id &&
          other.typeId == this.typeId &&
          other.title == this.title &&
          other.normalizedTitle == this.normalizedTitle &&
          other.altTitle == this.altTitle &&
          other.normalizedAltTitle == this.normalizedAltTitle &&
          other.summary == this.summary &&
          other.creator == this.creator &&
          other.year == this.year &&
          other.barcode == this.barcode &&
          other.customFields == this.customFields &&
          other.currentRevisionId == this.currentRevisionId &&
          other.createdAt == this.createdAt);
}

class ObjectsCompanion extends UpdateCompanion<ObjectRow> {
  final Value<String> id;
  final Value<String> typeId;
  final Value<String> title;
  final Value<String> normalizedTitle;
  final Value<String?> altTitle;
  final Value<String?> normalizedAltTitle;
  final Value<String?> summary;
  final Value<String?> creator;
  final Value<int?> year;
  final Value<String?> barcode;
  final Value<String?> customFields;
  final Value<String?> currentRevisionId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ObjectsCompanion({
    this.id = const Value.absent(),
    this.typeId = const Value.absent(),
    this.title = const Value.absent(),
    this.normalizedTitle = const Value.absent(),
    this.altTitle = const Value.absent(),
    this.normalizedAltTitle = const Value.absent(),
    this.summary = const Value.absent(),
    this.creator = const Value.absent(),
    this.year = const Value.absent(),
    this.barcode = const Value.absent(),
    this.customFields = const Value.absent(),
    this.currentRevisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObjectsCompanion.insert({
    required String id,
    required String typeId,
    required String title,
    required String normalizedTitle,
    this.altTitle = const Value.absent(),
    this.normalizedAltTitle = const Value.absent(),
    this.summary = const Value.absent(),
    this.creator = const Value.absent(),
    this.year = const Value.absent(),
    this.barcode = const Value.absent(),
    this.customFields = const Value.absent(),
    this.currentRevisionId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       typeId = Value(typeId),
       title = Value(title),
       normalizedTitle = Value(normalizedTitle),
       createdAt = Value(createdAt);
  static Insertable<ObjectRow> custom({
    Expression<String>? id,
    Expression<String>? typeId,
    Expression<String>? title,
    Expression<String>? normalizedTitle,
    Expression<String>? altTitle,
    Expression<String>? normalizedAltTitle,
    Expression<String>? summary,
    Expression<String>? creator,
    Expression<int>? year,
    Expression<String>? barcode,
    Expression<String>? customFields,
    Expression<String>? currentRevisionId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeId != null) 'type_id': typeId,
      if (title != null) 'title': title,
      if (normalizedTitle != null) 'normalized_title': normalizedTitle,
      if (altTitle != null) 'alt_title': altTitle,
      if (normalizedAltTitle != null)
        'normalized_alt_title': normalizedAltTitle,
      if (summary != null) 'summary': summary,
      if (creator != null) 'creator': creator,
      if (year != null) 'year': year,
      if (barcode != null) 'barcode': barcode,
      if (customFields != null) 'custom_fields': customFields,
      if (currentRevisionId != null) 'current_revision_id': currentRevisionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? typeId,
    Value<String>? title,
    Value<String>? normalizedTitle,
    Value<String?>? altTitle,
    Value<String?>? normalizedAltTitle,
    Value<String?>? summary,
    Value<String?>? creator,
    Value<int?>? year,
    Value<String?>? barcode,
    Value<String?>? customFields,
    Value<String?>? currentRevisionId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ObjectsCompanion(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      title: title ?? this.title,
      normalizedTitle: normalizedTitle ?? this.normalizedTitle,
      altTitle: altTitle ?? this.altTitle,
      normalizedAltTitle: normalizedAltTitle ?? this.normalizedAltTitle,
      summary: summary ?? this.summary,
      creator: creator ?? this.creator,
      year: year ?? this.year,
      barcode: barcode ?? this.barcode,
      customFields: customFields ?? this.customFields,
      currentRevisionId: currentRevisionId ?? this.currentRevisionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<String>(typeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (normalizedTitle.present) {
      map['normalized_title'] = Variable<String>(normalizedTitle.value);
    }
    if (altTitle.present) {
      map['alt_title'] = Variable<String>(altTitle.value);
    }
    if (normalizedAltTitle.present) {
      map['normalized_alt_title'] = Variable<String>(normalizedAltTitle.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (creator.present) {
      map['creator'] = Variable<String>(creator.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (customFields.present) {
      map['custom_fields'] = Variable<String>(customFields.value);
    }
    if (currentRevisionId.present) {
      map['current_revision_id'] = Variable<String>(currentRevisionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObjectsCompanion(')
          ..write('id: $id, ')
          ..write('typeId: $typeId, ')
          ..write('title: $title, ')
          ..write('normalizedTitle: $normalizedTitle, ')
          ..write('altTitle: $altTitle, ')
          ..write('normalizedAltTitle: $normalizedAltTitle, ')
          ..write('summary: $summary, ')
          ..write('creator: $creator, ')
          ..write('year: $year, ')
          ..write('barcode: $barcode, ')
          ..write('customFields: $customFields, ')
          ..write('currentRevisionId: $currentRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObjectRevisionsTable extends ObjectRevisions
    with TableInfo<$ObjectRevisionsTable, ObjectRevisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObjectRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objects (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _parentRevisionIdMeta = const VerificationMeta(
    'parentRevisionId',
  );
  @override
  late final GeneratedColumn<String> parentRevisionId = GeneratedColumn<String>(
    'parent_revision_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorProfileIdMeta = const VerificationMeta(
    'authorProfileId',
  );
  @override
  late final GeneratedColumn<String> authorProfileId = GeneratedColumn<String>(
    'author_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadVersionMeta = const VerificationMeta(
    'payloadVersion',
  );
  @override
  late final GeneratedColumn<int> payloadVersion = GeneratedColumn<int>(
    'payload_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originPackageIdMeta = const VerificationMeta(
    'originPackageId',
  );
  @override
  late final GeneratedColumn<String> originPackageId = GeneratedColumn<String>(
    'origin_package_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    objectId,
    parentRevisionId,
    authorProfileId,
    deviceId,
    createdAt,
    importedAt,
    payloadVersion,
    payloadJson,
    contentHash,
    originPackageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'object_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObjectRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('parent_revision_id')) {
      context.handle(
        _parentRevisionIdMeta,
        parentRevisionId.isAcceptableOrUnknown(
          data['parent_revision_id']!,
          _parentRevisionIdMeta,
        ),
      );
    }
    if (data.containsKey('author_profile_id')) {
      context.handle(
        _authorProfileIdMeta,
        authorProfileId.isAcceptableOrUnknown(
          data['author_profile_id']!,
          _authorProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('payload_version')) {
      context.handle(
        _payloadVersionMeta,
        payloadVersion.isAcceptableOrUnknown(
          data['payload_version']!,
          _payloadVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('origin_package_id')) {
      context.handle(
        _originPackageIdMeta,
        originPackageId.isAcceptableOrUnknown(
          data['origin_package_id']!,
          _originPackageIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObjectRevisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObjectRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      objectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_id'],
      )!,
      parentRevisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_revision_id'],
      ),
      authorProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_profile_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      ),
      payloadVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      originPackageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_package_id'],
      ),
    );
  }

  @override
  $ObjectRevisionsTable createAlias(String alias) {
    return $ObjectRevisionsTable(attachedDatabase, alias);
  }
}

class ObjectRevisionRow extends DataClass
    implements Insertable<ObjectRevisionRow> {
  final String id;
  final String objectId;
  final String? parentRevisionId;
  final String? authorProfileId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime? importedAt;
  final int payloadVersion;
  final String payloadJson;
  final String contentHash;
  final String? originPackageId;
  const ObjectRevisionRow({
    required this.id,
    required this.objectId,
    this.parentRevisionId,
    this.authorProfileId,
    this.deviceId,
    required this.createdAt,
    this.importedAt,
    required this.payloadVersion,
    required this.payloadJson,
    required this.contentHash,
    this.originPackageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['object_id'] = Variable<String>(objectId);
    if (!nullToAbsent || parentRevisionId != null) {
      map['parent_revision_id'] = Variable<String>(parentRevisionId);
    }
    if (!nullToAbsent || authorProfileId != null) {
      map['author_profile_id'] = Variable<String>(authorProfileId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<DateTime>(importedAt);
    }
    map['payload_version'] = Variable<int>(payloadVersion);
    map['payload_json'] = Variable<String>(payloadJson);
    map['content_hash'] = Variable<String>(contentHash);
    if (!nullToAbsent || originPackageId != null) {
      map['origin_package_id'] = Variable<String>(originPackageId);
    }
    return map;
  }

  ObjectRevisionsCompanion toCompanion(bool nullToAbsent) {
    return ObjectRevisionsCompanion(
      id: Value(id),
      objectId: Value(objectId),
      parentRevisionId: parentRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentRevisionId),
      authorProfileId: authorProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorProfileId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
      payloadVersion: Value(payloadVersion),
      payloadJson: Value(payloadJson),
      contentHash: Value(contentHash),
      originPackageId: originPackageId == null && nullToAbsent
          ? const Value.absent()
          : Value(originPackageId),
    );
  }

  factory ObjectRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObjectRevisionRow(
      id: serializer.fromJson<String>(json['id']),
      objectId: serializer.fromJson<String>(json['objectId']),
      parentRevisionId: serializer.fromJson<String?>(json['parentRevisionId']),
      authorProfileId: serializer.fromJson<String?>(json['authorProfileId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      importedAt: serializer.fromJson<DateTime?>(json['importedAt']),
      payloadVersion: serializer.fromJson<int>(json['payloadVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      originPackageId: serializer.fromJson<String?>(json['originPackageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'objectId': serializer.toJson<String>(objectId),
      'parentRevisionId': serializer.toJson<String?>(parentRevisionId),
      'authorProfileId': serializer.toJson<String?>(authorProfileId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'importedAt': serializer.toJson<DateTime?>(importedAt),
      'payloadVersion': serializer.toJson<int>(payloadVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'contentHash': serializer.toJson<String>(contentHash),
      'originPackageId': serializer.toJson<String?>(originPackageId),
    };
  }

  ObjectRevisionRow copyWith({
    String? id,
    String? objectId,
    Value<String?> parentRevisionId = const Value.absent(),
    Value<String?> authorProfileId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> importedAt = const Value.absent(),
    int? payloadVersion,
    String? payloadJson,
    String? contentHash,
    Value<String?> originPackageId = const Value.absent(),
  }) => ObjectRevisionRow(
    id: id ?? this.id,
    objectId: objectId ?? this.objectId,
    parentRevisionId: parentRevisionId.present
        ? parentRevisionId.value
        : this.parentRevisionId,
    authorProfileId: authorProfileId.present
        ? authorProfileId.value
        : this.authorProfileId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
    payloadVersion: payloadVersion ?? this.payloadVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    contentHash: contentHash ?? this.contentHash,
    originPackageId: originPackageId.present
        ? originPackageId.value
        : this.originPackageId,
  );
  ObjectRevisionRow copyWithCompanion(ObjectRevisionsCompanion data) {
    return ObjectRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      parentRevisionId: data.parentRevisionId.present
          ? data.parentRevisionId.value
          : this.parentRevisionId,
      authorProfileId: data.authorProfileId.present
          ? data.authorProfileId.value
          : this.authorProfileId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      payloadVersion: data.payloadVersion.present
          ? data.payloadVersion.value
          : this.payloadVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      originPackageId: data.originPackageId.present
          ? data.originPackageId.value
          : this.originPackageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObjectRevisionRow(')
          ..write('id: $id, ')
          ..write('objectId: $objectId, ')
          ..write('parentRevisionId: $parentRevisionId, ')
          ..write('authorProfileId: $authorProfileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('contentHash: $contentHash, ')
          ..write('originPackageId: $originPackageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    objectId,
    parentRevisionId,
    authorProfileId,
    deviceId,
    createdAt,
    importedAt,
    payloadVersion,
    payloadJson,
    contentHash,
    originPackageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObjectRevisionRow &&
          other.id == this.id &&
          other.objectId == this.objectId &&
          other.parentRevisionId == this.parentRevisionId &&
          other.authorProfileId == this.authorProfileId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.importedAt == this.importedAt &&
          other.payloadVersion == this.payloadVersion &&
          other.payloadJson == this.payloadJson &&
          other.contentHash == this.contentHash &&
          other.originPackageId == this.originPackageId);
}

class ObjectRevisionsCompanion extends UpdateCompanion<ObjectRevisionRow> {
  final Value<String> id;
  final Value<String> objectId;
  final Value<String?> parentRevisionId;
  final Value<String?> authorProfileId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> importedAt;
  final Value<int> payloadVersion;
  final Value<String> payloadJson;
  final Value<String> contentHash;
  final Value<String?> originPackageId;
  final Value<int> rowid;
  const ObjectRevisionsCompanion({
    this.id = const Value.absent(),
    this.objectId = const Value.absent(),
    this.parentRevisionId = const Value.absent(),
    this.authorProfileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.originPackageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObjectRevisionsCompanion.insert({
    required String id,
    required String objectId,
    this.parentRevisionId = const Value.absent(),
    this.authorProfileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime createdAt,
    this.importedAt = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    required String payloadJson,
    required String contentHash,
    this.originPackageId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       objectId = Value(objectId),
       createdAt = Value(createdAt),
       payloadJson = Value(payloadJson),
       contentHash = Value(contentHash);
  static Insertable<ObjectRevisionRow> custom({
    Expression<String>? id,
    Expression<String>? objectId,
    Expression<String>? parentRevisionId,
    Expression<String>? authorProfileId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? importedAt,
    Expression<int>? payloadVersion,
    Expression<String>? payloadJson,
    Expression<String>? contentHash,
    Expression<String>? originPackageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (objectId != null) 'object_id': objectId,
      if (parentRevisionId != null) 'parent_revision_id': parentRevisionId,
      if (authorProfileId != null) 'author_profile_id': authorProfileId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (importedAt != null) 'imported_at': importedAt,
      if (payloadVersion != null) 'payload_version': payloadVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (contentHash != null) 'content_hash': contentHash,
      if (originPackageId != null) 'origin_package_id': originPackageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObjectRevisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? objectId,
    Value<String?>? parentRevisionId,
    Value<String?>? authorProfileId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? importedAt,
    Value<int>? payloadVersion,
    Value<String>? payloadJson,
    Value<String>? contentHash,
    Value<String?>? originPackageId,
    Value<int>? rowid,
  }) {
    return ObjectRevisionsCompanion(
      id: id ?? this.id,
      objectId: objectId ?? this.objectId,
      parentRevisionId: parentRevisionId ?? this.parentRevisionId,
      authorProfileId: authorProfileId ?? this.authorProfileId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      importedAt: importedAt ?? this.importedAt,
      payloadVersion: payloadVersion ?? this.payloadVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      contentHash: contentHash ?? this.contentHash,
      originPackageId: originPackageId ?? this.originPackageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (parentRevisionId.present) {
      map['parent_revision_id'] = Variable<String>(parentRevisionId.value);
    }
    if (authorProfileId.present) {
      map['author_profile_id'] = Variable<String>(authorProfileId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (payloadVersion.present) {
      map['payload_version'] = Variable<int>(payloadVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (originPackageId.present) {
      map['origin_package_id'] = Variable<String>(originPackageId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObjectRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('objectId: $objectId, ')
          ..write('parentRevisionId: $parentRevisionId, ')
          ..write('authorProfileId: $authorProfileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('contentHash: $contentHash, ')
          ..write('originPackageId: $originPackageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentRevisionIdMeta = const VerificationMeta(
    'currentRevisionId',
  );
  @override
  late final GeneratedColumn<String> currentRevisionId =
      GeneratedColumn<String>(
        'current_revision_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    parentId,
    name,
    normalizedName,
    description,
    icon,
    color,
    sortOrder,
    level,
    path,
    currentRevisionId,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('current_revision_id')) {
      context.handle(
        _currentRevisionIdMeta,
        currentRevisionId.isAcceptableOrUnknown(
          data['current_revision_id']!,
          _currentRevisionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      currentRevisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_revision_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String profileId;
  final String? parentId;
  final String name;
  final String normalizedName;
  final String? description;
  final String? icon;
  final int? color;
  final int sortOrder;

  /// Уровень вложенности (корень = 0).
  final int level;

  /// Материализованный путь из id через «/» (включая собственный id).
  final String path;
  final String? currentRevisionId;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const CategoryRow({
    required this.id,
    required this.profileId,
    this.parentId,
    required this.name,
    required this.normalizedName,
    this.description,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.level,
    required this.path,
    this.currentRevisionId,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['level'] = Variable<int>(level);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || currentRevisionId != null) {
      map['current_revision_id'] = Variable<String>(currentRevisionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      sortOrder: Value(sortOrder),
      level: Value(level),
      path: Value(path),
      currentRevisionId: currentRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentRevisionId),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<int?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      level: serializer.fromJson<int>(json['level']),
      path: serializer.fromJson<String>(json['path']),
      currentRevisionId: serializer.fromJson<String?>(
        json['currentRevisionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<int?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'level': serializer.toJson<int>(level),
      'path': serializer.toJson<String>(path),
      'currentRevisionId': serializer.toJson<String?>(currentRevisionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? profileId,
    Value<String?> parentId = const Value.absent(),
    String? name,
    String? normalizedName,
    Value<String?> description = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<int?> color = const Value.absent(),
    int? sortOrder,
    int? level,
    String? path,
    Value<String?> currentRevisionId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => CategoryRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    description: description.present ? description.value : this.description,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    level: level ?? this.level,
    path: path ?? this.path,
    currentRevisionId: currentRevisionId.present
        ? currentRevisionId.value
        : this.currentRevisionId,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      level: data.level.present ? data.level.value : this.level,
      path: data.path.present ? data.path.value : this.path,
      currentRevisionId: data.currentRevisionId.present
          ? data.currentRevisionId.value
          : this.currentRevisionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('level: $level, ')
          ..write('path: $path, ')
          ..write('currentRevisionId: $currentRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    parentId,
    name,
    normalizedName,
    description,
    icon,
    color,
    sortOrder,
    level,
    path,
    currentRevisionId,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.level == this.level &&
          other.path == this.path &&
          other.currentRevisionId == this.currentRevisionId &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String?> description;
  final Value<String?> icon;
  final Value<int?> color;
  final Value<int> sortOrder;
  final Value<int> level;
  final Value<String> path;
  final Value<String?> currentRevisionId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.level = const Value.absent(),
    this.path = const Value.absent(),
    this.currentRevisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String profileId,
    this.parentId = const Value.absent(),
    required String name,
    required String normalizedName,
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.level = const Value.absent(),
    required String path,
    this.currentRevisionId = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       path = Value(path),
       createdAt = Value(createdAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<int>? level,
    Expression<String>? path,
    Expression<String>? currentRevisionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (level != null) 'level': level,
      if (path != null) 'path': path,
      if (currentRevisionId != null) 'current_revision_id': currentRevisionId,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String?>? parentId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String?>? description,
    Value<String?>? icon,
    Value<int?>? color,
    Value<int>? sortOrder,
    Value<int>? level,
    Value<String>? path,
    Value<String?>? currentRevisionId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      level: level ?? this.level,
      path: path ?? this.path,
      currentRevisionId: currentRevisionId ?? this.currentRevisionId,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (currentRevisionId.present) {
      map['current_revision_id'] = Variable<String>(currentRevisionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('level: $level, ')
          ..write('path: $path, ')
          ..write('currentRevisionId: $currentRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryRevisionsTable extends CategoryRevisions
    with TableInfo<$CategoryRevisionsTable, CategoryRevisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _parentRevisionIdMeta = const VerificationMeta(
    'parentRevisionId',
  );
  @override
  late final GeneratedColumn<String> parentRevisionId = GeneratedColumn<String>(
    'parent_revision_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorProfileIdMeta = const VerificationMeta(
    'authorProfileId',
  );
  @override
  late final GeneratedColumn<String> authorProfileId = GeneratedColumn<String>(
    'author_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadVersionMeta = const VerificationMeta(
    'payloadVersion',
  );
  @override
  late final GeneratedColumn<int> payloadVersion = GeneratedColumn<int>(
    'payload_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originPackageIdMeta = const VerificationMeta(
    'originPackageId',
  );
  @override
  late final GeneratedColumn<String> originPackageId = GeneratedColumn<String>(
    'origin_package_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    parentRevisionId,
    authorProfileId,
    deviceId,
    createdAt,
    importedAt,
    payloadVersion,
    payloadJson,
    contentHash,
    originPackageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('parent_revision_id')) {
      context.handle(
        _parentRevisionIdMeta,
        parentRevisionId.isAcceptableOrUnknown(
          data['parent_revision_id']!,
          _parentRevisionIdMeta,
        ),
      );
    }
    if (data.containsKey('author_profile_id')) {
      context.handle(
        _authorProfileIdMeta,
        authorProfileId.isAcceptableOrUnknown(
          data['author_profile_id']!,
          _authorProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('payload_version')) {
      context.handle(
        _payloadVersionMeta,
        payloadVersion.isAcceptableOrUnknown(
          data['payload_version']!,
          _payloadVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('origin_package_id')) {
      context.handle(
        _originPackageIdMeta,
        originPackageId.isAcceptableOrUnknown(
          data['origin_package_id']!,
          _originPackageIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRevisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      parentRevisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_revision_id'],
      ),
      authorProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_profile_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      ),
      payloadVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      originPackageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_package_id'],
      ),
    );
  }

  @override
  $CategoryRevisionsTable createAlias(String alias) {
    return $CategoryRevisionsTable(attachedDatabase, alias);
  }
}

class CategoryRevisionRow extends DataClass
    implements Insertable<CategoryRevisionRow> {
  final String id;
  final String categoryId;
  final String? parentRevisionId;
  final String? authorProfileId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime? importedAt;
  final int payloadVersion;
  final String payloadJson;
  final String contentHash;
  final String? originPackageId;
  const CategoryRevisionRow({
    required this.id,
    required this.categoryId,
    this.parentRevisionId,
    this.authorProfileId,
    this.deviceId,
    required this.createdAt,
    this.importedAt,
    required this.payloadVersion,
    required this.payloadJson,
    required this.contentHash,
    this.originPackageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || parentRevisionId != null) {
      map['parent_revision_id'] = Variable<String>(parentRevisionId);
    }
    if (!nullToAbsent || authorProfileId != null) {
      map['author_profile_id'] = Variable<String>(authorProfileId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<DateTime>(importedAt);
    }
    map['payload_version'] = Variable<int>(payloadVersion);
    map['payload_json'] = Variable<String>(payloadJson);
    map['content_hash'] = Variable<String>(contentHash);
    if (!nullToAbsent || originPackageId != null) {
      map['origin_package_id'] = Variable<String>(originPackageId);
    }
    return map;
  }

  CategoryRevisionsCompanion toCompanion(bool nullToAbsent) {
    return CategoryRevisionsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      parentRevisionId: parentRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentRevisionId),
      authorProfileId: authorProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorProfileId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
      payloadVersion: Value(payloadVersion),
      payloadJson: Value(payloadJson),
      contentHash: Value(contentHash),
      originPackageId: originPackageId == null && nullToAbsent
          ? const Value.absent()
          : Value(originPackageId),
    );
  }

  factory CategoryRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRevisionRow(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      parentRevisionId: serializer.fromJson<String?>(json['parentRevisionId']),
      authorProfileId: serializer.fromJson<String?>(json['authorProfileId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      importedAt: serializer.fromJson<DateTime?>(json['importedAt']),
      payloadVersion: serializer.fromJson<int>(json['payloadVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      originPackageId: serializer.fromJson<String?>(json['originPackageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'parentRevisionId': serializer.toJson<String?>(parentRevisionId),
      'authorProfileId': serializer.toJson<String?>(authorProfileId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'importedAt': serializer.toJson<DateTime?>(importedAt),
      'payloadVersion': serializer.toJson<int>(payloadVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'contentHash': serializer.toJson<String>(contentHash),
      'originPackageId': serializer.toJson<String?>(originPackageId),
    };
  }

  CategoryRevisionRow copyWith({
    String? id,
    String? categoryId,
    Value<String?> parentRevisionId = const Value.absent(),
    Value<String?> authorProfileId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> importedAt = const Value.absent(),
    int? payloadVersion,
    String? payloadJson,
    String? contentHash,
    Value<String?> originPackageId = const Value.absent(),
  }) => CategoryRevisionRow(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    parentRevisionId: parentRevisionId.present
        ? parentRevisionId.value
        : this.parentRevisionId,
    authorProfileId: authorProfileId.present
        ? authorProfileId.value
        : this.authorProfileId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
    payloadVersion: payloadVersion ?? this.payloadVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    contentHash: contentHash ?? this.contentHash,
    originPackageId: originPackageId.present
        ? originPackageId.value
        : this.originPackageId,
  );
  CategoryRevisionRow copyWithCompanion(CategoryRevisionsCompanion data) {
    return CategoryRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      parentRevisionId: data.parentRevisionId.present
          ? data.parentRevisionId.value
          : this.parentRevisionId,
      authorProfileId: data.authorProfileId.present
          ? data.authorProfileId.value
          : this.authorProfileId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      payloadVersion: data.payloadVersion.present
          ? data.payloadVersion.value
          : this.payloadVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      originPackageId: data.originPackageId.present
          ? data.originPackageId.value
          : this.originPackageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRevisionRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('parentRevisionId: $parentRevisionId, ')
          ..write('authorProfileId: $authorProfileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('contentHash: $contentHash, ')
          ..write('originPackageId: $originPackageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    parentRevisionId,
    authorProfileId,
    deviceId,
    createdAt,
    importedAt,
    payloadVersion,
    payloadJson,
    contentHash,
    originPackageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRevisionRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.parentRevisionId == this.parentRevisionId &&
          other.authorProfileId == this.authorProfileId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.importedAt == this.importedAt &&
          other.payloadVersion == this.payloadVersion &&
          other.payloadJson == this.payloadJson &&
          other.contentHash == this.contentHash &&
          other.originPackageId == this.originPackageId);
}

class CategoryRevisionsCompanion extends UpdateCompanion<CategoryRevisionRow> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String?> parentRevisionId;
  final Value<String?> authorProfileId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> importedAt;
  final Value<int> payloadVersion;
  final Value<String> payloadJson;
  final Value<String> contentHash;
  final Value<String?> originPackageId;
  final Value<int> rowid;
  const CategoryRevisionsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.parentRevisionId = const Value.absent(),
    this.authorProfileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.originPackageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryRevisionsCompanion.insert({
    required String id,
    required String categoryId,
    this.parentRevisionId = const Value.absent(),
    this.authorProfileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime createdAt,
    this.importedAt = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    required String payloadJson,
    required String contentHash,
    this.originPackageId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt),
       payloadJson = Value(payloadJson),
       contentHash = Value(contentHash);
  static Insertable<CategoryRevisionRow> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? parentRevisionId,
    Expression<String>? authorProfileId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? importedAt,
    Expression<int>? payloadVersion,
    Expression<String>? payloadJson,
    Expression<String>? contentHash,
    Expression<String>? originPackageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (parentRevisionId != null) 'parent_revision_id': parentRevisionId,
      if (authorProfileId != null) 'author_profile_id': authorProfileId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (importedAt != null) 'imported_at': importedAt,
      if (payloadVersion != null) 'payload_version': payloadVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (contentHash != null) 'content_hash': contentHash,
      if (originPackageId != null) 'origin_package_id': originPackageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryRevisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String?>? parentRevisionId,
    Value<String?>? authorProfileId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? importedAt,
    Value<int>? payloadVersion,
    Value<String>? payloadJson,
    Value<String>? contentHash,
    Value<String?>? originPackageId,
    Value<int>? rowid,
  }) {
    return CategoryRevisionsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      parentRevisionId: parentRevisionId ?? this.parentRevisionId,
      authorProfileId: authorProfileId ?? this.authorProfileId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      importedAt: importedAt ?? this.importedAt,
      payloadVersion: payloadVersion ?? this.payloadVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      contentHash: contentHash ?? this.contentHash,
      originPackageId: originPackageId ?? this.originPackageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (parentRevisionId.present) {
      map['parent_revision_id'] = Variable<String>(parentRevisionId.value);
    }
    if (authorProfileId.present) {
      map['author_profile_id'] = Variable<String>(authorProfileId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (payloadVersion.present) {
      map['payload_version'] = Variable<int>(payloadVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (originPackageId.present) {
      map['origin_package_id'] = Variable<String>(originPackageId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('parentRevisionId: $parentRevisionId, ')
          ..write('authorProfileId: $authorProfileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('contentHash: $contentHash, ')
          ..write('originPackageId: $originPackageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    normalizedName,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String profileId;
  final String name;
  final String normalizedName;
  final int? color;
  const TagRow({
    required this.id,
    required this.profileId,
    required this.name,
    required this.normalizedName,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      color: serializer.fromJson<int?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'color': serializer.toJson<int?>(color),
    };
  }

  TagRow copyWith({
    String? id,
    String? profileId,
    String? name,
    String? normalizedName,
    Value<int?> color = const Value.absent(),
  }) => TagRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    color: color.present ? color.value : this.color,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, name, normalizedName, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<int?> color;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    required String normalizedName,
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       normalizedName = Value(normalizedName);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<int>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<int?>? color,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileEntriesTable extends ProfileEntries
    with TableInfo<$ProfileEntriesTable, ProfileEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objects (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
  static const VerificationMeta _shortNoteMeta = const VerificationMeta(
    'shortNote',
  );
  @override
  late final GeneratedColumn<String> shortNote = GeneratedColumn<String>(
    'short_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailedNoteMeta = const VerificationMeta(
    'detailedNote',
  );
  @override
  late final GeneratedColumn<String> detailedNote = GeneratedColumn<String>(
    'detailed_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _impressionDateMeta = const VerificationMeta(
    'impressionDate',
  );
  @override
  late final GeneratedColumn<DateTime> impressionDate =
      GeneratedColumn<DateTime>(
        'impression_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recommendedByProfileIdMeta =
      const VerificationMeta('recommendedByProfileId');
  @override
  late final GeneratedColumn<String> recommendedByProfileId =
      GeneratedColumn<String>(
        'recommended_by_profile_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recommendationSourceMeta =
      const VerificationMeta('recommendationSource');
  @override
  late final GeneratedColumn<String> recommendationSource =
      GeneratedColumn<String>(
        'recommendation_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _privacyMeta = const VerificationMeta(
    'privacy',
  );
  @override
  late final GeneratedColumn<String> privacy = GeneratedColumn<String>(
    'privacy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('shareable'),
  );
  static const VerificationMeta _sourceEntryIdMeta = const VerificationMeta(
    'sourceEntryId',
  );
  @override
  late final GeneratedColumn<String> sourceEntryId = GeneratedColumn<String>(
    'source_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followSourceMeta = const VerificationMeta(
    'followSource',
  );
  @override
  late final GeneratedColumn<bool> followSource = GeneratedColumn<bool>(
    'follow_source',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("follow_source" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdDeviceIdMeta = const VerificationMeta(
    'createdDeviceId',
  );
  @override
  late final GeneratedColumn<String> createdDeviceId = GeneratedColumn<String>(
    'created_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentRevisionIdMeta = const VerificationMeta(
    'currentRevisionId',
  );
  @override
  late final GeneratedColumn<String> currentRevisionId =
      GeneratedColumn<String>(
        'current_revision_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    objectId,
    relation,
    rating,
    status,
    shortNote,
    detailedNote,
    impressionDate,
    recommendedByProfileId,
    recommendationSource,
    privacy,
    sourceEntryId,
    followSource,
    createdDeviceId,
    currentRevisionId,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('short_note')) {
      context.handle(
        _shortNoteMeta,
        shortNote.isAcceptableOrUnknown(data['short_note']!, _shortNoteMeta),
      );
    }
    if (data.containsKey('detailed_note')) {
      context.handle(
        _detailedNoteMeta,
        detailedNote.isAcceptableOrUnknown(
          data['detailed_note']!,
          _detailedNoteMeta,
        ),
      );
    }
    if (data.containsKey('impression_date')) {
      context.handle(
        _impressionDateMeta,
        impressionDate.isAcceptableOrUnknown(
          data['impression_date']!,
          _impressionDateMeta,
        ),
      );
    }
    if (data.containsKey('recommended_by_profile_id')) {
      context.handle(
        _recommendedByProfileIdMeta,
        recommendedByProfileId.isAcceptableOrUnknown(
          data['recommended_by_profile_id']!,
          _recommendedByProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('recommendation_source')) {
      context.handle(
        _recommendationSourceMeta,
        recommendationSource.isAcceptableOrUnknown(
          data['recommendation_source']!,
          _recommendationSourceMeta,
        ),
      );
    }
    if (data.containsKey('privacy')) {
      context.handle(
        _privacyMeta,
        privacy.isAcceptableOrUnknown(data['privacy']!, _privacyMeta),
      );
    }
    if (data.containsKey('source_entry_id')) {
      context.handle(
        _sourceEntryIdMeta,
        sourceEntryId.isAcceptableOrUnknown(
          data['source_entry_id']!,
          _sourceEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('follow_source')) {
      context.handle(
        _followSourceMeta,
        followSource.isAcceptableOrUnknown(
          data['follow_source']!,
          _followSourceMeta,
        ),
      );
    }
    if (data.containsKey('created_device_id')) {
      context.handle(
        _createdDeviceIdMeta,
        createdDeviceId.isAcceptableOrUnknown(
          data['created_device_id']!,
          _createdDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('current_revision_id')) {
      context.handle(
        _currentRevisionIdMeta,
        currentRevisionId.isAcceptableOrUnknown(
          data['current_revision_id']!,
          _currentRevisionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      objectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_id'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      shortNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_note'],
      ),
      detailedNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detailed_note'],
      ),
      impressionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}impression_date'],
      ),
      recommendedByProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommended_by_profile_id'],
      ),
      recommendationSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommendation_source'],
      ),
      privacy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy'],
      )!,
      sourceEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_entry_id'],
      ),
      followSource: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}follow_source'],
      )!,
      createdDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_device_id'],
      ),
      currentRevisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_revision_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ProfileEntriesTable createAlias(String alias) {
    return $ProfileEntriesTable(attachedDatabase, alias);
  }
}

class ProfileEntryRow extends DataClass implements Insertable<ProfileEntryRow> {
  final String id;
  final String profileId;
  final String objectId;

  /// Отношение (§10): love | like | neutral | dislike | avoid | wantToTry.
  final String? relation;

  /// Оценка 0..10 с шагом 0.5 (§10), необязательна.
  final double? rating;

  /// Статус (зависит от типа, хранится текстом).
  final String? status;
  final String? shortNote;
  final String? detailedNote;
  final DateTime? impressionDate;

  /// Кто порекомендовал и источник (§12).
  final String? recommendedByProfileId;
  final String? recommendationSource;

  /// Приватность (§25): onlyMe | shareable | shareNoNote | shareNoPhotos |
  /// shareBasic | shareProtected.
  final String privacy;

  /// Ссылка на исходную запись (при добавлении чужой записи себе — §12).
  final String? sourceEntryId;
  final bool followSource;
  final String? createdDeviceId;
  final String? currentRevisionId;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const ProfileEntryRow({
    required this.id,
    required this.profileId,
    required this.objectId,
    this.relation,
    this.rating,
    this.status,
    this.shortNote,
    this.detailedNote,
    this.impressionDate,
    this.recommendedByProfileId,
    this.recommendationSource,
    required this.privacy,
    this.sourceEntryId,
    required this.followSource,
    this.createdDeviceId,
    this.currentRevisionId,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['object_id'] = Variable<String>(objectId);
    if (!nullToAbsent || relation != null) {
      map['relation'] = Variable<String>(relation);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || shortNote != null) {
      map['short_note'] = Variable<String>(shortNote);
    }
    if (!nullToAbsent || detailedNote != null) {
      map['detailed_note'] = Variable<String>(detailedNote);
    }
    if (!nullToAbsent || impressionDate != null) {
      map['impression_date'] = Variable<DateTime>(impressionDate);
    }
    if (!nullToAbsent || recommendedByProfileId != null) {
      map['recommended_by_profile_id'] = Variable<String>(
        recommendedByProfileId,
      );
    }
    if (!nullToAbsent || recommendationSource != null) {
      map['recommendation_source'] = Variable<String>(recommendationSource);
    }
    map['privacy'] = Variable<String>(privacy);
    if (!nullToAbsent || sourceEntryId != null) {
      map['source_entry_id'] = Variable<String>(sourceEntryId);
    }
    map['follow_source'] = Variable<bool>(followSource);
    if (!nullToAbsent || createdDeviceId != null) {
      map['created_device_id'] = Variable<String>(createdDeviceId);
    }
    if (!nullToAbsent || currentRevisionId != null) {
      map['current_revision_id'] = Variable<String>(currentRevisionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ProfileEntriesCompanion toCompanion(bool nullToAbsent) {
    return ProfileEntriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      objectId: Value(objectId),
      relation: relation == null && nullToAbsent
          ? const Value.absent()
          : Value(relation),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      shortNote: shortNote == null && nullToAbsent
          ? const Value.absent()
          : Value(shortNote),
      detailedNote: detailedNote == null && nullToAbsent
          ? const Value.absent()
          : Value(detailedNote),
      impressionDate: impressionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(impressionDate),
      recommendedByProfileId: recommendedByProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendedByProfileId),
      recommendationSource: recommendationSource == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendationSource),
      privacy: Value(privacy),
      sourceEntryId: sourceEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEntryId),
      followSource: Value(followSource),
      createdDeviceId: createdDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdDeviceId),
      currentRevisionId: currentRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentRevisionId),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ProfileEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileEntryRow(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      objectId: serializer.fromJson<String>(json['objectId']),
      relation: serializer.fromJson<String?>(json['relation']),
      rating: serializer.fromJson<double?>(json['rating']),
      status: serializer.fromJson<String?>(json['status']),
      shortNote: serializer.fromJson<String?>(json['shortNote']),
      detailedNote: serializer.fromJson<String?>(json['detailedNote']),
      impressionDate: serializer.fromJson<DateTime?>(json['impressionDate']),
      recommendedByProfileId: serializer.fromJson<String?>(
        json['recommendedByProfileId'],
      ),
      recommendationSource: serializer.fromJson<String?>(
        json['recommendationSource'],
      ),
      privacy: serializer.fromJson<String>(json['privacy']),
      sourceEntryId: serializer.fromJson<String?>(json['sourceEntryId']),
      followSource: serializer.fromJson<bool>(json['followSource']),
      createdDeviceId: serializer.fromJson<String?>(json['createdDeviceId']),
      currentRevisionId: serializer.fromJson<String?>(
        json['currentRevisionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'objectId': serializer.toJson<String>(objectId),
      'relation': serializer.toJson<String?>(relation),
      'rating': serializer.toJson<double?>(rating),
      'status': serializer.toJson<String?>(status),
      'shortNote': serializer.toJson<String?>(shortNote),
      'detailedNote': serializer.toJson<String?>(detailedNote),
      'impressionDate': serializer.toJson<DateTime?>(impressionDate),
      'recommendedByProfileId': serializer.toJson<String?>(
        recommendedByProfileId,
      ),
      'recommendationSource': serializer.toJson<String?>(recommendationSource),
      'privacy': serializer.toJson<String>(privacy),
      'sourceEntryId': serializer.toJson<String?>(sourceEntryId),
      'followSource': serializer.toJson<bool>(followSource),
      'createdDeviceId': serializer.toJson<String?>(createdDeviceId),
      'currentRevisionId': serializer.toJson<String?>(currentRevisionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ProfileEntryRow copyWith({
    String? id,
    String? profileId,
    String? objectId,
    Value<String?> relation = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> shortNote = const Value.absent(),
    Value<String?> detailedNote = const Value.absent(),
    Value<DateTime?> impressionDate = const Value.absent(),
    Value<String?> recommendedByProfileId = const Value.absent(),
    Value<String?> recommendationSource = const Value.absent(),
    String? privacy,
    Value<String?> sourceEntryId = const Value.absent(),
    bool? followSource,
    Value<String?> createdDeviceId = const Value.absent(),
    Value<String?> currentRevisionId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ProfileEntryRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    objectId: objectId ?? this.objectId,
    relation: relation.present ? relation.value : this.relation,
    rating: rating.present ? rating.value : this.rating,
    status: status.present ? status.value : this.status,
    shortNote: shortNote.present ? shortNote.value : this.shortNote,
    detailedNote: detailedNote.present ? detailedNote.value : this.detailedNote,
    impressionDate: impressionDate.present
        ? impressionDate.value
        : this.impressionDate,
    recommendedByProfileId: recommendedByProfileId.present
        ? recommendedByProfileId.value
        : this.recommendedByProfileId,
    recommendationSource: recommendationSource.present
        ? recommendationSource.value
        : this.recommendationSource,
    privacy: privacy ?? this.privacy,
    sourceEntryId: sourceEntryId.present
        ? sourceEntryId.value
        : this.sourceEntryId,
    followSource: followSource ?? this.followSource,
    createdDeviceId: createdDeviceId.present
        ? createdDeviceId.value
        : this.createdDeviceId,
    currentRevisionId: currentRevisionId.present
        ? currentRevisionId.value
        : this.currentRevisionId,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ProfileEntryRow copyWithCompanion(ProfileEntriesCompanion data) {
    return ProfileEntryRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      relation: data.relation.present ? data.relation.value : this.relation,
      rating: data.rating.present ? data.rating.value : this.rating,
      status: data.status.present ? data.status.value : this.status,
      shortNote: data.shortNote.present ? data.shortNote.value : this.shortNote,
      detailedNote: data.detailedNote.present
          ? data.detailedNote.value
          : this.detailedNote,
      impressionDate: data.impressionDate.present
          ? data.impressionDate.value
          : this.impressionDate,
      recommendedByProfileId: data.recommendedByProfileId.present
          ? data.recommendedByProfileId.value
          : this.recommendedByProfileId,
      recommendationSource: data.recommendationSource.present
          ? data.recommendationSource.value
          : this.recommendationSource,
      privacy: data.privacy.present ? data.privacy.value : this.privacy,
      sourceEntryId: data.sourceEntryId.present
          ? data.sourceEntryId.value
          : this.sourceEntryId,
      followSource: data.followSource.present
          ? data.followSource.value
          : this.followSource,
      createdDeviceId: data.createdDeviceId.present
          ? data.createdDeviceId.value
          : this.createdDeviceId,
      currentRevisionId: data.currentRevisionId.present
          ? data.currentRevisionId.value
          : this.currentRevisionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEntryRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('objectId: $objectId, ')
          ..write('relation: $relation, ')
          ..write('rating: $rating, ')
          ..write('status: $status, ')
          ..write('shortNote: $shortNote, ')
          ..write('detailedNote: $detailedNote, ')
          ..write('impressionDate: $impressionDate, ')
          ..write('recommendedByProfileId: $recommendedByProfileId, ')
          ..write('recommendationSource: $recommendationSource, ')
          ..write('privacy: $privacy, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('followSource: $followSource, ')
          ..write('createdDeviceId: $createdDeviceId, ')
          ..write('currentRevisionId: $currentRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    objectId,
    relation,
    rating,
    status,
    shortNote,
    detailedNote,
    impressionDate,
    recommendedByProfileId,
    recommendationSource,
    privacy,
    sourceEntryId,
    followSource,
    createdDeviceId,
    currentRevisionId,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileEntryRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.objectId == this.objectId &&
          other.relation == this.relation &&
          other.rating == this.rating &&
          other.status == this.status &&
          other.shortNote == this.shortNote &&
          other.detailedNote == this.detailedNote &&
          other.impressionDate == this.impressionDate &&
          other.recommendedByProfileId == this.recommendedByProfileId &&
          other.recommendationSource == this.recommendationSource &&
          other.privacy == this.privacy &&
          other.sourceEntryId == this.sourceEntryId &&
          other.followSource == this.followSource &&
          other.createdDeviceId == this.createdDeviceId &&
          other.currentRevisionId == this.currentRevisionId &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class ProfileEntriesCompanion extends UpdateCompanion<ProfileEntryRow> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> objectId;
  final Value<String?> relation;
  final Value<double?> rating;
  final Value<String?> status;
  final Value<String?> shortNote;
  final Value<String?> detailedNote;
  final Value<DateTime?> impressionDate;
  final Value<String?> recommendedByProfileId;
  final Value<String?> recommendationSource;
  final Value<String> privacy;
  final Value<String?> sourceEntryId;
  final Value<bool> followSource;
  final Value<String?> createdDeviceId;
  final Value<String?> currentRevisionId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ProfileEntriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.objectId = const Value.absent(),
    this.relation = const Value.absent(),
    this.rating = const Value.absent(),
    this.status = const Value.absent(),
    this.shortNote = const Value.absent(),
    this.detailedNote = const Value.absent(),
    this.impressionDate = const Value.absent(),
    this.recommendedByProfileId = const Value.absent(),
    this.recommendationSource = const Value.absent(),
    this.privacy = const Value.absent(),
    this.sourceEntryId = const Value.absent(),
    this.followSource = const Value.absent(),
    this.createdDeviceId = const Value.absent(),
    this.currentRevisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileEntriesCompanion.insert({
    required String id,
    required String profileId,
    required String objectId,
    this.relation = const Value.absent(),
    this.rating = const Value.absent(),
    this.status = const Value.absent(),
    this.shortNote = const Value.absent(),
    this.detailedNote = const Value.absent(),
    this.impressionDate = const Value.absent(),
    this.recommendedByProfileId = const Value.absent(),
    this.recommendationSource = const Value.absent(),
    this.privacy = const Value.absent(),
    this.sourceEntryId = const Value.absent(),
    this.followSource = const Value.absent(),
    this.createdDeviceId = const Value.absent(),
    this.currentRevisionId = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       objectId = Value(objectId),
       createdAt = Value(createdAt);
  static Insertable<ProfileEntryRow> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? objectId,
    Expression<String>? relation,
    Expression<double>? rating,
    Expression<String>? status,
    Expression<String>? shortNote,
    Expression<String>? detailedNote,
    Expression<DateTime>? impressionDate,
    Expression<String>? recommendedByProfileId,
    Expression<String>? recommendationSource,
    Expression<String>? privacy,
    Expression<String>? sourceEntryId,
    Expression<bool>? followSource,
    Expression<String>? createdDeviceId,
    Expression<String>? currentRevisionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (objectId != null) 'object_id': objectId,
      if (relation != null) 'relation': relation,
      if (rating != null) 'rating': rating,
      if (status != null) 'status': status,
      if (shortNote != null) 'short_note': shortNote,
      if (detailedNote != null) 'detailed_note': detailedNote,
      if (impressionDate != null) 'impression_date': impressionDate,
      if (recommendedByProfileId != null)
        'recommended_by_profile_id': recommendedByProfileId,
      if (recommendationSource != null)
        'recommendation_source': recommendationSource,
      if (privacy != null) 'privacy': privacy,
      if (sourceEntryId != null) 'source_entry_id': sourceEntryId,
      if (followSource != null) 'follow_source': followSource,
      if (createdDeviceId != null) 'created_device_id': createdDeviceId,
      if (currentRevisionId != null) 'current_revision_id': currentRevisionId,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? objectId,
    Value<String?>? relation,
    Value<double?>? rating,
    Value<String?>? status,
    Value<String?>? shortNote,
    Value<String?>? detailedNote,
    Value<DateTime?>? impressionDate,
    Value<String?>? recommendedByProfileId,
    Value<String?>? recommendationSource,
    Value<String>? privacy,
    Value<String?>? sourceEntryId,
    Value<bool>? followSource,
    Value<String?>? createdDeviceId,
    Value<String?>? currentRevisionId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ProfileEntriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      objectId: objectId ?? this.objectId,
      relation: relation ?? this.relation,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      shortNote: shortNote ?? this.shortNote,
      detailedNote: detailedNote ?? this.detailedNote,
      impressionDate: impressionDate ?? this.impressionDate,
      recommendedByProfileId:
          recommendedByProfileId ?? this.recommendedByProfileId,
      recommendationSource: recommendationSource ?? this.recommendationSource,
      privacy: privacy ?? this.privacy,
      sourceEntryId: sourceEntryId ?? this.sourceEntryId,
      followSource: followSource ?? this.followSource,
      createdDeviceId: createdDeviceId ?? this.createdDeviceId,
      currentRevisionId: currentRevisionId ?? this.currentRevisionId,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (shortNote.present) {
      map['short_note'] = Variable<String>(shortNote.value);
    }
    if (detailedNote.present) {
      map['detailed_note'] = Variable<String>(detailedNote.value);
    }
    if (impressionDate.present) {
      map['impression_date'] = Variable<DateTime>(impressionDate.value);
    }
    if (recommendedByProfileId.present) {
      map['recommended_by_profile_id'] = Variable<String>(
        recommendedByProfileId.value,
      );
    }
    if (recommendationSource.present) {
      map['recommendation_source'] = Variable<String>(
        recommendationSource.value,
      );
    }
    if (privacy.present) {
      map['privacy'] = Variable<String>(privacy.value);
    }
    if (sourceEntryId.present) {
      map['source_entry_id'] = Variable<String>(sourceEntryId.value);
    }
    if (followSource.present) {
      map['follow_source'] = Variable<bool>(followSource.value);
    }
    if (createdDeviceId.present) {
      map['created_device_id'] = Variable<String>(createdDeviceId.value);
    }
    if (currentRevisionId.present) {
      map['current_revision_id'] = Variable<String>(currentRevisionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEntriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('objectId: $objectId, ')
          ..write('relation: $relation, ')
          ..write('rating: $rating, ')
          ..write('status: $status, ')
          ..write('shortNote: $shortNote, ')
          ..write('detailedNote: $detailedNote, ')
          ..write('impressionDate: $impressionDate, ')
          ..write('recommendedByProfileId: $recommendedByProfileId, ')
          ..write('recommendationSource: $recommendationSource, ')
          ..write('privacy: $privacy, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('followSource: $followSource, ')
          ..write('createdDeviceId: $createdDeviceId, ')
          ..write('currentRevisionId: $currentRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileEntryRevisionsTable extends ProfileEntryRevisions
    with TableInfo<$ProfileEntryRevisionsTable, ProfileEntryRevisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileEntryRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile_entries (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _parentRevisionIdMeta = const VerificationMeta(
    'parentRevisionId',
  );
  @override
  late final GeneratedColumn<String> parentRevisionId = GeneratedColumn<String>(
    'parent_revision_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorProfileIdMeta = const VerificationMeta(
    'authorProfileId',
  );
  @override
  late final GeneratedColumn<String> authorProfileId = GeneratedColumn<String>(
    'author_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadVersionMeta = const VerificationMeta(
    'payloadVersion',
  );
  @override
  late final GeneratedColumn<int> payloadVersion = GeneratedColumn<int>(
    'payload_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originPackageIdMeta = const VerificationMeta(
    'originPackageId',
  );
  @override
  late final GeneratedColumn<String> originPackageId = GeneratedColumn<String>(
    'origin_package_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    parentRevisionId,
    authorProfileId,
    deviceId,
    createdAt,
    importedAt,
    payloadVersion,
    payloadJson,
    contentHash,
    originPackageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_entry_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileEntryRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('parent_revision_id')) {
      context.handle(
        _parentRevisionIdMeta,
        parentRevisionId.isAcceptableOrUnknown(
          data['parent_revision_id']!,
          _parentRevisionIdMeta,
        ),
      );
    }
    if (data.containsKey('author_profile_id')) {
      context.handle(
        _authorProfileIdMeta,
        authorProfileId.isAcceptableOrUnknown(
          data['author_profile_id']!,
          _authorProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    if (data.containsKey('payload_version')) {
      context.handle(
        _payloadVersionMeta,
        payloadVersion.isAcceptableOrUnknown(
          data['payload_version']!,
          _payloadVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('origin_package_id')) {
      context.handle(
        _originPackageIdMeta,
        originPackageId.isAcceptableOrUnknown(
          data['origin_package_id']!,
          _originPackageIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileEntryRevisionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileEntryRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      parentRevisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_revision_id'],
      ),
      authorProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_profile_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      ),
      payloadVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      originPackageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_package_id'],
      ),
    );
  }

  @override
  $ProfileEntryRevisionsTable createAlias(String alias) {
    return $ProfileEntryRevisionsTable(attachedDatabase, alias);
  }
}

class ProfileEntryRevisionRow extends DataClass
    implements Insertable<ProfileEntryRevisionRow> {
  final String id;
  final String entryId;
  final String? parentRevisionId;
  final String? authorProfileId;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime? importedAt;
  final int payloadVersion;
  final String payloadJson;
  final String contentHash;
  final String? originPackageId;
  const ProfileEntryRevisionRow({
    required this.id,
    required this.entryId,
    this.parentRevisionId,
    this.authorProfileId,
    this.deviceId,
    required this.createdAt,
    this.importedAt,
    required this.payloadVersion,
    required this.payloadJson,
    required this.contentHash,
    this.originPackageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_id'] = Variable<String>(entryId);
    if (!nullToAbsent || parentRevisionId != null) {
      map['parent_revision_id'] = Variable<String>(parentRevisionId);
    }
    if (!nullToAbsent || authorProfileId != null) {
      map['author_profile_id'] = Variable<String>(authorProfileId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<DateTime>(importedAt);
    }
    map['payload_version'] = Variable<int>(payloadVersion);
    map['payload_json'] = Variable<String>(payloadJson);
    map['content_hash'] = Variable<String>(contentHash);
    if (!nullToAbsent || originPackageId != null) {
      map['origin_package_id'] = Variable<String>(originPackageId);
    }
    return map;
  }

  ProfileEntryRevisionsCompanion toCompanion(bool nullToAbsent) {
    return ProfileEntryRevisionsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      parentRevisionId: parentRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentRevisionId),
      authorProfileId: authorProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorProfileId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAt: Value(createdAt),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
      payloadVersion: Value(payloadVersion),
      payloadJson: Value(payloadJson),
      contentHash: Value(contentHash),
      originPackageId: originPackageId == null && nullToAbsent
          ? const Value.absent()
          : Value(originPackageId),
    );
  }

  factory ProfileEntryRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileEntryRevisionRow(
      id: serializer.fromJson<String>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      parentRevisionId: serializer.fromJson<String?>(json['parentRevisionId']),
      authorProfileId: serializer.fromJson<String?>(json['authorProfileId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      importedAt: serializer.fromJson<DateTime?>(json['importedAt']),
      payloadVersion: serializer.fromJson<int>(json['payloadVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      originPackageId: serializer.fromJson<String?>(json['originPackageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryId': serializer.toJson<String>(entryId),
      'parentRevisionId': serializer.toJson<String?>(parentRevisionId),
      'authorProfileId': serializer.toJson<String?>(authorProfileId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'importedAt': serializer.toJson<DateTime?>(importedAt),
      'payloadVersion': serializer.toJson<int>(payloadVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'contentHash': serializer.toJson<String>(contentHash),
      'originPackageId': serializer.toJson<String?>(originPackageId),
    };
  }

  ProfileEntryRevisionRow copyWith({
    String? id,
    String? entryId,
    Value<String?> parentRevisionId = const Value.absent(),
    Value<String?> authorProfileId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> importedAt = const Value.absent(),
    int? payloadVersion,
    String? payloadJson,
    String? contentHash,
    Value<String?> originPackageId = const Value.absent(),
  }) => ProfileEntryRevisionRow(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    parentRevisionId: parentRevisionId.present
        ? parentRevisionId.value
        : this.parentRevisionId,
    authorProfileId: authorProfileId.present
        ? authorProfileId.value
        : this.authorProfileId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
    payloadVersion: payloadVersion ?? this.payloadVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    contentHash: contentHash ?? this.contentHash,
    originPackageId: originPackageId.present
        ? originPackageId.value
        : this.originPackageId,
  );
  ProfileEntryRevisionRow copyWithCompanion(
    ProfileEntryRevisionsCompanion data,
  ) {
    return ProfileEntryRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      parentRevisionId: data.parentRevisionId.present
          ? data.parentRevisionId.value
          : this.parentRevisionId,
      authorProfileId: data.authorProfileId.present
          ? data.authorProfileId.value
          : this.authorProfileId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      payloadVersion: data.payloadVersion.present
          ? data.payloadVersion.value
          : this.payloadVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      originPackageId: data.originPackageId.present
          ? data.originPackageId.value
          : this.originPackageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEntryRevisionRow(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('parentRevisionId: $parentRevisionId, ')
          ..write('authorProfileId: $authorProfileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('contentHash: $contentHash, ')
          ..write('originPackageId: $originPackageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    parentRevisionId,
    authorProfileId,
    deviceId,
    createdAt,
    importedAt,
    payloadVersion,
    payloadJson,
    contentHash,
    originPackageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileEntryRevisionRow &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.parentRevisionId == this.parentRevisionId &&
          other.authorProfileId == this.authorProfileId &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.importedAt == this.importedAt &&
          other.payloadVersion == this.payloadVersion &&
          other.payloadJson == this.payloadJson &&
          other.contentHash == this.contentHash &&
          other.originPackageId == this.originPackageId);
}

class ProfileEntryRevisionsCompanion
    extends UpdateCompanion<ProfileEntryRevisionRow> {
  final Value<String> id;
  final Value<String> entryId;
  final Value<String?> parentRevisionId;
  final Value<String?> authorProfileId;
  final Value<String?> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> importedAt;
  final Value<int> payloadVersion;
  final Value<String> payloadJson;
  final Value<String> contentHash;
  final Value<String?> originPackageId;
  final Value<int> rowid;
  const ProfileEntryRevisionsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.parentRevisionId = const Value.absent(),
    this.authorProfileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.originPackageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileEntryRevisionsCompanion.insert({
    required String id,
    required String entryId,
    this.parentRevisionId = const Value.absent(),
    this.authorProfileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime createdAt,
    this.importedAt = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    required String payloadJson,
    required String contentHash,
    this.originPackageId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entryId = Value(entryId),
       createdAt = Value(createdAt),
       payloadJson = Value(payloadJson),
       contentHash = Value(contentHash);
  static Insertable<ProfileEntryRevisionRow> custom({
    Expression<String>? id,
    Expression<String>? entryId,
    Expression<String>? parentRevisionId,
    Expression<String>? authorProfileId,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? importedAt,
    Expression<int>? payloadVersion,
    Expression<String>? payloadJson,
    Expression<String>? contentHash,
    Expression<String>? originPackageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (parentRevisionId != null) 'parent_revision_id': parentRevisionId,
      if (authorProfileId != null) 'author_profile_id': authorProfileId,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (importedAt != null) 'imported_at': importedAt,
      if (payloadVersion != null) 'payload_version': payloadVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (contentHash != null) 'content_hash': contentHash,
      if (originPackageId != null) 'origin_package_id': originPackageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileEntryRevisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? entryId,
    Value<String?>? parentRevisionId,
    Value<String?>? authorProfileId,
    Value<String?>? deviceId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? importedAt,
    Value<int>? payloadVersion,
    Value<String>? payloadJson,
    Value<String>? contentHash,
    Value<String?>? originPackageId,
    Value<int>? rowid,
  }) {
    return ProfileEntryRevisionsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      parentRevisionId: parentRevisionId ?? this.parentRevisionId,
      authorProfileId: authorProfileId ?? this.authorProfileId,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      importedAt: importedAt ?? this.importedAt,
      payloadVersion: payloadVersion ?? this.payloadVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      contentHash: contentHash ?? this.contentHash,
      originPackageId: originPackageId ?? this.originPackageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (parentRevisionId.present) {
      map['parent_revision_id'] = Variable<String>(parentRevisionId.value);
    }
    if (authorProfileId.present) {
      map['author_profile_id'] = Variable<String>(authorProfileId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (payloadVersion.present) {
      map['payload_version'] = Variable<int>(payloadVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (originPackageId.present) {
      map['origin_package_id'] = Variable<String>(originPackageId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEntryRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('parentRevisionId: $parentRevisionId, ')
          ..write('authorProfileId: $authorProfileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('contentHash: $contentHash, ')
          ..write('originPackageId: $originPackageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntryCategoriesTable extends EntryCategories
    with TableInfo<$EntryCategoriesTable, EntryCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile_entries (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, categoryId, isPrimary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, categoryId};
  @override
  EntryCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryCategoryRow(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $EntryCategoriesTable createAlias(String alias) {
    return $EntryCategoriesTable(attachedDatabase, alias);
  }
}

class EntryCategoryRow extends DataClass
    implements Insertable<EntryCategoryRow> {
  final String entryId;
  final String categoryId;
  final bool isPrimary;
  const EntryCategoryRow({
    required this.entryId,
    required this.categoryId,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['category_id'] = Variable<String>(categoryId);
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  EntryCategoriesCompanion toCompanion(bool nullToAbsent) {
    return EntryCategoriesCompanion(
      entryId: Value(entryId),
      categoryId: Value(categoryId),
      isPrimary: Value(isPrimary),
    );
  }

  factory EntryCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryCategoryRow(
      entryId: serializer.fromJson<String>(json['entryId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'categoryId': serializer.toJson<String>(categoryId),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  EntryCategoryRow copyWith({
    String? entryId,
    String? categoryId,
    bool? isPrimary,
  }) => EntryCategoryRow(
    entryId: entryId ?? this.entryId,
    categoryId: categoryId ?? this.categoryId,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  EntryCategoryRow copyWithCompanion(EntryCategoriesCompanion data) {
    return EntryCategoryRow(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryCategoryRow(')
          ..write('entryId: $entryId, ')
          ..write('categoryId: $categoryId, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, categoryId, isPrimary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryCategoryRow &&
          other.entryId == this.entryId &&
          other.categoryId == this.categoryId &&
          other.isPrimary == this.isPrimary);
}

class EntryCategoriesCompanion extends UpdateCompanion<EntryCategoryRow> {
  final Value<String> entryId;
  final Value<String> categoryId;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const EntryCategoriesCompanion({
    this.entryId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryCategoriesCompanion.insert({
    required String entryId,
    required String categoryId,
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       categoryId = Value(categoryId);
  static Insertable<EntryCategoryRow> custom({
    Expression<String>? entryId,
    Expression<String>? categoryId,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (categoryId != null) 'category_id': categoryId,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryCategoriesCompanion copyWith({
    Value<String>? entryId,
    Value<String>? categoryId,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return EntryCategoriesCompanion(
      entryId: entryId ?? this.entryId,
      categoryId: categoryId ?? this.categoryId,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryCategoriesCompanion(')
          ..write('entryId: $entryId, ')
          ..write('categoryId: $categoryId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntryTagsTable extends EntryTags
    with TableInfo<$EntryTagsTable, EntryTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile_entries (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, tagId};
  @override
  EntryTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryTagRow(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $EntryTagsTable createAlias(String alias) {
    return $EntryTagsTable(attachedDatabase, alias);
  }
}

class EntryTagRow extends DataClass implements Insertable<EntryTagRow> {
  final String entryId;
  final String tagId;
  const EntryTagRow({required this.entryId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  EntryTagsCompanion toCompanion(bool nullToAbsent) {
    return EntryTagsCompanion(entryId: Value(entryId), tagId: Value(tagId));
  }

  factory EntryTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryTagRow(
      entryId: serializer.fromJson<String>(json['entryId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  EntryTagRow copyWith({String? entryId, String? tagId}) =>
      EntryTagRow(entryId: entryId ?? this.entryId, tagId: tagId ?? this.tagId);
  EntryTagRow copyWithCompanion(EntryTagsCompanion data) {
    return EntryTagRow(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryTagRow(')
          ..write('entryId: $entryId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryTagRow &&
          other.entryId == this.entryId &&
          other.tagId == this.tagId);
}

class EntryTagsCompanion extends UpdateCompanion<EntryTagRow> {
  final Value<String> entryId;
  final Value<String> tagId;
  final Value<int> rowid;
  const EntryTagsCompanion({
    this.entryId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryTagsCompanion.insert({
    required String entryId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       tagId = Value(tagId);
  static Insertable<EntryTagRow> custom({
    Expression<String>? entryId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryTagsCompanion copyWith({
    Value<String>? entryId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return EntryTagsCompanion(
      entryId: entryId ?? this.entryId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryTagsCompanion(')
          ..write('entryId: $entryId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverAttachmentIdMeta = const VerificationMeta(
    'coverAttachmentId',
  );
  @override
  late final GeneratedColumn<String> coverAttachmentId =
      GeneratedColumn<String>(
        'cover_attachment_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    description,
    coverAttachmentId,
    color,
    sortOrder,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_attachment_id')) {
      context.handle(
        _coverAttachmentIdMeta,
        coverAttachmentId.isAcceptableOrUnknown(
          data['cover_attachment_id']!,
          _coverAttachmentIdMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverAttachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_attachment_id'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final String id;
  final String profileId;
  final String name;
  final String? description;
  final String? coverAttachmentId;
  final int? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const CollectionRow({
    required this.id,
    required this.profileId,
    required this.name,
    this.description,
    this.coverAttachmentId,
    this.color,
    required this.sortOrder,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverAttachmentId != null) {
      map['cover_attachment_id'] = Variable<String>(coverAttachmentId);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverAttachmentId: coverAttachmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverAttachmentId),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      coverAttachmentId: serializer.fromJson<String?>(
        json['coverAttachmentId'],
      ),
      color: serializer.fromJson<int?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'coverAttachmentId': serializer.toJson<String?>(coverAttachmentId),
      'color': serializer.toJson<int?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  CollectionRow copyWith({
    String? id,
    String? profileId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> coverAttachmentId = const Value.absent(),
    Value<int?> color = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => CollectionRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    coverAttachmentId: coverAttachmentId.present
        ? coverAttachmentId.value
        : this.coverAttachmentId,
    color: color.present ? color.value : this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverAttachmentId: data.coverAttachmentId.present
          ? data.coverAttachmentId.value
          : this.coverAttachmentId,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverAttachmentId: $coverAttachmentId, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    name,
    description,
    coverAttachmentId,
    color,
    sortOrder,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverAttachmentId == this.coverAttachmentId &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> coverAttachmentId;
  final Value<int?> color;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverAttachmentId = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    this.description = const Value.absent(),
    this.coverAttachmentId = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CollectionRow> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverAttachmentId,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverAttachmentId != null) 'cover_attachment_id': coverAttachmentId,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? coverAttachmentId,
    Value<int?>? color,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverAttachmentId: coverAttachmentId ?? this.coverAttachmentId,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverAttachmentId.present) {
      map['cover_attachment_id'] = Variable<String>(coverAttachmentId.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverAttachmentId: $coverAttachmentId, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionEntriesTable extends CollectionEntries
    with TableInfo<$CollectionEntriesTable, CollectionEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profile_entries (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    collectionId,
    entryId,
    sortOrder,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, entryId};
  @override
  CollectionEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionEntryRow(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CollectionEntriesTable createAlias(String alias) {
    return $CollectionEntriesTable(attachedDatabase, alias);
  }
}

class CollectionEntryRow extends DataClass
    implements Insertable<CollectionEntryRow> {
  final String collectionId;
  final String entryId;
  final int sortOrder;
  final DateTime addedAt;
  const CollectionEntryRow({
    required this.collectionId,
    required this.entryId,
    required this.sortOrder,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<String>(collectionId);
    map['entry_id'] = Variable<String>(entryId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CollectionEntriesCompanion toCompanion(bool nullToAbsent) {
    return CollectionEntriesCompanion(
      collectionId: Value(collectionId),
      entryId: Value(entryId),
      sortOrder: Value(sortOrder),
      addedAt: Value(addedAt),
    );
  }

  factory CollectionEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionEntryRow(
      collectionId: serializer.fromJson<String>(json['collectionId']),
      entryId: serializer.fromJson<String>(json['entryId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<String>(collectionId),
      'entryId': serializer.toJson<String>(entryId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CollectionEntryRow copyWith({
    String? collectionId,
    String? entryId,
    int? sortOrder,
    DateTime? addedAt,
  }) => CollectionEntryRow(
    collectionId: collectionId ?? this.collectionId,
    entryId: entryId ?? this.entryId,
    sortOrder: sortOrder ?? this.sortOrder,
    addedAt: addedAt ?? this.addedAt,
  );
  CollectionEntryRow copyWithCompanion(CollectionEntriesCompanion data) {
    return CollectionEntryRow(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionEntryRow(')
          ..write('collectionId: $collectionId, ')
          ..write('entryId: $entryId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, entryId, sortOrder, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionEntryRow &&
          other.collectionId == this.collectionId &&
          other.entryId == this.entryId &&
          other.sortOrder == this.sortOrder &&
          other.addedAt == this.addedAt);
}

class CollectionEntriesCompanion extends UpdateCompanion<CollectionEntryRow> {
  final Value<String> collectionId;
  final Value<String> entryId;
  final Value<int> sortOrder;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CollectionEntriesCompanion({
    this.collectionId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionEntriesCompanion.insert({
    required String collectionId,
    required String entryId,
    this.sortOrder = const Value.absent(),
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       entryId = Value(entryId),
       addedAt = Value(addedAt);
  static Insertable<CollectionEntryRow> custom({
    Expression<String>? collectionId,
    Expression<String>? entryId,
    Expression<int>? sortOrder,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (entryId != null) 'entry_id': entryId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionEntriesCompanion copyWith({
    Value<String>? collectionId,
    Value<String>? entryId,
    Value<int>? sortOrder,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CollectionEntriesCompanion(
      collectionId: collectionId ?? this.collectionId,
      entryId: entryId ?? this.entryId,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionEntriesCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('entryId: $entryId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbPathMeta = const VerificationMeta(
    'thumbPath',
  );
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
    'thumb_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sha256,
    storagePath,
    thumbPath,
    mimeType,
    width,
    height,
    byteSize,
    caption,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePathMeta);
    }
    if (data.containsKey('thumb_path')) {
      context.handle(
        _thumbPathMeta,
        thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sha256},
  ];
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      )!,
      thumbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumb_path'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String id;

  /// SHA-256 содержимого — уникален (дедупликация).
  final String sha256;

  /// Относительный путь файла в хранилище приложения (не исходный путь).
  final String storagePath;
  final String? thumbPath;
  final String mimeType;
  final int? width;
  final int? height;
  final int byteSize;
  final String? caption;
  final DateTime createdAt;
  const AttachmentRow({
    required this.id,
    required this.sha256,
    required this.storagePath,
    this.thumbPath,
    required this.mimeType,
    this.width,
    this.height,
    required this.byteSize,
    this.caption,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sha256'] = Variable<String>(sha256);
    map['storage_path'] = Variable<String>(storagePath);
    if (!nullToAbsent || thumbPath != null) {
      map['thumb_path'] = Variable<String>(thumbPath);
    }
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['byte_size'] = Variable<int>(byteSize);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      sha256: Value(sha256),
      storagePath: Value(storagePath),
      thumbPath: thumbPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbPath),
      mimeType: Value(mimeType),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      byteSize: Value(byteSize),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      sha256: serializer.fromJson<String>(json['sha256']),
      storagePath: serializer.fromJson<String>(json['storagePath']),
      thumbPath: serializer.fromJson<String?>(json['thumbPath']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      caption: serializer.fromJson<String?>(json['caption']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sha256': serializer.toJson<String>(sha256),
      'storagePath': serializer.toJson<String>(storagePath),
      'thumbPath': serializer.toJson<String?>(thumbPath),
      'mimeType': serializer.toJson<String>(mimeType),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'byteSize': serializer.toJson<int>(byteSize),
      'caption': serializer.toJson<String?>(caption),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttachmentRow copyWith({
    String? id,
    String? sha256,
    String? storagePath,
    Value<String?> thumbPath = const Value.absent(),
    String? mimeType,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    int? byteSize,
    Value<String?> caption = const Value.absent(),
    DateTime? createdAt,
  }) => AttachmentRow(
    id: id ?? this.id,
    sha256: sha256 ?? this.sha256,
    storagePath: storagePath ?? this.storagePath,
    thumbPath: thumbPath.present ? thumbPath.value : this.thumbPath,
    mimeType: mimeType ?? this.mimeType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    byteSize: byteSize ?? this.byteSize,
    caption: caption.present ? caption.value : this.caption,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      caption: data.caption.present ? data.caption.value : this.caption,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('sha256: $sha256, ')
          ..write('storagePath: $storagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('byteSize: $byteSize, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sha256,
    storagePath,
    thumbPath,
    mimeType,
    width,
    height,
    byteSize,
    caption,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.sha256 == this.sha256 &&
          other.storagePath == this.storagePath &&
          other.thumbPath == this.thumbPath &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.byteSize == this.byteSize &&
          other.caption == this.caption &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> id;
  final Value<String> sha256;
  final Value<String> storagePath;
  final Value<String?> thumbPath;
  final Value<String> mimeType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int> byteSize;
  final Value<String?> caption;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String sha256,
    required String storagePath,
    this.thumbPath = const Value.absent(),
    required String mimeType,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int byteSize,
    this.caption = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sha256 = Value(sha256),
       storagePath = Value(storagePath),
       mimeType = Value(mimeType),
       byteSize = Value(byteSize),
       createdAt = Value(createdAt);
  static Insertable<AttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? sha256,
    Expression<String>? storagePath,
    Expression<String>? thumbPath,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? byteSize,
    Expression<String>? caption,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sha256 != null) 'sha256': sha256,
      if (storagePath != null) 'storage_path': storagePath,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (byteSize != null) 'byte_size': byteSize,
      if (caption != null) 'caption': caption,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sha256,
    Value<String>? storagePath,
    Value<String?>? thumbPath,
    Value<String>? mimeType,
    Value<int?>? width,
    Value<int?>? height,
    Value<int>? byteSize,
    Value<String?>? caption,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      sha256: sha256 ?? this.sha256,
      storagePath: storagePath ?? this.storagePath,
      thumbPath: thumbPath ?? this.thumbPath,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      byteSize: byteSize ?? this.byteSize,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('sha256: $sha256, ')
          ..write('storagePath: $storagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('byteSize: $byteSize, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RevisionAttachmentsTable extends RevisionAttachments
    with TableInfo<$RevisionAttachmentsTable, RevisionAttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevisionAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityKindMeta = const VerificationMeta(
    'entityKind',
  );
  @override
  late final GeneratedColumn<String> entityKind = GeneratedColumn<String>(
    'entity_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<String> revisionId = GeneratedColumn<String>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attachments (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityKind,
    revisionId,
    attachmentId,
    sortOrder,
    isPrimary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revision_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<RevisionAttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_kind')) {
      context.handle(
        _entityKindMeta,
        entityKind.isAcceptableOrUnknown(data['entity_kind']!, _entityKindMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKindMeta);
    }
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RevisionAttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RevisionAttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_kind'],
      )!,
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_id'],
      )!,
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $RevisionAttachmentsTable createAlias(String alias) {
    return $RevisionAttachmentsTable(attachedDatabase, alias);
  }
}

class RevisionAttachmentRow extends DataClass
    implements Insertable<RevisionAttachmentRow> {
  final String id;

  /// Тип сущности: object | entry | profile | collection.
  final String entityKind;
  final String revisionId;
  final String attachmentId;
  final int sortOrder;
  final bool isPrimary;
  const RevisionAttachmentRow({
    required this.id,
    required this.entityKind,
    required this.revisionId,
    required this.attachmentId,
    required this.sortOrder,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_kind'] = Variable<String>(entityKind);
    map['revision_id'] = Variable<String>(revisionId);
    map['attachment_id'] = Variable<String>(attachmentId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  RevisionAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return RevisionAttachmentsCompanion(
      id: Value(id),
      entityKind: Value(entityKind),
      revisionId: Value(revisionId),
      attachmentId: Value(attachmentId),
      sortOrder: Value(sortOrder),
      isPrimary: Value(isPrimary),
    );
  }

  factory RevisionAttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RevisionAttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      entityKind: serializer.fromJson<String>(json['entityKind']),
      revisionId: serializer.fromJson<String>(json['revisionId']),
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityKind': serializer.toJson<String>(entityKind),
      'revisionId': serializer.toJson<String>(revisionId),
      'attachmentId': serializer.toJson<String>(attachmentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  RevisionAttachmentRow copyWith({
    String? id,
    String? entityKind,
    String? revisionId,
    String? attachmentId,
    int? sortOrder,
    bool? isPrimary,
  }) => RevisionAttachmentRow(
    id: id ?? this.id,
    entityKind: entityKind ?? this.entityKind,
    revisionId: revisionId ?? this.revisionId,
    attachmentId: attachmentId ?? this.attachmentId,
    sortOrder: sortOrder ?? this.sortOrder,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  RevisionAttachmentRow copyWithCompanion(RevisionAttachmentsCompanion data) {
    return RevisionAttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      entityKind: data.entityKind.present
          ? data.entityKind.value
          : this.entityKind,
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RevisionAttachmentRow(')
          ..write('id: $id, ')
          ..write('entityKind: $entityKind, ')
          ..write('revisionId: $revisionId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityKind,
    revisionId,
    attachmentId,
    sortOrder,
    isPrimary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RevisionAttachmentRow &&
          other.id == this.id &&
          other.entityKind == this.entityKind &&
          other.revisionId == this.revisionId &&
          other.attachmentId == this.attachmentId &&
          other.sortOrder == this.sortOrder &&
          other.isPrimary == this.isPrimary);
}

class RevisionAttachmentsCompanion
    extends UpdateCompanion<RevisionAttachmentRow> {
  final Value<String> id;
  final Value<String> entityKind;
  final Value<String> revisionId;
  final Value<String> attachmentId;
  final Value<int> sortOrder;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const RevisionAttachmentsCompanion({
    this.id = const Value.absent(),
    this.entityKind = const Value.absent(),
    this.revisionId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RevisionAttachmentsCompanion.insert({
    required String id,
    required String entityKind,
    required String revisionId,
    required String attachmentId,
    this.sortOrder = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityKind = Value(entityKind),
       revisionId = Value(revisionId),
       attachmentId = Value(attachmentId);
  static Insertable<RevisionAttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? entityKind,
    Expression<String>? revisionId,
    Expression<String>? attachmentId,
    Expression<int>? sortOrder,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityKind != null) 'entity_kind': entityKind,
      if (revisionId != null) 'revision_id': revisionId,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RevisionAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityKind,
    Value<String>? revisionId,
    Value<String>? attachmentId,
    Value<int>? sortOrder,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return RevisionAttachmentsCompanion(
      id: id ?? this.id,
      entityKind: entityKind ?? this.entityKind,
      revisionId: revisionId ?? this.revisionId,
      attachmentId: attachmentId ?? this.attachmentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityKind.present) {
      map['entity_kind'] = Variable<String>(entityKind.value);
    }
    if (revisionId.present) {
      map['revision_id'] = Variable<String>(revisionId.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevisionAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('entityKind: $entityKind, ')
          ..write('revisionId: $revisionId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageHashMeta = const VerificationMeta(
    'packageHash',
  );
  @override
  late final GeneratedColumn<String> packageHash = GeneratedColumn<String>(
    'package_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageId,
    packageHash,
    profileId,
    deviceId,
    importedAt,
    summaryJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('package_hash')) {
      context.handle(
        _packageHashMeta,
        packageHash.isAcceptableOrUnknown(
          data['package_hash']!,
          _packageHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageHashMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {packageHash},
  ];
  @override
  ImportBatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      packageHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_hash'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      ),
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatchRow extends DataClass implements Insertable<ImportBatchRow> {
  final String id;
  final String packageId;
  final String packageHash;
  final String? profileId;
  final String? deviceId;
  final DateTime importedAt;
  final String? summaryJson;
  const ImportBatchRow({
    required this.id,
    required this.packageId,
    required this.packageHash,
    this.profileId,
    this.deviceId,
    required this.importedAt,
    this.summaryJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['package_id'] = Variable<String>(packageId);
    map['package_hash'] = Variable<String>(packageHash);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || summaryJson != null) {
      map['summary_json'] = Variable<String>(summaryJson);
    }
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      packageId: Value(packageId),
      packageHash: Value(packageHash),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      importedAt: Value(importedAt),
      summaryJson: summaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryJson),
    );
  }

  factory ImportBatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatchRow(
      id: serializer.fromJson<String>(json['id']),
      packageId: serializer.fromJson<String>(json['packageId']),
      packageHash: serializer.fromJson<String>(json['packageHash']),
      profileId: serializer.fromJson<String?>(json['profileId']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      summaryJson: serializer.fromJson<String?>(json['summaryJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'packageId': serializer.toJson<String>(packageId),
      'packageHash': serializer.toJson<String>(packageHash),
      'profileId': serializer.toJson<String?>(profileId),
      'deviceId': serializer.toJson<String?>(deviceId),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'summaryJson': serializer.toJson<String?>(summaryJson),
    };
  }

  ImportBatchRow copyWith({
    String? id,
    String? packageId,
    String? packageHash,
    Value<String?> profileId = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    DateTime? importedAt,
    Value<String?> summaryJson = const Value.absent(),
  }) => ImportBatchRow(
    id: id ?? this.id,
    packageId: packageId ?? this.packageId,
    packageHash: packageHash ?? this.packageHash,
    profileId: profileId.present ? profileId.value : this.profileId,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    importedAt: importedAt ?? this.importedAt,
    summaryJson: summaryJson.present ? summaryJson.value : this.summaryJson,
  );
  ImportBatchRow copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatchRow(
      id: data.id.present ? data.id.value : this.id,
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      packageHash: data.packageHash.present
          ? data.packageHash.value
          : this.packageHash,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchRow(')
          ..write('id: $id, ')
          ..write('packageId: $packageId, ')
          ..write('packageHash: $packageHash, ')
          ..write('profileId: $profileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('importedAt: $importedAt, ')
          ..write('summaryJson: $summaryJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageId,
    packageHash,
    profileId,
    deviceId,
    importedAt,
    summaryJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatchRow &&
          other.id == this.id &&
          other.packageId == this.packageId &&
          other.packageHash == this.packageHash &&
          other.profileId == this.profileId &&
          other.deviceId == this.deviceId &&
          other.importedAt == this.importedAt &&
          other.summaryJson == this.summaryJson);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatchRow> {
  final Value<String> id;
  final Value<String> packageId;
  final Value<String> packageHash;
  final Value<String?> profileId;
  final Value<String?> deviceId;
  final Value<DateTime> importedAt;
  final Value<String?> summaryJson;
  final Value<int> rowid;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.packageId = const Value.absent(),
    this.packageHash = const Value.absent(),
    this.profileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    required String id,
    required String packageId,
    required String packageHash,
    this.profileId = const Value.absent(),
    this.deviceId = const Value.absent(),
    required DateTime importedAt,
    this.summaryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       packageId = Value(packageId),
       packageHash = Value(packageHash),
       importedAt = Value(importedAt);
  static Insertable<ImportBatchRow> custom({
    Expression<String>? id,
    Expression<String>? packageId,
    Expression<String>? packageHash,
    Expression<String>? profileId,
    Expression<String>? deviceId,
    Expression<DateTime>? importedAt,
    Expression<String>? summaryJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageId != null) 'package_id': packageId,
      if (packageHash != null) 'package_hash': packageHash,
      if (profileId != null) 'profile_id': profileId,
      if (deviceId != null) 'device_id': deviceId,
      if (importedAt != null) 'imported_at': importedAt,
      if (summaryJson != null) 'summary_json': summaryJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? packageId,
    Value<String>? packageHash,
    Value<String?>? profileId,
    Value<String?>? deviceId,
    Value<DateTime>? importedAt,
    Value<String?>? summaryJson,
    Value<int>? rowid,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      packageHash: packageHash ?? this.packageHash,
      profileId: profileId ?? this.profileId,
      deviceId: deviceId ?? this.deviceId,
      importedAt: importedAt ?? this.importedAt,
      summaryJson: summaryJson ?? this.summaryJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (packageHash.present) {
      map['package_hash'] = Variable<String>(packageHash.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('packageId: $packageId, ')
          ..write('packageHash: $packageHash, ')
          ..write('profileId: $profileId, ')
          ..write('deviceId: $deviceId, ')
          ..write('importedAt: $importedAt, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportBatchesTable extends ExportBatches
    with TableInfo<$ExportBatchesTable, ExportBatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exportedAtMeta = const VerificationMeta(
    'exportedAt',
  );
  @override
  late final GeneratedColumn<DateTime> exportedAt = GeneratedColumn<DateTime>(
    'exported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryJsonMeta = const VerificationMeta(
    'summaryJson',
  );
  @override
  late final GeneratedColumn<String> summaryJson = GeneratedColumn<String>(
    'summary_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageId,
    profileId,
    mode,
    exportedAt,
    summaryJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportBatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('exported_at')) {
      context.handle(
        _exportedAtMeta,
        exportedAt.isAcceptableOrUnknown(data['exported_at']!, _exportedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_exportedAtMeta);
    }
    if (data.containsKey('summary_json')) {
      context.handle(
        _summaryJsonMeta,
        summaryJson.isAcceptableOrUnknown(
          data['summary_json']!,
          _summaryJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportBatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportBatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      exportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exported_at'],
      )!,
      summaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_json'],
      ),
    );
  }

  @override
  $ExportBatchesTable createAlias(String alias) {
    return $ExportBatchesTable(attachedDatabase, alias);
  }
}

class ExportBatchRow extends DataClass implements Insertable<ExportBatchRow> {
  final String id;
  final String packageId;
  final String profileId;
  final String mode;
  final DateTime exportedAt;
  final String? summaryJson;
  const ExportBatchRow({
    required this.id,
    required this.packageId,
    required this.profileId,
    required this.mode,
    required this.exportedAt,
    this.summaryJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['package_id'] = Variable<String>(packageId);
    map['profile_id'] = Variable<String>(profileId);
    map['mode'] = Variable<String>(mode);
    map['exported_at'] = Variable<DateTime>(exportedAt);
    if (!nullToAbsent || summaryJson != null) {
      map['summary_json'] = Variable<String>(summaryJson);
    }
    return map;
  }

  ExportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ExportBatchesCompanion(
      id: Value(id),
      packageId: Value(packageId),
      profileId: Value(profileId),
      mode: Value(mode),
      exportedAt: Value(exportedAt),
      summaryJson: summaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryJson),
    );
  }

  factory ExportBatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportBatchRow(
      id: serializer.fromJson<String>(json['id']),
      packageId: serializer.fromJson<String>(json['packageId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      mode: serializer.fromJson<String>(json['mode']),
      exportedAt: serializer.fromJson<DateTime>(json['exportedAt']),
      summaryJson: serializer.fromJson<String?>(json['summaryJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'packageId': serializer.toJson<String>(packageId),
      'profileId': serializer.toJson<String>(profileId),
      'mode': serializer.toJson<String>(mode),
      'exportedAt': serializer.toJson<DateTime>(exportedAt),
      'summaryJson': serializer.toJson<String?>(summaryJson),
    };
  }

  ExportBatchRow copyWith({
    String? id,
    String? packageId,
    String? profileId,
    String? mode,
    DateTime? exportedAt,
    Value<String?> summaryJson = const Value.absent(),
  }) => ExportBatchRow(
    id: id ?? this.id,
    packageId: packageId ?? this.packageId,
    profileId: profileId ?? this.profileId,
    mode: mode ?? this.mode,
    exportedAt: exportedAt ?? this.exportedAt,
    summaryJson: summaryJson.present ? summaryJson.value : this.summaryJson,
  );
  ExportBatchRow copyWithCompanion(ExportBatchesCompanion data) {
    return ExportBatchRow(
      id: data.id.present ? data.id.value : this.id,
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      mode: data.mode.present ? data.mode.value : this.mode,
      exportedAt: data.exportedAt.present
          ? data.exportedAt.value
          : this.exportedAt,
      summaryJson: data.summaryJson.present
          ? data.summaryJson.value
          : this.summaryJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportBatchRow(')
          ..write('id: $id, ')
          ..write('packageId: $packageId, ')
          ..write('profileId: $profileId, ')
          ..write('mode: $mode, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('summaryJson: $summaryJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, packageId, profileId, mode, exportedAt, summaryJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportBatchRow &&
          other.id == this.id &&
          other.packageId == this.packageId &&
          other.profileId == this.profileId &&
          other.mode == this.mode &&
          other.exportedAt == this.exportedAt &&
          other.summaryJson == this.summaryJson);
}

class ExportBatchesCompanion extends UpdateCompanion<ExportBatchRow> {
  final Value<String> id;
  final Value<String> packageId;
  final Value<String> profileId;
  final Value<String> mode;
  final Value<DateTime> exportedAt;
  final Value<String?> summaryJson;
  final Value<int> rowid;
  const ExportBatchesCompanion({
    this.id = const Value.absent(),
    this.packageId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.mode = const Value.absent(),
    this.exportedAt = const Value.absent(),
    this.summaryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportBatchesCompanion.insert({
    required String id,
    required String packageId,
    required String profileId,
    required String mode,
    required DateTime exportedAt,
    this.summaryJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       packageId = Value(packageId),
       profileId = Value(profileId),
       mode = Value(mode),
       exportedAt = Value(exportedAt);
  static Insertable<ExportBatchRow> custom({
    Expression<String>? id,
    Expression<String>? packageId,
    Expression<String>? profileId,
    Expression<String>? mode,
    Expression<DateTime>? exportedAt,
    Expression<String>? summaryJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageId != null) 'package_id': packageId,
      if (profileId != null) 'profile_id': profileId,
      if (mode != null) 'mode': mode,
      if (exportedAt != null) 'exported_at': exportedAt,
      if (summaryJson != null) 'summary_json': summaryJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? packageId,
    Value<String>? profileId,
    Value<String>? mode,
    Value<DateTime>? exportedAt,
    Value<String?>? summaryJson,
    Value<int>? rowid,
  }) {
    return ExportBatchesCompanion(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      profileId: profileId ?? this.profileId,
      mode: mode ?? this.mode,
      exportedAt: exportedAt ?? this.exportedAt,
      summaryJson: summaryJson ?? this.summaryJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (exportedAt.present) {
      map['exported_at'] = Variable<DateTime>(exportedAt.value);
    }
    if (summaryJson.present) {
      map['summary_json'] = Variable<String>(summaryJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('packageId: $packageId, ')
          ..write('profileId: $profileId, ')
          ..write('mode: $mode, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('summaryJson: $summaryJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomingChangesTable extends IncomingChanges
    with TableInfo<$IncomingChangesTable, IncomingChangeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomingChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityKindMeta = const VerificationMeta(
    'entityKind',
  );
  @override
  late final GeneratedColumn<String> entityKind = GeneratedColumn<String>(
    'entity_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<String> revisionId = GeneratedColumn<String>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourcePackageIdMeta = const VerificationMeta(
    'sourcePackageId',
  );
  @override
  late final GeneratedColumn<String> sourcePackageId = GeneratedColumn<String>(
    'source_package_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    entityKind,
    entityId,
    revisionId,
    sourcePackageId,
    receivedAt,
    seen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incoming_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomingChangeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('entity_kind')) {
      context.handle(
        _entityKindMeta,
        entityKind.isAcceptableOrUnknown(data['entity_kind']!, _entityKindMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKindMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('source_package_id')) {
      context.handle(
        _sourcePackageIdMeta,
        sourcePackageId.isAcceptableOrUnknown(
          data['source_package_id']!,
          _sourcePackageIdMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomingChangeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomingChangeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      entityKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_kind'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_id'],
      )!,
      sourcePackageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_package_id'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      seen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen'],
      )!,
    );
  }

  @override
  $IncomingChangesTable createAlias(String alias) {
    return $IncomingChangesTable(attachedDatabase, alias);
  }
}

class IncomingChangeRow extends DataClass
    implements Insertable<IncomingChangeRow> {
  final String id;
  final String profileId;
  final String entityKind;
  final String entityId;
  final String revisionId;
  final String? sourcePackageId;
  final DateTime receivedAt;
  final bool seen;
  const IncomingChangeRow({
    required this.id,
    required this.profileId,
    required this.entityKind,
    required this.entityId,
    required this.revisionId,
    this.sourcePackageId,
    required this.receivedAt,
    required this.seen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['entity_kind'] = Variable<String>(entityKind);
    map['entity_id'] = Variable<String>(entityId);
    map['revision_id'] = Variable<String>(revisionId);
    if (!nullToAbsent || sourcePackageId != null) {
      map['source_package_id'] = Variable<String>(sourcePackageId);
    }
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['seen'] = Variable<bool>(seen);
    return map;
  }

  IncomingChangesCompanion toCompanion(bool nullToAbsent) {
    return IncomingChangesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      entityKind: Value(entityKind),
      entityId: Value(entityId),
      revisionId: Value(revisionId),
      sourcePackageId: sourcePackageId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePackageId),
      receivedAt: Value(receivedAt),
      seen: Value(seen),
    );
  }

  factory IncomingChangeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomingChangeRow(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      entityKind: serializer.fromJson<String>(json['entityKind']),
      entityId: serializer.fromJson<String>(json['entityId']),
      revisionId: serializer.fromJson<String>(json['revisionId']),
      sourcePackageId: serializer.fromJson<String?>(json['sourcePackageId']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      seen: serializer.fromJson<bool>(json['seen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'entityKind': serializer.toJson<String>(entityKind),
      'entityId': serializer.toJson<String>(entityId),
      'revisionId': serializer.toJson<String>(revisionId),
      'sourcePackageId': serializer.toJson<String?>(sourcePackageId),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'seen': serializer.toJson<bool>(seen),
    };
  }

  IncomingChangeRow copyWith({
    String? id,
    String? profileId,
    String? entityKind,
    String? entityId,
    String? revisionId,
    Value<String?> sourcePackageId = const Value.absent(),
    DateTime? receivedAt,
    bool? seen,
  }) => IncomingChangeRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    entityKind: entityKind ?? this.entityKind,
    entityId: entityId ?? this.entityId,
    revisionId: revisionId ?? this.revisionId,
    sourcePackageId: sourcePackageId.present
        ? sourcePackageId.value
        : this.sourcePackageId,
    receivedAt: receivedAt ?? this.receivedAt,
    seen: seen ?? this.seen,
  );
  IncomingChangeRow copyWithCompanion(IncomingChangesCompanion data) {
    return IncomingChangeRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      entityKind: data.entityKind.present
          ? data.entityKind.value
          : this.entityKind,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      sourcePackageId: data.sourcePackageId.present
          ? data.sourcePackageId.value
          : this.sourcePackageId,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      seen: data.seen.present ? data.seen.value : this.seen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomingChangeRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('entityKind: $entityKind, ')
          ..write('entityId: $entityId, ')
          ..write('revisionId: $revisionId, ')
          ..write('sourcePackageId: $sourcePackageId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    entityKind,
    entityId,
    revisionId,
    sourcePackageId,
    receivedAt,
    seen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomingChangeRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.entityKind == this.entityKind &&
          other.entityId == this.entityId &&
          other.revisionId == this.revisionId &&
          other.sourcePackageId == this.sourcePackageId &&
          other.receivedAt == this.receivedAt &&
          other.seen == this.seen);
}

class IncomingChangesCompanion extends UpdateCompanion<IncomingChangeRow> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> entityKind;
  final Value<String> entityId;
  final Value<String> revisionId;
  final Value<String?> sourcePackageId;
  final Value<DateTime> receivedAt;
  final Value<bool> seen;
  final Value<int> rowid;
  const IncomingChangesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.entityKind = const Value.absent(),
    this.entityId = const Value.absent(),
    this.revisionId = const Value.absent(),
    this.sourcePackageId = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.seen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomingChangesCompanion.insert({
    required String id,
    required String profileId,
    required String entityKind,
    required String entityId,
    required String revisionId,
    this.sourcePackageId = const Value.absent(),
    required DateTime receivedAt,
    this.seen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       entityKind = Value(entityKind),
       entityId = Value(entityId),
       revisionId = Value(revisionId),
       receivedAt = Value(receivedAt);
  static Insertable<IncomingChangeRow> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? entityKind,
    Expression<String>? entityId,
    Expression<String>? revisionId,
    Expression<String>? sourcePackageId,
    Expression<DateTime>? receivedAt,
    Expression<bool>? seen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (entityKind != null) 'entity_kind': entityKind,
      if (entityId != null) 'entity_id': entityId,
      if (revisionId != null) 'revision_id': revisionId,
      if (sourcePackageId != null) 'source_package_id': sourcePackageId,
      if (receivedAt != null) 'received_at': receivedAt,
      if (seen != null) 'seen': seen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomingChangesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? entityKind,
    Value<String>? entityId,
    Value<String>? revisionId,
    Value<String?>? sourcePackageId,
    Value<DateTime>? receivedAt,
    Value<bool>? seen,
    Value<int>? rowid,
  }) {
    return IncomingChangesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      entityKind: entityKind ?? this.entityKind,
      entityId: entityId ?? this.entityId,
      revisionId: revisionId ?? this.revisionId,
      sourcePackageId: sourcePackageId ?? this.sourcePackageId,
      receivedAt: receivedAt ?? this.receivedAt,
      seen: seen ?? this.seen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (entityKind.present) {
      map['entity_kind'] = Variable<String>(entityKind.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (revisionId.present) {
      map['revision_id'] = Variable<String>(revisionId.value);
    }
    if (sourcePackageId.present) {
      map['source_package_id'] = Variable<String>(sourcePackageId.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomingChangesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('entityKind: $entityKind, ')
          ..write('entityId: $entityId, ')
          ..write('revisionId: $revisionId, ')
          ..write('sourcePackageId: $sourcePackageId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('seen: $seen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, DraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    kind,
    payloadJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class DraftRow extends DataClass implements Insertable<DraftRow> {
  final String id;
  final String? profileId;
  final String kind;
  final String payloadJson;
  final DateTime updatedAt;
  const DraftRow({
    required this.id,
    this.profileId,
    required this.kind,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory DraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftRow(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String?>(json['profileId']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String?>(profileId),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DraftRow copyWith({
    String? id,
    Value<String?> profileId = const Value.absent(),
    String? kind,
    String? payloadJson,
    DateTime? updatedAt,
  }) => DraftRow(
    id: id ?? this.id,
    profileId: profileId.present ? profileId.value : this.profileId,
    kind: kind ?? this.kind,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DraftRow copyWithCompanion(DraftsCompanion data) {
    return DraftRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, kind, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class DraftsCompanion extends UpdateCompanion<DraftRow> {
  final Value<String> id;
  final Value<String?> profileId;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String id,
    this.profileId = const Value.absent(),
    required String kind,
    required String payloadJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<DraftRow> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith({
    Value<String>? id,
    Value<String?>? profileId,
    Value<String>? kind,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DraftsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ProfileDevicesTable profileDevices = $ProfileDevicesTable(this);
  late final $ProfileLocalSettingsTable profileLocalSettings =
      $ProfileLocalSettingsTable(this);
  late final $ProfileKeysTable profileKeys = $ProfileKeysTable(this);
  late final $ObjectTypesTable objectTypes = $ObjectTypesTable(this);
  late final $ObjectsTable objects = $ObjectsTable(this);
  late final $ObjectRevisionsTable objectRevisions = $ObjectRevisionsTable(
    this,
  );
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CategoryRevisionsTable categoryRevisions =
      $CategoryRevisionsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ProfileEntriesTable profileEntries = $ProfileEntriesTable(this);
  late final $ProfileEntryRevisionsTable profileEntryRevisions =
      $ProfileEntryRevisionsTable(this);
  late final $EntryCategoriesTable entryCategories = $EntryCategoriesTable(
    this,
  );
  late final $EntryTagsTable entryTags = $EntryTagsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionEntriesTable collectionEntries =
      $CollectionEntriesTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $RevisionAttachmentsTable revisionAttachments =
      $RevisionAttachmentsTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final $ExportBatchesTable exportBatches = $ExportBatchesTable(this);
  late final $IncomingChangesTable incomingChanges = $IncomingChangesTable(
    this,
  );
  late final $SettingsTable settings = $SettingsTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    profileDevices,
    profileLocalSettings,
    profileKeys,
    objectTypes,
    objects,
    objectRevisions,
    categories,
    categoryRevisions,
    tags,
    profileEntries,
    profileEntryRevisions,
    entryCategories,
    entryTags,
    collections,
    collectionEntries,
    attachments,
    revisionAttachments,
    importBatches,
    exportBatches,
    incomingChanges,
    settings,
    drafts,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      Value<String> type,
      required String firstName,
      Value<String?> lastName,
      Value<String?> nickname,
      Value<String?> avatarAttachmentId,
      Value<int?> color,
      Value<String?> bio,
      Value<String?> publicKey,
      Value<String?> fingerprint,
      Value<int> profileVersion,
      Value<String> retransmitMode,
      Value<String?> currentRevisionId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> firstName,
      Value<String?> lastName,
      Value<String?> nickname,
      Value<String?> avatarAttachmentId,
      Value<int?> color,
      Value<String?> bio,
      Value<String?> publicKey,
      Value<String?> fingerprint,
      Value<int> profileVersion,
      Value<String> retransmitMode,
      Value<String?> currentRevisionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfileDevicesTable, List<ProfileDeviceRow>>
  _profileDevicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.profileDevices,
    aliasName: 'profiles__id__profile_devices__profile_id',
  );

  $$ProfileDevicesTableProcessedTableManager get profileDevicesRefs {
    final manager = $$ProfileDevicesTableTableManager(
      $_db,
      $_db.profileDevices,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_profileDevicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProfileLocalSettingsTable,
    List<ProfileLocalSettingRow>
  >
  _profileLocalSettingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.profileLocalSettings,
        aliasName: 'profiles__id__profile_local_settings__profile_id',
      );

  $$ProfileLocalSettingsTableProcessedTableManager
  get profileLocalSettingsRefs {
    final manager = $$ProfileLocalSettingsTableTableManager(
      $_db,
      $_db.profileLocalSettings,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileLocalSettingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProfileKeysTable, List<ProfileKeyRow>>
  _profileKeysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.profileKeys,
    aliasName: 'profiles__id__profile_keys__profile_id',
  );

  $$ProfileKeysTableProcessedTableManager get profileKeysRefs {
    final manager = $$ProfileKeysTableTableManager(
      $_db,
      $_db.profileKeys,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_profileKeysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ObjectTypesTable, List<ObjectTypeRow>>
  _objectTypesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.objectTypes,
    aliasName: 'profiles__id__object_types__profile_id',
  );

  $$ObjectTypesTableProcessedTableManager get objectTypesRefs {
    final manager = $$ObjectTypesTableTableManager(
      $_db,
      $_db.objectTypes,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_objectTypesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategoriesTable, List<CategoryRow>>
  _categoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categories,
    aliasName: 'profiles__id__categories__profile_id',
  );

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TagsTable, List<TagRow>> _tagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tags,
    aliasName: 'profiles__id__tags__profile_id',
  );

  $$TagsTableProcessedTableManager get tagsRefs {
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProfileEntriesTable, List<ProfileEntryRow>>
  _profileEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.profileEntries,
    aliasName: 'profiles__id__profile_entries__profile_id',
  );

  $$ProfileEntriesTableProcessedTableManager get profileEntriesRefs {
    final manager = $$ProfileEntriesTableTableManager(
      $_db,
      $_db.profileEntries,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_profileEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CollectionsTable, List<CollectionRow>>
  _collectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collections,
    aliasName: 'profiles__id__collections__profile_id',
  );

  $$CollectionsTableProcessedTableManager get collectionsRefs {
    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_collectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
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

  ColumnFilters<String> get avatarAttachmentId => $composableBuilder(
    column: $table.avatarAttachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profileVersion => $composableBuilder(
    column: $table.profileVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retransmitMode => $composableBuilder(
    column: $table.retransmitMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> profileDevicesRefs(
    Expression<bool> Function($$ProfileDevicesTableFilterComposer f) f,
  ) {
    final $$ProfileDevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileDevices,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileDevicesTableFilterComposer(
            $db: $db,
            $table: $db.profileDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> profileLocalSettingsRefs(
    Expression<bool> Function($$ProfileLocalSettingsTableFilterComposer f) f,
  ) {
    final $$ProfileLocalSettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileLocalSettings,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileLocalSettingsTableFilterComposer(
            $db: $db,
            $table: $db.profileLocalSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> profileKeysRefs(
    Expression<bool> Function($$ProfileKeysTableFilterComposer f) f,
  ) {
    final $$ProfileKeysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileKeys,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileKeysTableFilterComposer(
            $db: $db,
            $table: $db.profileKeys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> objectTypesRefs(
    Expression<bool> Function($$ObjectTypesTableFilterComposer f) f,
  ) {
    final $$ObjectTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.objectTypes,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectTypesTableFilterComposer(
            $db: $db,
            $table: $db.objectTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoriesRefs(
    Expression<bool> Function($$CategoriesTableFilterComposer f) f,
  ) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tagsRefs(
    Expression<bool> Function($$TagsTableFilterComposer f) f,
  ) {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> profileEntriesRefs(
    Expression<bool> Function($$ProfileEntriesTableFilterComposer f) f,
  ) {
    final $$ProfileEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableFilterComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionsRefs(
    Expression<bool> Function($$CollectionsTableFilterComposer f) f,
  ) {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
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

  ColumnOrderings<String> get avatarAttachmentId => $composableBuilder(
    column: $table.avatarAttachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profileVersion => $composableBuilder(
    column: $table.profileVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retransmitMode => $composableBuilder(
    column: $table.retransmitMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatarAttachmentId => $composableBuilder(
    column: $table.avatarAttachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get profileVersion => $composableBuilder(
    column: $table.profileVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retransmitMode => $composableBuilder(
    column: $table.retransmitMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> profileDevicesRefs<T extends Object>(
    Expression<T> Function($$ProfileDevicesTableAnnotationComposer a) f,
  ) {
    final $$ProfileDevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileDevices,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileDevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.profileDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> profileLocalSettingsRefs<T extends Object>(
    Expression<T> Function($$ProfileLocalSettingsTableAnnotationComposer a) f,
  ) {
    final $$ProfileLocalSettingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileLocalSettings,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileLocalSettingsTableAnnotationComposer(
                $db: $db,
                $table: $db.profileLocalSettings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> profileKeysRefs<T extends Object>(
    Expression<T> Function($$ProfileKeysTableAnnotationComposer a) f,
  ) {
    final $$ProfileKeysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileKeys,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileKeysTableAnnotationComposer(
            $db: $db,
            $table: $db.profileKeys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> objectTypesRefs<T extends Object>(
    Expression<T> Function($$ObjectTypesTableAnnotationComposer a) f,
  ) {
    final $$ObjectTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.objectTypes,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.objectTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categoriesRefs<T extends Object>(
    Expression<T> Function($$CategoriesTableAnnotationComposer a) f,
  ) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tagsRefs<T extends Object>(
    Expression<T> Function($$TagsTableAnnotationComposer a) f,
  ) {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> profileEntriesRefs<T extends Object>(
    Expression<T> Function($$ProfileEntriesTableAnnotationComposer a) f,
  ) {
    final $$ProfileEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collectionsRefs<T extends Object>(
    Expression<T> Function($$CollectionsTableAnnotationComposer a) f,
  ) {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (ProfileRow, $$ProfilesTableReferences),
          ProfileRow,
          PrefetchHooks Function({
            bool profileDevicesRefs,
            bool profileLocalSettingsRefs,
            bool profileKeysRefs,
            bool objectTypesRefs,
            bool categoriesRefs,
            bool tagsRefs,
            bool profileEntriesRefs,
            bool collectionsRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> avatarAttachmentId = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> fingerprint = const Value.absent(),
                Value<int> profileVersion = const Value.absent(),
                Value<String> retransmitMode = const Value.absent(),
                Value<String?> currentRevisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                type: type,
                firstName: firstName,
                lastName: lastName,
                nickname: nickname,
                avatarAttachmentId: avatarAttachmentId,
                color: color,
                bio: bio,
                publicKey: publicKey,
                fingerprint: fingerprint,
                profileVersion: profileVersion,
                retransmitMode: retransmitMode,
                currentRevisionId: currentRevisionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> type = const Value.absent(),
                required String firstName,
                Value<String?> lastName = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> avatarAttachmentId = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> fingerprint = const Value.absent(),
                Value<int> profileVersion = const Value.absent(),
                Value<String> retransmitMode = const Value.absent(),
                Value<String?> currentRevisionId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                type: type,
                firstName: firstName,
                lastName: lastName,
                nickname: nickname,
                avatarAttachmentId: avatarAttachmentId,
                color: color,
                bio: bio,
                publicKey: publicKey,
                fingerprint: fingerprint,
                profileVersion: profileVersion,
                retransmitMode: retransmitMode,
                currentRevisionId: currentRevisionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileDevicesRefs = false,
                profileLocalSettingsRefs = false,
                profileKeysRefs = false,
                objectTypesRefs = false,
                categoriesRefs = false,
                tagsRefs = false,
                profileEntriesRefs = false,
                collectionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (profileDevicesRefs) db.profileDevices,
                    if (profileLocalSettingsRefs) db.profileLocalSettings,
                    if (profileKeysRefs) db.profileKeys,
                    if (objectTypesRefs) db.objectTypes,
                    if (categoriesRefs) db.categories,
                    if (tagsRefs) db.tags,
                    if (profileEntriesRefs) db.profileEntries,
                    if (collectionsRefs) db.collections,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (profileDevicesRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          ProfileDeviceRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._profileDevicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileDevicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (profileLocalSettingsRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          ProfileLocalSettingRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._profileLocalSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileLocalSettingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (profileKeysRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          ProfileKeyRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._profileKeysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileKeysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (objectTypesRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          ObjectTypeRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._objectTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).objectTypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categoriesRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          CategoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._categoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tagsRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          TagRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._tagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).tagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (profileEntriesRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          ProfileEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._profileEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (collectionsRefs)
                        await $_getPrefetchedData<
                          ProfileRow,
                          $ProfilesTable,
                          CollectionRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._collectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, $$ProfilesTableReferences),
      ProfileRow,
      PrefetchHooks Function({
        bool profileDevicesRefs,
        bool profileLocalSettingsRefs,
        bool profileKeysRefs,
        bool objectTypesRefs,
        bool categoriesRefs,
        bool tagsRefs,
        bool profileEntriesRefs,
        bool collectionsRefs,
      })
    >;
typedef $$ProfileDevicesTableCreateCompanionBuilder =
    ProfileDevicesCompanion Function({
      required String id,
      required String profileId,
      required String name,
      Value<String?> deviceType,
      Value<String?> model,
      Value<String?> os,
      required DateTime registeredAt,
      Value<DateTime?> lastExportAt,
      Value<DateTime?> lastImportAt,
      Value<bool> trusted,
      Value<int> rowid,
    });
typedef $$ProfileDevicesTableUpdateCompanionBuilder =
    ProfileDevicesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> name,
      Value<String?> deviceType,
      Value<String?> model,
      Value<String?> os,
      Value<DateTime> registeredAt,
      Value<DateTime?> lastExportAt,
      Value<DateTime?> lastImportAt,
      Value<bool> trusted,
      Value<int> rowid,
    });

final class $$ProfileDevicesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProfileDevicesTable, ProfileDeviceRow> {
  $$ProfileDevicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('profile_devices__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileDevicesTable> {
  $$ProfileDevicesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get os => $composableBuilder(
    column: $table.os,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastImportAt => $composableBuilder(
    column: $table.lastImportAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trusted => $composableBuilder(
    column: $table.trusted,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileDevicesTable> {
  $$ProfileDevicesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get os => $composableBuilder(
    column: $table.os,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastImportAt => $composableBuilder(
    column: $table.lastImportAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trusted => $composableBuilder(
    column: $table.trusted,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileDevicesTable> {
  $$ProfileDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get deviceType => $composableBuilder(
    column: $table.deviceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get os =>
      $composableBuilder(column: $table.os, builder: (column) => column);

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastExportAt => $composableBuilder(
    column: $table.lastExportAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastImportAt => $composableBuilder(
    column: $table.lastImportAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trusted =>
      $composableBuilder(column: $table.trusted, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileDevicesTable,
          ProfileDeviceRow,
          $$ProfileDevicesTableFilterComposer,
          $$ProfileDevicesTableOrderingComposer,
          $$ProfileDevicesTableAnnotationComposer,
          $$ProfileDevicesTableCreateCompanionBuilder,
          $$ProfileDevicesTableUpdateCompanionBuilder,
          (ProfileDeviceRow, $$ProfileDevicesTableReferences),
          ProfileDeviceRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProfileDevicesTableTableManager(
    _$AppDatabase db,
    $ProfileDevicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> deviceType = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> os = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<DateTime?> lastExportAt = const Value.absent(),
                Value<DateTime?> lastImportAt = const Value.absent(),
                Value<bool> trusted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileDevicesCompanion(
                id: id,
                profileId: profileId,
                name: name,
                deviceType: deviceType,
                model: model,
                os: os,
                registeredAt: registeredAt,
                lastExportAt: lastExportAt,
                lastImportAt: lastImportAt,
                trusted: trusted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                Value<String?> deviceType = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> os = const Value.absent(),
                required DateTime registeredAt,
                Value<DateTime?> lastExportAt = const Value.absent(),
                Value<DateTime?> lastImportAt = const Value.absent(),
                Value<bool> trusted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileDevicesCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                deviceType: deviceType,
                model: model,
                os: os,
                registeredAt: registeredAt,
                lastExportAt: lastExportAt,
                lastImportAt: lastImportAt,
                trusted: trusted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileDevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ProfileDevicesTableReferences
                                    ._profileIdTable(db),
                                referencedColumn:
                                    $$ProfileDevicesTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileDevicesTable,
      ProfileDeviceRow,
      $$ProfileDevicesTableFilterComposer,
      $$ProfileDevicesTableOrderingComposer,
      $$ProfileDevicesTableAnnotationComposer,
      $$ProfileDevicesTableCreateCompanionBuilder,
      $$ProfileDevicesTableUpdateCompanionBuilder,
      (ProfileDeviceRow, $$ProfileDevicesTableReferences),
      ProfileDeviceRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ProfileLocalSettingsTableCreateCompanionBuilder =
    ProfileLocalSettingsCompanion Function({
      required String profileId,
      Value<String?> localName,
      Value<String?> localNote,
      Value<bool> pinned,
      Value<bool> hidden,
      Value<int?> displayColor,
      Value<bool> showOnHome,
      Value<bool> trusted,
      Value<bool> notifyUpdates,
      Value<DateTime?> lastViewedAt,
      Value<String> transferMode,
      Value<int> rowid,
    });
typedef $$ProfileLocalSettingsTableUpdateCompanionBuilder =
    ProfileLocalSettingsCompanion Function({
      Value<String> profileId,
      Value<String?> localName,
      Value<String?> localNote,
      Value<bool> pinned,
      Value<bool> hidden,
      Value<int?> displayColor,
      Value<bool> showOnHome,
      Value<bool> trusted,
      Value<bool> notifyUpdates,
      Value<DateTime?> lastViewedAt,
      Value<String> transferMode,
      Value<int> rowid,
    });

final class $$ProfileLocalSettingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProfileLocalSettingsTable,
          ProfileLocalSettingRow
        > {
  $$ProfileLocalSettingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) => db.profiles
      .createAlias('profile_local_settings__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileLocalSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileLocalSettingsTable> {
  $$ProfileLocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localName => $composableBuilder(
    column: $table.localName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localNote => $composableBuilder(
    column: $table.localNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayColor => $composableBuilder(
    column: $table.displayColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trusted => $composableBuilder(
    column: $table.trusted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyUpdates => $composableBuilder(
    column: $table.notifyUpdates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferMode => $composableBuilder(
    column: $table.transferMode,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileLocalSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileLocalSettingsTable> {
  $$ProfileLocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localName => $composableBuilder(
    column: $table.localName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localNote => $composableBuilder(
    column: $table.localNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayColor => $composableBuilder(
    column: $table.displayColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trusted => $composableBuilder(
    column: $table.trusted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyUpdates => $composableBuilder(
    column: $table.notifyUpdates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferMode => $composableBuilder(
    column: $table.transferMode,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileLocalSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileLocalSettingsTable> {
  $$ProfileLocalSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localName =>
      $composableBuilder(column: $table.localName, builder: (column) => column);

  GeneratedColumn<String> get localNote =>
      $composableBuilder(column: $table.localNote, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<int> get displayColor => $composableBuilder(
    column: $table.displayColor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showOnHome => $composableBuilder(
    column: $table.showOnHome,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trusted =>
      $composableBuilder(column: $table.trusted, builder: (column) => column);

  GeneratedColumn<bool> get notifyUpdates => $composableBuilder(
    column: $table.notifyUpdates,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transferMode => $composableBuilder(
    column: $table.transferMode,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileLocalSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileLocalSettingsTable,
          ProfileLocalSettingRow,
          $$ProfileLocalSettingsTableFilterComposer,
          $$ProfileLocalSettingsTableOrderingComposer,
          $$ProfileLocalSettingsTableAnnotationComposer,
          $$ProfileLocalSettingsTableCreateCompanionBuilder,
          $$ProfileLocalSettingsTableUpdateCompanionBuilder,
          (ProfileLocalSettingRow, $$ProfileLocalSettingsTableReferences),
          ProfileLocalSettingRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProfileLocalSettingsTableTableManager(
    _$AppDatabase db,
    $ProfileLocalSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileLocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileLocalSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProfileLocalSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String?> localName = const Value.absent(),
                Value<String?> localNote = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int?> displayColor = const Value.absent(),
                Value<bool> showOnHome = const Value.absent(),
                Value<bool> trusted = const Value.absent(),
                Value<bool> notifyUpdates = const Value.absent(),
                Value<DateTime?> lastViewedAt = const Value.absent(),
                Value<String> transferMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileLocalSettingsCompanion(
                profileId: profileId,
                localName: localName,
                localNote: localNote,
                pinned: pinned,
                hidden: hidden,
                displayColor: displayColor,
                showOnHome: showOnHome,
                trusted: trusted,
                notifyUpdates: notifyUpdates,
                lastViewedAt: lastViewedAt,
                transferMode: transferMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                Value<String?> localName = const Value.absent(),
                Value<String?> localNote = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int?> displayColor = const Value.absent(),
                Value<bool> showOnHome = const Value.absent(),
                Value<bool> trusted = const Value.absent(),
                Value<bool> notifyUpdates = const Value.absent(),
                Value<DateTime?> lastViewedAt = const Value.absent(),
                Value<String> transferMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileLocalSettingsCompanion.insert(
                profileId: profileId,
                localName: localName,
                localNote: localNote,
                pinned: pinned,
                hidden: hidden,
                displayColor: displayColor,
                showOnHome: showOnHome,
                trusted: trusted,
                notifyUpdates: notifyUpdates,
                lastViewedAt: lastViewedAt,
                transferMode: transferMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileLocalSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$ProfileLocalSettingsTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$ProfileLocalSettingsTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileLocalSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileLocalSettingsTable,
      ProfileLocalSettingRow,
      $$ProfileLocalSettingsTableFilterComposer,
      $$ProfileLocalSettingsTableOrderingComposer,
      $$ProfileLocalSettingsTableAnnotationComposer,
      $$ProfileLocalSettingsTableCreateCompanionBuilder,
      $$ProfileLocalSettingsTableUpdateCompanionBuilder,
      (ProfileLocalSettingRow, $$ProfileLocalSettingsTableReferences),
      ProfileLocalSettingRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ProfileKeysTableCreateCompanionBuilder =
    ProfileKeysCompanion Function({
      required String profileId,
      required String publicKey,
      required String fingerprint,
      Value<String?> encryptedPrivateKey,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ProfileKeysTableUpdateCompanionBuilder =
    ProfileKeysCompanion Function({
      Value<String> profileId,
      Value<String> publicKey,
      Value<String> fingerprint,
      Value<String?> encryptedPrivateKey,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ProfileKeysTableReferences
    extends BaseReferences<_$AppDatabase, $ProfileKeysTable, ProfileKeyRow> {
  $$ProfileKeysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('profile_keys__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileKeysTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileKeysTable> {
  $$ProfileKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileKeysTable> {
  $$ProfileKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileKeysTable> {
  $$ProfileKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileKeysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileKeysTable,
          ProfileKeyRow,
          $$ProfileKeysTableFilterComposer,
          $$ProfileKeysTableOrderingComposer,
          $$ProfileKeysTableAnnotationComposer,
          $$ProfileKeysTableCreateCompanionBuilder,
          $$ProfileKeysTableUpdateCompanionBuilder,
          (ProfileKeyRow, $$ProfileKeysTableReferences),
          ProfileKeyRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProfileKeysTableTableManager(_$AppDatabase db, $ProfileKeysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String?> encryptedPrivateKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileKeysCompanion(
                profileId: profileId,
                publicKey: publicKey,
                fingerprint: fingerprint,
                encryptedPrivateKey: encryptedPrivateKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String publicKey,
                required String fingerprint,
                Value<String?> encryptedPrivateKey = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProfileKeysCompanion.insert(
                profileId: profileId,
                publicKey: publicKey,
                fingerprint: fingerprint,
                encryptedPrivateKey: encryptedPrivateKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileKeysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ProfileKeysTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$ProfileKeysTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileKeysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileKeysTable,
      ProfileKeyRow,
      $$ProfileKeysTableFilterComposer,
      $$ProfileKeysTableOrderingComposer,
      $$ProfileKeysTableAnnotationComposer,
      $$ProfileKeysTableCreateCompanionBuilder,
      $$ProfileKeysTableUpdateCompanionBuilder,
      (ProfileKeyRow, $$ProfileKeysTableReferences),
      ProfileKeyRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ObjectTypesTableCreateCompanionBuilder =
    ObjectTypesCompanion Function({
      required String id,
      required String profileId,
      required String name,
      required String normalizedName,
      Value<String?> icon,
      Value<int?> color,
      Value<int> sortOrder,
      Value<bool> builtIn,
      Value<bool> hidden,
      Value<String?> fieldsSchema,
      required DateTime createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$ObjectTypesTableUpdateCompanionBuilder =
    ObjectTypesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> name,
      Value<String> normalizedName,
      Value<String?> icon,
      Value<int?> color,
      Value<int> sortOrder,
      Value<bool> builtIn,
      Value<bool> hidden,
      Value<String?> fieldsSchema,
      Value<DateTime> createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$ObjectTypesTableReferences
    extends BaseReferences<_$AppDatabase, $ObjectTypesTable, ObjectTypeRow> {
  $$ObjectTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('object_types__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ObjectsTable, List<ObjectRow>> _objectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.objects,
    aliasName: 'object_types__id__objects__type_id',
  );

  $$ObjectsTableProcessedTableManager get objectsRefs {
    final manager = $$ObjectsTableTableManager(
      $_db,
      $_db.objects,
    ).filter((f) => f.typeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_objectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObjectTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ObjectTypesTable> {
  $$ObjectTypesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldsSchema => $composableBuilder(
    column: $table.fieldsSchema,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> objectsRefs(
    Expression<bool> Function($$ObjectsTableFilterComposer f) f,
  ) {
    final $$ObjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.objects,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectsTableFilterComposer(
            $db: $db,
            $table: $db.objects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObjectTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ObjectTypesTable> {
  $$ObjectTypesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldsSchema => $composableBuilder(
    column: $table.fieldsSchema,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObjectTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObjectTypesTable> {
  $$ObjectTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<String> get fieldsSchema => $composableBuilder(
    column: $table.fieldsSchema,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> objectsRefs<T extends Object>(
    Expression<T> Function($$ObjectsTableAnnotationComposer a) f,
  ) {
    final $$ObjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.objects,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.objects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObjectTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObjectTypesTable,
          ObjectTypeRow,
          $$ObjectTypesTableFilterComposer,
          $$ObjectTypesTableOrderingComposer,
          $$ObjectTypesTableAnnotationComposer,
          $$ObjectTypesTableCreateCompanionBuilder,
          $$ObjectTypesTableUpdateCompanionBuilder,
          (ObjectTypeRow, $$ObjectTypesTableReferences),
          ObjectTypeRow,
          PrefetchHooks Function({bool profileId, bool objectsRefs})
        > {
  $$ObjectTypesTableTableManager(_$AppDatabase db, $ObjectTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObjectTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObjectTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObjectTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<String?> fieldsSchema = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObjectTypesCompanion(
                id: id,
                profileId: profileId,
                name: name,
                normalizedName: normalizedName,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                builtIn: builtIn,
                hidden: hidden,
                fieldsSchema: fieldsSchema,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                required String normalizedName,
                Value<String?> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<String?> fieldsSchema = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObjectTypesCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                normalizedName: normalizedName,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                builtIn: builtIn,
                hidden: hidden,
                fieldsSchema: fieldsSchema,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ObjectTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, objectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (objectsRefs) db.objects],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$ObjectTypesTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$ObjectTypesTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (objectsRefs)
                    await $_getPrefetchedData<
                      ObjectTypeRow,
                      $ObjectTypesTable,
                      ObjectRow
                    >(
                      currentTable: table,
                      referencedTable: $$ObjectTypesTableReferences
                          ._objectsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ObjectTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).objectsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.typeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ObjectTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObjectTypesTable,
      ObjectTypeRow,
      $$ObjectTypesTableFilterComposer,
      $$ObjectTypesTableOrderingComposer,
      $$ObjectTypesTableAnnotationComposer,
      $$ObjectTypesTableCreateCompanionBuilder,
      $$ObjectTypesTableUpdateCompanionBuilder,
      (ObjectTypeRow, $$ObjectTypesTableReferences),
      ObjectTypeRow,
      PrefetchHooks Function({bool profileId, bool objectsRefs})
    >;
typedef $$ObjectsTableCreateCompanionBuilder =
    ObjectsCompanion Function({
      required String id,
      required String typeId,
      required String title,
      required String normalizedTitle,
      Value<String?> altTitle,
      Value<String?> normalizedAltTitle,
      Value<String?> summary,
      Value<String?> creator,
      Value<int?> year,
      Value<String?> barcode,
      Value<String?> customFields,
      Value<String?> currentRevisionId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ObjectsTableUpdateCompanionBuilder =
    ObjectsCompanion Function({
      Value<String> id,
      Value<String> typeId,
      Value<String> title,
      Value<String> normalizedTitle,
      Value<String?> altTitle,
      Value<String?> normalizedAltTitle,
      Value<String?> summary,
      Value<String?> creator,
      Value<int?> year,
      Value<String?> barcode,
      Value<String?> customFields,
      Value<String?> currentRevisionId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ObjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ObjectsTable, ObjectRow> {
  $$ObjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ObjectTypesTable _typeIdTable(_$AppDatabase db) =>
      db.objectTypes.createAlias('objects__type_id__object_types__id');

  $$ObjectTypesTableProcessedTableManager get typeId {
    final $_column = $_itemColumn<String>('type_id')!;

    final manager = $$ObjectTypesTableTableManager(
      $_db,
      $_db.objectTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ObjectRevisionsTable, List<ObjectRevisionRow>>
  _objectRevisionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.objectRevisions,
    aliasName: 'objects__id__object_revisions__object_id',
  );

  $$ObjectRevisionsTableProcessedTableManager get objectRevisionsRefs {
    final manager = $$ObjectRevisionsTableTableManager(
      $_db,
      $_db.objectRevisions,
    ).filter((f) => f.objectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _objectRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProfileEntriesTable, List<ProfileEntryRow>>
  _profileEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.profileEntries,
    aliasName: 'objects__id__profile_entries__object_id',
  );

  $$ProfileEntriesTableProcessedTableManager get profileEntriesRefs {
    final manager = $$ProfileEntriesTableTableManager(
      $_db,
      $_db.profileEntries,
    ).filter((f) => f.objectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_profileEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ObjectsTable> {
  $$ObjectsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altTitle => $composableBuilder(
    column: $table.altTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedAltTitle => $composableBuilder(
    column: $table.normalizedAltTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creator => $composableBuilder(
    column: $table.creator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customFields => $composableBuilder(
    column: $table.customFields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ObjectTypesTableFilterComposer get typeId {
    final $$ObjectTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.objectTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectTypesTableFilterComposer(
            $db: $db,
            $table: $db.objectTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> objectRevisionsRefs(
    Expression<bool> Function($$ObjectRevisionsTableFilterComposer f) f,
  ) {
    final $$ObjectRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.objectRevisions,
      getReferencedColumn: (t) => t.objectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.objectRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> profileEntriesRefs(
    Expression<bool> Function($$ProfileEntriesTableFilterComposer f) f,
  ) {
    final $$ProfileEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.objectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableFilterComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObjectsTable> {
  $$ObjectsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altTitle => $composableBuilder(
    column: $table.altTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedAltTitle => $composableBuilder(
    column: $table.normalizedAltTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creator => $composableBuilder(
    column: $table.creator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customFields => $composableBuilder(
    column: $table.customFields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObjectTypesTableOrderingComposer get typeId {
    final $$ObjectTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.objectTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectTypesTableOrderingComposer(
            $db: $db,
            $table: $db.objectTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObjectsTable> {
  $$ObjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get altTitle =>
      $composableBuilder(column: $table.altTitle, builder: (column) => column);

  GeneratedColumn<String> get normalizedAltTitle => $composableBuilder(
    column: $table.normalizedAltTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get creator =>
      $composableBuilder(column: $table.creator, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get customFields => $composableBuilder(
    column: $table.customFields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ObjectTypesTableAnnotationComposer get typeId {
    final $$ObjectTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.objectTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.objectTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> objectRevisionsRefs<T extends Object>(
    Expression<T> Function($$ObjectRevisionsTableAnnotationComposer a) f,
  ) {
    final $$ObjectRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.objectRevisions,
      getReferencedColumn: (t) => t.objectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.objectRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> profileEntriesRefs<T extends Object>(
    Expression<T> Function($$ProfileEntriesTableAnnotationComposer a) f,
  ) {
    final $$ProfileEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.objectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObjectsTable,
          ObjectRow,
          $$ObjectsTableFilterComposer,
          $$ObjectsTableOrderingComposer,
          $$ObjectsTableAnnotationComposer,
          $$ObjectsTableCreateCompanionBuilder,
          $$ObjectsTableUpdateCompanionBuilder,
          (ObjectRow, $$ObjectsTableReferences),
          ObjectRow,
          PrefetchHooks Function({
            bool typeId,
            bool objectRevisionsRefs,
            bool profileEntriesRefs,
          })
        > {
  $$ObjectsTableTableManager(_$AppDatabase db, $ObjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> typeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> normalizedTitle = const Value.absent(),
                Value<String?> altTitle = const Value.absent(),
                Value<String?> normalizedAltTitle = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> creator = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> customFields = const Value.absent(),
                Value<String?> currentRevisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObjectsCompanion(
                id: id,
                typeId: typeId,
                title: title,
                normalizedTitle: normalizedTitle,
                altTitle: altTitle,
                normalizedAltTitle: normalizedAltTitle,
                summary: summary,
                creator: creator,
                year: year,
                barcode: barcode,
                customFields: customFields,
                currentRevisionId: currentRevisionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String typeId,
                required String title,
                required String normalizedTitle,
                Value<String?> altTitle = const Value.absent(),
                Value<String?> normalizedAltTitle = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> creator = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> customFields = const Value.absent(),
                Value<String?> currentRevisionId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ObjectsCompanion.insert(
                id: id,
                typeId: typeId,
                title: title,
                normalizedTitle: normalizedTitle,
                altTitle: altTitle,
                normalizedAltTitle: normalizedAltTitle,
                summary: summary,
                creator: creator,
                year: year,
                barcode: barcode,
                customFields: customFields,
                currentRevisionId: currentRevisionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ObjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                typeId = false,
                objectRevisionsRefs = false,
                profileEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (objectRevisionsRefs) db.objectRevisions,
                    if (profileEntriesRefs) db.profileEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (typeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.typeId,
                                    referencedTable: $$ObjectsTableReferences
                                        ._typeIdTable(db),
                                    referencedColumn: $$ObjectsTableReferences
                                        ._typeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (objectRevisionsRefs)
                        await $_getPrefetchedData<
                          ObjectRow,
                          $ObjectsTable,
                          ObjectRevisionRow
                        >(
                          currentTable: table,
                          referencedTable: $$ObjectsTableReferences
                              ._objectRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).objectRevisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.objectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (profileEntriesRefs)
                        await $_getPrefetchedData<
                          ObjectRow,
                          $ObjectsTable,
                          ProfileEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ObjectsTableReferences
                              ._profileEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).profileEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.objectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ObjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObjectsTable,
      ObjectRow,
      $$ObjectsTableFilterComposer,
      $$ObjectsTableOrderingComposer,
      $$ObjectsTableAnnotationComposer,
      $$ObjectsTableCreateCompanionBuilder,
      $$ObjectsTableUpdateCompanionBuilder,
      (ObjectRow, $$ObjectsTableReferences),
      ObjectRow,
      PrefetchHooks Function({
        bool typeId,
        bool objectRevisionsRefs,
        bool profileEntriesRefs,
      })
    >;
typedef $$ObjectRevisionsTableCreateCompanionBuilder =
    ObjectRevisionsCompanion Function({
      required String id,
      required String objectId,
      Value<String?> parentRevisionId,
      Value<String?> authorProfileId,
      Value<String?> deviceId,
      required DateTime createdAt,
      Value<DateTime?> importedAt,
      Value<int> payloadVersion,
      required String payloadJson,
      required String contentHash,
      Value<String?> originPackageId,
      Value<int> rowid,
    });
typedef $$ObjectRevisionsTableUpdateCompanionBuilder =
    ObjectRevisionsCompanion Function({
      Value<String> id,
      Value<String> objectId,
      Value<String?> parentRevisionId,
      Value<String?> authorProfileId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime?> importedAt,
      Value<int> payloadVersion,
      Value<String> payloadJson,
      Value<String> contentHash,
      Value<String?> originPackageId,
      Value<int> rowid,
    });

final class $$ObjectRevisionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ObjectRevisionsTable,
          ObjectRevisionRow
        > {
  $$ObjectRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ObjectsTable _objectIdTable(_$AppDatabase db) =>
      db.objects.createAlias('object_revisions__object_id__objects__id');

  $$ObjectsTableProcessedTableManager get objectId {
    final $_column = $_itemColumn<String>('object_id')!;

    final manager = $$ObjectsTableTableManager(
      $_db,
      $_db.objects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ObjectRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $ObjectRevisionsTable> {
  $$ObjectRevisionsTableFilterComposer({
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

  ColumnFilters<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => ColumnFilters(column),
  );

  $$ObjectsTableFilterComposer get objectId {
    final $$ObjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectId,
      referencedTable: $db.objects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectsTableFilterComposer(
            $db: $db,
            $table: $db.objects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObjectRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObjectRevisionsTable> {
  $$ObjectRevisionsTableOrderingComposer({
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

  ColumnOrderings<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObjectsTableOrderingComposer get objectId {
    final $$ObjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectId,
      referencedTable: $db.objects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectsTableOrderingComposer(
            $db: $db,
            $table: $db.objects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObjectRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObjectRevisionsTable> {
  $$ObjectRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => column,
  );

  $$ObjectsTableAnnotationComposer get objectId {
    final $$ObjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectId,
      referencedTable: $db.objects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.objects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObjectRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObjectRevisionsTable,
          ObjectRevisionRow,
          $$ObjectRevisionsTableFilterComposer,
          $$ObjectRevisionsTableOrderingComposer,
          $$ObjectRevisionsTableAnnotationComposer,
          $$ObjectRevisionsTableCreateCompanionBuilder,
          $$ObjectRevisionsTableUpdateCompanionBuilder,
          (ObjectRevisionRow, $$ObjectRevisionsTableReferences),
          ObjectRevisionRow,
          PrefetchHooks Function({bool objectId})
        > {
  $$ObjectRevisionsTableTableManager(
    _$AppDatabase db,
    $ObjectRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObjectRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObjectRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObjectRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> objectId = const Value.absent(),
                Value<String?> parentRevisionId = const Value.absent(),
                Value<String?> authorProfileId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> importedAt = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String?> originPackageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObjectRevisionsCompanion(
                id: id,
                objectId: objectId,
                parentRevisionId: parentRevisionId,
                authorProfileId: authorProfileId,
                deviceId: deviceId,
                createdAt: createdAt,
                importedAt: importedAt,
                payloadVersion: payloadVersion,
                payloadJson: payloadJson,
                contentHash: contentHash,
                originPackageId: originPackageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String objectId,
                Value<String?> parentRevisionId = const Value.absent(),
                Value<String?> authorProfileId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> importedAt = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                required String payloadJson,
                required String contentHash,
                Value<String?> originPackageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObjectRevisionsCompanion.insert(
                id: id,
                objectId: objectId,
                parentRevisionId: parentRevisionId,
                authorProfileId: authorProfileId,
                deviceId: deviceId,
                createdAt: createdAt,
                importedAt: importedAt,
                payloadVersion: payloadVersion,
                payloadJson: payloadJson,
                contentHash: contentHash,
                originPackageId: originPackageId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ObjectRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({objectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (objectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.objectId,
                                referencedTable:
                                    $$ObjectRevisionsTableReferences
                                        ._objectIdTable(db),
                                referencedColumn:
                                    $$ObjectRevisionsTableReferences
                                        ._objectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ObjectRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObjectRevisionsTable,
      ObjectRevisionRow,
      $$ObjectRevisionsTableFilterComposer,
      $$ObjectRevisionsTableOrderingComposer,
      $$ObjectRevisionsTableAnnotationComposer,
      $$ObjectRevisionsTableCreateCompanionBuilder,
      $$ObjectRevisionsTableUpdateCompanionBuilder,
      (ObjectRevisionRow, $$ObjectRevisionsTableReferences),
      ObjectRevisionRow,
      PrefetchHooks Function({bool objectId})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String profileId,
      Value<String?> parentId,
      required String name,
      required String normalizedName,
      Value<String?> description,
      Value<String?> icon,
      Value<int?> color,
      Value<int> sortOrder,
      Value<int> level,
      required String path,
      Value<String?> currentRevisionId,
      required DateTime createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String?> parentId,
      Value<String> name,
      Value<String> normalizedName,
      Value<String?> description,
      Value<String?> icon,
      Value<int?> color,
      Value<int> sortOrder,
      Value<int> level,
      Value<String> path,
      Value<String?> currentRevisionId,
      Value<DateTime> createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('categories__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CategoryRevisionsTable, List<CategoryRevisionRow>>
  _categoryRevisionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.categoryRevisions,
        aliasName: 'categories__id__category_revisions__category_id',
      );

  $$CategoryRevisionsTableProcessedTableManager get categoryRevisionsRefs {
    final manager = $$CategoryRevisionsTableTableManager(
      $_db,
      $_db.categoryRevisions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _categoryRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntryCategoriesTable, List<EntryCategoryRow>>
  _entryCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryCategories,
    aliasName: 'categories__id__entry_categories__category_id',
  );

  $$EntryCategoriesTableProcessedTableManager get entryCategoriesRefs {
    final manager = $$EntryCategoriesTableTableManager(
      $_db,
      $_db.entryCategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entryCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> categoryRevisionsRefs(
    Expression<bool> Function($$CategoryRevisionsTableFilterComposer f) f,
  ) {
    final $$CategoryRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryRevisions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.categoryRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entryCategoriesRefs(
    Expression<bool> Function($$EntryCategoriesTableFilterComposer f) f,
  ) {
    final $$EntryCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.entryCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> categoryRevisionsRefs<T extends Object>(
    Expression<T> Function($$CategoryRevisionsTableAnnotationComposer a) f,
  ) {
    final $$CategoryRevisionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.categoryRevisions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CategoryRevisionsTableAnnotationComposer(
                $db: $db,
                $table: $db.categoryRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> entryCategoriesRefs<T extends Object>(
    Expression<T> Function($$EntryCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EntryCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entryCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool profileId,
            bool categoryRevisionsRefs,
            bool entryCategoriesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> currentRevisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                profileId: profileId,
                parentId: parentId,
                name: name,
                normalizedName: normalizedName,
                description: description,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                level: level,
                path: path,
                currentRevisionId: currentRevisionId,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                Value<String?> parentId = const Value.absent(),
                required String name,
                required String normalizedName,
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> level = const Value.absent(),
                required String path,
                Value<String?> currentRevisionId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                profileId: profileId,
                parentId: parentId,
                name: name,
                normalizedName: normalizedName,
                description: description,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                level: level,
                path: path,
                currentRevisionId: currentRevisionId,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                categoryRevisionsRefs = false,
                entryCategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (categoryRevisionsRefs) db.categoryRevisions,
                    if (entryCategoriesRefs) db.entryCategories,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable: $$CategoriesTableReferences
                                        ._profileIdTable(db),
                                    referencedColumn:
                                        $$CategoriesTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (categoryRevisionsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          CategoryRevisionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._categoryRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoryRevisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entryCategoriesRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          EntryCategoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._entryCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entryCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool profileId,
        bool categoryRevisionsRefs,
        bool entryCategoriesRefs,
      })
    >;
typedef $$CategoryRevisionsTableCreateCompanionBuilder =
    CategoryRevisionsCompanion Function({
      required String id,
      required String categoryId,
      Value<String?> parentRevisionId,
      Value<String?> authorProfileId,
      Value<String?> deviceId,
      required DateTime createdAt,
      Value<DateTime?> importedAt,
      Value<int> payloadVersion,
      required String payloadJson,
      required String contentHash,
      Value<String?> originPackageId,
      Value<int> rowid,
    });
typedef $$CategoryRevisionsTableUpdateCompanionBuilder =
    CategoryRevisionsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String?> parentRevisionId,
      Value<String?> authorProfileId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime?> importedAt,
      Value<int> payloadVersion,
      Value<String> payloadJson,
      Value<String> contentHash,
      Value<String?> originPackageId,
      Value<int> rowid,
    });

final class $$CategoryRevisionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CategoryRevisionsTable,
          CategoryRevisionRow
        > {
  $$CategoryRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('category_revisions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoryRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRevisionsTable> {
  $$CategoryRevisionsTableFilterComposer({
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

  ColumnFilters<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRevisionsTable> {
  $$CategoryRevisionsTableOrderingComposer({
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

  ColumnOrderings<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRevisionsTable> {
  $$CategoryRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRevisionsTable,
          CategoryRevisionRow,
          $$CategoryRevisionsTableFilterComposer,
          $$CategoryRevisionsTableOrderingComposer,
          $$CategoryRevisionsTableAnnotationComposer,
          $$CategoryRevisionsTableCreateCompanionBuilder,
          $$CategoryRevisionsTableUpdateCompanionBuilder,
          (CategoryRevisionRow, $$CategoryRevisionsTableReferences),
          CategoryRevisionRow,
          PrefetchHooks Function({bool categoryId})
        > {
  $$CategoryRevisionsTableTableManager(
    _$AppDatabase db,
    $CategoryRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRevisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> parentRevisionId = const Value.absent(),
                Value<String?> authorProfileId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> importedAt = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String?> originPackageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRevisionsCompanion(
                id: id,
                categoryId: categoryId,
                parentRevisionId: parentRevisionId,
                authorProfileId: authorProfileId,
                deviceId: deviceId,
                createdAt: createdAt,
                importedAt: importedAt,
                payloadVersion: payloadVersion,
                payloadJson: payloadJson,
                contentHash: contentHash,
                originPackageId: originPackageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                Value<String?> parentRevisionId = const Value.absent(),
                Value<String?> authorProfileId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> importedAt = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                required String payloadJson,
                required String contentHash,
                Value<String?> originPackageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRevisionsCompanion.insert(
                id: id,
                categoryId: categoryId,
                parentRevisionId: parentRevisionId,
                authorProfileId: authorProfileId,
                deviceId: deviceId,
                createdAt: createdAt,
                importedAt: importedAt,
                payloadVersion: payloadVersion,
                payloadJson: payloadJson,
                contentHash: contentHash,
                originPackageId: originPackageId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoryRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$CategoryRevisionsTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$CategoryRevisionsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CategoryRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRevisionsTable,
      CategoryRevisionRow,
      $$CategoryRevisionsTableFilterComposer,
      $$CategoryRevisionsTableOrderingComposer,
      $$CategoryRevisionsTableAnnotationComposer,
      $$CategoryRevisionsTableCreateCompanionBuilder,
      $$CategoryRevisionsTableUpdateCompanionBuilder,
      (CategoryRevisionRow, $$CategoryRevisionsTableReferences),
      CategoryRevisionRow,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String profileId,
      required String name,
      required String normalizedName,
      Value<int?> color,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> name,
      Value<String> normalizedName,
      Value<int?> color,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('tags__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntryTagsTable, List<EntryTagRow>>
  _entryTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryTags,
    aliasName: 'tags__id__entry_tags__tag_id',
  );

  $$EntryTagsTableProcessedTableManager get entryTagsRefs {
    final manager = $$EntryTagsTableTableManager(
      $_db,
      $_db.entryTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entryTagsRefs(
    Expression<bool> Function($$EntryTagsTableFilterComposer f) f,
  ) {
    final $$EntryTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryTagsTableFilterComposer(
            $db: $db,
            $table: $db.entryTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entryTagsRefs<T extends Object>(
    Expression<T> Function($$EntryTagsTableAnnotationComposer a) f,
  ) {
    final $$EntryTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool profileId, bool entryTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                normalizedName: normalizedName,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                required String normalizedName,
                Value<int?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                normalizedName: normalizedName,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, entryTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entryTagsRefs) db.entryTags],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$TagsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$TagsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entryTagsRefs)
                    await $_getPrefetchedData<TagRow, $TagsTable, EntryTagRow>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._entryTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).entryTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool profileId, bool entryTagsRefs})
    >;
typedef $$ProfileEntriesTableCreateCompanionBuilder =
    ProfileEntriesCompanion Function({
      required String id,
      required String profileId,
      required String objectId,
      Value<String?> relation,
      Value<double?> rating,
      Value<String?> status,
      Value<String?> shortNote,
      Value<String?> detailedNote,
      Value<DateTime?> impressionDate,
      Value<String?> recommendedByProfileId,
      Value<String?> recommendationSource,
      Value<String> privacy,
      Value<String?> sourceEntryId,
      Value<bool> followSource,
      Value<String?> createdDeviceId,
      Value<String?> currentRevisionId,
      required DateTime createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$ProfileEntriesTableUpdateCompanionBuilder =
    ProfileEntriesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> objectId,
      Value<String?> relation,
      Value<double?> rating,
      Value<String?> status,
      Value<String?> shortNote,
      Value<String?> detailedNote,
      Value<DateTime?> impressionDate,
      Value<String?> recommendedByProfileId,
      Value<String?> recommendationSource,
      Value<String> privacy,
      Value<String?> sourceEntryId,
      Value<bool> followSource,
      Value<String?> createdDeviceId,
      Value<String?> currentRevisionId,
      Value<DateTime> createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$ProfileEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProfileEntriesTable, ProfileEntryRow> {
  $$ProfileEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('profile_entries__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ObjectsTable _objectIdTable(_$AppDatabase db) =>
      db.objects.createAlias('profile_entries__object_id__objects__id');

  $$ObjectsTableProcessedTableManager get objectId {
    final $_column = $_itemColumn<String>('object_id')!;

    final manager = $$ObjectsTableTableManager(
      $_db,
      $_db.objects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ProfileEntryRevisionsTable,
    List<ProfileEntryRevisionRow>
  >
  _profileEntryRevisionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.profileEntryRevisions,
        aliasName: 'profile_entries__id__profile_entry_revisions__entry_id',
      );

  $$ProfileEntryRevisionsTableProcessedTableManager
  get profileEntryRevisionsRefs {
    final manager = $$ProfileEntryRevisionsTableTableManager(
      $_db,
      $_db.profileEntryRevisions,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileEntryRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntryCategoriesTable, List<EntryCategoryRow>>
  _entryCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryCategories,
    aliasName: 'profile_entries__id__entry_categories__entry_id',
  );

  $$EntryCategoriesTableProcessedTableManager get entryCategoriesRefs {
    final manager = $$EntryCategoriesTableTableManager(
      $_db,
      $_db.entryCategories,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entryCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntryTagsTable, List<EntryTagRow>>
  _entryTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryTags,
    aliasName: 'profile_entries__id__entry_tags__entry_id',
  );

  $$EntryTagsTableProcessedTableManager get entryTagsRefs {
    final manager = $$EntryTagsTableTableManager(
      $_db,
      $_db.entryTags,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CollectionEntriesTable, List<CollectionEntryRow>>
  _collectionEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.collectionEntries,
        aliasName: 'profile_entries__id__collection_entries__entry_id',
      );

  $$CollectionEntriesTableProcessedTableManager get collectionEntriesRefs {
    final manager = $$CollectionEntriesTableTableManager(
      $_db,
      $_db.collectionEntries,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfileEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileEntriesTable> {
  $$ProfileEntriesTableFilterComposer({
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

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortNote => $composableBuilder(
    column: $table.shortNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailedNote => $composableBuilder(
    column: $table.detailedNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get impressionDate => $composableBuilder(
    column: $table.impressionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendedByProfileId => $composableBuilder(
    column: $table.recommendedByProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendationSource => $composableBuilder(
    column: $table.recommendationSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacy => $composableBuilder(
    column: $table.privacy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEntryId => $composableBuilder(
    column: $table.sourceEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get followSource => $composableBuilder(
    column: $table.followSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdDeviceId => $composableBuilder(
    column: $table.createdDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectsTableFilterComposer get objectId {
    final $$ObjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectId,
      referencedTable: $db.objects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectsTableFilterComposer(
            $db: $db,
            $table: $db.objects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> profileEntryRevisionsRefs(
    Expression<bool> Function($$ProfileEntryRevisionsTableFilterComposer f) f,
  ) {
    final $$ProfileEntryRevisionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileEntryRevisions,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileEntryRevisionsTableFilterComposer(
                $db: $db,
                $table: $db.profileEntryRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> entryCategoriesRefs(
    Expression<bool> Function($$EntryCategoriesTableFilterComposer f) f,
  ) {
    final $$EntryCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryCategories,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.entryCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entryTagsRefs(
    Expression<bool> Function($$EntryTagsTableFilterComposer f) f,
  ) {
    final $$EntryTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryTags,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryTagsTableFilterComposer(
            $db: $db,
            $table: $db.entryTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionEntriesRefs(
    Expression<bool> Function($$CollectionEntriesTableFilterComposer f) f,
  ) {
    final $$CollectionEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionEntries,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionEntriesTableFilterComposer(
            $db: $db,
            $table: $db.collectionEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfileEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileEntriesTable> {
  $$ProfileEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortNote => $composableBuilder(
    column: $table.shortNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailedNote => $composableBuilder(
    column: $table.detailedNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get impressionDate => $composableBuilder(
    column: $table.impressionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendedByProfileId => $composableBuilder(
    column: $table.recommendedByProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendationSource => $composableBuilder(
    column: $table.recommendationSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacy => $composableBuilder(
    column: $table.privacy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEntryId => $composableBuilder(
    column: $table.sourceEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get followSource => $composableBuilder(
    column: $table.followSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDeviceId => $composableBuilder(
    column: $table.createdDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectsTableOrderingComposer get objectId {
    final $$ObjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectId,
      referencedTable: $db.objects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectsTableOrderingComposer(
            $db: $db,
            $table: $db.objects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileEntriesTable> {
  $$ProfileEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get shortNote =>
      $composableBuilder(column: $table.shortNote, builder: (column) => column);

  GeneratedColumn<String> get detailedNote => $composableBuilder(
    column: $table.detailedNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get impressionDate => $composableBuilder(
    column: $table.impressionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendedByProfileId => $composableBuilder(
    column: $table.recommendedByProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendationSource => $composableBuilder(
    column: $table.recommendationSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privacy =>
      $composableBuilder(column: $table.privacy, builder: (column) => column);

  GeneratedColumn<String> get sourceEntryId => $composableBuilder(
    column: $table.sourceEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get followSource => $composableBuilder(
    column: $table.followSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdDeviceId => $composableBuilder(
    column: $table.createdDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentRevisionId => $composableBuilder(
    column: $table.currentRevisionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectsTableAnnotationComposer get objectId {
    final $$ObjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectId,
      referencedTable: $db.objects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.objects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> profileEntryRevisionsRefs<T extends Object>(
    Expression<T> Function($$ProfileEntryRevisionsTableAnnotationComposer a) f,
  ) {
    final $$ProfileEntryRevisionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileEntryRevisions,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileEntryRevisionsTableAnnotationComposer(
                $db: $db,
                $table: $db.profileEntryRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> entryCategoriesRefs<T extends Object>(
    Expression<T> Function($$EntryCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EntryCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryCategories,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entryCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entryTagsRefs<T extends Object>(
    Expression<T> Function($$EntryTagsTableAnnotationComposer a) f,
  ) {
    final $$EntryTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryTags,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collectionEntriesRefs<T extends Object>(
    Expression<T> Function($$CollectionEntriesTableAnnotationComposer a) f,
  ) {
    final $$CollectionEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.collectionEntries,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CollectionEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.collectionEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProfileEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileEntriesTable,
          ProfileEntryRow,
          $$ProfileEntriesTableFilterComposer,
          $$ProfileEntriesTableOrderingComposer,
          $$ProfileEntriesTableAnnotationComposer,
          $$ProfileEntriesTableCreateCompanionBuilder,
          $$ProfileEntriesTableUpdateCompanionBuilder,
          (ProfileEntryRow, $$ProfileEntriesTableReferences),
          ProfileEntryRow,
          PrefetchHooks Function({
            bool profileId,
            bool objectId,
            bool profileEntryRevisionsRefs,
            bool entryCategoriesRefs,
            bool entryTagsRefs,
            bool collectionEntriesRefs,
          })
        > {
  $$ProfileEntriesTableTableManager(
    _$AppDatabase db,
    $ProfileEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> objectId = const Value.absent(),
                Value<String?> relation = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> shortNote = const Value.absent(),
                Value<String?> detailedNote = const Value.absent(),
                Value<DateTime?> impressionDate = const Value.absent(),
                Value<String?> recommendedByProfileId = const Value.absent(),
                Value<String?> recommendationSource = const Value.absent(),
                Value<String> privacy = const Value.absent(),
                Value<String?> sourceEntryId = const Value.absent(),
                Value<bool> followSource = const Value.absent(),
                Value<String?> createdDeviceId = const Value.absent(),
                Value<String?> currentRevisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileEntriesCompanion(
                id: id,
                profileId: profileId,
                objectId: objectId,
                relation: relation,
                rating: rating,
                status: status,
                shortNote: shortNote,
                detailedNote: detailedNote,
                impressionDate: impressionDate,
                recommendedByProfileId: recommendedByProfileId,
                recommendationSource: recommendationSource,
                privacy: privacy,
                sourceEntryId: sourceEntryId,
                followSource: followSource,
                createdDeviceId: createdDeviceId,
                currentRevisionId: currentRevisionId,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String objectId,
                Value<String?> relation = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> shortNote = const Value.absent(),
                Value<String?> detailedNote = const Value.absent(),
                Value<DateTime?> impressionDate = const Value.absent(),
                Value<String?> recommendedByProfileId = const Value.absent(),
                Value<String?> recommendationSource = const Value.absent(),
                Value<String> privacy = const Value.absent(),
                Value<String?> sourceEntryId = const Value.absent(),
                Value<bool> followSource = const Value.absent(),
                Value<String?> createdDeviceId = const Value.absent(),
                Value<String?> currentRevisionId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileEntriesCompanion.insert(
                id: id,
                profileId: profileId,
                objectId: objectId,
                relation: relation,
                rating: rating,
                status: status,
                shortNote: shortNote,
                detailedNote: detailedNote,
                impressionDate: impressionDate,
                recommendedByProfileId: recommendedByProfileId,
                recommendationSource: recommendationSource,
                privacy: privacy,
                sourceEntryId: sourceEntryId,
                followSource: followSource,
                createdDeviceId: createdDeviceId,
                currentRevisionId: currentRevisionId,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                objectId = false,
                profileEntryRevisionsRefs = false,
                entryCategoriesRefs = false,
                entryTagsRefs = false,
                collectionEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (profileEntryRevisionsRefs) db.profileEntryRevisions,
                    if (entryCategoriesRefs) db.entryCategories,
                    if (entryTagsRefs) db.entryTags,
                    if (collectionEntriesRefs) db.collectionEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$ProfileEntriesTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$ProfileEntriesTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (objectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.objectId,
                                    referencedTable:
                                        $$ProfileEntriesTableReferences
                                            ._objectIdTable(db),
                                    referencedColumn:
                                        $$ProfileEntriesTableReferences
                                            ._objectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (profileEntryRevisionsRefs)
                        await $_getPrefetchedData<
                          ProfileEntryRow,
                          $ProfileEntriesTable,
                          ProfileEntryRevisionRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfileEntriesTableReferences
                              ._profileEntryRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfileEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileEntryRevisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entryCategoriesRefs)
                        await $_getPrefetchedData<
                          ProfileEntryRow,
                          $ProfileEntriesTable,
                          EntryCategoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfileEntriesTableReferences
                              ._entryCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfileEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entryCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entryTagsRefs)
                        await $_getPrefetchedData<
                          ProfileEntryRow,
                          $ProfileEntriesTable,
                          EntryTagRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfileEntriesTableReferences
                              ._entryTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfileEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entryTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (collectionEntriesRefs)
                        await $_getPrefetchedData<
                          ProfileEntryRow,
                          $ProfileEntriesTable,
                          CollectionEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProfileEntriesTableReferences
                              ._collectionEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfileEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfileEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileEntriesTable,
      ProfileEntryRow,
      $$ProfileEntriesTableFilterComposer,
      $$ProfileEntriesTableOrderingComposer,
      $$ProfileEntriesTableAnnotationComposer,
      $$ProfileEntriesTableCreateCompanionBuilder,
      $$ProfileEntriesTableUpdateCompanionBuilder,
      (ProfileEntryRow, $$ProfileEntriesTableReferences),
      ProfileEntryRow,
      PrefetchHooks Function({
        bool profileId,
        bool objectId,
        bool profileEntryRevisionsRefs,
        bool entryCategoriesRefs,
        bool entryTagsRefs,
        bool collectionEntriesRefs,
      })
    >;
typedef $$ProfileEntryRevisionsTableCreateCompanionBuilder =
    ProfileEntryRevisionsCompanion Function({
      required String id,
      required String entryId,
      Value<String?> parentRevisionId,
      Value<String?> authorProfileId,
      Value<String?> deviceId,
      required DateTime createdAt,
      Value<DateTime?> importedAt,
      Value<int> payloadVersion,
      required String payloadJson,
      required String contentHash,
      Value<String?> originPackageId,
      Value<int> rowid,
    });
typedef $$ProfileEntryRevisionsTableUpdateCompanionBuilder =
    ProfileEntryRevisionsCompanion Function({
      Value<String> id,
      Value<String> entryId,
      Value<String?> parentRevisionId,
      Value<String?> authorProfileId,
      Value<String?> deviceId,
      Value<DateTime> createdAt,
      Value<DateTime?> importedAt,
      Value<int> payloadVersion,
      Value<String> payloadJson,
      Value<String> contentHash,
      Value<String?> originPackageId,
      Value<int> rowid,
    });

final class $$ProfileEntryRevisionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProfileEntryRevisionsTable,
          ProfileEntryRevisionRow
        > {
  $$ProfileEntryRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfileEntriesTable _entryIdTable(_$AppDatabase db) => db
      .profileEntries
      .createAlias('profile_entry_revisions__entry_id__profile_entries__id');

  $$ProfileEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$ProfileEntriesTableTableManager(
      $_db,
      $_db.profileEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileEntryRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileEntryRevisionsTable> {
  $$ProfileEntryRevisionsTableFilterComposer({
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

  ColumnFilters<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfileEntriesTableFilterComposer get entryId {
    final $$ProfileEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableFilterComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileEntryRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileEntryRevisionsTable> {
  $$ProfileEntryRevisionsTableOrderingComposer({
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

  ColumnOrderings<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfileEntriesTableOrderingComposer get entryId {
    final $$ProfileEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileEntryRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileEntryRevisionsTable> {
  $$ProfileEntryRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentRevisionId => $composableBuilder(
    column: $table.parentRevisionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorProfileId => $composableBuilder(
    column: $table.authorProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originPackageId => $composableBuilder(
    column: $table.originPackageId,
    builder: (column) => column,
  );

  $$ProfileEntriesTableAnnotationComposer get entryId {
    final $$ProfileEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileEntryRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileEntryRevisionsTable,
          ProfileEntryRevisionRow,
          $$ProfileEntryRevisionsTableFilterComposer,
          $$ProfileEntryRevisionsTableOrderingComposer,
          $$ProfileEntryRevisionsTableAnnotationComposer,
          $$ProfileEntryRevisionsTableCreateCompanionBuilder,
          $$ProfileEntryRevisionsTableUpdateCompanionBuilder,
          (ProfileEntryRevisionRow, $$ProfileEntryRevisionsTableReferences),
          ProfileEntryRevisionRow,
          PrefetchHooks Function({bool entryId})
        > {
  $$ProfileEntryRevisionsTableTableManager(
    _$AppDatabase db,
    $ProfileEntryRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileEntryRevisionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProfileEntryRevisionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProfileEntryRevisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String?> parentRevisionId = const Value.absent(),
                Value<String?> authorProfileId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> importedAt = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String?> originPackageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileEntryRevisionsCompanion(
                id: id,
                entryId: entryId,
                parentRevisionId: parentRevisionId,
                authorProfileId: authorProfileId,
                deviceId: deviceId,
                createdAt: createdAt,
                importedAt: importedAt,
                payloadVersion: payloadVersion,
                payloadJson: payloadJson,
                contentHash: contentHash,
                originPackageId: originPackageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entryId,
                Value<String?> parentRevisionId = const Value.absent(),
                Value<String?> authorProfileId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> importedAt = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                required String payloadJson,
                required String contentHash,
                Value<String?> originPackageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileEntryRevisionsCompanion.insert(
                id: id,
                entryId: entryId,
                parentRevisionId: parentRevisionId,
                authorProfileId: authorProfileId,
                deviceId: deviceId,
                createdAt: createdAt,
                importedAt: importedAt,
                payloadVersion: payloadVersion,
                payloadJson: payloadJson,
                contentHash: contentHash,
                originPackageId: originPackageId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileEntryRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable:
                                    $$ProfileEntryRevisionsTableReferences
                                        ._entryIdTable(db),
                                referencedColumn:
                                    $$ProfileEntryRevisionsTableReferences
                                        ._entryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileEntryRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileEntryRevisionsTable,
      ProfileEntryRevisionRow,
      $$ProfileEntryRevisionsTableFilterComposer,
      $$ProfileEntryRevisionsTableOrderingComposer,
      $$ProfileEntryRevisionsTableAnnotationComposer,
      $$ProfileEntryRevisionsTableCreateCompanionBuilder,
      $$ProfileEntryRevisionsTableUpdateCompanionBuilder,
      (ProfileEntryRevisionRow, $$ProfileEntryRevisionsTableReferences),
      ProfileEntryRevisionRow,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$EntryCategoriesTableCreateCompanionBuilder =
    EntryCategoriesCompanion Function({
      required String entryId,
      required String categoryId,
      Value<bool> isPrimary,
      Value<int> rowid,
    });
typedef $$EntryCategoriesTableUpdateCompanionBuilder =
    EntryCategoriesCompanion Function({
      Value<String> entryId,
      Value<String> categoryId,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

final class $$EntryCategoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $EntryCategoriesTable, EntryCategoryRow> {
  $$EntryCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfileEntriesTable _entryIdTable(_$AppDatabase db) => db
      .profileEntries
      .createAlias('entry_categories__entry_id__profile_entries__id');

  $$ProfileEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$ProfileEntriesTableTableManager(
      $_db,
      $_db.profileEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('entry_categories__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntryCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntryCategoriesTable> {
  $$EntryCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfileEntriesTableFilterComposer get entryId {
    final $$ProfileEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableFilterComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryCategoriesTable> {
  $$EntryCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfileEntriesTableOrderingComposer get entryId {
    final $$ProfileEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryCategoriesTable> {
  $$EntryCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  $$ProfileEntriesTableAnnotationComposer get entryId {
    final $$ProfileEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryCategoriesTable,
          EntryCategoryRow,
          $$EntryCategoriesTableFilterComposer,
          $$EntryCategoriesTableOrderingComposer,
          $$EntryCategoriesTableAnnotationComposer,
          $$EntryCategoriesTableCreateCompanionBuilder,
          $$EntryCategoriesTableUpdateCompanionBuilder,
          (EntryCategoryRow, $$EntryCategoriesTableReferences),
          EntryCategoryRow,
          PrefetchHooks Function({bool entryId, bool categoryId})
        > {
  $$EntryCategoriesTableTableManager(
    _$AppDatabase db,
    $EntryCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryCategoriesCompanion(
                entryId: entryId,
                categoryId: categoryId,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String categoryId,
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryCategoriesCompanion.insert(
                entryId: entryId,
                categoryId: categoryId,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntryCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable:
                                    $$EntryCategoriesTableReferences
                                        ._entryIdTable(db),
                                referencedColumn:
                                    $$EntryCategoriesTableReferences
                                        ._entryIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$EntryCategoriesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$EntryCategoriesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntryCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryCategoriesTable,
      EntryCategoryRow,
      $$EntryCategoriesTableFilterComposer,
      $$EntryCategoriesTableOrderingComposer,
      $$EntryCategoriesTableAnnotationComposer,
      $$EntryCategoriesTableCreateCompanionBuilder,
      $$EntryCategoriesTableUpdateCompanionBuilder,
      (EntryCategoryRow, $$EntryCategoriesTableReferences),
      EntryCategoryRow,
      PrefetchHooks Function({bool entryId, bool categoryId})
    >;
typedef $$EntryTagsTableCreateCompanionBuilder =
    EntryTagsCompanion Function({
      required String entryId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$EntryTagsTableUpdateCompanionBuilder =
    EntryTagsCompanion Function({
      Value<String> entryId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$EntryTagsTableReferences
    extends BaseReferences<_$AppDatabase, $EntryTagsTable, EntryTagRow> {
  $$EntryTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfileEntriesTable _entryIdTable(_$AppDatabase db) => db
      .profileEntries
      .createAlias('entry_tags__entry_id__profile_entries__id');

  $$ProfileEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$ProfileEntriesTableTableManager(
      $_db,
      $_db.profileEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('entry_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntryTagsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProfileEntriesTableFilterComposer get entryId {
    final $$ProfileEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableFilterComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProfileEntriesTableOrderingComposer get entryId {
    final $$ProfileEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ProfileEntriesTableAnnotationComposer get entryId {
    final $$ProfileEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryTagsTable,
          EntryTagRow,
          $$EntryTagsTableFilterComposer,
          $$EntryTagsTableOrderingComposer,
          $$EntryTagsTableAnnotationComposer,
          $$EntryTagsTableCreateCompanionBuilder,
          $$EntryTagsTableUpdateCompanionBuilder,
          (EntryTagRow, $$EntryTagsTableReferences),
          EntryTagRow,
          PrefetchHooks Function({bool entryId, bool tagId})
        > {
  $$EntryTagsTableTableManager(_$AppDatabase db, $EntryTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryTagsCompanion(
                entryId: entryId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => EntryTagsCompanion.insert(
                entryId: entryId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntryTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$EntryTagsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$EntryTagsTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$EntryTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$EntryTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntryTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryTagsTable,
      EntryTagRow,
      $$EntryTagsTableFilterComposer,
      $$EntryTagsTableOrderingComposer,
      $$EntryTagsTableAnnotationComposer,
      $$EntryTagsTableCreateCompanionBuilder,
      $$EntryTagsTableUpdateCompanionBuilder,
      (EntryTagRow, $$EntryTagsTableReferences),
      EntryTagRow,
      PrefetchHooks Function({bool entryId, bool tagId})
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String profileId,
      required String name,
      Value<String?> description,
      Value<String?> coverAttachmentId,
      Value<int?> color,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> name,
      Value<String?> description,
      Value<String?> coverAttachmentId,
      Value<int?> color,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('collections__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CollectionEntriesTable, List<CollectionEntryRow>>
  _collectionEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.collectionEntries,
        aliasName: 'collections__id__collection_entries__collection_id',
      );

  $$CollectionEntriesTableProcessedTableManager get collectionEntriesRefs {
    final manager = $$CollectionEntriesTableTableManager(
      $_db,
      $_db.collectionEntries,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverAttachmentId => $composableBuilder(
    column: $table.coverAttachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> collectionEntriesRefs(
    Expression<bool> Function($$CollectionEntriesTableFilterComposer f) f,
  ) {
    final $$CollectionEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionEntries,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionEntriesTableFilterComposer(
            $db: $db,
            $table: $db.collectionEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverAttachmentId => $composableBuilder(
    column: $table.coverAttachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverAttachmentId => $composableBuilder(
    column: $table.coverAttachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> collectionEntriesRefs<T extends Object>(
    Expression<T> Function($$CollectionEntriesTableAnnotationComposer a) f,
  ) {
    final $$CollectionEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.collectionEntries,
          getReferencedColumn: (t) => t.collectionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CollectionEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.collectionEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (CollectionRow, $$CollectionsTableReferences),
          CollectionRow,
          PrefetchHooks Function({bool profileId, bool collectionEntriesRefs})
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverAttachmentId = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                profileId: profileId,
                name: name,
                description: description,
                coverAttachmentId: coverAttachmentId,
                color: color,
                sortOrder: sortOrder,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> coverAttachmentId = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                description: description,
                coverAttachmentId: coverAttachmentId,
                color: color,
                sortOrder: sortOrder,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, collectionEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (collectionEntriesRefs) db.collectionEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$CollectionsTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$CollectionsTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (collectionEntriesRefs)
                        await $_getPrefetchedData<
                          CollectionRow,
                          $CollectionsTable,
                          CollectionEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._collectionEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (CollectionRow, $$CollectionsTableReferences),
      CollectionRow,
      PrefetchHooks Function({bool profileId, bool collectionEntriesRefs})
    >;
typedef $$CollectionEntriesTableCreateCompanionBuilder =
    CollectionEntriesCompanion Function({
      required String collectionId,
      required String entryId,
      Value<int> sortOrder,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$CollectionEntriesTableUpdateCompanionBuilder =
    CollectionEntriesCompanion Function({
      Value<String> collectionId,
      Value<String> entryId,
      Value<int> sortOrder,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$CollectionEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CollectionEntriesTable,
          CollectionEntryRow
        > {
  $$CollectionEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) => db
      .collections
      .createAlias('collection_entries__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<String>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProfileEntriesTable _entryIdTable(_$AppDatabase db) => db
      .profileEntries
      .createAlias('collection_entries__entry_id__profile_entries__id');

  $$ProfileEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$ProfileEntriesTableTableManager(
      $_db,
      $_db.profileEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionEntriesTable> {
  $$CollectionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfileEntriesTableFilterComposer get entryId {
    final $$ProfileEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableFilterComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionEntriesTable> {
  $$CollectionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfileEntriesTableOrderingComposer get entryId {
    final $$ProfileEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionEntriesTable> {
  $$CollectionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfileEntriesTableAnnotationComposer get entryId {
    final $$ProfileEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.profileEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.profileEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionEntriesTable,
          CollectionEntryRow,
          $$CollectionEntriesTableFilterComposer,
          $$CollectionEntriesTableOrderingComposer,
          $$CollectionEntriesTableAnnotationComposer,
          $$CollectionEntriesTableCreateCompanionBuilder,
          $$CollectionEntriesTableUpdateCompanionBuilder,
          (CollectionEntryRow, $$CollectionEntriesTableReferences),
          CollectionEntryRow,
          PrefetchHooks Function({bool collectionId, bool entryId})
        > {
  $$CollectionEntriesTableTableManager(
    _$AppDatabase db,
    $CollectionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> collectionId = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionEntriesCompanion(
                collectionId: collectionId,
                entryId: entryId,
                sortOrder: sortOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collectionId,
                required String entryId,
                Value<int> sortOrder = const Value.absent(),
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectionEntriesCompanion.insert(
                collectionId: collectionId,
                entryId: entryId,
                sortOrder: sortOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false, entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collectionId,
                                referencedTable:
                                    $$CollectionEntriesTableReferences
                                        ._collectionIdTable(db),
                                referencedColumn:
                                    $$CollectionEntriesTableReferences
                                        ._collectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable:
                                    $$CollectionEntriesTableReferences
                                        ._entryIdTable(db),
                                referencedColumn:
                                    $$CollectionEntriesTableReferences
                                        ._entryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CollectionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionEntriesTable,
      CollectionEntryRow,
      $$CollectionEntriesTableFilterComposer,
      $$CollectionEntriesTableOrderingComposer,
      $$CollectionEntriesTableAnnotationComposer,
      $$CollectionEntriesTableCreateCompanionBuilder,
      $$CollectionEntriesTableUpdateCompanionBuilder,
      (CollectionEntryRow, $$CollectionEntriesTableReferences),
      CollectionEntryRow,
      PrefetchHooks Function({bool collectionId, bool entryId})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String sha256,
      required String storagePath,
      Value<String?> thumbPath,
      required String mimeType,
      Value<int?> width,
      Value<int?> height,
      required int byteSize,
      Value<String?> caption,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> sha256,
      Value<String> storagePath,
      Value<String?> thumbPath,
      Value<String> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<int> byteSize,
      Value<String?> caption,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RevisionAttachmentsTable,
    List<RevisionAttachmentRow>
  >
  _revisionAttachmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.revisionAttachments,
        aliasName: 'attachments__id__revision_attachments__attachment_id',
      );

  $$RevisionAttachmentsTableProcessedTableManager get revisionAttachmentsRefs {
    final manager = $$RevisionAttachmentsTableTableManager(
      $_db,
      $_db.revisionAttachments,
    ).filter((f) => f.attachmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _revisionAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
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

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> revisionAttachmentsRefs(
    Expression<bool> Function($$RevisionAttachmentsTableFilterComposer f) f,
  ) {
    final $$RevisionAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisionAttachments,
      getReferencedColumn: (t) => t.attachmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisionAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.revisionAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> revisionAttachmentsRefs<T extends Object>(
    Expression<T> Function($$RevisionAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$RevisionAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.revisionAttachments,
          getReferencedColumn: (t) => t.attachmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RevisionAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.revisionAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (AttachmentRow, $$AttachmentsTableReferences),
          AttachmentRow,
          PrefetchHooks Function({bool revisionAttachmentsRefs})
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> storagePath = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                sha256: sha256,
                storagePath: storagePath,
                thumbPath: thumbPath,
                mimeType: mimeType,
                width: width,
                height: height,
                byteSize: byteSize,
                caption: caption,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sha256,
                required String storagePath,
                Value<String?> thumbPath = const Value.absent(),
                required String mimeType,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required int byteSize,
                Value<String?> caption = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                sha256: sha256,
                storagePath: storagePath,
                thumbPath: thumbPath,
                mimeType: mimeType,
                width: width,
                height: height,
                byteSize: byteSize,
                caption: caption,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({revisionAttachmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (revisionAttachmentsRefs) db.revisionAttachments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (revisionAttachmentsRefs)
                    await $_getPrefetchedData<
                      AttachmentRow,
                      $AttachmentsTable,
                      RevisionAttachmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$AttachmentsTableReferences
                          ._revisionAttachmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AttachmentsTableReferences(
                            db,
                            table,
                            p0,
                          ).revisionAttachmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.attachmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (AttachmentRow, $$AttachmentsTableReferences),
      AttachmentRow,
      PrefetchHooks Function({bool revisionAttachmentsRefs})
    >;
typedef $$RevisionAttachmentsTableCreateCompanionBuilder =
    RevisionAttachmentsCompanion Function({
      required String id,
      required String entityKind,
      required String revisionId,
      required String attachmentId,
      Value<int> sortOrder,
      Value<bool> isPrimary,
      Value<int> rowid,
    });
typedef $$RevisionAttachmentsTableUpdateCompanionBuilder =
    RevisionAttachmentsCompanion Function({
      Value<String> id,
      Value<String> entityKind,
      Value<String> revisionId,
      Value<String> attachmentId,
      Value<int> sortOrder,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

final class $$RevisionAttachmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RevisionAttachmentsTable,
          RevisionAttachmentRow
        > {
  $$RevisionAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttachmentsTable _attachmentIdTable(_$AppDatabase db) => db
      .attachments
      .createAlias('revision_attachments__attachment_id__attachments__id');

  $$AttachmentsTableProcessedTableManager get attachmentId {
    final $_column = $_itemColumn<String>('attachment_id')!;

    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attachmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RevisionAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $RevisionAttachmentsTable> {
  $$RevisionAttachmentsTableFilterComposer({
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

  ColumnFilters<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revisionId => $composableBuilder(
    column: $table.revisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  $$AttachmentsTableFilterComposer get attachmentId {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $RevisionAttachmentsTable> {
  $$RevisionAttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revisionId => $composableBuilder(
    column: $table.revisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttachmentsTableOrderingComposer get attachmentId {
    final $$AttachmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableOrderingComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevisionAttachmentsTable> {
  $$RevisionAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revisionId => $composableBuilder(
    column: $table.revisionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  $$AttachmentsTableAnnotationComposer get attachmentId {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RevisionAttachmentsTable,
          RevisionAttachmentRow,
          $$RevisionAttachmentsTableFilterComposer,
          $$RevisionAttachmentsTableOrderingComposer,
          $$RevisionAttachmentsTableAnnotationComposer,
          $$RevisionAttachmentsTableCreateCompanionBuilder,
          $$RevisionAttachmentsTableUpdateCompanionBuilder,
          (RevisionAttachmentRow, $$RevisionAttachmentsTableReferences),
          RevisionAttachmentRow,
          PrefetchHooks Function({bool attachmentId})
        > {
  $$RevisionAttachmentsTableTableManager(
    _$AppDatabase db,
    $RevisionAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevisionAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevisionAttachmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RevisionAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityKind = const Value.absent(),
                Value<String> revisionId = const Value.absent(),
                Value<String> attachmentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RevisionAttachmentsCompanion(
                id: id,
                entityKind: entityKind,
                revisionId: revisionId,
                attachmentId: attachmentId,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityKind,
                required String revisionId,
                required String attachmentId,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RevisionAttachmentsCompanion.insert(
                id: id,
                entityKind: entityKind,
                revisionId: revisionId,
                attachmentId: attachmentId,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RevisionAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attachmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (attachmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attachmentId,
                                referencedTable:
                                    $$RevisionAttachmentsTableReferences
                                        ._attachmentIdTable(db),
                                referencedColumn:
                                    $$RevisionAttachmentsTableReferences
                                        ._attachmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RevisionAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RevisionAttachmentsTable,
      RevisionAttachmentRow,
      $$RevisionAttachmentsTableFilterComposer,
      $$RevisionAttachmentsTableOrderingComposer,
      $$RevisionAttachmentsTableAnnotationComposer,
      $$RevisionAttachmentsTableCreateCompanionBuilder,
      $$RevisionAttachmentsTableUpdateCompanionBuilder,
      (RevisionAttachmentRow, $$RevisionAttachmentsTableReferences),
      RevisionAttachmentRow,
      PrefetchHooks Function({bool attachmentId})
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      required String id,
      required String packageId,
      required String packageHash,
      Value<String?> profileId,
      Value<String?> deviceId,
      required DateTime importedAt,
      Value<String?> summaryJson,
      Value<int> rowid,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<String> id,
      Value<String> packageId,
      Value<String> packageHash,
      Value<String?> profileId,
      Value<String?> deviceId,
      Value<DateTime> importedAt,
      Value<String?> summaryJson,
      Value<int> rowid,
    });

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
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

  ColumnFilters<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageHash => $composableBuilder(
    column: $table.packageHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
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

  ColumnOrderings<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageHash => $composableBuilder(
    column: $table.packageHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<String> get packageHash => $composableBuilder(
    column: $table.packageHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportBatchesTable,
          ImportBatchRow,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (
            ImportBatchRow,
            BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatchRow>,
          ),
          ImportBatchRow,
          PrefetchHooks Function()
        > {
  $$ImportBatchesTableTableManager(_$AppDatabase db, $ImportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> packageId = const Value.absent(),
                Value<String> packageHash = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String?> summaryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                packageId: packageId,
                packageHash: packageHash,
                profileId: profileId,
                deviceId: deviceId,
                importedAt: importedAt,
                summaryJson: summaryJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String packageId,
                required String packageHash,
                Value<String?> profileId = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required DateTime importedAt,
                Value<String?> summaryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                packageId: packageId,
                packageHash: packageHash,
                profileId: profileId,
                deviceId: deviceId,
                importedAt: importedAt,
                summaryJson: summaryJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportBatchesTable,
      ImportBatchRow,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (
        ImportBatchRow,
        BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatchRow>,
      ),
      ImportBatchRow,
      PrefetchHooks Function()
    >;
typedef $$ExportBatchesTableCreateCompanionBuilder =
    ExportBatchesCompanion Function({
      required String id,
      required String packageId,
      required String profileId,
      required String mode,
      required DateTime exportedAt,
      Value<String?> summaryJson,
      Value<int> rowid,
    });
typedef $$ExportBatchesTableUpdateCompanionBuilder =
    ExportBatchesCompanion Function({
      Value<String> id,
      Value<String> packageId,
      Value<String> profileId,
      Value<String> mode,
      Value<DateTime> exportedAt,
      Value<String?> summaryJson,
      Value<int> rowid,
    });

class $$ExportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ExportBatchesTable> {
  $$ExportBatchesTableFilterComposer({
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

  ColumnFilters<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportBatchesTable> {
  $$ExportBatchesTableOrderingComposer({
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

  ColumnOrderings<String> get packageId => $composableBuilder(
    column: $table.packageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportBatchesTable> {
  $$ExportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageId =>
      $composableBuilder(column: $table.packageId, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryJson => $composableBuilder(
    column: $table.summaryJson,
    builder: (column) => column,
  );
}

class $$ExportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportBatchesTable,
          ExportBatchRow,
          $$ExportBatchesTableFilterComposer,
          $$ExportBatchesTableOrderingComposer,
          $$ExportBatchesTableAnnotationComposer,
          $$ExportBatchesTableCreateCompanionBuilder,
          $$ExportBatchesTableUpdateCompanionBuilder,
          (
            ExportBatchRow,
            BaseReferences<_$AppDatabase, $ExportBatchesTable, ExportBatchRow>,
          ),
          ExportBatchRow,
          PrefetchHooks Function()
        > {
  $$ExportBatchesTableTableManager(_$AppDatabase db, $ExportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> packageId = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<DateTime> exportedAt = const Value.absent(),
                Value<String?> summaryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportBatchesCompanion(
                id: id,
                packageId: packageId,
                profileId: profileId,
                mode: mode,
                exportedAt: exportedAt,
                summaryJson: summaryJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String packageId,
                required String profileId,
                required String mode,
                required DateTime exportedAt,
                Value<String?> summaryJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportBatchesCompanion.insert(
                id: id,
                packageId: packageId,
                profileId: profileId,
                mode: mode,
                exportedAt: exportedAt,
                summaryJson: summaryJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportBatchesTable,
      ExportBatchRow,
      $$ExportBatchesTableFilterComposer,
      $$ExportBatchesTableOrderingComposer,
      $$ExportBatchesTableAnnotationComposer,
      $$ExportBatchesTableCreateCompanionBuilder,
      $$ExportBatchesTableUpdateCompanionBuilder,
      (
        ExportBatchRow,
        BaseReferences<_$AppDatabase, $ExportBatchesTable, ExportBatchRow>,
      ),
      ExportBatchRow,
      PrefetchHooks Function()
    >;
typedef $$IncomingChangesTableCreateCompanionBuilder =
    IncomingChangesCompanion Function({
      required String id,
      required String profileId,
      required String entityKind,
      required String entityId,
      required String revisionId,
      Value<String?> sourcePackageId,
      required DateTime receivedAt,
      Value<bool> seen,
      Value<int> rowid,
    });
typedef $$IncomingChangesTableUpdateCompanionBuilder =
    IncomingChangesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> entityKind,
      Value<String> entityId,
      Value<String> revisionId,
      Value<String?> sourcePackageId,
      Value<DateTime> receivedAt,
      Value<bool> seen,
      Value<int> rowid,
    });

class $$IncomingChangesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomingChangesTable> {
  $$IncomingChangesTableFilterComposer({
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

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revisionId => $composableBuilder(
    column: $table.revisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePackageId => $composableBuilder(
    column: $table.sourcePackageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IncomingChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomingChangesTable> {
  $$IncomingChangesTableOrderingComposer({
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

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revisionId => $composableBuilder(
    column: $table.revisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePackageId => $composableBuilder(
    column: $table.sourcePackageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomingChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomingChangesTable> {
  $$IncomingChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get entityKind => $composableBuilder(
    column: $table.entityKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get revisionId => $composableBuilder(
    column: $table.revisionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourcePackageId => $composableBuilder(
    column: $table.sourcePackageId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);
}

class $$IncomingChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomingChangesTable,
          IncomingChangeRow,
          $$IncomingChangesTableFilterComposer,
          $$IncomingChangesTableOrderingComposer,
          $$IncomingChangesTableAnnotationComposer,
          $$IncomingChangesTableCreateCompanionBuilder,
          $$IncomingChangesTableUpdateCompanionBuilder,
          (
            IncomingChangeRow,
            BaseReferences<
              _$AppDatabase,
              $IncomingChangesTable,
              IncomingChangeRow
            >,
          ),
          IncomingChangeRow,
          PrefetchHooks Function()
        > {
  $$IncomingChangesTableTableManager(
    _$AppDatabase db,
    $IncomingChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomingChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomingChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomingChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> entityKind = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> revisionId = const Value.absent(),
                Value<String?> sourcePackageId = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomingChangesCompanion(
                id: id,
                profileId: profileId,
                entityKind: entityKind,
                entityId: entityId,
                revisionId: revisionId,
                sourcePackageId: sourcePackageId,
                receivedAt: receivedAt,
                seen: seen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String entityKind,
                required String entityId,
                required String revisionId,
                Value<String?> sourcePackageId = const Value.absent(),
                required DateTime receivedAt,
                Value<bool> seen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomingChangesCompanion.insert(
                id: id,
                profileId: profileId,
                entityKind: entityKind,
                entityId: entityId,
                revisionId: revisionId,
                sourcePackageId: sourcePackageId,
                receivedAt: receivedAt,
                seen: seen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IncomingChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomingChangesTable,
      IncomingChangeRow,
      $$IncomingChangesTableFilterComposer,
      $$IncomingChangesTableOrderingComposer,
      $$IncomingChangesTableAnnotationComposer,
      $$IncomingChangesTableCreateCompanionBuilder,
      $$IncomingChangesTableUpdateCompanionBuilder,
      (
        IncomingChangeRow,
        BaseReferences<_$AppDatabase, $IncomingChangesTable, IncomingChangeRow>,
      ),
      IncomingChangeRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$DraftsTableCreateCompanionBuilder =
    DraftsCompanion Function({
      required String id,
      Value<String?> profileId,
      required String kind,
      required String payloadJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DraftsTableUpdateCompanionBuilder =
    DraftsCompanion Function({
      Value<String> id,
      Value<String?> profileId,
      Value<String> kind,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DraftsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
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

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
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

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftsTable,
          DraftRow,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (DraftRow, BaseReferences<_$AppDatabase, $DraftsTable, DraftRow>),
          DraftRow,
          PrefetchHooks Function()
        > {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion(
                id: id,
                profileId: profileId,
                kind: kind,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> profileId = const Value.absent(),
                required String kind,
                required String payloadJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion.insert(
                id: id,
                profileId: profileId,
                kind: kind,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftsTable,
      DraftRow,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (DraftRow, BaseReferences<_$AppDatabase, $DraftsTable, DraftRow>),
      DraftRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ProfileDevicesTableTableManager get profileDevices =>
      $$ProfileDevicesTableTableManager(_db, _db.profileDevices);
  $$ProfileLocalSettingsTableTableManager get profileLocalSettings =>
      $$ProfileLocalSettingsTableTableManager(_db, _db.profileLocalSettings);
  $$ProfileKeysTableTableManager get profileKeys =>
      $$ProfileKeysTableTableManager(_db, _db.profileKeys);
  $$ObjectTypesTableTableManager get objectTypes =>
      $$ObjectTypesTableTableManager(_db, _db.objectTypes);
  $$ObjectsTableTableManager get objects =>
      $$ObjectsTableTableManager(_db, _db.objects);
  $$ObjectRevisionsTableTableManager get objectRevisions =>
      $$ObjectRevisionsTableTableManager(_db, _db.objectRevisions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CategoryRevisionsTableTableManager get categoryRevisions =>
      $$CategoryRevisionsTableTableManager(_db, _db.categoryRevisions);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ProfileEntriesTableTableManager get profileEntries =>
      $$ProfileEntriesTableTableManager(_db, _db.profileEntries);
  $$ProfileEntryRevisionsTableTableManager get profileEntryRevisions =>
      $$ProfileEntryRevisionsTableTableManager(_db, _db.profileEntryRevisions);
  $$EntryCategoriesTableTableManager get entryCategories =>
      $$EntryCategoriesTableTableManager(_db, _db.entryCategories);
  $$EntryTagsTableTableManager get entryTags =>
      $$EntryTagsTableTableManager(_db, _db.entryTags);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionEntriesTableTableManager get collectionEntries =>
      $$CollectionEntriesTableTableManager(_db, _db.collectionEntries);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$RevisionAttachmentsTableTableManager get revisionAttachments =>
      $$RevisionAttachmentsTableTableManager(_db, _db.revisionAttachments);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
  $$ExportBatchesTableTableManager get exportBatches =>
      $$ExportBatchesTableTableManager(_db, _db.exportBatches);
  $$IncomingChangesTableTableManager get incomingChanges =>
      $$IncomingChangesTableTableManager(_db, _db.incomingChanges);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
}
