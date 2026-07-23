import 'package:drift/drift.dart';

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
    ProfileRelationships,
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
    Recommendations,
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      await _createSearch();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
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
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_entry_primary_category ON entry_categories (entry_id) WHERE is_primary = 1',
    ];
    for (final s in stmts) {
      await customStatement(s);
    }
  }

  /// Полнотекстовый поиск объектов (FTS5) + триггеры синхронизации.
  Future<void> _createSearch() async {
    await customStatement(
      "CREATE VIRTUAL TABLE IF NOT EXISTS object_search USING fts5("
      "title, alt_title, creator, content='objects', content_rowid='rowid')",
    );
    await customStatement(
      "CREATE TRIGGER IF NOT EXISTS objects_ai AFTER INSERT ON objects BEGIN "
      "INSERT INTO object_search(rowid, title, alt_title, creator) "
      "VALUES (new.rowid, new.title, new.alt_title, new.creator); END",
    );
    await customStatement(
      "CREATE TRIGGER IF NOT EXISTS objects_ad AFTER DELETE ON objects BEGIN "
      "INSERT INTO object_search(object_search, rowid, title, alt_title, creator) "
      "VALUES ('delete', old.rowid, old.title, old.alt_title, old.creator); END",
    );
    await customStatement(
      "CREATE TRIGGER IF NOT EXISTS objects_au AFTER UPDATE ON objects BEGIN "
      "INSERT INTO object_search(object_search, rowid, title, alt_title, creator) "
      "VALUES ('delete', old.rowid, old.title, old.alt_title, old.creator); "
      "INSERT INTO object_search(rowid, title, alt_title, creator) "
      "VALUES (new.rowid, new.title, new.alt_title, new.creator); END",
    );
  }

  /// Полнотекстовый поиск объектов по префиксу запроса. Возвращает id объектов.
  Future<List<String>> searchObjectIds(String query, {int limit = 50}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    // Экранируем и добавляем префиксный матч.
    final safe = trimmed.replaceAll('"', '""');
    final match = '"$safe"*';
    final rows = await customSelect(
      'SELECT o.id AS id FROM object_search s '
      'JOIN objects o ON o.rowid = s.rowid '
      'WHERE object_search MATCH ?1 ORDER BY rank LIMIT ?2',
      variables: [Variable<String>(match), Variable<int>(limit)],
      readsFrom: {objects},
    ).get();
    return rows.map((r) => r.read<String>('id')).toList();
  }
}
