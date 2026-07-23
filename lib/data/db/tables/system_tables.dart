import 'package:drift/drift.dart';

/// Журнал импортов (§20, §21).
@DataClassName('ImportBatchRow')
class ImportBatches extends Table {
  TextColumn get id => text()();
  TextColumn get packageId => text()();
  TextColumn get packageHash => text()();
  TextColumn get profileId => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  TextColumn get summaryJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {packageHash},
  ];
}

/// Журнал экспортов (§19).
@DataClassName('ExportBatchRow')
class ExportBatches extends Table {
  TextColumn get id => text()();
  TextColumn get packageId => text()();
  TextColumn get profileId => text()();
  TextColumn get mode => text()();
  DateTimeColumn get exportedAt => dateTime()();
  TextColumn get summaryJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Входящие изменения внешних профилей (§23).
@DataClassName('IncomingChangeRow')
class IncomingChanges extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get entityKind => text()();
  TextColumn get entityId => text()();
  TextColumn get revisionId => text()();
  TextColumn get sourcePackageId => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get seen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Настройки приложения (ключ-значение).
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Черновики форм (§11).
@DataClassName('DraftRow')
class Drafts extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().nullable()();
  TextColumn get kind => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
