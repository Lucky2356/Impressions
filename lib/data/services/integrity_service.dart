import 'dart:io';

import 'package:path/path.dart' as p;

import '../db/database.dart';
import 'image_service.dart';
import 'revision_service.dart';

/// Что именно нашлось при проверке.
enum IntegrityIssue {
  /// Файлы в папке изображений, на которые никто не ссылается.
  orphanFiles,

  /// Записи о фотографиях, файлов которых на диске нет.
  missingFiles,

  /// Запись без текущей версии: история есть, а «сейчас» не указано.
  entriesWithoutRevision,

  /// Связи с категориями, которых больше нет.
  danglingCategories,

  /// Состав подборок, ссылающийся на исчезнувшие записи.
  danglingCollectionEntries,

  /// Поисковый индекс разошёлся с таблицами.
  searchOutOfSync,
}

/// Одна находка: что и сколько.
class IntegrityFinding {
  const IntegrityFinding(this.issue, this.count);

  final IntegrityIssue issue;
  final int count;
}

/// Отчёт проверки.
class IntegrityReport {
  const IntegrityReport(this.findings);

  final List<IntegrityFinding> findings;

  bool get isClean => findings.isEmpty;

  /// Сколько места занимают файлы, на которые никто не ссылается.
  int countOf(IntegrityIssue issue) => findings
      .where((f) => f.issue == issue)
      .fold(0, (sum, f) => sum + f.count);
}

/// Проверка целостности данных и их починка.
///
/// Приложение обещает, что ничего не пропадает. Но расхождения всё равно
/// случаются: прерванный импорт, упавшее при обработке фотографии приложение,
/// файл, удалённый мимо приложения. Заметить такое можно было только по
/// симптому — пустая обложка, запись, которая не находится поиском.
class IntegrityService {
  IntegrityService(this.db, {Directory? mediaDirectory})
    : _images = ImageService(db, mediaDirectory: mediaDirectory);

  final AppDatabase db;
  final ImageService _images;

  /// Смотрит, но ничего не меняет.
  Future<IntegrityReport> check() async {
    final findings = <IntegrityFinding>[];

    void add(IntegrityIssue issue, int count) {
      if (count > 0) findings.add(IntegrityFinding(issue, count));
    }

    add(IntegrityIssue.orphanFiles, (await _orphanFiles()).length);
    add(IntegrityIssue.missingFiles, (await _missingFiles()).length);
    add(
      IntegrityIssue.entriesWithoutRevision,
      (await _entriesWithoutRevision()).length,
    );
    add(
      IntegrityIssue.danglingCategories,
      (await _danglingCategories()).length,
    );
    add(
      IntegrityIssue.danglingCollectionEntries,
      (await _danglingCollectionEntries()).length,
    );
    if (await _searchOutOfSync()) {
      add(IntegrityIssue.searchOutOfSync, 1);
    }

    return IntegrityReport(findings);
  }

  /// Чинит найденное и возвращает отчёт о том, что осталось.
  ///
  /// Ничего не удаляет из того, что несёт данные: лишние файлы стираются,
  /// повисшие связи снимаются, недостающие версии дописываются, индекс
  /// набирается заново. Сами записи, объекты и категории не трогаются — если
  /// потеряно что-то из них, это работа для восстановления из копии.
  Future<IntegrityReport> repair() async {
    for (final file in await _orphanFiles()) {
      if (file.existsSync()) await file.delete();
    }

    // Пропавший файл — это запись о фотографии, за которой ничего нет: она
    // рисует пустое место в карточке и мешает считать «есть ли фото».
    final missing = await _missingFiles();
    if (missing.isNotEmpty) {
      await (db.delete(
        db.revisionAttachments,
      )..where((ra) => ra.attachmentId.isIn(missing))).go();
      await (db.delete(db.attachments)..where((a) => a.id.isIn(missing))).go();
    }

    for (final entryId in await _entriesWithoutRevision()) {
      await RevisionService(db).commitEntry(entryId);
    }

    final dangling = await _danglingCategories();
    if (dangling.isNotEmpty) {
      await (db.delete(
        db.entryCategories,
      )..where((ec) => ec.categoryId.isIn(dangling))).go();
    }

    final orphanLinks = await _danglingCollectionEntries();
    if (orphanLinks.isNotEmpty) {
      await (db.delete(
        db.collectionEntries,
      )..where((ce) => ce.entryId.isIn(orphanLinks))).go();
    }

    if (await _searchOutOfSync()) await db.rebuildSearchIndex();

    return check();
  }

  /// Файлы в папке изображений, на которые не ссылается ни одна запись.
  Future<List<File>> _orphanFiles() async {
    final dir = Directory(await _images.mediaDirectoryPath());
    if (!dir.existsSync()) return const [];

    final known = <String>{};
    for (final row in await db.select(db.attachments).get()) {
      known.add(row.storagePath);
      final thumb = row.thumbPath;
      if (thumb != null) known.add(thumb);
    }

    return [
      for (final entity in dir.listSync())
        if (entity is File && !known.contains(p.basename(entity.path))) entity,
    ];
  }

  /// Записи о фотографиях, файлов которых на диске нет.
  Future<List<String>> _missingFiles() async {
    final dir = await _images.mediaDirectoryPath();
    final missing = <String>[];
    for (final row in await db.select(db.attachments).get()) {
      if (!File(p.join(dir, row.storagePath)).existsSync()) {
        missing.add(row.id);
      }
    }
    return missing;
  }

  Future<List<String>> _entriesWithoutRevision() async {
    final rows = await (db.select(
      db.profileEntries,
    )..where((e) => e.currentRevisionId.isNull())).get();
    return [for (final row in rows) row.id];
  }

  Future<List<String>> _danglingCategories() async {
    final categories = {
      for (final c in await db.select(db.categories).get()) c.id,
    };
    final links = await db.select(db.entryCategories).get();
    return [
      for (final link in links)
        if (!categories.contains(link.categoryId)) link.categoryId,
    ];
  }

  Future<List<String>> _danglingCollectionEntries() async {
    final entries = {
      for (final e in await db.select(db.profileEntries).get()) e.id,
    };
    final links = await db.select(db.collectionEntries).get();
    return [
      for (final link in links)
        if (!entries.contains(link.entryId)) link.entryId,
    ];
  }

  /// Разошёлся ли поисковый индекс с таблицами.
  ///
  /// Считать строки бесполезно: обе таблицы поиска — внешние (`content=`), и
  /// `COUNT(*)` они берут из самих объектов и записей. Зато у FTS5 есть своя
  /// проверка: она сверяет индекс с содержимым и ругается, если он отстал.
  /// Отставший индекс ничем себя не выдаёт — поиск просто не находит часть
  /// записей.
  Future<bool> _searchOutOfSync() async {
    for (final table in ['object_search', 'entry_search']) {
      try {
        await db.customStatement(
          "INSERT INTO $table($table, rank) VALUES('integrity-check', 1)",
        );
      } catch (_) {
        return true;
      }
    }
    return false;
  }
}
