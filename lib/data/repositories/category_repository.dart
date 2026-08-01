import 'package:drift/drift.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/normalize.dart';
import '../db/database.dart';

/// Ошибка недопустимой операции с деревом категорий (§7.1).
class CategoryTreeException implements Exception {
  CategoryTreeException(this.message);
  final String message;
  @override
  String toString() => 'CategoryTreeException: $message';
}

/// Репозиторий категорий. Реализует дерево на adjacency list + materialized
/// path (см. DATA_MODEL.md §3, CATEGORY_SYSTEM.md).
class CategoryRepository {
  CategoryRepository(this.db);
  final AppDatabase db;

  static const String _sep = '/';

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

  /// Обновляет оформление категории (иконка, цвет, описание, порядок).
  Future<void> updateAppearance(
    String id, {
    String? icon,
    int? color,
    String? description,
    int? sortOrder,
  }) async {
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        icon: icon == null ? const Value.absent() : Value(icon),
        color: color == null ? const Value.absent() : Value(color),
        description: description == null
            ? const Value.absent()
            : Value(description),
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

  /// Соседи категории — то, среди чего её можно двигать.
  Future<List<CategoryRow>> siblingsOf(CategoryRow node) {
    return node.parentId == null
        ? roots(node.profileId)
        : children(node.parentId!);
  }

  /// Переставляет категорию на шаг вверх или вниз среди соседей.
  ///
  /// Возвращает `false`, если двигать некуда — категория уже крайняя.
  ///
  /// Порядок перенумеровывается целиком, а не меняется местами у двух: до
  /// 1.11.0 `sortOrder` никто не выставлял, у всех стоял ноль, и обмен нулями
  /// не сдвинул бы ничего.
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

    await db.transaction(() async {
      for (var i = 0; i < reordered.length; i++) {
        await (db.update(db.categories)
              ..where((c) => c.id.equals(reordered[i].id)))
            .write(CategoriesCompanion(sortOrder: Value(i)));
      }
    });
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
  Future<void> move(String id, String? newParentId) async {
    await db.transaction(() async {
      final node = await byId(id);
      if (node == null) {
        throw CategoryTreeException('Категория не найдена');
      }
      if (newParentId == id) {
        throw CategoryTreeException('Категория не может быть своим родителем');
      }

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
      final oldLevel = node.level;
      final newLevel = newParent == null ? 0 : newParent.level + 1;
      final newPath = newParent == null
          ? node.id
          : '${newParent.path}$_sep${node.id}';
      final levelDelta = newLevel - oldLevel;

      if (newLevel > AppConfig.hardMaxCategoryDepth) {
        throw CategoryTreeException(
          'Превышена максимальная глубина вложенности',
        );
      }

      // Обновляем сам узел.
      await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          parentId: newParentId == null
              ? const Value(null)
              : Value(newParentId),
          path: Value(newPath),
          level: Value(newLevel),
        ),
      );

      // Обновляем потомков: заменяем префикс пути и сдвигаем уровень.
      final descs = await (db.select(
        db.categories,
      )..where((c) => c.path.like('$oldPath$_sep%'))).get();
      for (final d in descs) {
        final rest = d.path.substring(oldPath.length); // начинается с «/»
        await (db.update(db.categories)..where((c) => c.id.equals(d.id))).write(
          CategoriesCompanion(
            path: Value('$newPath$rest'),
            level: Value(d.level + levelDelta),
          ),
        );
      }
    });
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

  /// Восстанавливает категорию (§24). Родитель должен быть не архивным.
  Future<void> restore(String id) async {
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      const CategoriesCompanion(archivedAt: Value(null)),
    );
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
