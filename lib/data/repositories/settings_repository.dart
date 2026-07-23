import '../db/database.dart';

/// Ключи настроек приложения.
class SettingKeys {
  const SettingKeys._();
  static const activeProfileId = 'active_profile_id';
  static const themeMode = 'theme_mode';
  static const catalogViewMode = 'catalog_view_mode';
  static const catalogIncludeSubcategories = 'catalog_include_subcategories';
  static const onboardingDone = 'onboarding_done';

  /// Режим переноса записей между профилями (§7.4).
  static const transferMode = 'transfer_mode';

  /// Идентификатор текущего устройства (§5.2).
  static const currentDeviceId = 'current_device_id';
}

/// Репозиторий настроек (таблица ключ-значение).
class SettingsRepository {
  SettingsRepository(this.db);
  final AppDatabase db;

  Future<String?> get(String key) async {
    final row = await (db.select(
      db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await db
        .into(db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final v = await get(key);
    if (v == null) return defaultValue;
    return v == 'true';
  }

  Future<void> setBool(String key, bool value) =>
      set(key, value ? 'true' : 'false');

  Stream<String?> watch(String key) {
    return (db.select(db.settings)..where((s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }
}
