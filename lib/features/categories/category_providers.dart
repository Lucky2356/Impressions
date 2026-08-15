import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/db/database.dart';
import '../../data/models/category_tree.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/services/image_service.dart';
import '../catalog/catalog_providers.dart' show CatalogResults;

/// Ветка, открытая на экране категорий.
///
/// Общий для всего приложения, а не внутреннее состояние экрана: на категорию
/// нажимают и с главной. При этом фильтр каталога остаётся нетронутым — от
/// скрытой подстановки фильтра записи когда-то «пропадали» из каталога.
final selectedCategoryProvider = NotifierProvider<SelectedCategory, String?>(
  SelectedCategory.new,
);

class SelectedCategory extends Notifier<String?> {
  /// Откуда пришли: по этому следу «Назад» поднимается на уровень вверх, а не
  /// выбрасывает в корень с середины дерева.
  final _history = <String>[];

  @override
  String? build() => null;

  void select(String? id) {
    final current = state;
    if (current == id) return;
    if (current != null) _history.add(current);
    state = id;
  }

  /// Шаг назад. `false` — возвращаться уже некуда.
  bool back() {
    if (_history.isEmpty) {
      if (state == null) return false;
      state = null;
      return true;
    }
    state = _history.removeLast();
    return true;
  }

  /// Сбрасывает и выбор, и след — например при смене профиля.
  void clear() {
    _history.clear();
    state = null;
  }
}

/// Свёрнутые узлы дерева.
///
/// В провайдере, а не в состоянии экрана: разделы живут в `KeyedSubtree` и при
/// переключении уничтожаются вместе со своим `State`. Свёрнутое дерево
/// разворачивалось само, стоило сходить в каталог и обратно.
final collapsedCategoriesProvider =
    NotifierProvider<CollapsedCategories, Set<String>>(CollapsedCategories.new);

class CollapsedCategories extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
  }

  /// Разворачивает перечисленные узлы — например всех предков выбранной ветки.
  void expand(Iterable<String> ids) {
    final next = {...state}..removeAll(ids);
    if (next.length != state.length) state = next;
  }

  void expandAll() => state = const {};
  void collapseAll(Iterable<String> ids) => state = {...ids};
}

/// Выделенные в дереве ветки; `null` — режим выделения выключен.
///
/// Одно состояние, а не два провайдера «включён ли режим» и «что выбрано»:
/// иначе выключение режима и очистка выделения — две записи, которые однажды
/// разъедутся, и на экране останется панель «Выбрано 0».
///
/// До 1.17.0 массовый перенос делался пунктом «Перенести подкатегории…»: он
/// брал всех детей ветки целиком, и выбрать три ветки из семи было нечем.
class TreeSelection extends Notifier<Set<String>?> {
  @override
  Set<String>? build() => null;

  bool get active => state != null;

  void start() => state = const {};
  void stop() => state = null;

  void toggle(String id) {
    final next = {...?state};
    if (!next.remove(id)) next.add(id);
    state = next;
  }
}

final treeSelectionProvider = NotifierProvider<TreeSelection, Set<String>?>(
  TreeSelection.new,
);

/// Как показывать содержимое ветки: за что считать «здесь» и в каком порядке.
class CategoryBranchState {
  const CategoryBranchState({
    this.subtree = true,
    this.sort = EntrySort.recent,
    this.reverseSort = false,
  });

  /// Вся ветка или только записи, лежащие непосредственно в этой категории.
  final bool subtree;
  final EntrySort sort;
  final bool reverseSort;

  CategoryBranchState copyWith({
    bool? subtree,
    EntrySort? sort,
    bool? reverseSort,
  }) => CategoryBranchState(
    subtree: subtree ?? this.subtree,
    sort: sort ?? this.sort,
    reverseSort: reverseSort ?? this.reverseSort,
  );
}

final categoryBranchStateProvider =
    NotifierProvider<CategoryBranchView, CategoryBranchState>(
      CategoryBranchView.new,
    );

class CategoryBranchView extends Notifier<CategoryBranchState> {
  @override
  CategoryBranchState build() => const CategoryBranchState();

  void setSubtree(bool value) => state = state.copyWith(subtree: value);
  void setSort(EntrySort value) => state = state.copyWith(sort: value);
  void setReverse(bool value) => state = state.copyWith(reverseSort: value);
}

/// Все неархивные категории активного профиля, отсортированные так, чтобы
/// потомки шли сразу за родителем (сортировка по материализованному пути).
final allCategoriesProvider = FutureProvider<List<CategoryRow>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  final db = ref.watch(appDatabaseProvider);
  final rows =
      await (db.select(db.categories)
            ..where((c) => c.profileId.equals(profile.id))
            ..where((c) => c.archivedAt.isNull()))
          .get();
  return _sortByTreeOrder(rows);
});

/// Архивные категории активного профиля.
final archivedCategoriesProvider = FutureProvider<List<CategoryRow>>((
  ref,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.categories)
        ..where((c) => c.profileId.equals(profile.id))
        ..where((c) => c.archivedAt.isNotNull()))
      .get();
});

/// Количество записей по каждой категории (только непосредственно в ней).
final categoryDirectCountsProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const {};
  final db = ref.watch(appDatabaseProvider);
  final rows = await db
      .customSelect(
        'SELECT ec.category_id AS cid, COUNT(DISTINCT ec.entry_id) AS cnt '
        'FROM entry_categories ec '
        'JOIN profile_entries e ON e.id = ec.entry_id '
        'WHERE e.profile_id = ?1 AND e.archived_at IS NULL '
        'GROUP BY ec.category_id',
        variables: [Variable<String>(profile.id)],
        readsFrom: {db.entryCategories, db.profileEntries},
      )
      .get();
  return {for (final r in rows) r.read<String>('cid'): r.read<int>('cnt')};
});

/// Количество записей по ветке: сама категория плюс все её подкатегории (§7.5).
///
/// Считается за один проход: каждая категория добавляет свои записи себе и
/// всем предкам по материализованному пути. Прежний вариант для каждой
/// категории перебирал все остальные — на тысяче категорий это миллион
/// сравнений строк при каждом обновлении данных.
final categoryBranchCountsProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final direct = await ref.watch(categoryDirectCountsProvider.future);
  final cats = await ref.watch(allCategoriesProvider.future);

  final result = {for (final cat in cats) cat.id: 0};
  for (final cat in cats) {
    final own = direct[cat.id] ?? 0;
    if (own == 0) continue;
    // Путь содержит саму категорию и всех её предков.
    for (final ancestorId in CategoryTree.pathIds(cat.path)) {
      final current = result[ancestorId];
      if (current != null) result[ancestorId] = current + own;
    }
  }
  return result;
});

/// Сколько записей за раз просит страница ветки.
const int categoryPageSize = 60;

/// Записи ветки: показанная часть и сколько их всего.
///
/// Раньше страница ветки поднимала все записи разом, с обложками. На «Продукты»
/// в три тысячи записей это означало три тысячи строк ради первого экрана — и
/// заново на каждую правку любой из них.
final categoryFeedProvider =
    AsyncNotifierProvider<CategoryFeed, CatalogResults>(CategoryFeed.new);

class CategoryFeed extends AsyncNotifier<CatalogResults> {
  /// Под какие условия набран нынешний список.
  ///
  /// Обновление данных не сбрасывает набранную глубину: иначе правка записи
  /// возвращала бы человека в начало длинного списка прямо под рукой.
  ({String? id, CategoryBranchState view})? _shownFor;
  int _depth = categoryPageSize;
  bool _loadingMore = false;

  @override
  Future<CatalogResults> build() {
    ref.watch(dataRefreshProvider);
    ref.watch(activeProfileProvider);
    ref.watch(allCategoriesProvider);

    final key = (
      id: ref.watch(selectedCategoryProvider),
      view: ref.watch(categoryBranchStateProvider),
    );
    if (_shownFor?.id != key.id || !identical(_shownFor?.view, key.view)) {
      _shownFor = key;
      _depth = categoryPageSize;
    }
    return _window(limit: _depth, offset: 0);
  }

  Future<CatalogResults> _window({
    required int limit,
    required int offset,
  }) async {
    final profile = ref.read(activeProfileProvider);
    final categoryId = ref.read(selectedCategoryProvider);
    if (profile == null || categoryId == null) {
      return const CatalogResults(items: [], total: 0);
    }

    final view = ref.read(categoryBranchStateProvider);
    final all = await ref.read(allCategoriesProvider.future);
    final ids = view.subtree
        ? CategoryTree.branchIds(all, categoryId)
        : <String>[categoryId];
    if (ids.isEmpty) return const CatalogResults(items: [], total: 0);

    final page = await ref
        .read(entryRepositoryProvider)
        .entryPage(
          profile.id,
          categoryIds: ids,
          sort: view.sort,
          reverseSort: view.reverseSort,
          limit: limit,
          offset: offset,
        );
    return CatalogResults(items: page.items, total: page.total);
  }

  /// Подгружает следующую страницу.
  Future<void> more() async {
    if (_loadingMore) return;
    final shown = state.value;
    if (shown == null || !shown.hasMore) return;

    _loadingMore = true;
    try {
      final next = await _window(
        limit: categoryPageSize,
        offset: shown.items.length,
      );
      // Пока страница ехала, список мог смениться целиком.
      final now = state.value;
      if (now == null || now.items.length != shown.items.length) return;

      _depth = now.items.length + next.items.length;
      state = AsyncData(
        CatalogResults(items: [...now.items, ...next.items], total: next.total),
      );
    } finally {
      _loadingMore = false;
    }
  }
}

/// Видимая часть записей ветки вместе с общим числом.
///
/// Отдельно от [categoryFeedProvider] — по образцу каталога: экранам и тестам
/// есть что читать и чем подменять, не зная о том, как список набирается по
/// страницам.
final categoryBranchResultsProvider = FutureProvider<CatalogResults>(
  (ref) => ref.watch(categoryFeedProvider.future),
);

/// Сколько записей каждого типа лежит в ветке.
///
/// Отдельно от [categoryEntriesProvider]: подсказке нужен только перевес типа,
/// а тот поднимает всю ветку с обложками.
final branchTypeCountsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, categoryId) async {
      ref.watch(dataRefreshProvider);
      final profile = ref.watch(activeProfileProvider);
      if (profile == null) return const {};

      return ref
          .watch(entryRepositoryProvider)
          .typeCountsInCategories(
            profile.id,
            CategoryTree.branchIds(
              await ref.watch(allCategoriesProvider.future),
              categoryId,
            ),
          );
    });

/// Пути закреплённых обложек веток по идентификатору категории.
///
/// В базе у ветки лежит идентификатор вложения, а карточке нужен файл. Одним
/// запросом на всё дерево: спрашивать путь на каждую полку — это обращение к
/// базе на каждую карточку сетки.
final categoryCoverPathsProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final cats = await ref.watch(allCategoriesProvider.future);
  final byAttachment = {for (final c in cats) ?c.coverAttachmentId: c.id};
  if (byAttachment.isEmpty) return const {};

  final db = ref.watch(appDatabaseProvider);
  final rows = await (db.select(
    db.attachments,
  )..where((a) => a.id.isIn(byAttachment.keys))).get();
  final mediaDir = await ImageService(db).mediaDirectoryPath();
  return {
    for (final a in rows)
      ?byAttachment[a.id]: p.join(mediaDir, a.thumbPath ?? a.storagePath),
  };
});

/// По несколько обложек на категорию — для карточек-полок.
final categoryCoversProvider = FutureProvider<Map<String, List<String>>>((
  ref,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const {};
  return ref.watch(entryRepositoryProvider).categoryCovers(profile.id);
});

/// Сортировка по дереву: сравниваем последовательности sortOrder предков.
List<CategoryRow> _sortByTreeOrder(List<CategoryRow> rows) {
  final byId = CategoryTree.byId(rows);
  List<int> key(CategoryRow row) {
    final result = <int>[];
    for (final id in CategoryTree.pathIds(row.path)) {
      final node = byId[id];
      result.add(node?.sortOrder ?? 0);
    }
    return result;
  }

  final sorted = [...rows];
  sorted.sort((a, b) {
    final ka = key(a);
    final kb = key(b);
    for (var i = 0; i < ka.length && i < kb.length; i++) {
      final cmp = ka[i].compareTo(kb[i]);
      if (cmp != 0) return cmp;
    }
    final byDepth = ka.length.compareTo(kb.length);
    if (byDepth != 0) return byDepth;
    return a.name.compareTo(b.name);
  });
  return sorted;
}
