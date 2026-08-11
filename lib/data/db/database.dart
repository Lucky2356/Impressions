import 'package:drift/drift.dart';

import '../../core/utils/normalize.dart';
import 'connection.dart';
import 'tables/attachment_tables.dart';
import 'tables/category_tables.dart';
import 'tables/collection_tables.dart';
import 'tables/entry_tables.dart';
import 'tables/object_tables.dart';
import 'tables/profile_tables.dart';
import 'tables/system_tables.dart';

part 'database.g.dart';

/// Единая база данных приложения (SQLite через Drift).
///
/// Схема версионируется через [schemaVersion]; индексы, внешние ключи и
/// полнотекстовый поиск создаются в миграции. Физическое удаление не
/// используется как обычная операция — внешние ключи `RESTRICT`, применяется
/// архивирование (§24).
@DriftDatabase(
  tables: [
    Profiles,
    ProfileDevices,
    ProfileLocalSettings,
    ProfileKeys,
    ObjectTypes,
    Objects,
    ObjectRevisions,
    Categories,
    CategoryRevisions,
    Tags,
    ProfileEntries,
    ProfileEntryRevisions,
    EntryCategories,
    EntryTags,
    Collections,
    CollectionEntries,
    Attachments,
    RevisionAttachments,
    ImportBatches,
    ExportBatches,
    IncomingChanges,
    Settings,
    Drafts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Конструктор для тестов (in-memory или произвольное подключение).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      await _createSearch();
    },
    onUpgrade: (m, from, to) async {
      // 2: поиск по тексту заметок. Таблицы объектов не менялись, поэтому
      // достаточно завести недостающие виртуальные таблицы и наполнить их.
      if (from < 2) {
        await _createSearch();
      }
      // 3: «ё» и «е» считаются одной буквой. Триггеры кладут в индекс уже
      // свёрнутый текст, поэтому их надо пересоздать, а индекс — набрать
      // заново. Заодно приводятся нормализованные поля уже заведённых строк:
      // иначе старая «ёлка» перестала бы находиться по новому правилу.
      if (from < 3) {
        await _dropSearchTriggers();
        await _createSearch();
        await _foldYoInNormalizedColumns();
        await _rebuildSearchIndex();
      }
      // 4: убрана таблица profile_relationships. Она была заведена под связи
      // между профилями, за всё время не получила ни одной строки и ни одного
      // обращения в коде — пустая таблица в схеме только сбивает с толку того,
      // кто её читает. Кто кого посоветовал, хранится в самих записях
      // (recommended_by_profile_id).
      if (from < 4) {
        await customStatement('DROP TABLE IF EXISTS profile_relationships');
      }
      // 5: индексы под теги, обложки и подборки (создаются ниже общим
      // списком) и убрана таблица recommendations. Она дублировала то, что
      // записано в самой записи — кто её посоветовал, — и читалась только
      // затем, чтобы удалить: ни один экран её не показывал.
      if (from < 5) {
        await customStatement('DROP TABLE IF EXISTS recommendations');
      }
      await _createIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      // Журнал с упреждающей записью: каждая запись перестаёт быть полной
      // перезаписью журнала и `fsync`, а чтение не ждёт пишущего. Импорт
      // профиля и раскладывание пачки записей упирались именно в это.
      //
      // `synchronous = NORMAL` — обычная пара к WAL: при аварии приложения
      // данные целы, потерять последние транзакции можно только при внезапном
      // отключении питания. Резервные копии к этому готовы и до перехода:
      // перед копированием файла делается `wal_checkpoint(FULL)`, а после
      // восстановления соседние `-wal` и `-shm` удаляются (BackupService).
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
    },
  );

  Future<void> _createIndexes() async {
    const stmts = [
      'CREATE INDEX IF NOT EXISTS idx_categories_profile_parent ON categories (profile_id, parent_id)',
      'CREATE INDEX IF NOT EXISTS idx_categories_profile_path ON categories (profile_id, path)',
      'CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories (parent_id)',
      'CREATE INDEX IF NOT EXISTS idx_entries_profile_object ON profile_entries (profile_id, object_id)',
      'CREATE INDEX IF NOT EXISTS idx_entries_profile ON profile_entries (profile_id)',
      'CREATE INDEX IF NOT EXISTS idx_entry_categories_entry ON entry_categories (entry_id)',
      'CREATE INDEX IF NOT EXISTS idx_entry_categories_category ON entry_categories (category_id)',
      'CREATE INDEX IF NOT EXISTS idx_object_revisions_object ON object_revisions (object_id)',
      'CREATE INDEX IF NOT EXISTS idx_entry_revisions_entry ON profile_entry_revisions (entry_id)',
      'CREATE INDEX IF NOT EXISTS idx_category_revisions_category ON category_revisions (category_id)',
      'CREATE INDEX IF NOT EXISTS idx_objects_type ON objects (type_id)',
      'CREATE INDEX IF NOT EXISTS idx_objects_norm_title ON objects (normalized_title)',
      'CREATE INDEX IF NOT EXISTS idx_collection_entries_collection ON collection_entries (collection_id)',
      // Ходят чаще всего: отбор по тегу, обложки страницы каталога и «в каких
      // подборках эта запись». Поиск фотографии по хешу индекса не требует —
      // у `attachments.sha256` есть ограничение уникальности, а под него
      // SQLite держит свой индекс.
      'CREATE INDEX IF NOT EXISTS idx_entry_tags_tag ON entry_tags (tag_id)',
      'CREATE INDEX IF NOT EXISTS idx_revision_attachments_revision ON revision_attachments (revision_id)',
      'CREATE INDEX IF NOT EXISTS idx_collection_entries_entry ON collection_entries (entry_id)',
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_entry_primary_category ON entry_categories (entry_id) WHERE is_primary = 1',
    ];
    for (final s in stmts) {
      await customStatement(s);
    }
  }

  /// Полнотекстовый поиск заметок записей (FTS5) + триггеры синхронизации.
  ///
  /// Заметки лежат в другой таблице, чем названия, поэтому индексов два.
  /// Без этого поиск находил только по названию объекта, а текст впечатления
  /// оставался недоступен.
  Future<void> _createEntrySearch() async {
    final oldNote = _yo('old.short_note');
    final oldDetailed = _yo('old.detailed_note');
    final newNote = _yo('new.short_note');
    final newDetailed = _yo('new.detailed_note');

    await customStatement(
      'CREATE VIRTUAL TABLE IF NOT EXISTS entry_search USING fts5('
      'short_note, detailed_note, '
      "content='profile_entries', content_rowid='rowid')",
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS entries_ai AFTER INSERT ON profile_entries '
      'BEGIN INSERT INTO entry_search(rowid, short_note, detailed_note) '
      'VALUES (new.rowid, $newNote, $newDetailed); END',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS entries_ad AFTER DELETE ON profile_entries '
      'BEGIN INSERT INTO entry_search(entry_search, rowid, short_note, detailed_note) '
      "VALUES ('delete', old.rowid, $oldNote, $oldDetailed); END",
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS entries_au AFTER UPDATE ON profile_entries '
      'BEGIN INSERT INTO entry_search(entry_search, rowid, short_note, detailed_note) '
      "VALUES ('delete', old.rowid, $oldNote, $oldDetailed); "
      'INSERT INTO entry_search(rowid, short_note, detailed_note) '
      'VALUES (new.rowid, $newNote, $newDetailed); END',
    );
  }

  /// Наполняет индексы по уже существующим строкам — нужно после обновления
  /// схемы, когда триггеры ещё не видели старые данные.
  ///
  /// Строки набираются запросом, а не командой FTS5 `rebuild`: та читает
  /// таблицу-источник напрямую, минуя триггеры, и вернула бы в индекс сырой
  /// текст — со всеми «ё», ради которых индекс и пересобирается.
  Future<void> _rebuildSearchIndex() async {
    await customStatement(
      "INSERT INTO object_search(object_search) VALUES('delete-all')",
    );
    await customStatement(
      'INSERT INTO object_search(rowid, title, alt_title, creator) '
      "SELECT rowid, ${_yo('title')}, ${_yo('alt_title')}, ${_yo('creator')} "
      'FROM objects',
    );
    await customStatement(
      "INSERT INTO entry_search(entry_search) VALUES('delete-all')",
    );
    await customStatement(
      'INSERT INTO entry_search(rowid, short_note, detailed_note) '
      "SELECT rowid, ${_yo('short_note')}, ${_yo('detailed_note')} "
      'FROM profile_entries',
    );
  }

  /// Убирает триггеры поиска, чтобы пересоздать их с новым правилом.
  Future<void> _dropSearchTriggers() async {
    const names = [
      'objects_ai',
      'objects_ad',
      'objects_au',
      'entries_ai',
      'entries_ad',
      'entries_au',
    ];
    for (final name in names) {
      await customStatement('DROP TRIGGER IF EXISTS $name');
    }
  }

  /// Приводит нормализованные поля уже заведённых строк к правилу со «ё».
  ///
  /// По этим полям ищутся дубли, теги и категории: если их не поправить,
  /// заведённая раньше «ёлка» перестанет совпадать с новой «елкой», и вместо
  /// одной метки получится две.
  Future<void> _foldYoInNormalizedColumns() async {
    const columns = [
      ('categories', 'normalized_name'),
      ('tags', 'normalized_name'),
      ('object_types', 'normalized_name'),
      ('objects', 'normalized_title'),
      ('objects', 'normalized_alt_title'),
    ];
    for (final (table, column) in columns) {
      await customStatement(
        'UPDATE $table SET $column = ${_yo(column)} '
        "WHERE $column LIKE '%ё%'",
      );
    }
  }

  /// Полнотекстовый поиск объектов (FTS5) + триггеры синхронизации.
  Future<void> _createSearch() async {
    final oldTitle = _yo('old.title');
    final oldAlt = _yo('old.alt_title');
    final oldCreator = _yo('old.creator');
    final newTitle = _yo('new.title');
    final newAlt = _yo('new.alt_title');
    final newCreator = _yo('new.creator');

    await customStatement(
      'CREATE VIRTUAL TABLE IF NOT EXISTS object_search USING fts5('
      "title, alt_title, creator, content='objects', content_rowid='rowid')",
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS objects_ai AFTER INSERT ON objects BEGIN '
      'INSERT INTO object_search(rowid, title, alt_title, creator) '
      'VALUES (new.rowid, $newTitle, $newAlt, $newCreator); END',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS objects_ad AFTER DELETE ON objects BEGIN '
      'INSERT INTO object_search(object_search, rowid, title, alt_title, creator) '
      "VALUES ('delete', old.rowid, $oldTitle, $oldAlt, $oldCreator); END",
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS objects_au AFTER UPDATE ON objects BEGIN '
      'INSERT INTO object_search(object_search, rowid, title, alt_title, creator) '
      "VALUES ('delete', old.rowid, $oldTitle, $oldAlt, $oldCreator); "
      'INSERT INTO object_search(rowid, title, alt_title, creator) '
      'VALUES (new.rowid, $newTitle, $newAlt, $newCreator); END',
    );
    await _createEntrySearch();
  }

  /// Сводит «ё» к «е» средствами SQL — тем же правилом, что и [Normalize.yo].
  ///
  /// Нужно и в триггерах, и в запросе: токенизатор `unicode61` эти буквы не
  /// сближает, поэтому «елка» не находила «Ёлку», а «зелен» — «зелёную».
  static String _yo(String expr) =>
      "replace(replace($expr, 'ё', 'е'), 'Ё', 'Е')";

  /// Готовит запрос к FTS5: экранирует кавычки и разрешает поиск по началу
  /// слова, чтобы «колб» находило «колбасу».
  ///
  /// «ё» сводится к «е» так же, как при записи в индекс: там лежит уже
  /// свёрнутый текст, и запрос с «ё» иначе не совпал бы ни с чем.
  static String _matchExpression(String query) {
    final safe = Normalize.yo(query.trim()).replaceAll('"', '""');
    return '"$safe"*';
  }

  /// Полнотекстовый поиск объектов по префиксу запроса. Возвращает id объектов.
  Future<List<String>> searchObjectIds(String query, {int limit = 500}) async {
    if (query.trim().isEmpty) return [];
    final rows = await customSelect(
      'SELECT o.id AS id FROM object_search s '
      'JOIN objects o ON o.rowid = s.rowid '
      'WHERE object_search MATCH ?1 ORDER BY rank LIMIT ?2',
      variables: [
        Variable<String>(_matchExpression(query)),
        Variable<int>(limit),
      ],
      readsFrom: {objects},
    ).get();
    return rows.map((r) => r.read<String>('id')).toList();
  }

  /// Полнотекстовый поиск по тексту заметок. Возвращает id записей.
  Future<List<String>> searchEntryIdsByNote(
    String query, {
    int limit = 500,
  }) async {
    if (query.trim().isEmpty) return [];
    final rows = await customSelect(
      'SELECT e.id AS id FROM entry_search s '
      'JOIN profile_entries e ON e.rowid = s.rowid '
      'WHERE entry_search MATCH ?1 ORDER BY rank LIMIT ?2',
      variables: [
        Variable<String>(_matchExpression(query)),
        Variable<int>(limit),
      ],
      readsFrom: {profileEntries},
    ).get();
    return rows.map((r) => r.read<String>('id')).toList();
  }
}
