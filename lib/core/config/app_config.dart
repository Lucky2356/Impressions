/// Централизованная конфигурация приложения.
///
/// Рабочее название временное. Меняется ТОЛЬКО здесь — по всему проекту
/// имя приложения и расширение файла профиля берутся из этого класса,
/// а не хардкодятся в виджетах (требование §0 и §19 спецификации).
class AppConfig {
  const AppConfig._();

  /// Отображаемое имя приложения. Временное рабочее название.
  static const String appName = 'Впечатления';

  /// Внутренний технический идентификатор приложения.
  static const String appId = 'impressions';

  /// Расширение файла профиля (без точки). Используется при экспорте/импорте.
  static const String profileFileExtension = 'impressions';

  /// Полное расширение с точкой — для диалогов выбора файла.
  static String get profileFileExtensionDotted => '.$profileFileExtension';

  /// Версия формата контейнера профиля. Повышается при несовместимых
  /// изменениях структуры экспортного файла.
  static const int exportFormatVersion = 1;

  /// Версия схемы данных приложения (payload внутри revisions).
  static const int payloadVersion = 1;

  // ---- Лимиты безопасного импорта (§21) ----

  /// Максимальный размер файла пакета, байт (1 ГБ).
  static const int maxPackageBytes = 1024 * 1024 * 1024;

  /// Максимальный размер одного вложения, байт (30 МБ).
  static const int maxAttachmentBytes = 30 * 1024 * 1024;

  /// Максимальный размер после распаковки, байт (2 ГБ).
  static const int maxUnpackedBytes = 2 * 1024 * 1024 * 1024;

  static const int maxEntries = 20000;
  static const int maxRevisions = 50000;
  static const int maxAttachments = 20000;

  /// Максимальная глубина вложенности категорий по умолчанию.
  static const int defaultMaxCategoryDepth = 10;

  /// Технический максимум глубины вложенности категорий.
  static const int hardMaxCategoryDepth = 20;

  /// Сколько последних автоматических резервных копий хранить (§28).
  static const int autoBackupRetention = 7;

  /// Максимальное количество импортируемых профилей (§0, §29).
  static const int maxProfiles = 10;

  // ---- Обновления ----
  // Единственные адреса, к которым приложение обращается само, и только когда
  // проверка обновлений включена в настройках.

  /// Репозиторий проекта.
  static const String repositoryUrl =
      'https://github.com/Lucky2356/Impressions';

  /// Страница выпусков для человека.
  static const String releasesPageUrl = '$repositoryUrl/releases';

  /// Последний выпуск в машиночитаемом виде.
  static const String releasesApiUrl =
      'https://api.github.com/repos/Lucky2356/Impressions/releases/latest';
}
