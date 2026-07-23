import 'package:drift/drift.dart';

import 'profile_tables.dart';

/// Типы объектов (§8, §9): встроенные и пользовательские. Принадлежат профилю
/// (у каждого профиля свои типы и дерево).
@DataClassName('ObjectTypeRow')
class ObjectTypes extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get builtIn => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();

  /// JSON-схема пользовательских полей типа (§9).
  TextColumn get fieldsSchema => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Общий объект (§6.1): фильм, продукт, место… Отделён от мнения профиля.
@DataClassName('ObjectRow')
class Objects extends Table {
  TextColumn get id => text()();
  TextColumn get typeId =>
      text().references(ObjectTypes, #id, onDelete: KeyAction.restrict)();
  TextColumn get title => text()();
  TextColumn get normalizedTitle => text()();
  TextColumn get altTitle => text().nullable()();
  TextColumn get normalizedAltTitle => text().nullable()();
  TextColumn get summary => text().nullable()();

  /// Бренд/автор/режиссёр/исполнитель.
  TextColumn get creator => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get barcode => text().nullable()();

  /// JSON значений пользовательских полей.
  TextColumn get customFields => text().nullable()();
  TextColumn get currentRevisionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Неизменяемая версия объекта (§18).
@DataClassName('ObjectRevisionRow')
class ObjectRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get objectId =>
      text().references(Objects, #id, onDelete: KeyAction.restrict)();
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
