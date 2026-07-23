import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../categories/category_providers.dart';

/// Режим отображения каталога (§15).
enum CatalogViewMode { grid, compact, list }

/// Состояние каталога: фильтры, сортировка, режим. Сохраняется между запусками.
class CatalogState {
  const CatalogState({
    this.typeId,
    this.categoryId,
    this.includeSubcategories = true,
    this.tagIds = const [],
    this.relation,
    this.search = '',
    this.sort = EntrySort.recent,
    this.view = CatalogViewMode.grid,
  });

  final String? typeId;
  final String? categoryId;
  final bool includeSubcategories;

  /// Выбранные теги: запись подходит, если помечена хотя бы одним (§7.2).
  final List<String> tagIds;
  final String? relation;
  final String search;
  final EntrySort sort;
  final CatalogViewMode view;

  CatalogState copyWith({
    Object? typeId = _unset,
    Object? categoryId = _unset,
    bool? includeSubcategories,
    List<String>? tagIds,
    Object? relation = _unset,
    String? search,
    EntrySort? sort,
    CatalogViewMode? view,
  }) {
    return CatalogState(
      typeId: identical(typeId, _unset) ? this.typeId : typeId as String?,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      includeSubcategories: includeSubcategories ?? this.includeSubcategories,
      tagIds: tagIds ?? this.tagIds,
      relation: identical(relation, _unset)
          ? this.relation
          : relation as String?,
      search: search ?? this.search,
      sort: sort ?? this.sort,
      view: view ?? this.view,
    );
  }

  static const Object _unset = Object();
}

class CatalogController extends Notifier<CatalogState> {
  @override
  CatalogState build() {
    _restore();
    return const CatalogState();
  }

  /// Подтягивает сохранённые режим и переключатель подкатегорий (§15).
  Future<void> _restore() async {
    final settings = ref.read(settingsRepositoryProvider);
    final viewRaw = await settings.get(SettingKeys.catalogViewMode);
    final includeSub = await settings.getBool(
      SettingKeys.catalogIncludeSubcategories,
      defaultValue: true,
    );
    final view = CatalogViewMode.values
        .where((v) => v.name == viewRaw)
        .firstOrNull;
    state = state.copyWith(
      view: view ?? state.view,
      includeSubcategories: includeSub,
    );
  }

  void setType(String? id) => state = state.copyWith(typeId: id);
  void setRelation(String? r) => state = state.copyWith(relation: r);
  void setCategory(String? id) => state = state.copyWith(categoryId: id);

  /// Переключает тег в фильтре.
  void toggleTag(String tagId) {
    final next = [...state.tagIds];
    if (!next.remove(tagId)) next.add(tagId);
    state = state.copyWith(tagIds: next);
  }

  void setSearch(String q) => state = state.copyWith(search: q);
  void setSort(EntrySort s) => state = state.copyWith(sort: s);

  Future<void> setView(CatalogViewMode v) async {
    state = state.copyWith(view: v);
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.catalogViewMode, v.name);
  }

  Future<void> setIncludeSubcategories(bool value) async {
    state = state.copyWith(includeSubcategories: value);
    await ref
        .read(settingsRepositoryProvider)
        .setBool(SettingKeys.catalogIncludeSubcategories, value);
  }

  void reset() => state = CatalogState(view: state.view);
}

final catalogStateProvider = NotifierProvider<CatalogController, CatalogState>(
  CatalogController.new,
);

/// Результаты каталога с учётом фильтров и сортировки.
final catalogResultsProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  final s = ref.watch(catalogStateProvider);

  List<String>? categoryIds;
  if (s.categoryId != null) {
    if (s.includeSubcategories) {
      final all = await ref.watch(allCategoriesProvider.future);
      final selected = all.where((c) => c.id == s.categoryId).firstOrNull;
      if (selected != null) {
        final prefix = '${selected.path}/';
        categoryIds = [
          selected.id,
          ...all.where((c) => c.path.startsWith(prefix)).map((c) => c.id),
        ];
      } else {
        categoryIds = [s.categoryId!];
      }
    } else {
      categoryIds = [s.categoryId!];
    }
  }

  return ref
      .watch(entryRepositoryProvider)
      .entryViews(
        profile.id,
        categoryIds: categoryIds,
        tagIds: s.tagIds.isEmpty ? null : s.tagIds,
        relation: s.relation,
        typeId: s.typeId,
        search: s.search,
        sort: s.sort,
      );
});
