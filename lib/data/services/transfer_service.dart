import 'package:drift/drift.dart';

import '../../core/utils/normalize.dart';
import '../db/database.dart';
import '../repositories/category_repository.dart';
import '../repositories/entry_repository.dart';

/// Как поступать с категорией при переносе записи (§7.4).
enum TransferCategoryMode {
  /// Предлагать совпадающий путь (по умолчанию).
  suggestMatch,

  /// Автоматически создавать отсутствующие категории.
  autoCreate,

  /// Всегда спрашивать (решение принимает интерфейс).
  alwaysAsk,

  /// Сохранять без категории.
  noCategory,
}

/// Предложение по категории при переносе записи в другой профиль.
class CategorySuggestion {
  const CategorySuggestion({
    required this.sourcePathNames,
    required this.matchedCategoryId,
    required this.matchedPathNames,
    required this.missingNames,
  });

  /// Путь категории в профиле-источнике, например [Продукты, Колбасы].
  final List<String> sourcePathNames;

  /// Найденная существующая категория в целевом профиле (самое глубокое
  /// совпадение) либо null.
  final String? matchedCategoryId;

  /// Путь найденного совпадения.
  final List<String> matchedPathNames;

  /// Названия, которых не хватает, чтобы воспроизвести путь целиком.
  final List<String> missingNames;

  bool get isExactMatch => missingNames.isEmpty && matchedCategoryId != null;
  bool get hasNothing => matchedCategoryId == null && sourcePathNames.isEmpty;
}

/// Результат переноса записи.
class TransferResult {
  const TransferResult({required this.entryId, required this.categoryId});
  final String entryId;
  final String? categoryId;
}

/// Перенос чужой записи в свой профиль (§12) с сопоставлением категорий (§7.4).
///
/// Правила: чужие оценка и отношение НЕ копируются, исходная запись не
/// изменяется, сохраняются ссылка на источник, автор рекомендации и дата.
class TransferService {
  TransferService(this.db)
    : _categories = CategoryRepository(db),
      _entries = EntryRepository(db);

  final AppDatabase db;
  final CategoryRepository _categories;
  final EntryRepository _entries;

  /// Статус по умолчанию для перенесённой записи (§12).
  static const String defaultStatus = 'wantToTry';

  /// Разбирает путь основной категории записи в названиях.
  Future<List<String>> _sourcePathNames(ProfileEntryRow entry) async {
    final links = await (db.select(
      db.entryCategories,
    )..where((ec) => ec.entryId.equals(entry.id))).get();
    final primary = links.where((l) => l.isPrimary).firstOrNull;
    if (primary == null) return const [];

    final cats = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(entry.profileId))).get();
    final byId = {for (final c in cats) c.id: c};
    final selected = byId[primary.categoryId];
    if (selected == null) return const [];
    return [
      for (final id in selected.path.split('/'))
        if (byId[id] != null) byId[id]!.name,
    ];
  }

  /// Подбирает категорию в целевом профиле по пути источника.
  /// Сопоставление ведётся по нормализованным названиям (§7.4).
  Future<CategorySuggestion> suggestCategory({
    required String sourceEntryId,
    required String targetProfileId,
  }) async {
    final entry = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(sourceEntryId))).getSingle();
    final sourceNames = await _sourcePathNames(entry);
    if (sourceNames.isEmpty) {
      return const CategorySuggestion(
        sourcePathNames: [],
        matchedCategoryId: null,
        matchedPathNames: [],
        missingNames: [],
      );
    }

    final targetCats =
        await (db.select(db.categories)..where(
              (c) =>
                  c.profileId.equals(targetProfileId) & c.archivedAt.isNull(),
            ))
            .get();
    final byId = {for (final c in targetCats) c.id: c};

    String? currentParentId;
    String? matchedId;
    final matchedNames = <String>[];
    var index = 0;

    for (; index < sourceNames.length; index++) {
      final wanted = Normalize.name(sourceNames[index]);
      final candidate = targetCats
          .where(
            (c) => c.parentId == currentParentId && c.normalizedName == wanted,
          )
          .firstOrNull;
      if (candidate == null) break;
      matchedId = candidate.id;
      matchedNames.add(candidate.name);
      currentParentId = candidate.id;
    }

    // Проверяем, что найденная ветка действительно принадлежит целевому дереву.
    if (matchedId != null && byId[matchedId] == null) matchedId = null;

    return CategorySuggestion(
      sourcePathNames: sourceNames,
      matchedCategoryId: matchedId,
      matchedPathNames: matchedNames,
      missingNames: sourceNames.sublist(index),
    );
  }

  /// Создаёт недостающие категории целевого профиля по предложению.
  Future<String?> materializeCategory({
    required String targetProfileId,
    required CategorySuggestion suggestion,
  }) async {
    if (suggestion.missingNames.isEmpty) return suggestion.matchedCategoryId;

    var parentId = suggestion.matchedCategoryId;
    for (final name in suggestion.missingNames) {
      final created = parentId == null
          ? await _categories.createRoot(targetProfileId, name)
          : await _categories.createChild(parentId, name);
      parentId = created.id;
    }
    return parentId;
  }

  /// Находит или создаёт тип объекта в целевом профиле по названию исходного.
  Future<String> _resolveTypeId(String objectId, String targetProfileId) async {
    final object = await (db.select(
      db.objects,
    )..where((o) => o.id.equals(objectId))).getSingle();
    final sourceType = await (db.select(
      db.objectTypes,
    )..where((t) => t.id.equals(object.typeId))).getSingle();

    final normalized = Normalize.name(sourceType.name);
    final existing =
        await (db.select(db.objectTypes)..where(
              (t) =>
                  t.profileId.equals(targetProfileId) &
                  t.normalizedName.equals(normalized),
            ))
            .getSingleOrNull();
    if (existing != null) return existing.id;

    final created = await _entries.createObjectType(
      targetProfileId,
      sourceType.name,
      icon: sourceType.icon,
    );
    return created.id;
  }

  /// Переносит запись в целевой профиль.
  ///
  /// [categoryId] — явно выбранная категория; если не задана, применяется
  /// [mode]. Чужие оценка и отношение не копируются (§12).
  Future<TransferResult> transfer({
    required String sourceEntryId,
    required String targetProfileId,
    String? categoryId,
    TransferCategoryMode mode = TransferCategoryMode.suggestMatch,
  }) async {
    final source = await (db.select(
      db.profileEntries,
    )..where((e) => e.id.equals(sourceEntryId))).getSingle();

    if (source.profileId == targetProfileId) {
      throw StateError('Запись уже принадлежит этому профилю');
    }

    var resolvedCategoryId = categoryId;
    if (resolvedCategoryId == null && mode != TransferCategoryMode.noCategory) {
      final suggestion = await suggestCategory(
        sourceEntryId: sourceEntryId,
        targetProfileId: targetProfileId,
      );
      resolvedCategoryId = switch (mode) {
        TransferCategoryMode.autoCreate => await materializeCategory(
          targetProfileId: targetProfileId,
          suggestion: suggestion,
        ),
        TransferCategoryMode.suggestMatch => suggestion.matchedCategoryId,
        // «Всегда спрашивать» без явного выбора трактуем как «без категории»:
        // решение принимает интерфейс до вызова.
        TransferCategoryMode.alwaysAsk => null,
        TransferCategoryMode.noCategory => null,
      };
    }

    // Объект общий — переиспользуем его, но тип должен существовать у цели.
    await _resolveTypeId(source.objectId, targetProfileId);

    final created = await _entries.createEntry(
      profileId: targetProfileId,
      objectId: source.objectId,
      // Чужие отношение и оценка НЕ копируются (§12).
      relation: null,
      rating: null,
      status: defaultStatus,
      primaryCategoryId: resolvedCategoryId,
    );

    // Сохраняем источник, автора рекомендации и дату получения (§12).
    await (db.update(
      db.profileEntries,
    )..where((e) => e.id.equals(created.id))).write(
      ProfileEntriesCompanion(
        sourceEntryId: Value(sourceEntryId),
        recommendedByProfileId: Value(source.profileId),
        recommendationSource: const Value('transfer'),
      ),
    );

    // Кто посоветовал — записано выше, в самой записи. Отдельная таблица
    // `recommendations` дублировала это и нигде не читалась, поэтому убрана.

    return TransferResult(entryId: created.id, categoryId: resolvedCategoryId);
  }

  /// Уже есть ли у профиля запись об этом объекте.
  Future<bool> hasEntryFor(String profileId, String objectId) async {
    final row =
        await (db.select(db.profileEntries)..where(
              (e) =>
                  e.profileId.equals(profileId) &
                  e.objectId.equals(objectId) &
                  e.archivedAt.isNull(),
            ))
            .getSingleOrNull();
    return row != null;
  }
}
