import '../db/database.dart';

/// Ключи настроек приложения.
class SettingKeys {
  const SettingKeys._();
  static const activeProfileId = 'active_profile_id';
  static const themeMode = 'theme_mode';
  static const catalogViewMode = 'catalog_view_mode';
  static const catalogIncludeSubcategories = 'catalog_include_subcategories';

  /// Отбор каталога: тип, категория, отношение, теги, сортировка.
  static const catalogFilters = 'catalog_filters';

  /// Раздел, открытый в прошлый раз.
  static const lastSection = 'last_section';

  /// Куда клали в прошлый раз: подряд обычно заводят записи в одно место, а
  /// форма подставляла категорию только при входе из ветки.
  static const quickAddLastCategory = 'quick_add_last_category';
  static const quickAddLastType = 'quick_add_last_type';
  static const onboardingDone = 'onboarding_done';

  /// Обучение по разделам пройдено или пропущено.
  static const tourDone = 'tour_done';

  /// Версия, о новшествах которой уже рассказали.
  static const changelogSeenVersion = 'changelog_seen_version';

  /// Режим переноса записей между профилями (§7.4).
  static const transferMode = 'transfer_mode';

  /// Идентификатор текущего устройства (§5.2).
  static const currentDeviceId = 'current_device_id';

  // ---- Сетевые возможности ----
  // Всё, что обращается в сеть, выключается здесь и по умолчанию ограничено
  // явными действиями пользователя.

  /// Поиск сведений о товаре по отсканированному штрихкоду.
  static const barcodeLookupEnabled = 'barcode_lookup_enabled';

  /// Включённые источники товарных данных, через запятую.
  static const barcodeSources = 'barcode_sources';

  /// Фоновое обновление сведений о товарах с штрихкодом.
  static const productAutoUpdate = 'product_auto_update';

  /// Отметка времени последнего обновления товаров.
  static const productAutoUpdateAt = 'product_auto_update_at';

  /// Проверка новых версий приложения.
  static const appUpdateCheck = 'app_update_check';

  /// Последняя найденная версия приложения и ссылка на неё.
  static const appUpdateLatest = 'app_update_latest';
  static const appUpdateUrl = 'app_update_url';
  static const appUpdateCheckedAt = 'app_update_checked_at';

  /// Версия, о которой пользователь попросил больше не напоминать.
  static const appUpdateDismissed = 'app_update_dismissed';

  // ---- Резервные копии ----

  /// Новые копии шифруются.
  static const backupsEncrypted = 'backups_encrypted';

  /// Ключ копий, завёрнутый в пароль. Сам ключ здесь не хранится: база
  /// целиком попадает в копию, и ключ рядом с тем, что он защищает, ничего
  /// не защищает.
  static const backupKeyWrapped = 'backup_key_wrapped';

  /// Копия делается сама, по расписанию.
  static const autoBackupEnabled = 'auto_backup_enabled';

  /// Когда расписание сработало в прошлый раз.
  static const autoBackupAt = 'auto_backup_at';

  /// Папка, куда копия кладётся ещё и наружу: флешка, облачный клиент.
  ///
  /// Копии лежат рядом с базой, и потеря устройства уносит их вместе с ней.
  static const backupMirrorDir = 'backup_mirror_dir';
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
