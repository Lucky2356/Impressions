import 'dart:io';

import 'package:drift/drift.dart';

import '../../core/utils/chunks.dart';
import '../db/database.dart';
import 'image_service.dart';

/// Почему удалить нельзя.
enum PurgeRefusal {
  /// У категории есть подкатегории: сначала разберитесь с ними.
  categoryHasChildren,
}

class PurgeException implements Exception {
  const PurgeException(this.reason);
  final PurgeRefusal reason;
}

/// Окончательное удаление (§24).
///
/// Обычный способ убрать что-либо — архив: он ничего не теряет и позволяет
/// вернуть. Но архив рос бесконечно, и ошибочно заведённое оставалось в базе
/// навсегда. Здесь данные стираются по-настоящему; вернуть их можно только из
/// резервной копии, поэтому вызывать это следует лишь по явному подтверждению.
///
/// Порядок удаления важен: связь `revision_attachments → attachments`
/// объявлена `restrict`, поэтому вложение можно удалить только после того, как
/// на него никто не ссылается.
class PurgeService {
  PurgeService(this.db, {Directory? mediaDirectory})
    : _images = ImageService(db, mediaDirectory: mediaDirectory);

  final AppDatabase db;
  final ImageService _images;

  /// Сводит два одинаковых объекта в один.
  ///
  /// Диалог похожих объектов помогает только в момент создания: если два
  /// одинаковых уже заведены — а до 1.12.0 их плодило само приложение,
  /// подставляя первого кандидата, — свести их было нечем.
  ///
  /// Записи всех профилей переезжают на [keepId], фотографии и история самих
  /// записей остаются при них: они привязаны к записи, а не к объекту.
  /// Опустевший объект убирается тем же правилом, что и при удалении записи, —
  /// только если на него больше никто не смотрит.
  Future<void> mergeObjects({
    required String mergeId,
    required String keepId,
  }) async {
    if (mergeId == keepId) return;

    final orphanedAttachments = <String>{};
    await db.transaction(() async {
      await (db.update(db.profileEntries)
            ..where((e) => e.objectId.equals(mergeId)))
          .write(ProfileEntriesCompanion(objectId: Value(keepId)));
      orphanedAttachments.addAll(await _purgeObjectsIfUnused({mergeId}));
    });

    await _deleteAttachmentFiles(orphanedAttachments);
  }

  /// Удаляет запись профиля со всеми её версиями и связями.
  ///
  /// Объект (общее описание предмета) удаляется вместе с ней, только если на
  /// него больше не ссылается ничья запись: одним и тем же товаром могут
  /// пользоваться несколько профилей.
  Future<void> purgeEntry(String entryId) => purgeEntries([entryId]);

  /// Удаляет набор записей — по десятку запросов на всю пачку, а не на каждую.
  ///
  /// Разбор архива идёт пачками: отметить полсотни записей и снести их одним
  /// нажатием — обычное дело. Прежний цикл по [purgeEntry] делал на каждую
  /// запись свою транзакцию и больше десяти запросов внутри неё, а поиск
  /// осиротевших вложений добавлял по запросу на каждую фотографию.
  Future<void> purgeEntries(List<String> entryIds) async {
    if (entryIds.isEmpty) return;
    for (final chunk in chunked(entryIds, _purgeChunkSize)) {
      await _purgeEntryChunk(chunk);
    }
  }

  /// Записи удаляются пачками поменьше: внутри одной транзакции набирается
  /// несколько списков идентификаторов — версий, тегов, объектов, — и каждый
  /// уходит в запрос своим `IN (…)`.
  static const int _purgeChunkSize = 200;

  Future<void> _purgeEntryChunk(List<String> chunk) async {
    final entries = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.isIn(chunk))).get();
    if (entries.isEmpty) return;

    final ids = entries.map((e) => e.id).toList();
    final objectIds = entries.map((e) => e.objectId).toSet();
    final orphanedAttachments = <String>{};

    await db.transaction(() async {
      final revisionIds = (await (db.select(
        db.profileEntryRevisions,
      )..where((r) => r.entryId.isIn(ids))).get()).map((r) => r.id).toList();

      orphanedAttachments.addAll(await _detachRevisions(revisionIds));

      final tagIds =
          (await (db.select(
                db.entryTags,
              )..where((t) => t.entryId.isIn(ids))).get())
              .map((t) => t.tagId)
              .toSet()
              .toList();
      await (db.delete(db.entryTags)..where((t) => t.entryId.isIn(ids))).go();
      await _purgeTagsIfUnused(tagIds);

      // История повторов уходит вместе с записью: ссылка на неё стоит с
      // `restrict`, и без этого запись просто не удалилась бы.
      await (db.delete(db.entryVisits)..where((v) => v.entryId.isIn(ids))).go();
      await (db.delete(
        db.entryCategories,
      )..where((ec) => ec.entryId.isIn(ids))).go();
      await (db.delete(
        db.collectionEntries,
      )..where((ce) => ce.entryId.isIn(ids))).go();

      // Записи, добавленные с этих (§12), остаются — но ссылаться им уже
      // некуда, иначе получится указатель в пустоту.
      await (db.update(
        db.profileEntries,
      )..where((e) => e.sourceEntryId.isIn(ids))).write(
        const ProfileEntriesCompanion(
          sourceEntryId: Value(null),
          followSource: Value(false),
        ),
      );

      // Сначала снимаем ссылку на текущую версию, иначе она указывает на уже
      // удалённую строку.
      await (db.update(db.profileEntries)..where((e) => e.id.isIn(ids))).write(
        const ProfileEntriesCompanion(currentRevisionId: Value(null)),
      );
      await (db.delete(
        db.profileEntryRevisions,
      )..where((r) => r.entryId.isIn(ids))).go();
      await (db.delete(db.profileEntries)..where((e) => e.id.isIn(ids))).go();

      orphanedAttachments.addAll(await _purgeObjectsIfUnused(objectIds));
    });

    await _deleteAttachmentFiles(orphanedAttachments);
  }

  /// Удаляет категорию. Записи остаются — они лишь теряют эту полку.
  Future<void> purgeCategory(String categoryId) async {
    final children = await (db.select(
      db.categories,
    )..where((c) => c.parentId.equals(categoryId))).get();
    if (children.isNotEmpty) {
      throw const PurgeException(PurgeRefusal.categoryHasChildren);
    }

    final orphaned = <String>{};
    await db.transaction(() async {
      // Ветка отпускает свою обложку: пока она на неё смотрела, файл считался
      // занятым, и после удаления ветки он остался бы лежать навсегда.
      final branch = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(categoryId))).getSingleOrNull();
      await (db.delete(
        db.entryCategories,
      )..where((ec) => ec.categoryId.equals(categoryId))).go();
      await (db.delete(
        db.categories,
      )..where((c) => c.id.equals(categoryId))).go();

      if (branch?.coverAttachmentId case final id?) {
        final holders = await _pinnedCovers([id]);
        final links = await (db.select(
          db.revisionAttachments,
        )..where((ra) => ra.attachmentId.equals(id))).get();
        if (holders.isEmpty && links.isEmpty) orphaned.add(id);
      }
    });
    await _deleteAttachmentFiles(orphaned);
  }

  /// Удаляет подборку. Записи из неё не трогаем: подборка — только список.
  Future<void> purgeCollection(String collectionId) async {
    await db.transaction(() async {
      await (db.delete(
        db.collectionEntries,
      )..where((ce) => ce.collectionId.equals(collectionId))).go();
      await (db.delete(
        db.collections,
      )..where((c) => c.id.equals(collectionId))).go();
    });
  }

  /// Снимает вложения с версий и возвращает те, на которые больше никто
  /// не ссылается.
  Future<Set<String>> _detachRevisions(List<String> revisionIds) async {
    if (revisionIds.isEmpty) return const {};

    final candidates = <String>{};
    for (final chunk in chunked(revisionIds)) {
      final links = await (db.select(
        db.revisionAttachments,
      )..where((ra) => ra.revisionId.isIn(chunk))).get();
      candidates.addAll(links.map((l) => l.attachmentId));

      await (db.delete(
        db.revisionAttachments,
      )..where((ra) => ra.revisionId.isIn(chunk))).go();
    }
    if (candidates.isEmpty) return const {};

    // Файлы дедуплицируются по SHA-256, поэтому одно вложение вполне может
    // принадлежать нескольким записям. Уцелевшие ссылки спрашиваем одним
    // запросом на всю пачку: раньше это был запрос на каждую фотографию.
    final stillUsed = <String>{};
    for (final chunk in chunked(candidates.toList())) {
      final rows =
          await (db.selectOnly(db.revisionAttachments)
                ..addColumns([db.revisionAttachments.attachmentId])
                ..where(db.revisionAttachments.attachmentId.isIn(chunk))
                ..groupBy([db.revisionAttachments.attachmentId]))
              .get();
      stillUsed.addAll(
        rows.map((r) => r.read(db.revisionAttachments.attachmentId)!),
      );
    }
    stillUsed.addAll(await _pinnedCovers(candidates.toList()));
    return candidates.difference(stillUsed);
  }

  /// Вложения, закреплённые обложками ветки или подборки.
  ///
  /// Держателем файла считается не только версия записи: ветка и подборка
  /// ссылаются на вложение своим полем, и без этой проверки удаление записи
  /// насовсем уносило бы обложку у того, кто на неё смотрит.
  Future<Set<String>> _pinnedCovers(List<String> attachmentIds) async {
    if (attachmentIds.isEmpty) return const {};
    final used = <String>{};
    for (final chunk in chunked(attachmentIds)) {
      final branches = await (db.select(
        db.categories,
      )..where((c) => c.coverAttachmentId.isIn(chunk))).get();
      used.addAll([for (final c in branches) ?c.coverAttachmentId]);

      final collections = await (db.select(
        db.collections,
      )..where((c) => c.coverAttachmentId.isIn(chunk))).get();
      used.addAll([for (final c in collections) ?c.coverAttachmentId]);
    }
    return used;
  }

  /// Убирает теги, на которых после удаления записи никого не осталось.
  ///
  /// Иначе метка, поставленная однажды и по ошибке, навсегда остаётся в списке
  /// фильтров каталога — записи давно нет, а тег есть.
  Future<void> _purgeTagsIfUnused(List<String> tagIds) async {
    if (tagIds.isEmpty) return;

    final stillUsed = <String>{};
    for (final chunk in chunked(tagIds)) {
      final rows =
          await (db.selectOnly(db.entryTags)
                ..addColumns([db.entryTags.tagId])
                ..where(db.entryTags.tagId.isIn(chunk))
                ..groupBy([db.entryTags.tagId]))
              .get();
      stillUsed.addAll(rows.map((r) => r.read(db.entryTags.tagId)!));
    }

    final unused = tagIds.where((id) => !stillUsed.contains(id)).toList();
    for (final chunk in chunked(unused)) {
      await (db.delete(db.tags)..where((t) => t.id.isIn(chunk))).go();
    }
  }

  /// Убирает объекты, на которые после удаления записей никто не ссылается.
  ///
  /// Одним и тем же товаром пользуются разные профили, поэтому объект уходит
  /// не вместе с записью, а только когда на него больше не смотрят.
  Future<Set<String>> _purgeObjectsIfUnused(Set<String> objectIds) async {
    if (objectIds.isEmpty) return const {};

    final used = <String>{};
    for (final chunk in chunked(objectIds.toList())) {
      final rows =
          await (db.selectOnly(db.profileEntries)
                ..addColumns([db.profileEntries.objectId])
                ..where(db.profileEntries.objectId.isIn(chunk))
                ..groupBy([db.profileEntries.objectId]))
              .get();
      used.addAll(rows.map((r) => r.read(db.profileEntries.objectId)!));
    }

    final unused = objectIds.where((id) => !used.contains(id)).toList();
    if (unused.isEmpty) return const {};

    final revisionIds = <String>[];
    for (final chunk in chunked(unused)) {
      final rows = await (db.select(
        db.objectRevisions,
      )..where((r) => r.objectId.isIn(chunk))).get();
      revisionIds.addAll(rows.map((r) => r.id));
    }
    final orphaned = await _detachRevisions(revisionIds);

    for (final chunk in chunked(unused)) {
      await (db.update(db.objects)..where((o) => o.id.isIn(chunk))).write(
        const ObjectsCompanion(currentRevisionId: Value(null)),
      );
      await (db.delete(
        db.objectRevisions,
      )..where((r) => r.objectId.isIn(chunk))).go();
      await (db.delete(db.objects)..where((o) => o.id.isIn(chunk))).go();
    }
    return orphaned;
  }

  /// Убирает записи о вложениях и сами файлы с диска.
  ///
  /// Вне транзакции: удаление файлов не откатить, поэтому оно идёт последним —
  /// когда база уже точно приняла изменения.
  Future<void> _deleteAttachmentFiles(Set<String> attachmentIds) async {
    if (attachmentIds.isEmpty) return;

    final rows = await (db.select(
      db.attachments,
    )..where((a) => a.id.isIn(attachmentIds))).get();
    await (db.delete(
      db.attachments,
    )..where((a) => a.id.isIn(attachmentIds))).go();

    for (final row in rows) {
      for (final relative in [row.storagePath, row.thumbPath]) {
        if (relative == null) continue;
        final file = File(await _images.absolutePath(relative));
        if (file.existsSync()) await file.delete();
      }
    }
  }
}
