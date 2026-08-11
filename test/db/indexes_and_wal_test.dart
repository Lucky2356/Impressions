import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/db/database.dart';

import 'test_db.dart';

/// Индексы под частые запросы и режим журнала.
///
/// Индексы были заведены под категории, записи и объекты, но не под теги,
/// обложки и подборки — а именно туда каталог ходит на каждую страницу. Журнал
/// же оставался обычным: каждая запись означала перезапись журнала и полный
/// `fsync`.
void main() {
  late AppDatabase db;

  setUp(() => db = openTestDb());
  tearDown(() => db.close());

  Future<String> plan(String sql) async {
    final rows = await db.customSelect('EXPLAIN QUERY PLAN $sql').get();
    return rows.map((r) => r.data['detail'] as String? ?? '').join(' | ');
  }

  test('отбор по тегу идёт по индексу', () async {
    expect(
      await plan("SELECT entry_id FROM entry_tags WHERE tag_id = 't1'"),
      contains('USING INDEX idx_entry_tags_tag'),
    );
  });

  test('обложки страницы каталога идут по индексу', () async {
    expect(
      await plan(
        "SELECT attachment_id FROM revision_attachments WHERE revision_id = 'r1'",
      ),
      contains('USING INDEX idx_revision_attachments_revision'),
    );
  });

  test('подборки записи идут по индексу', () async {
    expect(
      await plan(
        "SELECT collection_id FROM collection_entries WHERE entry_id = 'e1'",
      ),
      contains('USING INDEX idx_collection_entries_entry'),
    );
  });

  test('поиск уже сохранённой фотографии идёт по индексу', () async {
    // Своего индекса здесь не нужно: ограничение уникальности на `sha256` уже
    // даёт SQLite индекс, и добавленный рядом просто дублировал бы его.
    expect(
      await plan("SELECT id FROM attachments WHERE sha256 = 'abc'"),
      allOf(contains('SEARCH attachments'), contains('USING INDEX')),
    );
  });

  test('файловая база открывается с журналом упреждающей записи', () async {
    // In-memory база живёт без журнала вовсе, поэтому режим проверяем на файле.
    final dir = await Directory.systemTemp.createTemp('impressions-wal');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/impressions.sqlite');

    final fileDb = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(fileDb.close);

    final mode = await fileDb
        .customSelect('PRAGMA journal_mode')
        .map((r) => r.data.values.first as String)
        .getSingle();
    final sync = await fileDb
        .customSelect('PRAGMA synchronous')
        .map((r) => r.data.values.first as int)
        .getSingle();

    expect(mode.toLowerCase(), 'wal');
    // 1 — NORMAL: при аварии приложения данные целы, а fsync на каждую
    // транзакцию не делается.
    expect(sync, 1);
  });
}
