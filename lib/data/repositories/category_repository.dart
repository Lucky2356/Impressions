import 'package:drift/drift.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/chunks.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/normalize.dart';
import '../db/database.dart';
import '../models/category_tree.dart';

/// Ошибка недопустимой операции с деревом категорий (§7.1).
class CategoryTreeException implements Exception {
  CategoryTreeException(this.message);
  final String message;
  @override
  String toString() => 'CategoryTreeException: $message';
}

/// Что переехало при объединении веток — чтобы сказать это до подтверждения.
class CategoryMergeResult {
  const CategoryMergeResult({
    required this.movedEntries,
    required this.movedChildren,
  });
  final int movedEntries;
  final int movedChildren;
}

/// Репозиторий категорий. Реализует дерево на adjacency list + materialized
/// path (см. DATA_MODEL.md §3, CATEGORY_SYSTEM.md).
class CategoryRepository {
  CategoryRepository(this.db);
  final AppDatabase db;

  /// Разделитель сегментов пути — тот же, которым дерево разбирают экраны.
  static const String _sep = CategoryTree.separator;

  Future<CategoryRow?> byId(String id) {
    return (db.select(
      db.categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Создаёт корневую категорию профиля.
  Future<CategoryRow> createRoot(
    String profileId,
    String name, {
    String? description,
    String? icon,
    int? color,
    int? sortOrder,
    String? defaultTypeId,
  }) async {
    final id = Ids.newId();
    final row = CategoriesCompanion.insert(
      id: id,
      profileId: profileId,
      parentId: const Value.absent(),
      name: name,
      normalizedName: Normalize.name(name),
      description: Value(description),
      icon: Value(icon),
      color: Value(color),
      sortOrder: Value(sortOrder ?? await _nextSortOrder(profileId, null)),
      level: const Value(0),
      path: id,
      defaultTypeId: Value(defaultTypeId),
      createdAt: DateTime.now(),
    );
    await db.into(db.categories).insert(row);
    return (await byId(id))!;
  }

  /// Создаёт подкатегорию внутри [parentId]. Проверяет лимит глубины.
  Future<CategoryRow> createChild(
    String parentId,
    String name, {
    String? description,
    String? icon,
    int? color,
    int? sortOrder,
  }) async {
    final parent = await byId(parentId);
    if (parent == null) {
      throw CategoryTreeException('Родительская категория не найдена');
    }
    final childLevel = parent.level + 1;
    if (childLevel > AppConfig.hardMaxCategoryDepth) {
      throw CategoryTreeException('Превышена максимальная глубина вложенности');
    }
    final id = Ids.newId();
    final row = CategoriesCompanion.insert(
      id: id,
      profileId: parent.profileId,
      parentId: Value(parent.id),
      name: name,
      normalizedName: Normalize.name(name),
      description: Value(description),
      icon: Value(icon),
      color: Value(color),
      sortOrder: Value(
        sortOrder ?? await _nextSortOrder(parent.profileId, parent.id),
      ),
      level: Value(childLevel),
      path: '${parent.path}$_sep$id',
      createdAt: DateTime.now(),
    );
    await db.into(db.categories).insert(row);
    return (await byId(id))!;
  }

  /// Переименовывает категорию.
  Future<void> rename(String id, String newName) async {
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(newName),
        normalizedName: Value(Normalize.name(newName)),
      ),
    );
  }

  /// Признак «поле не передали» — по образцу `EntryRepository`.
  static const Object _unset = Object();

  static Value<T?> _valueOf<T>(Object? v) =>
      identical(v, _unset) ? const Value.absent() : Value(v as T?);

  /// Обновляет оформление ветки.
  ///
  /// `null` здесь значит именно null — «убрать». «Не трогать» выражается тем,
  /// что поле не передали вовсе. Иначе нечем было бы сказать «цвет как у
  /// родителя» или «снять обложку»: раньше null означал и то, и другое.
  Future<void> updateAppearance(
    String id, {
    Object? icon = _unset,
    Object? color = _unset,
    Object? description = _unset,
    Object? coverAttachmentId = _unset,
    Object? defaultTypeId = _unset,
    int? sortOrder,
  }) async {
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        icon: _valueOf<String>(icon),
        color: _valueOf<int>(color),
        description: _valueOf<String>(description),
        coverAttachmentId: _valueOf<String>(coverAttachmentId),
        defaultTypeId: _valueOf<String>(defaultTypeId),
        sortOrder: sortOrder == null ? const Value.absent() : Value(sortOrder),
      ),
    );
  }

  /// Порядок соседей: сначала заданный вручную, потом по алфавиту.
  ///
  /// Название вторым ключом не для красоты: у категорий, заведённых до 1.11.0,
  /// `sortOrder` у всех нулевой, и без него SQLite возвращал бы их в порядке,
  /// который меняется от запроса к запросу.
  static List<OrderingTerm Function($CategoriesTable)> get _siblingOrder => [
    (c) => OrderingTerm(expression: c.sortOrder),
    (c) => OrderingTerm(expression: c.normalizedName),
  ];

  /// Прямые дочерние категории (без архивных по умолчанию).
  Future<List<CategoryRow>> children(
    String parentId, {
    bool includeArchived = false,
  }) {
    final q = db.select(db.categories)
      ..where((c) => c.parentId.equals(parentId))
      ..orderBy(_siblingOrder);
    if (!includeArchived) {
      q.where((c) => c.archivedAt.isNull());
    }
    return q.get();
  }

  /// Корневые категории профиля.
  Future<List<CategoryRow>> roots(
    String profileId, {
    bool includeArchived = false,
  }) {
    final q = db.select(db.categories)
      ..where((c) => c.profileId.equals(profileId) & c.parentId.isNull())
      ..orderBy(_siblingOrder);
    if (!includeArchived) {
      q.where((c) => c.archivedAt.isNull());
    }
    return q.get();
  }

  /// Все категории профиля в порядке соседства.
  ///
  /// Нужна тем, кто обходит дерево целиком: спрашивать детей у каждого узла —
  /// это запрос на каждую ветку, а веток у полного каталога сотни.
  Future<List<CategoryRow>> allOf(
    String profileId, {
    bool includeArchived = false,
  }) {
    final q = db.select(db.categories)
      ..where((c) => c.profileId.equals(profileId))
      ..orderBy(_siblingOrder);
    if (!includeArchived) {
      q.where((c) => c.archivedAt.isNull());
    }
    return q.get();
  }

  /// Соседи категории — то, среди чего её можно двигать.
  Future<List<CategoryRow>> siblingsOf(CategoryRow node) {
    return node.parentId == null
        ? roots(node.profileId)
        : children(node.parentId!);
  }

  /// Задаёт порядок ряда соседей целиком.
  ///
  /// Порядок перенумеровывается, а не меняется местами у двух: до 1.11.0
  /// `sortOrder` никто не выставлял, у всех стоял ноль, и обмен нулями не
  /// сдвинул бы ничего.
  Future<void> reorderSiblings(List<String> orderedIds) async {
    if (orderedIds.isEmpty) return;
    await db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          db.categories,
          CategoriesCompanion(sortOrder: Value(i)),
          where: (c) => c.id.equals(orderedIds[i]),
        );
      }
    });
  }

  /// Переставляет категорию на шаг вверх или вниз среди соседей.
  ///
  /// Возвращает `false`, если двигать некуда — категория уже крайняя.
  /// Запасной путь к тому же, что делает перетаскивание: экранный диктор не
  /// перетаскивает, и клавиатурой это тоже должно быть доступно.
  Future<bool> reorder(String id, {required bool up}) async {
    final node = await byId(id);
    if (node == null) return false;

    final siblings = await siblingsOf(node);
    final index = siblings.indexWhere((c) => c.id == id);
    if (index < 0) return false;

    final target = up ? index - 1 : index + 1;
    if (target < 0 || target >= siblings.length) return false;

    final reordered = [...siblings];
    reordered.insert(target, reordered.removeAt(index));
    await reorderSiblings([for (final c in reordered) c.id]);
    return true;
  }

  /// Номер, с которым новая категория встанет последней среди соседей.
  Future<int> _nextSortOrder(String profileId, String? parentId) async {
    final q = db.select(db.categories)
      ..where(
        (c) => parentId == null
            ? c.profileId.equals(profileId) & c.parentId.isNull()
            : c.parentId.equals(parentId),
      )
      ..orderBy([
        (c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.desc),
      ])
      ..limit(1);
    final last = await q.get();
    return last.isEmpty ? 0 : last.first.sortOrder + 1;
  }

  /// Все потомки категории (по префиксу материализованного пути), без самой
  /// категории.
  Future<List<CategoryRow>> descendants(CategoryRow node) {
    return (db.select(
      db.categories,
    )..where((c) => c.path.like('${node.path}$_sep%'))).get();
  }

  /// Предки категории в порядке от корня к родителю (по сегментам пути).
  Future<List<CategoryRow>> ancestors(CategoryRow node) async {
    final ids = node.path.split(_sep);
    ids.removeLast(); // убираем собственный id
    if (ids.isEmpty) return [];
    final rows = await (db.select(
      db.categories,
    )..where((c) => c.id.isIn(ids))).get();
    final byIdMap = {for (final r in rows) r.id: r};
    return [
      for (final id in ids)
        if (byIdMap[id] != null) byIdMap[id]!,
    ];
  }

  /// Хлебные крошки: предки + сама категория (§7.6).
  Future<List<CategoryRow>> breadcrumb(String id) async {
    final node = await byId(id);
    if (node == null) return [];
    final anc = await ancestors(node);
    return [...anc, node];
  }

  /// Перемещает категорию в нового родителя (или в корень при null).
  /// Проверяет циклы и пересчитывает path/level поддерева в транзакции.
  Future<void> move(String id, String? newParentId) =>
      db.transaction(() => _moveWithin(id, newParentId));

  /// Перемещает ветку и, если задан [index], ставит её на нужное место среди
  /// новых соседей.
  ///
  /// Бросок «между двумя соседями» — это одно действие, а не перемещение и
  /// перестановка по очереди: в середине такой пары дерево на кадр оказалось
  /// бы не там, куда его положили.
  Future<void> moveTo(String id, {String? newParentId, int? index}) {
    return db.transaction(() async {
      await _moveWithin(id, newParentId);
      if (index == null) return;

      final siblings = await _siblingsOfParent(id, newParentId);
      final ordered = [for (final c in siblings) c.id]..remove(id);
      ordered.insert(index.clamp(0, ordered.length), id);
      await reorderSiblings(ordered);
    });
  }

  /// Переносит несколько веток разом.
  ///
  /// Потомки перемещаемых узлов из списка выбрасываются: ветка едет целиком,
  /// и двигать её содержимое отдельно значило бы вынуть его из-под родителя.
  /// Возвращает, сколько веток реально переехало.
  Future<int> moveMany(List<String> ids, String? newParentId) async {
    if (ids.isEmpty) return 0;
    return db.transaction(() async {
      final nodes = await (db.select(
        db.categories,
      )..where((c) => c.id.isIn(ids))).get();

      // Сначала верхние: перемещение родителя уже уносит с собой детей.
      nodes.sort((a, b) => a.level.compareTo(b.level));
      final moved = <CategoryRow>[];
      for (final node in nodes) {
        final insideAlreadyMoved = moved.any(
          (m) => node.path.startsWith('${m.path}$_sep'),
        );
        if (insideAlreadyMoved) continue;
        await _moveWithin(node.id, newParentId);
        moved.add(node);
      }
      return moved.length;
    });
  }

  /// Общая часть перемещения. Своей транзакции не открывает: её заводит тот,
  /// кто зовёт, — иначе слияние получилось бы набором отдельных действий,
  /// каждое из которых могло бы уцелеть без остальных.
  Future<void> _moveWithin(String id, String? newParentId) async {
    final node = await byId(id);
    if (node == null) {
      throw CategoryTreeException('Категория не найдена');
    }
    if (newParentId == id) {
      throw CategoryTreeException('Категория не может быть своим родителем');
    }
    if (node.parentId == newParentId) return;

    CategoryRow? newParent;
    if (newParentId != null) {
      newParent = await byId(newParentId);
      if (newParent == null) {
        throw CategoryTreeException('Новый родитель не найден');
      }
      if (newParent.profileId != node.profileId) {
        throw CategoryTreeException('Родитель из другого профиля');
      }
      // Запрет перемещения родителя внутрь своего потомка (защита от циклов).
      if (newParent.path == node.path ||
          newParent.path.startsWith('${node.path}$_sep')) {
        throw CategoryTreeException(
          'Нельзя переместить категорию внутрь её потомка',
        );
      }
    }

    final oldPath = node.path;
    final newLevel = newParent == null ? 0 : newParent.level + 1;
    final newPath = newParent == null
        ? node.id
        : '${newParent.path}$_sep${node.id}';
    final levelDelta = newLevel - node.level;

    if (newLevel + await _subtreeHeight(node) >
        AppConfig.hardMaxCategoryDepth) {
      throw CategoryTreeException('Превышена максимальная глубина вложенности');
    }

    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        parentId: newParentId == null ? const Value(null) : Value(newParentId),
        path: Value(newPath),
        level: Value(newLevel),
        sortOrder: Value(await _nextSortOrder(node.profileId, newParentId)),
      ),
    );

    // Потомки — одним запросом: замена префикса пути и сдвиг уровня. Раньше
    // здесь был `SELECT` и `UPDATE` на каждого, то есть на ветке в триста
    // узлов — триста с лишним обращений к базе на одно перетаскивание.
    // Экранировать `LIKE` не нужно: идентификаторы — UUID, ни «%», ни «_» в
    // них не бывает.
    await db.customUpdate(
      'UPDATE categories SET path = ?1 || substr(path, ?2), '
      'level = level + ?3 WHERE path LIKE ?4',
      variables: [
        Variable<String>(newPath),
        // substr считает с единицы: остаток пути начинается с «/».
        Variable<int>(oldPath.length + 1),
        Variable<int>(levelDelta),
        Variable<String>('$oldPath$_sep%'),
      ],
      updates: {db.categories},
    );
  }

  /// Насколько глубоко уходит поддерево — 0 у листа.
  ///
  /// Считается до перемещения: под новым родителем ветка не должна пробить
  /// предел глубины не только собой, но и своим содержимым.
  Future<int> _subtreeHeight(CategoryRow node) async {
    final deepest = db.categories.level.max();
    final row =
        await (db.selectOnly(db.categories)
              ..addColumns([deepest])
              ..where(db.categories.path.like('${node.path}$_sep%')))
            .getSingle();
    final max = row.read(deepest);
    return max == null ? 0 : max - node.level;
  }

  /// Соседи по новому родителю — уже после перемещения.
  Future<List<CategoryRow>> _siblingsOfParent(
    String id,
    String? parentId,
  ) async {
    if (parentId != null) return children(parentId, includeArchived: true);
    final node = await byId(id);
    return node == null
        ? const []
        : roots(node.profileId, includeArchived: true);
  }

  /// Архивирует категорию вместе с поддеревом (§24). Записи не теряются.
  Future<void> archive(String id) async {
    final node = await byId(id);
    if (node == null) return;
    final now = DateTime.now();
    await (db.update(db.categories)
          ..where((c) => c.id.equals(id) | c.path.like('${node.path}$_sep%')))
        .write(CategoriesCompanion(archivedAt: Value(now)));
  }

  /// Возвращает ветку из архива (§24).
  ///
  /// Симметрично [archive]: раз архивирование опускает всё поддерево, то и
  /// возвращать надо его же. Предки поднимаются вместе с ней — иначе
  /// восстановленная ветка осталась бы висеть под архивным родителем и её
  /// нигде не было бы видно.
  Future<void> restore(String id, {bool withSubtree = true}) async {
    final node = await byId(id);
    if (node == null) return;

    final ancestorIds = CategoryTree.pathIds(node.path);
    await (db.update(db.categories)..where((c) {
          final self = c.id.isIn(ancestorIds);
          return withSubtree ? self | c.path.like('${node.path}$_sep%') : self;
        }))
        .write(const CategoriesCompanion(archivedAt: Value(null)));
  }

  /// Сводит одну ветку в другую (§7.1).
  ///
  /// Записи и подкатегории переезжают в выбранную категорию, а исходная уходит
  /// в архив — не исчезает: её видно в архиве, и оттуда её можно убрать
  /// насовсем. Отменить одним нажатием это нельзя, поэтому спрашивать надо до,
  /// а не предлагать «Вернуть» после.
  Future<CategoryMergeResult> merge({
    required String sourceId,
    required String targetId,
  }) {
    return db.transaction(() async {
      final source = await byId(sourceId);
      final target = await byId(targetId);
      if (source == null || target == null) {
        throw CategoryTreeException('Категория не найдена');
      }
      if (sourceId == targetId) {
        throw CategoryTreeException('Нельзя объединить категорию с ней самой');
      }
      if (source.profileId != target.profileId) {
        throw CategoryTreeException('Категории из разных профилей');
      }
      if (target.path.startsWith('${source.path}$_sep')) {
        throw CategoryTreeException(
          'Нельзя объединить категорию с её подкатегорией',
        );
      }

      // Дети переезжают целиком — каждый тянет своё поддерево.
      final kids = await children(sourceId, includeArchived: true);
      for (final kid in kids) {
        await _moveWithin(kid.id, targetId);
      }

      final movedEntries = await _moveEntryLinks(sourceId, targetId);
      await archive(sourceId);

      return CategoryMergeResult(
        movedEntries: movedEntries,
        movedChildren: kids.length,
      );
    });
  }

  /// Переводит связи записей с одной категории на другую.
  ///
  /// Прямым `UPDATE ... SET category_id` этого не сделать: у записи, лежащей
  /// в обеих категориях, столкнётся первичный ключ (entry_id, category_id), а
  /// у записи с двумя основными — уникальный индекс на основную категорию.
  /// Поэтому совпавшие разбираем поимённо, а остальные переводим пачкой.
  Future<int> _moveEntryLinks(String sourceId, String targetId) async {
    final fromSource = await (db.select(
      db.entryCategories,
    )..where((l) => l.categoryId.equals(sourceId))).get();
    if (fromSource.isEmpty) return 0;

    final entryIds = [for (final l in fromSource) l.entryId];
    final atTarget = {
      for (final chunk in chunked(entryIds))
        for (final l
            in await (db.select(db.entryCategories)..where(
                  (l) => l.categoryId.equals(targetId) & l.entryId.isIn(chunk),
                ))
                .get())
          l.entryId: l,
    };

    final toRelink = <String>[];
    for (final link in fromSource) {
      final existing = atTarget[link.entryId];
      if (existing == null) {
        toRelink.add(link.entryId);
        continue;
      }
      // Запись уже лежит в цели. Сначала убираем исходную связь и только
      // потом поднимаем целевую: на записи может быть лишь одна основная
      // категория, и в промежутке их оказалось бы две.
      await (db.delete(db.entryCategories)..where(
            (l) =>
                l.entryId.equals(link.entryId) & l.categoryId.equals(sourceId),
          ))
          .go();
      // Если основной была связь с исходной категорией, основной становится
      // связь с целевой — иначе запись осталась бы без основной вовсе.
      if (link.isPrimary && !existing.isPrimary) {
        await (db.update(db.entryCategories)..where(
              (l) =>
                  l.entryId.equals(link.entryId) &
                  l.categoryId.equals(targetId),
            ))
            .write(const EntryCategoriesCompanion(isPrimary: Value(true)));
      }
    }

    for (final chunk in chunked(toRelink)) {
      await (db.update(db.entryCategories)..where(
            (l) => l.categoryId.equals(sourceId) & l.entryId.isIn(chunk),
          ))
          .write(EntryCategoriesCompanion(categoryId: Value(targetId)));
    }
    return fromSource.length;
  }

  /// Количество записей в категории или во всей ветке (§7.5).
  Future<int> countEntriesInBranch(
    String categoryId, {
    bool includeSubcategories = true,
  }) async {
    final node = await byId(categoryId);
    if (node == null) return 0;

    final Iterable<String> categoryIds;
    if (includeSubcategories) {
      final descs = await descendants(node);
      categoryIds = [node.id, ...descs.map((d) => d.id)];
    } else {
      categoryIds = [node.id];
    }

    final countExpr = db.entryCategories.entryId.count(distinct: true);
    final query = db.selectOnly(db.entryCategories)
      ..addColumns([countExpr])
      ..where(db.entryCategories.categoryId.isIn(categoryIds.toList()));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
