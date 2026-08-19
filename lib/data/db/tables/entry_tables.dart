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

  /// Отношение (§10): love | like | neutral | dislike | avoid.
  ///
  /// `wantToTry` жил здесь до схемы 7 и означал стадию, а не мнение; при
  /// переходе он переехал в [status]. В старых базах он ещё встречается —
  /// разбирает его миграция.
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

/// Отдельный раз, когда впечатление повторили (§10).
///
/// У записи одна оценка и одна дата: сходили в то же кафе второй раз — и
/// первый приходилось затирать. Между тем «понравилось тогда» и «понравилось
/// сейчас» — разные сведения, и вся ценность личного архива как раз в том,
/// чтобы видеть, как мнение менялось.
///
/// Запись при этом продолжает хранить последнее: её `rating` и
/// `impression_date` обновляются вместе с новым посещением. Так каталог,
/// фильтры, статистика, итоги года и обмен файлами продолжают работать без
/// единой правки — считать оценку из посещений на каждый запрос значило бы
/// переписать всю выборку записей ради того же числа.
@DataClassName('EntryVisitRow')
class EntryVisits extends Table {
  TextColumn get id => text()();
  TextColumn get entryId =>
      text().references(ProfileEntries, #id, onDelete: KeyAction.restrict)();

  /// Когда это было. Обязательна: посещение без даты не встроить в историю.
  DateTimeColumn get occurredAt => dateTime()();

  /// Оценка именно этого раза; может отсутствовать.
  RealColumn get rating => real().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

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
