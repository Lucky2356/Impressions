// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appNameFallback => 'Впечатления';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonSaveAndClose => 'Сохранить и закрыть';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonArchive => 'Архивировать';

  @override
  String get commonRestore => 'Восстановить';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonCreate => 'Создать';

  @override
  String get commonRename => 'Переименовать';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get commonImport => 'Импорт';

  @override
  String get commonExport => 'Экспорт';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonSkip => 'Пропустить';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get commonNothingFound => 'Ничего не найдено';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get navHome => 'Главная';

  @override
  String get navCatalog => 'Каталог';

  @override
  String get navCollections => 'Подборки';

  @override
  String get navCompare => 'Сравнение';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navProfiles => 'Профили';

  @override
  String get navImport => 'Импорт';

  @override
  String get navSectionMain => 'Разделы';

  @override
  String get navSectionProfiles => 'Профили и обмен';

  @override
  String get navSectionOther => 'Ещё';

  @override
  String get headerHelp => 'Помощь';

  @override
  String get headerSearchHint => 'Поиск по записям, категориям, профилям…';

  @override
  String get homeTitle => 'Главная';

  @override
  String get homeGreeting => 'С возвращением';

  @override
  String get statEntries => 'Записей';

  @override
  String get statCategories => 'Категорий';

  @override
  String get statProfiles => 'Профилей';

  @override
  String get statCollections => 'Подборок';

  @override
  String get statUnitPieces => 'шт.';

  @override
  String get sectionRecent => 'Недавние записи';

  @override
  String get sectionCollections => 'Подборки';

  @override
  String get sectionImpression => 'Последняя рекомендация';

  @override
  String get sectionWantToTry => 'Хочу попробовать';

  @override
  String get sectionShowAll => 'Показать все';

  @override
  String get collectionNew => 'Новая подборка';

  @override
  String get comingSoonTitle => 'Появится на следующих этапах';

  @override
  String get comingSoonMessage =>
      'Этот раздел будет реализован в ходе разработки основных функций.';

  @override
  String get quickAddTitle => 'Новая запись';

  @override
  String get quickAddNameLabel => 'Название';

  @override
  String get quickAddNameHint => 'Например: Папа может';

  @override
  String get quickAddNameRequired => 'Укажите название';

  @override
  String get quickAddTypeLabel => 'Тип';

  @override
  String get quickAddCategoryLabel => 'Категория';

  @override
  String get quickAddNoCategory => 'Без категории';

  @override
  String get quickAddRelationLabel => 'Отношение';

  @override
  String get quickAddDetails => 'Добавить подробности';

  @override
  String get quickAddRatingLabel => 'Оценка';

  @override
  String get quickAddRatingNone => 'Без оценки';

  @override
  String get quickAddNoteLabel => 'Заметка';

  @override
  String get quickAddSaved => 'Запись добавлена';

  @override
  String get quickAddPickCategory => 'Выбрать категорию';

  @override
  String get quickAddSearchCategory => 'Поиск категории';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get categoryAddRoot => 'Новая корневая категория';

  @override
  String get categoryAddChild => 'Добавить подкатегорию';

  @override
  String get categoryRename => 'Переименовать';

  @override
  String get categoryMove => 'Переместить';

  @override
  String get categoryArchive => 'Архивировать';

  @override
  String get categoryRestore => 'Восстановить';

  @override
  String get categoryNameLabel => 'Название категории';

  @override
  String get categoryMoveToRoot => 'В корень';

  @override
  String get categoryMoveTarget => 'Куда переместить';

  @override
  String get categoryArchiveConfirm =>
      'Архивировать категорию вместе с подкатегориями? Записи не будут удалены.';

  @override
  String get categoryEmptyTitle => 'Категорий пока нет';

  @override
  String get categoryEmptyMessage =>
      'Создайте первую категорию, чтобы раскладывать записи по полкам.';

  @override
  String categoryEntriesCount(int count) {
    return '$count зап.';
  }

  @override
  String get categoryShowSubcategories => 'Показывать записи из подкатегорий';

  @override
  String get catalogEmptyTitle => 'Записей пока нет';

  @override
  String get catalogEmptyMessage =>
      'Добавьте первую запись — это займёт несколько секунд.';

  @override
  String get catalogAllTypes => 'Все типы';

  @override
  String get catalogAllRelations => 'Все отношения';

  @override
  String get catalogAllCategories => 'Все категории';

  @override
  String get catalogSearchHint => 'Поиск по названию';

  @override
  String get catalogNothingFoundTitle => 'Ничего не найдено';

  @override
  String get catalogNothingFoundMessage =>
      'Попробуйте изменить фильтры или поисковый запрос.';

  @override
  String get catalogResetFilters => 'Сбросить фильтры';

  @override
  String get catalogViewGrid => 'Крупная сетка';

  @override
  String get catalogViewCompact => 'Компактная сетка';

  @override
  String get catalogViewList => 'Список';

  @override
  String get catalogSortRecent => 'Недавно добавленные';

  @override
  String get catalogSortTitle => 'По названию';

  @override
  String get catalogSortRating => 'По оценке';

  @override
  String get catalogSortImpression => 'По дате впечатления';

  @override
  String get catalogSortLabel => 'Сортировка';

  @override
  String catalogFound(int count) {
    return 'Найдено: $count';
  }

  @override
  String get entryDetailTitle => 'Запись';

  @override
  String get entryEdit => 'Изменить запись';

  @override
  String get entryHistory => 'История изменений';

  @override
  String get entryHistoryEmpty => 'Изменений пока нет';

  @override
  String get entryRestoreRevision => 'Восстановить эту версию';

  @override
  String get entryRestored => 'Версия восстановлена';

  @override
  String get entryNoteLabel => 'Заметка';

  @override
  String get entryArchive => 'Архивировать запись';

  @override
  String get entryArchived => 'Запись архивирована';

  @override
  String entryVersionAt(String date) {
    return 'Версия от $date';
  }

  @override
  String get collectionsTitle => 'Подборки';

  @override
  String get collectionCreate => 'Новая подборка';

  @override
  String get collectionNameLabel => 'Название подборки';

  @override
  String get collectionEmptyTitle => 'Подборок пока нет';

  @override
  String get collectionEmptyMessage =>
      'Подборки — это ручные списки: «Посмотреть вместе», «Купить», «Посетить летом».';

  @override
  String collectionEntriesCount(int count) {
    return '$count зап.';
  }

  @override
  String get collectionOpenEmpty => 'В подборке пока нет записей';

  @override
  String get collectionAddTo => 'Добавить в подборку';

  @override
  String get collectionRemoveFrom => 'Убрать из подборки';

  @override
  String get collectionRename => 'Переименовать';

  @override
  String get collectionArchive => 'Архивировать подборку';

  @override
  String get collectionAdded => 'Добавлено в подборку';

  @override
  String get photoAdd => 'Добавить фото';

  @override
  String get photoSectionTitle => 'Фотографии';

  @override
  String get photoRejected =>
      'Файл отклонён: неподдерживаемый или повреждённый формат';

  @override
  String get photoDuplicate => 'Такое изображение уже добавлено';

  @override
  String get photoRemove => 'Удалить фотографию';

  @override
  String get photoDropHint => 'Перетащите изображения сюда';

  @override
  String get profilesTitle => 'Профили';

  @override
  String get profileCreate => 'Новый профиль';

  @override
  String get profileSwitchTo => 'Сделать активным';

  @override
  String get profileActiveBadge => 'Активный';

  @override
  String get profileTypePrimary => 'Мой основной профиль';

  @override
  String get profileTypeOtherDevice => 'Мой профиль на другом устройстве';

  @override
  String get profileTypeExternal => 'Внешний профиль';

  @override
  String get profileTypeExternalArchived => 'Архивный внешний профиль';

  @override
  String get profileLocalSettings => 'Локальные настройки';

  @override
  String get profileLocalHint =>
      'Эти данные видны только вам и не передаются при экспорте.';

  @override
  String get profileLocalName => 'Локальное имя';

  @override
  String get profileLocalNameHint => 'Например: Саша с работы';

  @override
  String get profileLocalNote => 'Заметка о человеке';

  @override
  String get profileSaved => 'Сохранено';

  @override
  String profileEntriesCount(int count) {
    return '$count зап.';
  }

  @override
  String get compareTitle => 'Сравнение профилей';

  @override
  String get compareFirst => 'Первый профиль';

  @override
  String get compareSecond => 'Второй профиль';

  @override
  String get compareNeedTwo => 'Нужны два разных профиля';

  @override
  String get compareNeedTwoMessage =>
      'Создайте или импортируйте ещё один профиль, чтобы сравнивать предпочтения.';

  @override
  String get compareModeOnlyFirst => 'Есть у первого, нет у второго';

  @override
  String get compareModeOnlySecond => 'Есть у второго, нет у первого';

  @override
  String get compareModeBoth => 'Есть у обоих';

  @override
  String get compareModeBothLike => 'Нравится обоим';

  @override
  String get compareModeRatingDiffers => 'Оценки сильно отличаются';

  @override
  String get compareModeRecommended => 'Первый рекомендует, второй не добавил';

  @override
  String get compareEmpty => 'Совпадений нет';

  @override
  String get compareEmptyMessage =>
      'Попробуйте другой режим сравнения или профили.';

  @override
  String compareSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get compareTransferSelected => 'Добавить выбранное себе';

  @override
  String compareTransferred(int count) {
    return 'Добавлено записей: $count';
  }

  @override
  String get compareNoEntry => 'Нет записи';

  @override
  String get transferTitle => 'Добавить в мой профиль';

  @override
  String get transferCategoryQuestion => 'Что сделать с категорией?';

  @override
  String transferSourcePath(String path) {
    return 'Категория источника: $path';
  }

  @override
  String get transferUseMatch => 'Использовать существующую категорию';

  @override
  String get transferCreatePath => 'Создать недостающие категории';

  @override
  String get transferNoCategory => 'Сохранить без категории';

  @override
  String get transferDone => 'Запись добавлена в ваш профиль';

  @override
  String get transferAlreadyHave => 'У вас уже есть запись об этом объекте';

  @override
  String get exportTitle => 'Экспорт профиля';

  @override
  String get exportAction => 'Экспортировать';

  @override
  String get exportIncludePhotos => 'С фотографиями';

  @override
  String get exportProtect => 'Защитить паролем';

  @override
  String get exportPassword => 'Пароль пакета';

  @override
  String get exportComposition => 'Что войдёт в файл';

  @override
  String get exportEntries => 'Записей';

  @override
  String get exportCategories => 'Категорий';

  @override
  String get exportSubcategories => 'из них подкатегорий';

  @override
  String get exportObjects => 'Объектов';

  @override
  String get exportRevisions => 'Версий';

  @override
  String get exportPhotos => 'Фотографий';

  @override
  String get exportExcludedPrivate => 'Исключено приватных записей';

  @override
  String get exportSize => 'Размер';

  @override
  String exportSaved(String path) {
    return 'Файл сохранён: $path';
  }

  @override
  String get exportCancelled => 'Экспорт отменён';

  @override
  String get exportForbidden =>
      'Владелец запретил повторную передачу этого профиля';

  @override
  String get importTitle => 'Импорт профиля';

  @override
  String get importPickFile => 'Выбрать файл';

  @override
  String get importDropHint => 'Перетащите файл профиля сюда или выберите его';

  @override
  String get importChecking => 'Проверяем пакет…';

  @override
  String get importApplying => 'Применяем изменения…';

  @override
  String get importPreviewTitle => 'Предварительный просмотр';

  @override
  String importProfileLine(String name) {
    return 'Профиль: $name';
  }

  @override
  String importFingerprintLine(String value) {
    return 'Отпечаток: $value';
  }

  @override
  String get importTrustQuestion => 'Новый профиль. Доверять этому профилю?';

  @override
  String get importVerified => 'Профиль подтверждён, подпись файла корректна';

  @override
  String get importNoChanges =>
      'Этот пакет уже был импортирован. Новых изменений нет.';

  @override
  String get importNewEntries => 'Новых записей';

  @override
  String get importChangedEntries => 'Изменённых записей';

  @override
  String get importNewCategories => 'Новых категорий';

  @override
  String get importMovedCategories => 'Перемещённых категорий';

  @override
  String get importNewImages => 'Новых изображений';

  @override
  String get importUnchanged => 'Без изменений';

  @override
  String get importApply => 'Импортировать';

  @override
  String get importDone => 'Импорт завершён';

  @override
  String get importBackupCreated => 'Создана резервная копия перед импортом';

  @override
  String get importPasswordNeeded => 'Пакет защищён паролем';

  @override
  String get importErrorTitle => 'Импорт не выполнен';

  @override
  String get backupsTitle => 'Резервные копии';

  @override
  String get backupCreate => 'Создать копию';

  @override
  String get backupCreated => 'Копия создана';

  @override
  String get backupVerifyOk => 'Копия цела';

  @override
  String get backupVerifyFailed => 'Копия повреждена';

  @override
  String get backupReasonManual => 'вручную';

  @override
  String get backupReasonBeforeImport => 'перед импортом';

  @override
  String get backupReasonBeforeRestore => 'перед восстановлением';

  @override
  String get backupEmpty => 'Резервных копий пока нет';

  @override
  String get backupVerify => 'Проверить целостность';

  @override
  String backupSizeLabel(String size) {
    return '$size КБ';
  }

  @override
  String get backupRetentionHint =>
      'Автоматические копии создаются перед импортом. Хранятся последние 7, копии, созданные вручную, не удаляются.';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsBehaviour => 'Поведение';

  @override
  String get settingsShowSubcategoriesDefault =>
      'По умолчанию показывать записи из подкатегорий';

  @override
  String get settingsTransferMode => 'При переносе записей';

  @override
  String get settingsTransferSuggest => 'Предлагать совпадающий путь';

  @override
  String get settingsTransferAutoCreate =>
      'Автоматически создавать отсутствующие категории';

  @override
  String get settingsTransferAlwaysAsk => 'Всегда спрашивать';

  @override
  String get settingsTransferNoCategory => 'Сохранять без категории';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsTypes => 'Типы объектов';

  @override
  String get settingsDevices => 'Устройства';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get settingsStorage => 'Хранилище';

  @override
  String get settingsPrivacyNote =>
      'Приложение работает полностью локально: без сервера, облака, регистрации, аналитики и сетевых запросов.';

  @override
  String get settingsLanguage => 'Язык интерфейса';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get typesTitle => 'Типы объектов';

  @override
  String get typeRename => 'Переименовать тип';

  @override
  String get typeHide => 'Скрыть';

  @override
  String get typeShow => 'Показать';

  @override
  String get typeNameLabel => 'Название типа';

  @override
  String get typeHidden => 'Скрыт';

  @override
  String get typeCreate => 'Новый тип';

  @override
  String get typeEmpty => 'Типов пока нет';

  @override
  String get devicesTitle => 'Устройства';

  @override
  String get deviceThis => 'Это устройство';

  @override
  String get deviceRename => 'Переименовать устройство';

  @override
  String get deviceNameLabel => 'Название устройства';

  @override
  String deviceRegisteredAt(String date) {
    return 'Зарегистрировано $date';
  }

  @override
  String get deviceEmpty => 'Устройств пока нет';

  @override
  String get tagsLabel => 'Теги';

  @override
  String get tagAdd => 'Добавить тег';

  @override
  String get tagNameLabel => 'Название тега';

  @override
  String get tagRemove => 'Убрать тег';

  @override
  String get tagsHint =>
      'Теги — свободные метки без вложенности, они не заменяют категории.';

  @override
  String get privacyLabel => 'Доступность';

  @override
  String get privacyOnlyMe => 'Только мне';

  @override
  String get privacyShareable => 'Можно передавать';

  @override
  String get privacyNoNote => 'Передавать без заметки';

  @override
  String get privacyNoPhotos => 'Передавать без фотографий';

  @override
  String get privacyBasic => 'Передавать только основную информацию';

  @override
  String get updatesTitle => 'Обновления';

  @override
  String get updatesEmpty => 'Новых изменений нет';

  @override
  String get updatesEmptyMessage =>
      'Здесь появятся изменения, пришедшие с импортом чужих профилей.';

  @override
  String get updatesMarkSeen => 'Отметить просмотренным';

  @override
  String updatesFrom(String name) {
    return 'Профиль: $name';
  }

  @override
  String get duplicateTitle => 'Возможные дубли';

  @override
  String get duplicateMessage =>
      'Похожие объекты уже есть. Связать их или оставить раздельно?';

  @override
  String get duplicateKeepSeparate => 'Оставить раздельно';

  @override
  String get duplicateUseExisting => 'Использовать существующий';

  @override
  String get exportModeFull => 'Весь профиль';

  @override
  String get exportModeBranch => 'Ветка категории';

  @override
  String get exportModeCollection => 'Подборка';

  @override
  String get exportModeLabel => 'Что экспортировать';

  @override
  String get hotkeysTitle => 'Горячие клавиши';

  @override
  String get hotkeyNewEntry => 'Новая запись';

  @override
  String get hotkeySearch => 'Поиск';

  @override
  String get hotkeyImport => 'Импорт';

  @override
  String get hotkeyExport => 'Экспорт';

  @override
  String get hotkeyProfiles => 'Переключатель профилей';

  @override
  String get hotkeyClose => 'Закрыть диалог';

  @override
  String get onboardingWelcomeTitle => 'Ваш личный архив впечатлений';

  @override
  String get onboardingWelcomeSubtitle =>
      'Храните предпочтения, рекомендации и коллекции. Всё локально, без сети и регистрации.';

  @override
  String get onboardingCreateProfile => 'Создать профиль';

  @override
  String get onboardingProfileNameHint => 'Как вас зовут?';

  @override
  String get onboardingProfileNameLabel => 'Имя';

  @override
  String get onboardingLastNameLabel => 'Фамилия (необязательно)';

  @override
  String get onboardingNicknameLabel => 'Псевдоним (необязательно)';

  @override
  String get onboardingNameRequired => 'Укажите имя';

  @override
  String get onboardingStarterTitle => 'Стартовая структура';

  @override
  String get onboardingStarterSubcategories => 'Создать примерные подкатегории';

  @override
  String get onboardingStarterHint =>
      'Например: Продукты → Колбасы, Сыры, Напитки. Всё можно переименовать или удалить позже.';

  @override
  String get onboardingCreating => 'Создаём профиль…';

  @override
  String get componentGalleryTitle => 'Галерея компонентов';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get relationLove => 'Обожаю';

  @override
  String get relationLike => 'Нравится';

  @override
  String get relationNeutral => 'Нейтрально';

  @override
  String get relationDislike => 'Не нравится';

  @override
  String get relationAvoid => 'Избегаю';

  @override
  String get relationWantToTry => 'Хочу попробовать';

  @override
  String get emptyCatalogTitle => 'Здесь пока пусто';

  @override
  String get emptyCatalogSubtitle =>
      'Добавьте первую запись — это займёт несколько секунд.';

  @override
  String get entryAddToMyProfile => 'Добавить в мой профиль';

  @override
  String get profileSwitcherActive => 'Активный профиль';

  @override
  String get profileSwitcherTitle => 'Профили';

  @override
  String get breadcrumbObjectSeparator => ' / ';
}
