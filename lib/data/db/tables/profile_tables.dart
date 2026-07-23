import 'package:drift/drift.dart';

/// Профили (§5). Тип профиля: myPrimary | myOtherDevice | external |
/// externalArchived (хранится текстом).
@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().withDefault(const Constant('myPrimary'))();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  TextColumn get nickname => text().nullable()();
  TextColumn get avatarAttachmentId => text().nullable()();
  IntColumn get color => integer().nullable()();
  TextColumn get bio => text().nullable()();
  TextColumn get publicKey => text().nullable()();
  TextColumn get fingerprint => text().nullable()();
  IntColumn get profileVersion => integer().withDefault(const Constant(1))();

  /// Режим повторной передачи: allowed | discouraged | forbidden.
  TextColumn get retransmitMode =>
      text().withDefault(const Constant('allowed'))();
  TextColumn get currentRevisionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Устройства профиля (§5.2).
@DataClassName('ProfileDeviceRow')
class ProfileDevices extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get deviceType => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get os => text().nullable()();
  DateTimeColumn get registeredAt => dateTime()();
  DateTimeColumn get lastExportAt => dateTime().nullable()();
  DateTimeColumn get lastImportAt => dateTime().nullable()();
  BoolColumn get trusted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Локальные настройки о профиле (§5.3). НЕ экспортируются.
@DataClassName('ProfileLocalSettingRow')
class ProfileLocalSettings extends Table {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get localName => text().nullable()();
  TextColumn get localNote => text().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  IntColumn get displayColor => integer().nullable()();
  BoolColumn get showOnHome => boolean().withDefault(const Constant(true))();
  BoolColumn get trusted => boolean().withDefault(const Constant(false))();
  BoolColumn get notifyUpdates => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastViewedAt => dateTime().nullable()();

  /// Режим переноса записей (§7.4): suggestMatch | autoCreate | alwaysAsk |
  /// noCategory.
  TextColumn get transferMode =>
      text().withDefault(const Constant('suggestMatch'))();

  @override
  Set<Column> get primaryKey => {profileId};
}

/// Ключи профиля (§22). Закрытый ключ хранится в защищённой форме и только
/// для собственных профилей.
@DataClassName('ProfileKeyRow')
class ProfileKeys extends Table {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get publicKey => text()();
  TextColumn get fingerprint => text()();

  /// Зашифрованный закрытый ключ (null для внешних профилей).
  TextColumn get encryptedPrivateKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {profileId};
}

/// Локальные связи/псевдонимы между профилями (§5.3).
@DataClassName('ProfileRelationshipRow')
class ProfileRelationships extends Table {
  TextColumn get id => text()();
  @ReferenceName('outgoingRelationships')
  TextColumn get fromProfileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  @ReferenceName('incomingRelationships')
  TextColumn get toProfileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get relation => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
