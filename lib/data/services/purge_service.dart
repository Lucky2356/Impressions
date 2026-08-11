import 'dart:io';

import 'package:drift/drift.dart';

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
      orphanedAttachments.addAll(await _purgeObjectIfUnused(mergeId));
    });

    await _deleteAttachmentFiles(orphanedAttachments);
  }

  /// Удаляет запись профиля со всеми её версиями и связями.
  ///
  /// Объект (общее описание предмета) удаляется вместе с ней, только если на
  /// него больше не ссылается ничья запись: одним и тем же товаром могут
  /// пользоваться несколько профилей.
  Future<void> purgeEntry(String entryId) async {
    final entry = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entryId))).getSingleOrNull();
    if (entry == null) return;

    final orphanedAttachments = <String>{};

    await db.transaction(() async {
      final revisionIds =
          (await (db.select(
                db.profileEntryRevisions,
              )..where((r) => r.entryId.equals(entryId))).get())
              .map((r) => r.id)
              .toList();

      orphanedAttachments.addAll(await _detachRevisions(revisionIds));

      final tagIds =
          (await (db.select(
                db.entryTags,
              )..where((t) => t.entryId.equals(entryId))).get())
              .map((t) => t.tagId)
              .toList();
      await (db.delete(
        db.entryTags,
      )..where((t) => t.entryId.equals(entryId))).go();
      await _purgeTagsIfUnused(tagIds);

      await (db.delete(
        db.entryCategories,
      )..where((ec) => ec.entryId.equals(entryId))).go();
      await (db.delete(
        db.collectionEntries,
      )..where((ce) => ce.entryId.equals(entryId))).go();

      // Записи, добавленные с этой (§12), остаются — но ссылаться им уже
      // некуда, иначе получится указатель в пустоту.
      await (db.update(
        db.profileEntries,
      )..where((e) => e.sourceEntryId.equals(entryId))).write(
        const ProfileEntriesCompanion(
          sourceEntryId: Value(null),
          followSource: Value(false),
        ),
      );

      // Сначала снимаем ссылку на текущую версию, иначе она указывает на уже
      // удалённую строку.
      await (db.update(db.profileEntries)..where((e) => e.id.equals(entryId)))
          .write(const ProfileEntriesCompanion(currentRevisionId: Value(null)));
      await (db.delete(
        db.profileEntryRevisions,
      )..where((r) => r.entryId.equals(entryId))).go();
      await (db.delete(
        db.profileEntries,
      )..where((e) => e.id.equals(entryId))).go();

      orphanedAttachments.addAll(await _purgeObjectIfUnused(entry.objectId));
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

    await db.transaction(() async {
      await (db.delete(
        db.entryCategories,
      )..where((ec) => ec.categoryId.equals(categoryId))).go();
      await (db.delete(
        db.categories,
      )..where((c) => c.id.equals(categoryId))).go();
    });
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

    final links = await (db.select(
      db.revisionAttachments,
    )..where((ra) => ra.revisionId.isIn(revisionIds))).get();
    if (links.isEmpty) return const {};

    await (db.delete(
      db.revisionAttachments,
    )..where((ra) => ra.revisionId.isIn(revisionIds))).go();

    final orphaned = <String>{};
    for (final id in links.map((l) => l.attachmentId).toSet()) {
      final stillUsed = await (db.select(
        db.revisionAttachments,
      )..where((ra) => ra.attachmentId.equals(id))).getSingleOrNull();
      // Файлы дедуплицируются по SHA-256, поэтому одно вложение вполне может
      // принадлежать нескольким записям.
      if (stillUsed == null) orphaned.add(id);
    }
    return orphaned;
  }

  /// Убирает теги, на которых после удаления записи никого не осталось.
  ///
  /// Иначе метка, поставленная однажды и по ошибке, навсегда остаётся в списке
  /// фильтров каталога — записи давно нет, а тег есть.
  Future<void> _purgeTagsIfUnused(List<String> tagIds) async {
    for (final id in tagIds) {
      // Строк на тег может быть много, поэтому limit(1) и get(): у
      // getSingleOrNull на нескольких строках падение, а не ответ.
      final stillUsed =
          await (db.select(db.entryTags)
                ..where((et) => et.tagId.equals(id))
                ..limit(1))
              .get();
      if (stillUsed.isNotEmpty) continue;
      await (db.delete(db.tags)..where((t) => t.id.equals(id))).go();
    }
  }

  Future<Set<String>> _purgeObjectIfUnused(String objectId) async {
    // Ссылок на объект может быть сколько угодно — им пользуются разные
    // профили. getSingleOrNull на двух и более строках падает, а не отвечает
    // «занято», поэтому limit(1) и get().
    final used =
        await (db.select(db.profileEntries)
              ..where((e) => e.objectId.equals(objectId))
              ..limit(1))
            .get();
    if (used.isNotEmpty) return const {};

    final revisionIds =
        (await (db.select(
              db.objectRevisions,
            )..where((r) => r.objectId.equals(objectId))).get())
            .map((r) => r.id)
            .toList();
    final orphaned = await _detachRevisions(revisionIds);

    await (db.update(db.objects)..where((o) => o.id.equals(objectId))).write(
      const ObjectsCompanion(currentRevisionId: Value(null)),
    );
    await (db.delete(
      db.objectRevisions,
    )..where((r) => r.objectId.equals(objectId))).go();
    await (db.delete(db.objects)..where((o) => o.id.equals(objectId))).go();
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
