import 'dart:convert';

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
    this.reverseSort = false,
    this.withoutRating = false,
    this.withoutCategory = false,
    this.withoutPhoto = false,
    this.recommendedOnly = false,
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

  /// Порядок развёрнут: «худшие сначала», «Я → А», «самые старые».
  final bool reverseSort;

  /// «Что я не доделал»: без оценки, мимо категорий, без фотографии.
  final bool withoutRating;
  final bool withoutCategory;
  final bool withoutPhoto;

  /// Только записи, которые кто-то посоветовал.
  final bool recommendedOnly;

  final CatalogViewMode view;

  /// Включён ли хоть один отбор — от него зависит и подсказка про пустой
  /// список, и кнопка «Сбросить фильтры».
  bool get hasFilters =>
      search.isNotEmpty ||
      typeId != null ||
      relation != null ||
      categoryId != null ||
      tagIds.isNotEmpty ||
      withoutRating ||
      withoutCategory ||
      withoutPhoto ||
      recommendedOnly;

  CatalogState copyWith({
    Object? typeId = _unset,
    Object? categoryId = _unset,
    bool? includeSubcategories,
    List<String>? tagIds,
    Object? relation = _unset,
    String? search,
    EntrySort? sort,
    bool? reverseSort,
    bool? withoutRating,
    bool? withoutCategory,
    bool? withoutPhoto,
    bool? recommendedOnly,
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
      reverseSort: reverseSort ?? this.reverseSort,
      withoutRating: withoutRating ?? this.withoutRating,
      withoutCategory: withoutCategory ?? this.withoutCategory,
      withoutPhoto: withoutPhoto ?? this.withoutPhoto,
      recommendedOnly: recommendedOnly ?? this.recommendedOnly,
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

  /// Подтягивает сохранённые режим, фильтры и сортировку (§15).
  ///
  /// Сохранялись только режим отображения и переключатель подкатегорий: тип,
  /// категория, отношение и теги сбрасывались при каждом запуске, и человек,
  /// который ведёт одну ветку, каждый раз выставлял их заново.
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

    final filtersRaw = await settings.get(SettingKeys.catalogFilters);
    // Настройки могли дочитаться уже после того, как провайдер выбросили.
    if (!ref.mounted) return;
    var restored = state.copyWith(
      view: view ?? state.view,
      includeSubcategories: includeSub,
    );
    if (filtersRaw != null) {
      try {
        final json = jsonDecode(filtersRaw);
        if (json is Map<String, Object?>) {
          restored = _fromJson(json, restored);
        }
      } on FormatException {
        // Настройка записана прошлой версией — просто начинаем с чистых
        // фильтров, ронять запуск из-за этого нельзя.
      }
    }
    // Запрос в поиске не восстанавливаем: он приходит из строки в шапке и
    // сохранённым выглядел бы как «каталог сам себя отфильтровал».
    state = restored.copyWith(search: '');
  }

  CatalogState _fromJson(Map<String, Object?> json, CatalogState base) {
    String? text(String key) {
      final value = json[key];
      return value is String && value.isNotEmpty ? value : null;
    }

    return base.copyWith(
      typeId: text('typeId'),
      categoryId: text('categoryId'),
      relation: text('relation'),
      tagIds: switch (json['tagIds']) {
        final List<Object?> list => [
          for (final id in list)
            if (id is String) id,
        ],
        _ => const <String>[],
      },
      sort:
          EntrySort.values.where((s) => s.name == json['sort']).firstOrNull ??
          base.sort,
      reverseSort: json['reverseSort'] == true,
      withoutRating: json['withoutRating'] == true,
      withoutCategory: json['withoutCategory'] == true,
      withoutPhoto: json['withoutPhoto'] == true,
      recommendedOnly: json['recommendedOnly'] == true,
    );
  }

  /// Сохраняет отбор, чтобы он пережил перезапуск.
  Future<void> _persist() async {
    await ref
        .read(settingsRepositoryProvider)
        .set(
          SettingKeys.catalogFilters,
          jsonEncode({
            'typeId': state.typeId,
            'categoryId': state.categoryId,
            'relation': state.relation,
            'tagIds': state.tagIds,
            'sort': state.sort.name,
            'reverseSort': state.reverseSort,
            'withoutRating': state.withoutRating,
            'withoutCategory': state.withoutCategory,
            'withoutPhoto': state.withoutPhoto,
            'recommendedOnly': state.recommendedOnly,
          }),
        );
  }

  void setType(String? id) {
    state = state.copyWith(typeId: id);
    _persist();
  }

  void setRelation(String? r) {
    state = state.copyWith(relation: r);
    _persist();
  }

  void setCategory(String? id) {
    state = state.copyWith(categoryId: id);
    _persist();
  }

  /// Переключает тег в фильтре.
  void toggleTag(String tagId) {
    final next = [...state.tagIds];
    if (!next.remove(tagId)) next.add(tagId);
    state = state.copyWith(tagIds: next);
    _persist();
  }

  void setSearch(String q) => state = state.copyWith(search: q);

  void setSort(EntrySort s) {
    state = state.copyWith(sort: s);
    _persist();
  }

  /// Разворачивает порядок: «худшие сначала», «Я → А», «самые старые».
  void toggleSortDirection() {
    state = state.copyWith(reverseSort: !state.reverseSort);
    _persist();
  }

  void setWithoutRating(bool value) {
    state = state.copyWith(withoutRating: value);
    _persist();
  }

  void setWithoutCategory(bool value) {
    state = state.copyWith(withoutCategory: value);
    _persist();
  }

  void setRecommendedOnly(bool value) {
    state = state.copyWith(recommendedOnly: value);
    _persist();
  }

  void setWithoutPhoto(bool value) {
    state = state.copyWith(withoutPhoto: value);
    _persist();
  }

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

  void reset() {
    state = CatalogState(
      view: state.view,
      includeSubcategories: state.includeSubcategories,
    );
    _persist();
  }
}

final catalogStateProvider = NotifierProvider<CatalogController, CatalogState>(
  CatalogController.new,
);

/// Просьба поставить курсор в поле поиска каталога.
///
/// На телефоне поля поиска в шапке нет — там значок, который переводит в
/// каталог. Без этого человек попадал в каталог и должен был сам догадаться
/// нажать на поле. Считаем нажатия, а не храним признак: два обращения подряд
/// должны сработать оба.
class CatalogSearchFocus extends Notifier<int> {
  @override
  int build() => 0;

  void request() => state++;
}

final catalogSearchFocusProvider = NotifierProvider<CatalogSearchFocus, int>(
  CatalogSearchFocus.new,
);

/// Сколько записей подгружается за один шаг прокрутки.
///
/// Каталог рассчитан на десятки тысяч записей, а строил разом весь список:
/// при полном профиле это заметная задержка на каждом изменении фильтра.
const int catalogPageSize = 60;

/// Сколько записей каталог сейчас показывает.
///
/// Сбрасывается при любом изменении фильтров: иначе после смены условий
/// осталась бы «подгруженная» глубина от прошлого запроса.
class CatalogPage extends Notifier<int> {
  @override
  int build() {
    ref.listen(catalogStateProvider, (_, _) => state = catalogPageSize);
    return catalogPageSize;
  }

  void more() => state += catalogPageSize;
}

final catalogPageProvider = NotifierProvider<CatalogPage, int>(CatalogPage.new);

/// Что показывает каталог: подгруженная часть и сколько всего подходит.
///
/// Одним значением, а не двумя провайдерами: иначе счётчик в заголовке и
/// список могли разойтись — что и произошло, когда общее число считалось
/// отдельно от отображаемого среза.
class CatalogResults {
  const CatalogResults({required this.items, required this.total});

  /// Всё поместилось: показанное и есть весь результат.
  CatalogResults.of(this.items) : total = items.length;

  final List<EntryView> items;

  /// Сколько записей подходит под фильтры целиком.
  final int total;

  bool get hasMore => items.length < total;
}

/// Видимая часть результатов вместе с общим числом.
///
/// Сначала берутся только идентификаторы всего найденного — по ним считается
/// «сколько всего» и отрезается страница. Карточки собираются лишь для этой
/// страницы: обложки и пути категорий — самая дорогая часть выборки, и делать
/// их для всего профиля на каждую букву в поиске незачем.
final catalogResultsProvider = FutureProvider<CatalogResults>((ref) async {
  final all = await ref.watch(catalogMatchingIdsProvider.future);
  final limit = ref.watch(catalogPageProvider);
  if (all.isEmpty) return const CatalogResults(items: [], total: 0);

  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const CatalogResults(items: [], total: 0);

  final pageIds = all.length <= limit ? all : all.sublist(0, limit);
  final items = await ref
      .watch(entryRepositoryProvider)
      .entryViews(
        profile.id,
        entryIds: pageIds,
        sort: ref.watch(catalogStateProvider).sort,
        reverseSort: ref.watch(catalogStateProvider).reverseSort,
      );
  return CatalogResults(items: items, total: all.length);
});

/// Идентификаторы всего, что подходит под текущие фильтры.
final catalogMatchingIdsProvider = FutureProvider<List<String>>((ref) async {
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
      .matchingEntryIds(
        profile.id,
        categoryIds: categoryIds,
        tagIds: s.tagIds.isEmpty ? null : s.tagIds,
        relation: s.relation,
        typeId: s.typeId,
        search: s.search,
        sort: s.sort,
        reverseSort: s.reverseSort,
        withoutRating: s.withoutRating,
        withoutCategory: s.withoutCategory,
        withoutPhoto: s.withoutPhoto,
        recommendedOnly: s.recommendedOnly,
      );
});
