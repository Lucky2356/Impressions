import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/settings_repository.dart';
import 'app_state.dart';

/// Режим темы приложения: системная / светлая / тёмная (§3.2).
/// Сохраняется в таблице настроек и восстанавливается при запуске.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Значение подгружается асинхронно: до этого показывается системная тема.
    _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final raw = await ref
        .read(settingsRepositoryProvider)
        .get(SettingKeys.themeMode);
    final restored = ThemeMode.values.where((m) => m.name == raw).firstOrNull;
    if (restored != null) state = restored;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.themeMode, mode.name);
  }

  Future<void> toggle() =>
      set(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
