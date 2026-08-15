import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../data/repositories/settings_repository.dart';

/// Что закреплено на главной (§14).
///
/// Главная показывала корневые категории и недавнее — то есть то, что решило
/// приложение. Что человек ведёт прямо сейчас, оно знать не могло: ветка
/// «Сериалы › Смотрю с женой» и подборка «На выходные» лежали там же, где и
/// всё остальное.
///
/// Список идентификаторов в настройках, а не столбец в базе: закрепление —
/// свойство этого устройства, а не самой ветки. На телефоне и на компьютере
/// закреплено разное, и это правильно.
class PinnedIds extends AsyncNotifier<List<String>> {
  PinnedIds(this.settingKey);

  final String settingKey;

  @override
  Future<List<String>> build() async {
    return parse(await ref.read(settingsRepositoryProvider).get(settingKey));
  }

  /// Разбирает список из настроек. Мусор пропускается молча: испорченная
  /// запись не должна лишать человека остального закреплённого.
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

  bool contains(String id) => (state.value ?? const []).contains(id);

  /// Закрепляет или снимает — одно и то же действие в обе стороны.
  Future<void> toggle(String id) async {
    final next = [...(state.value ?? const <String>[])];
    if (!next.remove(id)) next.add(id);

    await ref
        .read(settingsRepositoryProvider)
        .set(settingKey, jsonEncode(next));
    state = AsyncData(next);
  }
}

final pinnedCategoryIdsProvider =
    AsyncNotifierProvider<PinnedIds, List<String>>(
      () => PinnedIds(SettingKeys.homePinnedCategories),
    );

final pinnedCollectionIdsProvider =
    AsyncNotifierProvider<PinnedIds, List<String>>(
      () => PinnedIds(SettingKeys.homePinnedCollections),
    );
