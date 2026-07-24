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
  String get commonUndo => 'Вернуть';

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
  String get navMore => 'Ещё';

  @override
  String get navAllSections => 'Все разделы';

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
  String get categoryArchived => 'Категория убрана в архив';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
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
  String bulkSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count записей',
      many: 'Выбрано $count записей',
      few: 'Выбрано $count записи',
      one: 'Выбрана $count запись',
    );
    return '$_temp0';
  }

  @override
  String get bulkSelectAll => 'Выбрать все';

  @override
  String get bulkSelectOne => 'Выделить';

  @override
  String get bulkCancel => 'Снять выделение';

  @override
  String get bulkSetCategory => 'В категорию';

  @override
  String get bulkAddTag => 'Добавить тег';

  @override
  String get bulkAddToCollection => 'В подборку';

  @override
  String get bulkArchive => 'В архив';

  @override
  String bulkArchiveConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Убрать $count записей в архив? Их можно будет вернуть.',
      many: 'Убрать $count записей в архив? Их можно будет вернуть.',
      few: 'Убрать $count записи в архив? Их можно будет вернуть.',
      one: 'Убрать $count запись в архив? Её можно будет вернуть.',
    );
    return '$_temp0';
  }

  @override
  String bulkArchived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей убрано в архив',
      many: '$count записей убрано в архив',
      few: '$count записи убраны в архив',
      one: '$count запись убрана в архив',
    );
    return '$_temp0';
  }

  @override
  String get entryOpen => 'Открыть';

  @override
  String get entryContextHint => 'Нажмите правой кнопкой для действий';

  @override
  String get catalogAddedHiddenByFilters =>
      'Запись добавлена, но не подходит под текущие фильтры';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count записей',
      many: 'Найдено $count записей',
      few: 'Найдено $count записи',
      one: 'Найдена $count запись',
    );
    return '$_temp0';
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
  String get entryEditObject => 'Изменить описание';

  @override
  String get entryEditObjectHint =>
      'Название, бренд и год относятся к самому объекту и видны во всех профилях, где он есть. Прежние значения останутся в истории.';

  @override
  String get entryCreatorLabel => 'Бренд, автор или режиссёр';

  @override
  String get entryYearLabel => 'Год';

  @override
  String get entryImpressionDate => 'Дата впечатления';

  @override
  String get entryImpressionDateNone => 'Не указана';

  @override
  String get entryImpressionDateClear => 'Убрать дату';

  @override
  String get entryArchive => 'Архивировать запись';

  @override
  String get entryArchived => 'Запись убрана в архив';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
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
  String get collectionArchived => 'Подборка убрана в архив';

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
  String get tourTitle => 'Как пользоваться';

  @override
  String get tourSkip => 'Пропустить';

  @override
  String get tourNext => 'Дальше';

  @override
  String get tourFinish => 'Понятно';

  @override
  String get tourRepeat => 'Пройти обучение заново';

  @override
  String get tourAddTitle => 'Записать впечатление';

  @override
  String get tourAddBody =>
      'Для новой записи хватает названия. Отношение, оценка и фотографии — сразу в форме; заметка, дата, теги и подборка прячутся за «Добавить подробности».';

  @override
  String get tourAddHintDesktop =>
      'Ctrl + N — открыть форму, не отрывая рук от клавиатуры';

  @override
  String get tourAddHintMobile =>
      'Оранжевая кнопка «+» внизу справа доступна с любого экрана';

  @override
  String get tourScanTitle => 'Товар по штрихкоду';

  @override
  String get tourScanBodyDesktop =>
      'Штрихкод можно ввести руками, считать USB-сканером или распознать с фотографии. Название и бренд подтянутся из открытых товарных баз.';

  @override
  String get tourScanBodyMobile =>
      'Наведите камеру на штрихкод — название и бренд подтянутся из открытых товарных баз. Наружу уходит только сам код.';

  @override
  String get tourScanHintDesktop => 'Ctrl + B — открыть сканирование';

  @override
  String get tourShelvesTitle => 'Полки вместо списка';

  @override
  String get tourShelvesBody =>
      'Категории показываются полками: видно цвет, число записей и фотографии из ветки. Нажатие уводит вглубь, значок списка показывает записи самой полки. Кто привык к дереву — переключатель рядом с заголовком.';

  @override
  String get tourSearchTitle => 'Найти за секунду';

  @override
  String get tourSearchBody =>
      'Поиск идёт по названиям и по тексту заметок. Фильтры по типу, категории, отношению и тегам прячутся за кнопкой «Фильтры», а включённые подсвечиваются.';

  @override
  String get tourSearchHintDesktop => 'Ctrl + F — перейти в поиск';

  @override
  String get tourBulkTitle => 'Разом, а не по одной';

  @override
  String get tourBulkBodyDesktop =>
      'Ctrl + нажатие выделяет записи. Выделенным можно сразу назначить категорию, добавить тег, положить в подборку или убрать в архив. Правая кнопка открывает меню записи.';

  @override
  String get tourBulkBodyMobile =>
      'Долгое нажатие включает выделение. Выделенным можно сразу назначить категорию, добавить тег, положить в подборку или убрать в архив.';

  @override
  String get tourSafetyTitle => 'Ничего не пропадает';

  @override
  String get tourSafetyBody =>
      'Убранное уходит в архив и возвращается оттуда целым. Каждое изменение записи сохраняется отдельной версией. В настройках есть резервные копии — их можно создать и развернуть обратно.';

  @override
  String get searchClear => 'Очистить поиск';

  @override
  String get catalogFilters => 'Фильтры';

  @override
  String get categoryShowEntries => 'Показать записи';

  @override
  String get categoryViewShelves => 'Полками';

  @override
  String get categoryViewTree => 'Деревом';

  @override
  String get categoryShelfEmptyTitle => 'Внутри пока пусто';

  @override
  String get categoryShelfEmptyMessage =>
      'Добавьте подкатегорию или заведите сюда первую запись.';

  @override
  String get errorStateTitle => 'Не удалось показать этот раздел';

  @override
  String get errorStateMessage =>
      'Данные на месте — сбой произошёл при их чтении. Попробуйте перейти в раздел заново или перезапустить приложение.';

  @override
  String get errorStateDetails => 'Подробности';

  @override
  String catalogSearchChip(String query) {
    return 'Поиск: $query';
  }

  @override
  String get purgeAction => 'Удалить навсегда';

  @override
  String purgeConfirmTitle(String title) {
    return 'Удалить «$title» навсегда?';
  }

  @override
  String get purgeConfirmMessage =>
      'Это не архивирование: запись, её версии и фотографии будут стёрты. Отменить будет нельзя — вернуть можно только из резервной копии.';

  @override
  String get purgeDone => 'Удалено навсегда';

  @override
  String get purgeCategoryHasChildren =>
      'Сначала разберитесь с подкатегориями: удалять ветку целиком нельзя.';

  @override
  String get photoMakeCover => 'Сделать обложкой';

  @override
  String get photoIsCover => 'Обложка записи';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
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
      'Автоматические копии создаются перед импортом и восстановлением. Хранятся последние 7 автоматических и 20 созданных вручную.';

  @override
  String get backupRestore => 'Восстановить';

  @override
  String get backupRestoreConfirmTitle => 'Восстановить из копии?';

  @override
  String backupRestoreConfirmMessage(String date) {
    return 'Все записи, категории и фотографии будут заменены содержимым копии от $date. Копия нынешнего состояния будет создана автоматически, так что вернуться будет куда.';
  }

  @override
  String get backupRestoreDoneTitle => 'Копия восстановлена';

  @override
  String get backupRestoreDoneMessage =>
      'Данные заменены. Закройте приложение и откройте снова — работать с восстановленной базой можно только после перезапуска.';

  @override
  String get backupRestoreQuit => 'Закрыть приложение';

  @override
  String get backupRestoreNotFound => 'Файл копии не найден';

  @override
  String get backupRestoreTooNew =>
      'Копия сделана более новой версией приложения. Обновите приложение и попробуйте снова.';

  @override
  String get backupEncryptionTitle => 'Защищать копии паролем';

  @override
  String get backupEncryptionHint =>
      'Копия, унесённая с устройства, без пароля не читается. На этом устройстве копии открываются сами — пароль спрашивают только чужие.';

  @override
  String get backupEncryptionOn => 'Копии защищены паролем';

  @override
  String get backupEncryptionOff => 'Защита копий выключена';

  @override
  String get backupEncryptionChange => 'Сменить пароль';

  @override
  String get backupEncryptionUnavailable =>
      'Хранилище ключей операционной системы недоступно — защитить копии нечем.';

  @override
  String get backupPasswordTitle => 'Пароль для копий';

  @override
  String get backupPasswordMessage =>
      'Забытый пароль означает потерю копий: восстановить их будет нечем. Запишите его там же, где остальные важные пароли.';

  @override
  String get backupPasswordField => 'Пароль';

  @override
  String get backupPasswordRepeat => 'Ещё раз';

  @override
  String get backupPasswordMismatch => 'Пароли не совпадают';

  @override
  String get backupPasswordShort => 'Не короче восьми знаков';

  @override
  String get backupPasswordChangedNote =>
      'Уже созданные копии продолжат открываться прежним паролем: он записан в каждом файле и задним числом не меняется.';

  @override
  String get backupDisableTitle => 'Выключить защиту копий?';

  @override
  String get backupDisableMessage =>
      'Новые копии будут создаваться без пароля. Уже созданные по-прежнему потребуют старый пароль.';

  @override
  String get backupUnlockTitle => 'Копия защищена паролем';

  @override
  String get backupUnlockMessage =>
      'Эта копия сделана на другом устройстве или до переустановки, поэтому ключа к ней здесь нет.';

  @override
  String get backupWrongPassword => 'Неверный пароль';

  @override
  String get backupEncryptedBadge => 'под паролем';

  @override
  String get quickAddTypeVsCategory =>
      'Тип задаёт набор полей записи, категория — вашу полку в дереве.';

  @override
  String entryRatingOf(Object value) {
    return 'оценка $value';
  }

  @override
  String a11yCategoryShelf(Object count, Object name) {
    return '$name, $count';
  }

  @override
  String a11ySummaryItem(Object label, Object value) {
    return '$label: $value';
  }

  @override
  String get errorLogTitle => 'Журнал ошибок';

  @override
  String get errorLogHint =>
      'Сбои записываются на этом устройстве и никуда не отправляются. Если приложение повело себя странно, скопируйте журнал и приложите к сообщению об ошибке.';

  @override
  String get errorLogEmpty => 'Сбоев не было';

  @override
  String errorLogCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
  }

  @override
  String get errorLogShow => 'Показать';

  @override
  String get errorLogCopy => 'Скопировать';

  @override
  String get errorLogCopied => 'Журнал скопирован в буфер обмена';

  @override
  String get errorLogClear => 'Очистить';

  @override
  String get errorLogCleared => 'Журнал очищен';

  @override
  String get settingsAdvanced => 'Дополнительно';

  @override
  String get settingsAdvancedHint =>
      'Настраивают один раз или не трогают вовсе';

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
      'Записи, фотографии и ключи хранятся только на устройстве: без сервера, облака, регистрации, аналитики и телеметрии. В сеть уходят лишь штрихкод при поиске товара и запрос списка выпусков при проверке обновлений — оба отключаются выше.';

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
  String get hotkeyScan => 'Сканировать штрихкод';

  @override
  String get hotkeySettings => 'Настройки';

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

  @override
  String categoriesSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count категорий в дереве',
      many: '$count категорий в дереве',
      few: '$count категории в дереве',
      one: '$count категория в дереве',
    );
    return '$_temp0';
  }

  @override
  String get categorySearchHint => 'Найти категорию';

  @override
  String get categoryExpandAll => 'Развернуть всё';

  @override
  String get categoryCollapseAll => 'Свернуть всё';

  @override
  String get categoryIcon => 'Значок категории';

  @override
  String get typeIcon => 'Значок типа';

  @override
  String get categoryOpenInCatalog => 'Показать записи';

  @override
  String categorySubcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подкатегорий',
      many: '$count подкатегорий',
      few: '$count подкатегории',
      one: '$count подкатегория',
    );
    return '$_temp0';
  }

  @override
  String categoryDirectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count прямо здесь',
      many: '$count прямо здесь',
      few: '$count прямо здесь',
      one: '$count прямо здесь',
    );
    return '$_temp0';
  }

  @override
  String categoryBranchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей в ветке',
      many: '$count записей в ветке',
      few: '$count записи в ветке',
      one: '$count запись в ветке',
    );
    return '$_temp0';
  }

  @override
  String get categorySubcategoriesTitle => 'Подкатегории';

  @override
  String get categoryEntriesTitle => 'Записи';

  @override
  String get categoryBranchEmpty => 'В этой ветке пока нет записей';

  @override
  String get categoryPickTitle => 'Выберите категорию';

  @override
  String get categoryPickMessage =>
      'Слева — дерево категорий. Выберите ветку, чтобы увидеть, что в ней лежит.';

  @override
  String get catalogTypeLabel => 'Тип';

  @override
  String get catalogCategoryLabel => 'Категория';

  @override
  String get catalogRelationLabel => 'Отношение';

  @override
  String get searchGlobalHint => 'Поиск по записям';

  @override
  String get searchResultsTitle => 'Результаты поиска';

  @override
  String get headerNotifications => 'Уведомления';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsEmpty => 'Новых событий нет';

  @override
  String get notificationsEmptyHint =>
      'Здесь появятся входящие изменения, обновления и итоги импорта.';

  @override
  String get notificationsMarkAllRead => 'Отметить всё прочитанным';

  @override
  String get notificationsOpen => 'Открыть';

  @override
  String get notificationIncomingTitle => 'Входящие изменения';

  @override
  String notificationIncomingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count изменений в импортированных профилях',
      many: '$count изменений в импортированных профилях',
      few: '$count изменения в импортированных профилях',
      one: '$count изменение в импортированных профилях',
    );
    return '$_temp0';
  }

  @override
  String get notificationUpdateTitle => 'Доступна новая версия';

  @override
  String notificationUpdateBody(String version) {
    return 'Версия $version готова к установке';
  }

  @override
  String get notificationProductsTitle => 'Сведения о товарах обновлены';

  @override
  String notificationProductsBody(int count) {
    return 'Дополнено карточек: $count';
  }

  @override
  String get notificationImportTitle => 'Импорт завершён';

  @override
  String notificationImportBody(String date) {
    return 'Пакет от $date';
  }

  @override
  String get notificationBackupTitle => 'Резервная копия создана';

  @override
  String notificationBackupBody(String date) {
    return 'Последняя копия от $date';
  }

  @override
  String get collectionPickTitle => 'Добавить записи';

  @override
  String get collectionPickEmpty =>
      'В профиле пока нет записей, которые можно добавить';

  @override
  String collectionPickSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String profilesSubtitle(int count, int max) {
    return '$count из $max возможных';
  }

  @override
  String get profileMenuManage => 'Все профили';

  @override
  String get profileMenuLocal => 'Локальные настройки';

  @override
  String get profileMenuExport => 'Экспортировать профиль';

  @override
  String get profileMenuSwitch => 'Переключиться';

  @override
  String get profileMenuSettings => 'Настройки приложения';

  @override
  String get barcodeTitle => 'Добавить по штрихкоду';

  @override
  String get barcodeHintMobile =>
      'Наведите камеру на штрихкод или QR-код либо введите цифры вручную.';

  @override
  String get barcodeHintDesktop =>
      'Введите код вручную, отсканируйте USB-сканером или распознайте с фотографии.';

  @override
  String get barcodeCodeLabel => 'Штрихкод или QR';

  @override
  String get barcodeLookup => 'Найти';

  @override
  String get barcodeUseCamera => 'Камера';

  @override
  String get barcodePhoto => 'Сфотографировать';

  @override
  String get barcodeFromFile => 'Распознать с изображения';

  @override
  String get barcodeNotRecognized =>
      'Код на изображении не найден. Попробуйте снимок покрупнее и без бликов.';

  @override
  String get barcodeUseResult => 'Добавить';

  @override
  String barcodeFoundIn(String source) {
    return 'Источник: $source';
  }

  @override
  String get barcodeNotFound => 'Товар не найден ни в одной базе';

  @override
  String get barcodeLookupFailed => 'Не удалось связаться с базами товаров';

  @override
  String get barcodeFillManually =>
      'Код сохранится в карточке — название можно ввести вручную.';

  @override
  String get barcodeTorch => 'Подсветка';

  @override
  String get barcodeScanAction => 'Сканировать код';

  @override
  String get settingsNetworkTitle => 'Товарные базы и обновления';

  @override
  String get settingsNetworkHint =>
      'Единственные сетевые запросы приложения. Наружу уходит только штрихкод и номер версии.';

  @override
  String get settingsBarcodeLookup => 'Искать товар по штрихкоду';

  @override
  String get settingsBarcodeSources => 'Источники данных';

  @override
  String get settingsProductAutoUpdate =>
      'Дополнять карточки товаров автоматически';

  @override
  String get settingsProductAutoUpdateHint =>
      'Не чаще раза в сутки. Введённые вручную названия не заменяются.';

  @override
  String get settingsProductRefreshNow => 'Обновить сейчас';

  @override
  String settingsProductRefreshed(int checked, int updated) {
    return 'Проверено $checked, дополнено $updated';
  }

  @override
  String get settingsAppUpdateCheck => 'Проверять обновления приложения';

  @override
  String get settingsAppUpdateNow => 'Проверить сейчас';

  @override
  String get settingsUpToDate => 'Установлена последняя версия';

  @override
  String get settingsUpdateUnavailable =>
      'Список версий недоступен. Возможно, репозиторий закрыт — тогда обновляйте приложение вручную со страницы выпусков.';

  @override
  String get settingsUpdateFailed =>
      'Не удалось проверить обновления. Проверьте подключение к интернету и попробуйте позже.';

  @override
  String get updateTitle => 'Обновление приложения';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String updateCurrent(String version) {
    return 'Установлена версия $version';
  }

  @override
  String get updateDownload => 'Скачать установщик';

  @override
  String get updateOpenPage => 'Открыть страницу выпуска';

  @override
  String get updateLater => 'Позже';

  @override
  String get updateSkip => 'Пропустить эту версию';

  @override
  String get updateInstallNow => 'Установить';

  @override
  String get updateInstallHint =>
      'Приложение закроется, обновится и запустится снова.';

  @override
  String get updateInstallHintAndroid =>
      'Приложение скачает обновление и передаст его системе. В первый раз Android попросит разрешить установку из этого источника.';

  @override
  String get updateInstalling => 'Открываем установщик…';

  @override
  String updateDownloading(int percent) {
    return 'Скачивание: $percent%';
  }

  @override
  String get updateDownloadingUnknown => 'Скачивание…';

  @override
  String get updateFailed => 'Не удалось обновить';

  @override
  String get onboardingStep1Title => 'Ваши вкусы, а не чужие оценки';

  @override
  String get onboardingStep1Body =>
      'Продукты, блюда, фильмы, книги, места — всё, о чём хочется помнить, понравилось оно или нет. Для новой записи хватает названия.';

  @override
  String get onboardingStep2Title => 'Мнение отдельно от вещи';

  @override
  String get onboardingStep2Body =>
      '«Интерстеллар» — один объект на всех. Ваша оценка и оценка близкого человека — две разные записи. Поэтому профилями можно обмениваться: чужое мнение не перепишет ваше.';

  @override
  String get onboardingStep3Title => 'Всё остаётся у вас';

  @override
  String get onboardingStep3Body =>
      'Без аккаунта, сервера и облака. Поделиться можно файлом, который вы создаёте сами и передаёте кому хотите.';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get exportReadable => 'Для чтения';

  @override
  String get exportCsv => 'Таблица CSV';

  @override
  String get exportMarkdown => 'Текст Markdown';

  @override
  String get insightsTitle => 'Статистика';

  @override
  String insightsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'По $count записям',
      many: 'По $count записям',
      few: 'По $count записям',
      one: 'По $count записи',
    );
    return '$_temp0';
  }

  @override
  String get insightsEmptyTitle => 'Пока нечего показывать';

  @override
  String get insightsEmptyMessage =>
      'Добавьте несколько записей — здесь появятся распределение оценок, отношения и динамика по месяцам.';

  @override
  String get insightsTotal => 'Записей';

  @override
  String get insightsAverage => 'Средняя оценка';

  @override
  String get insightsWithPhotos => 'С фотографиями';

  @override
  String get insightsWithNotes => 'С заметками';

  @override
  String get insightsRatings => 'Распределение оценок';

  @override
  String get insightsRelations => 'Отношение';

  @override
  String get insightsCategories => 'Самые заполненные категории';

  @override
  String get insightsTimeline => 'Добавления по месяцам';

  @override
  String get wishlistTitle => 'Хочу попробовать';

  @override
  String wishlistSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задумок',
      many: '$count задумок',
      few: '$count задумки',
      one: '$count задумка',
    );
    return '$_temp0';
  }

  @override
  String get wishlistEmptyTitle => 'Список пуст';

  @override
  String get wishlistEmptyMessage =>
      'Отмечайте отношением «Хочу попробовать» то, до чего ещё не дошли руки, — оно соберётся здесь.';

  @override
  String get wishlistMarkTried => 'Попробовал';

  @override
  String get wishlistRatingTitle => 'Как впечатления?';

  @override
  String get wishlistRatingHint =>
      'Отношение подставится по оценке, дата впечатления — сегодняшняя. Всё можно изменить в карточке.';

  @override
  String get archiveTitle => 'Архив';

  @override
  String archiveSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count убранных объектов',
      many: '$count убранных объектов',
      few: '$count убранных объекта',
      one: '$count убранный объект',
    );
    return '$_temp0';
  }

  @override
  String get archiveEmptyTitle => 'Архив пуст';

  @override
  String get archiveEmptyMessage =>
      'Здесь появляется всё, что вы убрали из работы. Ничего не удаляется — любое можно вернуть.';

  @override
  String get archiveEntries => 'Записи';

  @override
  String get archiveCategories => 'Категории';

  @override
  String get archiveCollections => 'Подборки';

  @override
  String archiveCategoryLevel(int level) {
    return 'Уровень вложенности: $level';
  }

  @override
  String get archiveRestored => 'Возвращено из архива';

  @override
  String get incomingTitle => 'Входящие изменения';

  @override
  String get incomingSubtitle =>
      'Что изменилось в импортированных профилях (§23)';

  @override
  String get incomingEmptyTitle => 'Изменений нет';

  @override
  String get incomingEmptyMessage =>
      'После импорта обновлённого профиля здесь появится список того, что изменилось.';

  @override
  String get incomingMarkSeen => 'Отметить просмотренным';

  @override
  String get incomingMarkAllSeen => 'Отметить все просмотренными';

  @override
  String get incomingKindEntry => 'Запись';

  @override
  String get incomingKindObject => 'Объект';

  @override
  String get incomingKindCategory => 'Категория';

  @override
  String incomingReceivedAt(String date) {
    return 'Получено $date';
  }

  @override
  String get incomingNewBadge => 'Новое';

  @override
  String get fieldsTitle => 'Поля типа';

  @override
  String get fieldsHint =>
      'Дополнительные поля, которые появятся у записей этого типа.';

  @override
  String get fieldsAdd => 'Добавить поле';

  @override
  String get fieldsEmpty => 'Своих полей пока нет';

  @override
  String get fieldsNameLabel => 'Название поля';

  @override
  String get fieldsKindLabel => 'Тип значения';

  @override
  String get fieldsKindText => 'Текст';

  @override
  String get fieldsKindNumber => 'Число';

  @override
  String get fieldsKindDate => 'Дата';

  @override
  String get fieldsKindBool => 'Да или нет';

  @override
  String get fieldsKindChoice => 'Выбор из списка';

  @override
  String get fieldsChoicesLabel => 'Варианты через запятую';

  @override
  String get fieldsRemove => 'Удалить поле';

  @override
  String fieldsEditFor(String type) {
    return 'Поля типа «$type»';
  }

  @override
  String get fieldsValuesTitle => 'Дополнительно';

  @override
  String quickAddBarcodeHint(String code) {
    return 'Заполнено по штрихкоду $code';
  }

  @override
  String get keyStorageTitle => 'Хранение закрытого ключа';

  @override
  String get keyStorageOs => 'Отдельно от базы, под защитой системы';

  @override
  String get keyStorageOsWindows =>
      'Файл зашифрован средствами Windows (DPAPI) на вашу учётную запись: на другом компьютере он бесполезен.';

  @override
  String get keyStorageOsMobile =>
      'Файл лежит в защищённом каталоге приложения и не попадает в резервные копии.';

  @override
  String get keyStorageDb => 'В базе приложения — без защиты на диске';

  @override
  String get keyStorageDbHint =>
      'Секрет лежит в той же базе, что и зашифрованный им ключ, поэтому шифрование ключа сейчас ничего не даёт: скопировав файл базы, его можно прочитать. Перенесите секрет в хранилище системы.';

  @override
  String get keyStorageMove => 'Перенести в хранилище ОС';

  @override
  String get keyStorageMoved =>
      'Ключ перенесён в хранилище операционной системы';

  @override
  String get keyStorageMoveFailed =>
      'Хранилище системы недоступно — секрет остался в базе';
}
