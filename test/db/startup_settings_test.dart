import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/app/locale_controller.dart';
import 'package:impressions/app/navigation.dart';
import 'package:impressions/app/theme_controller.dart';
import 'package:impressions/app/ui_scale_controller.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/settings_repository.dart';

import 'query_counter.dart';

/// Настройки запуска читаются одним запросом.
///
/// Тема, язык, масштаб, последний раздел и активный профиль восстанавливались
/// каждый своим `get` — пять обращений к базе на первом кадре, при том что
/// `getAll` был написан ровно для такого случая.
void main() {
  late AppDatabase db;
  late QueryCounter counter;

  setUp(() => (db, counter) = openCountingDb());
  tearDown(() => db.close());

  /// Даём провайдерам дочитать: настройки они берут асинхронно.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  ProviderContainer start() {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('пять настроек запуска — один запрос к таблице', () async {
    final container = start();
    counter.reset();

    // Ровно то, что трогает интерфейс на первом кадре.
    container
      ..read(themeModeProvider)
      ..read(localeProvider)
      ..read(uiScaleProvider)
      ..read(navProvider)
      ..read(activeProfileIdProvider);
    await settle();

    expect(counter.matching('FROM "settings"'), 1);
  });

  test('сохранённые значения восстанавливаются все до одного', () async {
    final settings = SettingsRepository(db);
    await settings.set(SettingKeys.themeMode, ThemeMode.dark.name);
    await settings.set(SettingKeys.language, 'en');
    await settings.set(SettingKeys.uiScale, UiScale.s125.name);
    await settings.set(SettingKeys.lastSection, NavIds.catalog);
    await settings.set(SettingKeys.activeProfileId, 'p-42');

    final container = start();
    container
      ..read(themeModeProvider)
      ..read(localeProvider)
      ..read(uiScaleProvider)
      ..read(navProvider)
      ..read(activeProfileIdProvider);
    await settle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(localeProvider), const Locale('en'));
    expect(container.read(uiScaleProvider), UiScale.s125);
    expect(container.read(navProvider), NavIds.catalog);
    expect(container.read(activeProfileIdProvider).value, 'p-42');
  });
}
