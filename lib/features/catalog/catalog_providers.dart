import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/models/category_tree.dart';
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

  /// Отбор в виде, пригодном для сохранения.
  ///
  /// Живёт в модели, а не в контроллере: тот же вид используют и сохранённые
  /// отборы, и восстановление после перезапуска.
  Map<String, Object?> toJson() => {
    'typeId': typeId,
    'categoryId': categoryId,
    'includeSubcategories': includeSubcategories,
    'relation': relation,
    'tagIds': tagIds,
    'sort': sort.name,
    'reverseSort': reverseSort,
    'withoutRating': withoutRating,
    'withoutCategory': withoutCategory,
    'withoutPhoto': withoutPhoto,
    'recommendedOnly': recommendedOnly,
  };

  /// Восстанавливает отбор поверх [base]: вид отображения и прочее, чего в
  /// записи нет, остаётся прежним.
  static CatalogState fromJson(Map<String, Object?> json, CatalogState base) {
    String? text(String key) {
      final value = json[key];
      return value is String && value.isNotEmpty ? value : null;
    }

    return base.copyWith(
      typeId: text('typeId'),
      categoryId: text('categoryId'),
      includeSubcategories:
          json['includeSubcategories'] as bool? ?? base.includeSubcategories,
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
          restored = CatalogState.fromJson(json, restored);
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

  /// Сохраняет отбор, чтобы он пережил перезапуск.
  Future<void> _persist() async {
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.catalogFilters, jsonEncode(state.toJson()));
  }

  /// Ставит отбор целиком — из сохранённого набора.
  void apply(CatalogState filters) {
    state = filters.copyWith(view: state.view, search: '');
    _persist();
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

/// Показанные страницы каталога.
///
/// База отдаёт ровно показанную страницу и число «сколько всего подходит».
/// Раньше сюда поднимался список идентификаторов всего найденного — на каждую
/// букву в поиске и каждое переключение фильтра, при том что нужны из него
/// были только длина и первые шестьдесят строк.
///
/// Подгрузка при этом растила предел: чтобы показать шестисотую запись,
/// каталог просил у базы первые шестьсот — и так на каждый шаг прокрутки.
/// Пролистать профиль в пять тысяч записей стоило двухсот тысяч прочитанных
/// строк вместо пяти. Теперь шаг просит только свою страницу, а показанное
/// накапливается здесь.
class CatalogFeed extends AsyncNotifier<CatalogResults> {
  /// Условия, под которые набран нынешний список.
  ///
  /// Смена фильтров начинает список заново, а обновление данных — нет: иначе
  /// правка записи сбрасывала бы каталог в начало прямо под рукой у человека.
  CatalogState? _shownFor;

  /// Сколько записей показано — столько же перечитываем при обновлении данных.
  int _depth = catalogPageSize;

  bool _loadingMore = false;

  @override
  Future<CatalogResults> build() {
    ref.watch(dataRefreshProvider);
    ref.watch(activeProfileProvider);
    // Ветка категорий считается по дереву: его изменение меняет и отбор.
    ref.watch(allCategoriesProvider);

    final s = ref.watch(catalogStateProvider);
    if (!identical(s, _shownFor)) {
      _shownFor = s;
      _depth = catalogPageSize;
    }
    return _window(limit: _depth, offset: 0);
  }

  Future<CatalogResults> _window({
    required int limit,
    required int offset,
  }) async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return const CatalogResults(items: [], total: 0);

    final s = ref.read(catalogStateProvider);
    final page = await ref
        .read(entryRepositoryProvider)
        .entryPage(
          profile.id,
          categoryIds: await _categoryScope(ref, s),
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
          limit: limit,
          offset: offset,
        );
    return CatalogResults(items: page.items, total: page.total);
  }

  /// Подгружает следующую страницу и дописывает её к показанному.
  Future<void> more() async {
    final shown = state.value;
    if (shown == null || !shown.hasMore || _loadingMore) return;

    _loadingMore = true;
    try {
      final next = await _window(
        limit: catalogPageSize,
        offset: shown.items.length,
      );
      // Пока страница ехала, список мог смениться целиком — тогда дописывать
      // её некуда.
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

final catalogFeedProvider = AsyncNotifierProvider<CatalogFeed, CatalogResults>(
  CatalogFeed.new,
);

/// Видимая часть результатов вместе с общим числом.
///
/// Отдельно от [catalogFeedProvider], чтобы экранам и тестам было что читать и
/// чем подменять, не зная о том, как список набирается по страницам.
final catalogResultsProvider = FutureProvider<CatalogResults>(
  (ref) => ref.watch(catalogFeedProvider.future),
);

/// Категории, попадающие под отбор: сама выбранная и, если попрошено, ветка.
Future<List<String>?> _categoryScope(Ref ref, CatalogState s) async {
  final selectedId = s.categoryId;
  if (selectedId == null) return null;
  if (!s.includeSubcategories) return [selectedId];

  final branch = CategoryTree.branchIds(
    await ref.watch(allCategoriesProvider.future),
    selectedId,
  );
  // Категории может уже не быть — фильтр помнится между запусками. Отбор по
  // ней всё равно должен остаться отбором, а не сняться сам собой.
  return branch.isEmpty ? [selectedId] : branch;
}
