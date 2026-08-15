import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:impressions/data/db/database.dart';

/// Создаёт изолированную in-memory базу для тестов.
///
/// В тестах каждая база использует собственный executor, поэтому штатное
/// предупреждение drift о нескольких экземплярах здесь неактуально.
AppDatabase openTestDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Колонки, добавленные каждой версией схемы, — для подделки старой базы.
const _columnsAddedIn = <int, List<String>>{
  7: [
    'categories.default_type_id',
    'categories.cover_attachment_id',
    'object_types.statuses_json',
    'object_types.progress_unit',
    'profile_entries.progress_current',
    'profile_entries.progress_total',
    'collections.filter_json',
  ],
};

/// Приводит только что созданную базу к виду базы указанной версии схемы.
///
/// `onCreate` заводит таблицы по нынешнему описанию — сразу со всеми
/// колонками. Настоящая база пятой версии их не знает, и без этого шага
/// проверка миграции упиралась бы в «такая колонка уже есть» вместо того,
/// чтобы проверять миграцию.
Future<void> pretendSchemaVersion(AppDatabase db, int version) async {
  for (final entry in _columnsAddedIn.entries) {
    if (entry.key <= version) continue;
    for (final column in entry.value) {
      final parts = column.split('.');
      await db.customStatement(
        'ALTER TABLE ${parts.first} DROP COLUMN ${parts.last}',
      );
    }
  }
  await db.customStatement('PRAGMA user_version = $version');
}
