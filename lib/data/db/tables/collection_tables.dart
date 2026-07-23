import 'package:drift/drift.dart';

import 'entry_tables.dart';
import 'profile_tables.dart';

/// Подборки внутри профиля (§27).
@DataClassName('CollectionRow')
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverAttachmentId => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Состав подборки с ручным порядком (§27).
@DataClassName('CollectionEntryRow')
class CollectionEntries extends Table {
  TextColumn get collectionId =>
      text().references(Collections, #id, onDelete: KeyAction.restrict)();
  TextColumn get entryId =>
      text().references(ProfileEntries, #id, onDelete: KeyAction.restrict)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {collectionId, entryId};
}
