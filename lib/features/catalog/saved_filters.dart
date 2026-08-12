import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/repositories/settings_repository.dart';
import 'catalog_providers.dart';

/// Названный отбор каталога.
class SavedFilter {
  const SavedFilter({required this.name, required this.filters});

  final String name;
  final CatalogState filters;

  Map<String, Object?> toJson() => {'name': name, 'filters': filters.toJson()};

  static SavedFilter? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final name = json['name'];
    final filters = json['filters'];
    if (name is! String || name.isEmpty || filters is! Map<String, Object?>) {
      return null;
    }
    return SavedFilter(
      name: name,
      filters: CatalogState.fromJson(filters, const CatalogState()),
    );
  }
}

/// Сохранённые отборы каталога.
///
/// Состояние каталога и так переживает перезапуск, но оно одно: «без оценки в
/// Продуктах» и «любимое за год» собирались заново каждый раз, хотя это те же
/// несколько переключателей.
class SavedFilters extends AsyncNotifier<List<SavedFilter>> {
  @override
  Future<List<SavedFilter>> build() async {
    ref.watch(dataRefreshProvider);
    final raw = await ref
        .read(settingsRepositoryProvider)
        .get(SettingKeys.catalogSavedFilters);
    return parse(raw);
  }

  /// Разбирает список из настроек. Мусор молча пропускается: испорченная
  /// запись не должна лишать человека остальных отборов.
  static List<SavedFilter> parse(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final json = jsonDecode(raw);
      if (json is! List) return const [];
      return [for (final item in json) ?SavedFilter.fromJson(item)];
    } on FormatException {
      return const [];
    }
  }

  Future<void> _write(List<SavedFilter> filters) async {
    await ref
        .read(settingsRepositoryProvider)
        .set(
          SettingKeys.catalogSavedFilters,
          jsonEncode([for (final f in filters) f.toJson()]),
        );
    state = AsyncData(filters);
  }

  /// Сохраняет текущий отбор под именем. Одноимённый заменяется — иначе список
  /// зарастал бы «Продукты», «Продукты (2)», «Продукты (3)».
  Future<void> save(String name, CatalogState filters) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final current = [...(state.value ?? const <SavedFilter>[])]
      ..removeWhere((f) => f.name.toLowerCase() == trimmed.toLowerCase());
    await _write([...current, SavedFilter(name: trimmed, filters: filters)]);
  }

  Future<void> remove(String name) async {
    final current = [...(state.value ?? const <SavedFilter>[])]
      ..removeWhere((f) => f.name == name);
    await _write(current);
  }
}

final savedFiltersProvider =
    AsyncNotifierProvider<SavedFilters, List<SavedFilter>>(SavedFilters.new);
