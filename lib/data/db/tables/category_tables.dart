import 'package:drift/drift.dart';

import 'profile_tables.dart';

/// Категория (§7, §17). Дерево: adjacency list (`parentId`) + materialized
/// path (`path`) + `level`. Принадлежит профилю.
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get parentId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Уровень вложенности (корень = 0).
  IntColumn get level => integer().withDefault(const Constant(0))();

  /// Материализованный путь из id через «/» (включая собственный id).
  TextColumn get path => text()();
  TextColumn get currentRevisionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Неизменяемая версия категории (§18).
@DataClassName('CategoryRevisionRow')
class CategoryRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get parentRevisionId => text().nullable()();
  TextColumn get authorProfileId => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get importedAt => dateTime().nullable()();
  IntColumn get payloadVersion => integer().withDefault(const Constant(1))();
  TextColumn get payloadJson => text()();
  TextColumn get contentHash => text()();
  TextColumn get originPackageId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Свободные теги (§7.2). Принадлежат профилю.
@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  IntColumn get color => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
