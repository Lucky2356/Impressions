import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/repositories/settings_repository.dart';

/// Недавние запросы и недавно открытые записи.
///
/// Истории не было ни у поиска, ни у карточек: закрыли запись — ищи её снова,
/// а часто повторяемый запрос набирали каждый раз заново.
class RecentStore extends AsyncNotifier<RecentData> {
  /// Сколько помним. Больше десятка — уже не «недавнее», а свалка.
  static const limit = 10;

  @override
  Future<RecentData> build() async {
    ref.watch(dataRefreshProvider);
    final settings = ref.read(settingsRepositoryProvider);
    return RecentData(
      searches: parse(await settings.get(SettingKeys.recentSearches)),
      entryIds: parse(await settings.get(SettingKeys.recentEntries)),
    );
  }

  /// Разбирает список строк. Мусор — это пустая история, а не ошибка запуска.
  static List<String> parse(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final json = jsonDecode(raw);
      if (json is! List) return const [];
      return [
        for (final item in json)
          if (item is String && item.isNotEmpty) item,
      ];
    } on FormatException {
      return const [];
    }
  }

  /// Кладёт значение первым, убирая его прежнее вхождение.
  static List<String> push(List<String> current, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return current;
    final next = [trimmed, ...current.where((v) => v != trimmed)];
    return next.length <= limit ? next : next.sublist(0, limit);
  }

  Future<void> rememberSearch(String query) async {
    final data = state.value ?? const RecentData();
    final next = push(data.searches, query);
    if (next.length == data.searches.length &&
        next.isNotEmpty &&
        data.searches.isNotEmpty &&
        next.first == data.searches.first) {
      return;
    }
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.recentSearches, jsonEncode(next));
    state = AsyncData(data.copyWith(searches: next));
  }

  Future<void> rememberEntry(String entryId) async {
    final data = state.value ?? const RecentData();
    final next = push(data.entryIds, entryId);
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.recentEntries, jsonEncode(next));
    state = AsyncData(data.copyWith(entryIds: next));
  }

  Future<void> clear() async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.set(SettingKeys.recentSearches, '');
    await settings.set(SettingKeys.recentEntries, '');
    state = const AsyncData(RecentData());
  }
}

/// Недавнее: запросы и записи.
class RecentData {
  const RecentData({this.searches = const [], this.entryIds = const []});

  final List<String> searches;
  final List<String> entryIds;

  RecentData copyWith({List<String>? searches, List<String>? entryIds}) =>
      RecentData(
        searches: searches ?? this.searches,
        entryIds: entryIds ?? this.entryIds,
      );
}

final recentStoreProvider = AsyncNotifierProvider<RecentStore, RecentData>(
  RecentStore.new,
);
