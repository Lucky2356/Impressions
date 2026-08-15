import 'package:drift/drift.dart';

import 'category_tables.dart';
import 'object_tables.dart';
import 'profile_tables.dart';

/// Запись профиля об объекте (§6.2) — мнение конкретного человека.
@DataClassName('ProfileEntryRow')
class ProfileEntries extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get objectId =>
      text().references(Objects, #id, onDelete: KeyAction.restrict)();

  /// Отношение (§10): love | like | neutral | dislike | avoid | wantToTry.
  TextColumn get relation => text().nullable()();

  /// Оценка 0..10 с шагом 0.5 (§10), необязательна.
  RealColumn get rating => real().nullable()();

  /// Статус (§10): ключ из набора, заданного типом объекта.
  TextColumn get status => text().nullable()();

  /// Прогресс: сколько пройдено и сколько всего. Единица — у типа.
  IntColumn get progressCurrent => integer().nullable()();
  IntColumn get progressTotal => integer().nullable()();
  TextColumn get shortNote => text().nullable()();
  TextColumn get detailedNote => text().nullable()();
  DateTimeColumn get impressionDate => dateTime().nullable()();

  /// Кто порекомендовал и источник (§12).
  TextColumn get recommendedByProfileId => text().nullable()();
  TextColumn get recommendationSource => text().nullable()();

  /// Приватность (§25): onlyMe | shareable | shareNoNote | shareNoPhotos |
  /// shareBasic | shareProtected.
  TextColumn get privacy => text().withDefault(const Constant('shareable'))();

  /// Ссылка на исходную запись (при добавлении чужой записи себе — §12).
  TextColumn get sourceEntryId => text().nullable()();
  BoolColumn get followSource => boolean().withDefault(const Constant(false))();
  TextColumn get createdDeviceId => text().nullable()();
  TextColumn get currentRevisionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Неизменяемая версия записи профиля (§18).
@DataClassName('ProfileEntryRevisionRow')
class ProfileEntryRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get entryId =>
      text().references(ProfileEntries, #id, onDelete: KeyAction.restrict)();
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

/// Связь запись↔категория (§7.2): одна основная + дополнительные.
@DataClassName('EntryCategoryRow')
class EntryCategories extends Table {
  TextColumn get entryId =>
      text().references(ProfileEntries, #id, onDelete: KeyAction.restrict)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {entryId, categoryId};
}

/// Связь запись↔тег (§7.2).
@DataClassName('EntryTagRow')
class EntryTags extends Table {
  TextColumn get entryId =>
      text().references(ProfileEntries, #id, onDelete: KeyAction.restrict)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.restrict)();

  @override
  Set<Column> get primaryKey => {entryId, tagId};
}
