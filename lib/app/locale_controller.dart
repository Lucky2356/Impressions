import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/gen/app_localizations.dart';
import '../data/repositories/settings_repository.dart';
import 'app_state.dart';

/// Язык интерфейса. `null` — тот, что стоит в системе.
///
/// Хранится рядом с темой, в той же таблице настроек: язык — такая же
/// настройка внешнего вида, а не свойство данных.
final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  /// Языки, на которых есть интерфейс.
  static List<Locale> get supported => AppLocalizations.supportedLocales;

  /// Разбирает сохранённое значение: пустое или незнакомое — язык системы.
  ///
  /// Незнакомое возможно после отката на прежнюю версию приложения, где такого
  /// перевода ещё нет: показать системный язык честнее, чем упасть.
  static Locale? parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return supported.where((l) => l.languageCode == raw).firstOrNull;
  }

  @override
  Locale? build() {
    // Значение читается асинхронно: до этого действует язык системы.
    _restore();
    return null;
  }

  Future<void> _restore() async {
    final raw = await ref
        .read(settingsRepositoryProvider)
        .get(SettingKeys.language);
    final restored = parse(raw);
    if (restored != null) state = restored;
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.language, locale?.languageCode ?? '');
  }
}
