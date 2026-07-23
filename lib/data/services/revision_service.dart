import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/hashing.dart';
import '../../core/utils/ids.dart';
import '../db/database.dart';

/// Создание неизменяемых версий сущностей (§18).
///
/// Изменение сущности = новая revision; старые сохраняются в истории.
/// Восстановление старой версии создаёт новую revision на основе старой,
/// а не изменяет существующую.
class RevisionService {
  RevisionService(this.db);
  final AppDatabase db;

  /// Полезная нагрузка записи профиля для версии.
  static Map<String, Object?> entryPayload(ProfileEntryRow e) => {
    'relation': e.relation,
    'rating': e.rating,
    'status': e.status,
    'shortNote': e.shortNote,
    'detailedNote': e.detailedNote,
    'impressionDate': e.impressionDate?.toIso8601String(),
    'privacy': e.privacy,
    'archivedAt': e.archivedAt?.toIso8601String(),
  };

  /// Полезная нагрузка объекта для версии.
  static Map<String, Object?> objectPayload(ObjectRow o) => {
    'title': o.title,
    'altTitle': o.altTitle,
    'summary': o.summary,
    'creator': o.creator,
    'year': o.year,
    'barcode': o.barcode,
    'customFields': o.customFields,
  };

  /// Полезная нагрузка категории для версии.
  static Map<String, Object?> categoryPayload(CategoryRow c) => {
    'name': c.name,
    'parentId': c.parentId,
    'description': c.description,
    'icon': c.icon,
    'color': c.color,
    'sortOrder': c.sortOrder,
    'archivedAt': c.archivedAt?.toIso8601String(),
  };

  /// Хеш содержимого текущей версии сущности (или null, если версий нет).
  ///
  /// Сравнение ведётся именно с ТЕКУЩЕЙ версией, а не со всей историей:
  /// это позволяет не плодить версии при сохранении без изменений и при этом
  /// корректно фиксировать восстановление старой версии как новую (§18).
  Future<String?> _currentHash(String? currentRevisionId, String table) async {
    if (currentRevisionId == null) return null;
    final rows = await db
        .customSelect(
          'SELECT content_hash AS h FROM $table WHERE id = ?1',
          variables: [Variable<String>(currentRevisionId)],
        )
        .get();
    return rows.isEmpty ? null : rows.first.read<String>('h');
  }

  /// Создаёт версию записи профиля и делает её текущей.
  /// Если содержимое совпадает с текущей версией, новая версия не создаётся.
  Future<String> commitEntry(
    String entryId, {
    String? authorProfileId,
    String? deviceId,
    String? originPackageId,
    DateTime? importedAt,
  }) async {
    final entry = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(entryId))).getSingle();
    final payload = entryPayload(entry);
    final hash = Hashing.contentHash(payload);

    final currentHash = await _currentHash(
      entry.currentRevisionId,
      'profile_entry_revisions',
    );
    if (currentHash == hash) return entry.currentRevisionId!;

    final id = Ids.newId();
    await db.transaction(() async {
      await db
          .into(db.profileEntryRevisions)
          .insert(
            ProfileEntryRevisionsCompanion.insert(
              id: id,
              entryId: entryId,
              parentRevisionId: Value(entry.currentRevisionId),
              authorProfileId: Value(authorProfileId ?? entry.profileId),
              deviceId: Value(deviceId),
              createdAt: DateTime.now(),
              importedAt: Value(importedAt),
              payloadVersion: const Value(AppConfig.payloadVersion),
              payloadJson: jsonEncode(payload),
              contentHash: hash,
              originPackageId: Value(originPackageId),
            ),
          );
      await (db.update(db.profileEntries)..where((e) => e.id.equals(entryId)))
          .write(ProfileEntriesCompanion(currentRevisionId: Value(id)));
      // Вложения переносятся на новую версию, иначе фотографии «терялись бы»
      // при каждом изменении записи (§16, §18).
      await _carryAttachments(entry.currentRevisionId, id, 'entry');
    });
    return id;
  }

  /// Копирует связи вложений с родительской версии на новую.
  Future<void> _carryAttachments(
    String? parentRevisionId,
    String newRevisionId,
    String kind,
  ) async {
    if (parentRevisionId == null) return;
    final links = await (db.select(
      db.revisionAttachments,
    )..where((ra) => ra.revisionId.equals(parentRevisionId))).get();
    for (final l in links) {
      await db
          .into(db.revisionAttachments)
          .insert(
            RevisionAttachmentsCompanion.insert(
              id: Ids.newId(),
              entityKind: kind,
              revisionId: newRevisionId,
              attachmentId: l.attachmentId,
              sortOrder: Value(l.sortOrder),
              isPrimary: Value(l.isPrimary),
            ),
          );
    }
  }

  /// Создаёт версию объекта и делает её текущей.
  Future<String> commitObject(
    String objectId, {
    String? authorProfileId,
    String? deviceId,
    String? originPackageId,
  }) async {
    final obj = await (db.select(
      db.objects,
    )..where((o) => o.id.equals(objectId))).getSingle();
    final payload = objectPayload(obj);
    final hash = Hashing.contentHash(payload);

    final currentHash = await _currentHash(
      obj.currentRevisionId,
      'object_revisions',
    );
    if (currentHash == hash) return obj.currentRevisionId!;

    final id = Ids.newId();
    await db.transaction(() async {
      await db
          .into(db.objectRevisions)
          .insert(
            ObjectRevisionsCompanion.insert(
              id: id,
              objectId: objectId,
              parentRevisionId: Value(obj.currentRevisionId),
              authorProfileId: Value(authorProfileId),
              deviceId: Value(deviceId),
              createdAt: DateTime.now(),
              payloadVersion: const Value(AppConfig.payloadVersion),
              payloadJson: jsonEncode(payload),
              contentHash: hash,
              originPackageId: Value(originPackageId),
            ),
          );
      await (db.update(db.objects)..where((o) => o.id.equals(objectId))).write(
        ObjectsCompanion(currentRevisionId: Value(id)),
      );
    });
    return id;
  }

  /// Создаёт версию категории и делает её текущей.
  Future<String> commitCategory(
    String categoryId, {
    String? authorProfileId,
    String? deviceId,
    String? originPackageId,
  }) async {
    final cat = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(categoryId))).getSingle();
    final payload = categoryPayload(cat);
    final hash = Hashing.contentHash(payload);

    final currentHash = await _currentHash(
      cat.currentRevisionId,
      'category_revisions',
    );
    if (currentHash == hash) return cat.currentRevisionId!;

    final id = Ids.newId();
    await db.transaction(() async {
      await db
          .into(db.categoryRevisions)
          .insert(
            CategoryRevisionsCompanion.insert(
              id: id,
              categoryId: categoryId,
              parentRevisionId: Value(cat.currentRevisionId),
              authorProfileId: Value(authorProfileId ?? cat.profileId),
              deviceId: Value(deviceId),
              createdAt: DateTime.now(),
              payloadVersion: const Value(AppConfig.payloadVersion),
              payloadJson: jsonEncode(payload),
              contentHash: hash,
              originPackageId: Value(originPackageId),
            ),
          );
      await (db.update(db.categories)..where((c) => c.id.equals(categoryId)))
          .write(CategoriesCompanion(currentRevisionId: Value(id)));
    });
    return id;
  }

  /// История версий записи профиля, от новых к старым.
  ///
  /// Вторичная сортировка по rowid делает порядок детерминированным, когда
  /// несколько версий созданы в пределах одной миллисекунды.
  Future<List<ProfileEntryRevisionRow>> entryHistory(String entryId) {
    return (db.select(db.profileEntryRevisions)
          ..where((r) => r.entryId.equals(entryId))
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc),
            (r) => OrderingTerm(expression: r.rowId, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Восстанавливает состояние записи из старой версии: применяет её поля
  /// и создаёт НОВУЮ версию на основе старой (§18).
  Future<void> restoreEntryRevision(String entryId, String revisionId) async {
    final rev = await (db.select(
      db.profileEntryRevisions,
    )..where((r) => r.id.equals(revisionId))).getSingle();
    final payload = jsonDecode(rev.payloadJson) as Map<String, Object?>;

    await (db.update(
      db.profileEntries,
    )..where((e) => e.id.equals(entryId))).write(
      ProfileEntriesCompanion(
        relation: Value(payload['relation'] as String?),
        rating: Value((payload['rating'] as num?)?.toDouble()),
        status: Value(payload['status'] as String?),
        shortNote: Value(payload['shortNote'] as String?),
        detailedNote: Value(payload['detailedNote'] as String?),
        privacy: Value(payload['privacy'] as String? ?? 'shareable'),
        impressionDate: Value(
          payload['impressionDate'] == null
              ? null
              : DateTime.tryParse(payload['impressionDate'] as String),
        ),
      ),
    );
    await commitEntry(entryId);
  }
}
