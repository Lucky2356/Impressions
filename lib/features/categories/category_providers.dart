import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';

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
final categoryBranchCountsProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final direct = await ref.watch(categoryDirectCountsProvider.future);
  final cats = await ref.watch(allCategoriesProvider.future);
  final result = <String, int>{};
  for (final cat in cats) {
    var total = direct[cat.id] ?? 0;
    final prefix = '${cat.path}/';
    for (final other in cats) {
      if (other.path.startsWith(prefix)) {
        total += direct[other.id] ?? 0;
      }
    }
    result[cat.id] = total;
  }
  return result;
});

/// Сортировка по дереву: сравниваем последовательности sortOrder предков.
List<CategoryRow> _sortByTreeOrder(List<CategoryRow> rows) {
  final byId = {for (final r in rows) r.id: r};
  List<int> key(CategoryRow row) {
    final result = <int>[];
    for (final id in row.path.split('/')) {
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
