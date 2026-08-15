import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonRestore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get commonRestore;

  /// No description provided for @commonUndo.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть'**
  String get commonUndo;

  /// No description provided for @commonEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get commonAdd;

  /// No description provided for @commonCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get commonCreate;

  /// No description provided for @commonSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get commonSearch;

  /// No description provided for @commonClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get commonSkip;

  /// No description provided for @commonYes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get commonYes;

  /// No description provided for @commonNothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get commonNothingFound;

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navCatalog.
  ///
  /// In ru, this message translates to:
  /// **'Каталог'**
  String get navCatalog;

  /// No description provided for @navCollections.
  ///
  /// In ru, this message translates to:
  /// **'Подборки'**
  String get navCollections;

  /// No description provided for @navCompare.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение'**
  String get navCompare;

  /// No description provided for @navSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @navProfiles.
  ///
  /// In ru, this message translates to:
  /// **'Профили'**
  String get navProfiles;

  /// No description provided for @navImport.
  ///
  /// In ru, this message translates to:
  /// **'Импорт'**
  String get navImport;

  /// No description provided for @navSectionMain.
  ///
  /// In ru, this message translates to:
  /// **'Разделы'**
  String get navSectionMain;

  /// No description provided for @navSectionProfiles.
  ///
  /// In ru, this message translates to:
  /// **'Профили и обмен'**
  String get navSectionProfiles;

  /// No description provided for @navSectionOther.
  ///
  /// In ru, this message translates to:
  /// **'Ещё'**
  String get navSectionOther;

  /// No description provided for @navMore.
  ///
  /// In ru, this message translates to:
  /// **'Ещё'**
  String get navMore;

  /// No description provided for @navAllSections.
  ///
  /// In ru, this message translates to:
  /// **'Все разделы'**
  String get navAllSections;

  /// No description provided for @headerHelp.
  ///
  /// In ru, this message translates to:
  /// **'Помощь'**
  String get headerHelp;

  /// No description provided for @homeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homeTitle;

  /// No description provided for @statEntries.
  ///
  /// In ru, this message translates to:
  /// **'Записей'**
  String get statEntries;

  /// No description provided for @statCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категорий'**
  String get statCategories;

  /// No description provided for @sectionRecent.
  ///
  /// In ru, this message translates to:
  /// **'Недавние записи'**
  String get sectionRecent;

  /// No description provided for @sectionWantToTry.
  ///
  /// In ru, this message translates to:
  /// **'Хочу попробовать'**
  String get sectionWantToTry;

  /// No description provided for @quickAddTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая запись'**
  String get quickAddTitle;

  /// No description provided for @quickAddNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get quickAddNameLabel;

  /// No description provided for @quickAddNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Папа может'**
  String get quickAddNameHint;

  /// No description provided for @quickAddNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите название'**
  String get quickAddNameRequired;

  /// No description provided for @quickAddTypeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get quickAddTypeLabel;

  /// No description provided for @quickAddCategoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get quickAddCategoryLabel;

  /// No description provided for @quickAddNoCategory.
  ///
  /// In ru, this message translates to:
  /// **'Без категории'**
  String get quickAddNoCategory;

  /// No description provided for @quickAddSaveAndMore.
  ///
  /// In ru, this message translates to:
  /// **'И ещё'**
  String get quickAddSaveAndMore;

  /// No description provided for @quickAddSavedInARow.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Заведена {count} запись подряд} few{Заведено {count} записи подряд} many{Заведено {count} записей подряд} other{Заведено {count} записей подряд}}'**
  String quickAddSavedInARow(int count);

  /// No description provided for @quickAddRelationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отношение'**
  String get quickAddRelationLabel;

  /// No description provided for @quickAddDetails.
  ///
  /// In ru, this message translates to:
  /// **'Добавить подробности'**
  String get quickAddDetails;

  /// No description provided for @quickAddDraftRestored.
  ///
  /// In ru, this message translates to:
  /// **'Продолжаем недописанное'**
  String get quickAddDraftRestored;

  /// No description provided for @quickAddDraftNoPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фотографии в черновик не попадают — их нужно выбрать заново'**
  String get quickAddDraftNoPhotos;

  /// No description provided for @quickAddDraftDiscard.
  ///
  /// In ru, this message translates to:
  /// **'Начать заново'**
  String get quickAddDraftDiscard;

  /// No description provided for @entryRateAction.
  ///
  /// In ru, this message translates to:
  /// **'Поставить оценку'**
  String get entryRateAction;

  /// No description provided for @quickAddRatingLabel.
  ///
  /// In ru, this message translates to:
  /// **'Оценка'**
  String get quickAddRatingLabel;

  /// No description provided for @quickAddRatingNone.
  ///
  /// In ru, this message translates to:
  /// **'Без оценки'**
  String get quickAddRatingNone;

  /// No description provided for @quickAddNoteLabel.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get quickAddNoteLabel;

  /// No description provided for @quickAddPickCategory.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать категорию'**
  String get quickAddPickCategory;

  /// No description provided for @quickAddSearchCategory.
  ///
  /// In ru, this message translates to:
  /// **'Поиск категории'**
  String get quickAddSearchCategory;

  /// No description provided for @categoriesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categoriesTitle;

  /// No description provided for @categoryAddRoot.
  ///
  /// In ru, this message translates to:
  /// **'Новая корневая категория'**
  String get categoryAddRoot;

  /// No description provided for @categoryAddChild.
  ///
  /// In ru, this message translates to:
  /// **'Добавить подкатегорию'**
  String get categoryAddChild;

  /// No description provided for @categoryRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get categoryRename;

  /// No description provided for @categoryMove.
  ///
  /// In ru, this message translates to:
  /// **'Переместить'**
  String get categoryMove;

  /// No description provided for @categoryMoveUp.
  ///
  /// In ru, this message translates to:
  /// **'Выше'**
  String get categoryMoveUp;

  /// No description provided for @categoryMoveDown.
  ///
  /// In ru, this message translates to:
  /// **'Ниже'**
  String get categoryMoveDown;

  /// No description provided for @categoryMoveEdge.
  ///
  /// In ru, this message translates to:
  /// **'Дальше двигать некуда'**
  String get categoryMoveEdge;

  /// No description provided for @categoryArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать'**
  String get categoryArchive;

  /// No description provided for @categoryArchived.
  ///
  /// In ru, this message translates to:
  /// **'Категория убрана в архив'**
  String get categoryArchived;

  /// No description provided for @categoryNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название категории'**
  String get categoryNameLabel;

  /// No description provided for @categoryEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Категорий пока нет'**
  String get categoryEmptyTitle;

  /// No description provided for @categoryEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Создайте первую категорию, чтобы раскладывать записи по полкам.'**
  String get categoryEmptyMessage;

  /// No description provided for @categoryEntriesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись} few{{count} записи} many{{count} записей} other{{count} записей}}'**
  String categoryEntriesCount(int count);

  /// No description provided for @categoryShowSubcategories.
  ///
  /// In ru, this message translates to:
  /// **'Показывать записи из подкатегорий'**
  String get categoryShowSubcategories;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Записей пока нет'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первую запись — это займёт несколько секунд.'**
  String get catalogEmptyMessage;

  /// No description provided for @catalogAllTypes.
  ///
  /// In ru, this message translates to:
  /// **'Все типы'**
  String get catalogAllTypes;

  /// No description provided for @catalogAllRelations.
  ///
  /// In ru, this message translates to:
  /// **'Все отношения'**
  String get catalogAllRelations;

  /// No description provided for @catalogAllCategories.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get catalogAllCategories;

  /// No description provided for @catalogSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по названию'**
  String get catalogSearchHint;

  /// No description provided for @catalogNothingFoundTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get catalogNothingFoundTitle;

  /// No description provided for @catalogNothingFoundMessage.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить фильтры или поисковый запрос.'**
  String get catalogNothingFoundMessage;

  /// No description provided for @catalogResetFilters.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get catalogResetFilters;

  /// No description provided for @bulkSelected.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Выбрана {count} запись} few{Выбрано {count} записи} many{Выбрано {count} записей} other{Выбрано {count} записей}}'**
  String bulkSelected(int count);

  /// No description provided for @bulkSelectAll.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать все'**
  String get bulkSelectAll;

  /// No description provided for @bulkSelectOne.
  ///
  /// In ru, this message translates to:
  /// **'Выделить'**
  String get bulkSelectOne;

  /// No description provided for @bulkCancel.
  ///
  /// In ru, this message translates to:
  /// **'Снять выделение'**
  String get bulkCancel;

  /// No description provided for @bulkSetCategory.
  ///
  /// In ru, this message translates to:
  /// **'В категорию'**
  String get bulkSetCategory;

  /// No description provided for @bulkAddTag.
  ///
  /// In ru, this message translates to:
  /// **'Добавить тег'**
  String get bulkAddTag;

  /// No description provided for @bulkAddToCollection.
  ///
  /// In ru, this message translates to:
  /// **'В подборку'**
  String get bulkAddToCollection;

  /// No description provided for @bulkRelation.
  ///
  /// In ru, this message translates to:
  /// **'Отношение'**
  String get bulkRelation;

  /// No description provided for @bulkRating.
  ///
  /// In ru, this message translates to:
  /// **'Оценка'**
  String get bulkRating;

  /// No description provided for @bulkRemoveTag.
  ///
  /// In ru, this message translates to:
  /// **'Снять тег'**
  String get bulkRemoveTag;

  /// No description provided for @bulkRemoveTagEmpty.
  ///
  /// In ru, this message translates to:
  /// **'У выделенных записей нет тегов'**
  String get bulkRemoveTagEmpty;

  /// No description provided for @bulkMore.
  ///
  /// In ru, this message translates to:
  /// **'Ещё'**
  String get bulkMore;

  /// No description provided for @bulkDone.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Изменена {count} запись} few{Изменено {count} записи} many{Изменено {count} записей} other{Изменено {count} записей}}'**
  String bulkDone(int count);

  /// No description provided for @bulkArchive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get bulkArchive;

  /// No description provided for @bulkArchived.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись убрана в архив} few{{count} записи убраны в архив} many{{count} записей убрано в архив} other{{count} записей убрано в архив}}'**
  String bulkArchived(int count);

  /// No description provided for @entryOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get entryOpen;

  /// No description provided for @catalogAddedHiddenByFilters.
  ///
  /// In ru, this message translates to:
  /// **'Запись добавлена, но не подходит под текущие фильтры'**
  String get catalogAddedHiddenByFilters;

  /// No description provided for @catalogViewGrid.
  ///
  /// In ru, this message translates to:
  /// **'Крупная сетка'**
  String get catalogViewGrid;

  /// No description provided for @catalogViewCompact.
  ///
  /// In ru, this message translates to:
  /// **'Компактная сетка'**
  String get catalogViewCompact;

  /// No description provided for @catalogViewList.
  ///
  /// In ru, this message translates to:
  /// **'Список'**
  String get catalogViewList;

  /// No description provided for @catalogSortRecent.
  ///
  /// In ru, this message translates to:
  /// **'Недавно добавленные'**
  String get catalogSortRecent;

  /// No description provided for @catalogSortTitle.
  ///
  /// In ru, this message translates to:
  /// **'По названию'**
  String get catalogSortTitle;

  /// No description provided for @catalogSortRating.
  ///
  /// In ru, this message translates to:
  /// **'По оценке'**
  String get catalogSortRating;

  /// No description provided for @catalogSortImpression.
  ///
  /// In ru, this message translates to:
  /// **'По дате впечатления'**
  String get catalogSortImpression;

  /// No description provided for @catalogSortLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get catalogSortLabel;

  /// No description provided for @catalogSortNatural.
  ///
  /// In ru, this message translates to:
  /// **'Обычный порядок'**
  String get catalogSortNatural;

  /// No description provided for @catalogSortReversed.
  ///
  /// In ru, this message translates to:
  /// **'Обратный порядок'**
  String get catalogSortReversed;

  /// No description provided for @catalogWithoutRating.
  ///
  /// In ru, this message translates to:
  /// **'Без оценки'**
  String get catalogWithoutRating;

  /// No description provided for @catalogWithoutCategory.
  ///
  /// In ru, this message translates to:
  /// **'Без категории'**
  String get catalogWithoutCategory;

  /// No description provided for @catalogWithoutPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Без фотографии'**
  String get catalogWithoutPhoto;

  /// No description provided for @catalogRecommended.
  ///
  /// In ru, this message translates to:
  /// **'Мне посоветовали'**
  String get catalogRecommended;

  /// No description provided for @catalogFound.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Найдена {count} запись} few{Найдено {count} записи} many{Найдено {count} записей} other{Найдено {count} записей}}'**
  String catalogFound(int count);

  /// No description provided for @entryDetailTitle.
  ///
  /// In ru, this message translates to:
  /// **'Запись'**
  String get entryDetailTitle;

  /// No description provided for @entryHistory.
  ///
  /// In ru, this message translates to:
  /// **'История изменений'**
  String get entryHistory;

  /// No description provided for @entryRestoreRevision.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить эту версию'**
  String get entryRestoreRevision;

  /// No description provided for @entryRestored.
  ///
  /// In ru, this message translates to:
  /// **'Версия восстановлена'**
  String get entryRestored;

  /// No description provided for @entryNoteLabel.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get entryNoteLabel;

  /// No description provided for @entryEditObject.
  ///
  /// In ru, this message translates to:
  /// **'Изменить описание'**
  String get entryEditObject;

  /// No description provided for @entryRecommendedBy.
  ///
  /// In ru, this message translates to:
  /// **'Посоветовал: {name}'**
  String entryRecommendedBy(String name);

  /// No description provided for @entryEditObjectHint.
  ///
  /// In ru, this message translates to:
  /// **'Название, бренд и год относятся к самому объекту и видны во всех профилях, где он есть. Прежние значения останутся в истории.'**
  String get entryEditObjectHint;

  /// No description provided for @entryMerge.
  ///
  /// In ru, this message translates to:
  /// **'Объединить с…'**
  String get entryMerge;

  /// No description provided for @entryMergeTitle.
  ///
  /// In ru, this message translates to:
  /// **'С чем объединить'**
  String get entryMergeTitle;

  /// No description provided for @entryMergeMessage.
  ///
  /// In ru, this message translates to:
  /// **'Записи этого объекта переедут на выбранный. Оценки, заметки, фотографии и история останутся при записях.'**
  String get entryMergeMessage;

  /// No description provided for @entryMergeEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Похожих объектов не нашлось'**
  String get entryMergeEmpty;

  /// No description provided for @entryMergeDone.
  ///
  /// In ru, this message translates to:
  /// **'Объекты объединены'**
  String get entryMergeDone;

  /// No description provided for @entryMergeAction.
  ///
  /// In ru, this message translates to:
  /// **'Объединить'**
  String get entryMergeAction;

  /// No description provided for @entryCreatorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Бренд, автор или режиссёр'**
  String get entryCreatorLabel;

  /// No description provided for @entryYearLabel.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get entryYearLabel;

  /// No description provided for @entryImpressionDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата впечатления'**
  String get entryImpressionDate;

  /// No description provided for @entryImpressionDateNone.
  ///
  /// In ru, this message translates to:
  /// **'Не указана'**
  String get entryImpressionDateNone;

  /// No description provided for @entryImpressionDateClear.
  ///
  /// In ru, this message translates to:
  /// **'Убрать дату'**
  String get entryImpressionDateClear;

  /// No description provided for @entryArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать запись'**
  String get entryArchive;

  /// No description provided for @entryArchived.
  ///
  /// In ru, this message translates to:
  /// **'Запись убрана в архив'**
  String get entryArchived;

  /// No description provided for @entryVersionAt.
  ///
  /// In ru, this message translates to:
  /// **'Версия от {date}'**
  String entryVersionAt(String date);

  /// No description provided for @collectionsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подборки'**
  String get collectionsTitle;

  /// No description provided for @collectionCreate.
  ///
  /// In ru, this message translates to:
  /// **'Новая подборка'**
  String get collectionCreate;

  /// No description provided for @collectionNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название подборки'**
  String get collectionNameLabel;

  /// No description provided for @collectionEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подборок пока нет'**
  String get collectionEmptyTitle;

  /// No description provided for @collectionEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Подборки — это ручные списки: «Посмотреть вместе», «Купить», «Посетить летом».'**
  String get collectionEmptyMessage;

  /// No description provided for @collectionEntriesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись} few{{count} записи} many{{count} записей} other{{count} записей}}'**
  String collectionEntriesCount(int count);

  /// No description provided for @collectionOpenEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В подборке пока нет записей'**
  String get collectionOpenEmpty;

  /// No description provided for @collectionAddTo.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в подборку'**
  String get collectionAddTo;

  /// No description provided for @collectionRemoveFrom.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из подборки'**
  String get collectionRemoveFrom;

  /// No description provided for @collectionRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get collectionRename;

  /// No description provided for @collectionArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать подборку'**
  String get collectionArchive;

  /// No description provided for @collectionArchived.
  ///
  /// In ru, this message translates to:
  /// **'Подборка убрана в архив'**
  String get collectionArchived;

  /// No description provided for @collectionAdded.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в подборку'**
  String get collectionAdded;

  /// No description provided for @photoAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get photoAdd;

  /// No description provided for @photoSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фотографии'**
  String get photoSectionTitle;

  /// No description provided for @photoRejected.
  ///
  /// In ru, this message translates to:
  /// **'Файл отклонён: неподдерживаемый или повреждённый формат'**
  String get photoRejected;

  /// No description provided for @photoDuplicate.
  ///
  /// In ru, this message translates to:
  /// **'Такое изображение уже добавлено'**
  String get photoDuplicate;

  /// No description provided for @photoRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить фотографию'**
  String get photoRemove;

  /// No description provided for @tourTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как пользоваться'**
  String get tourTitle;

  /// No description provided for @tourSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get tourSkip;

  /// No description provided for @tourNext.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get tourNext;

  /// No description provided for @tourFinish.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get tourFinish;

  /// No description provided for @tourRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Пройти обучение заново'**
  String get tourRepeat;

  /// No description provided for @tourAddTitle.
  ///
  /// In ru, this message translates to:
  /// **'Записать впечатление'**
  String get tourAddTitle;

  /// No description provided for @tourAddBody.
  ///
  /// In ru, this message translates to:
  /// **'Для новой записи хватает названия. Отношение, оценка и фотографии — сразу в форме; заметка, дата, теги и подборка прячутся за «Добавить подробности».'**
  String get tourAddBody;

  /// No description provided for @tourAddHintDesktop.
  ///
  /// In ru, this message translates to:
  /// **'Ctrl + N — открыть форму, не отрывая рук от клавиатуры'**
  String get tourAddHintDesktop;

  /// No description provided for @tourAddHintMobile.
  ///
  /// In ru, this message translates to:
  /// **'Оранжевая кнопка «+» внизу справа доступна с любого экрана'**
  String get tourAddHintMobile;

  /// No description provided for @tourScanTitle.
  ///
  /// In ru, this message translates to:
  /// **'Товар по штрихкоду'**
  String get tourScanTitle;

  /// No description provided for @tourScanBodyDesktop.
  ///
  /// In ru, this message translates to:
  /// **'Штрихкод можно ввести руками, считать USB-сканером или распознать с фотографии. Название и бренд подтянутся из открытых товарных баз.'**
  String get tourScanBodyDesktop;

  /// No description provided for @tourScanBodyMobile.
  ///
  /// In ru, this message translates to:
  /// **'Наведите камеру на штрихкод — название и бренд подтянутся из открытых товарных баз. Наружу уходит только сам код.'**
  String get tourScanBodyMobile;

  /// No description provided for @tourScanHintDesktop.
  ///
  /// In ru, this message translates to:
  /// **'Ctrl + B — открыть сканирование'**
  String get tourScanHintDesktop;

  /// No description provided for @tourShelvesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Полки вместо списка'**
  String get tourShelvesTitle;

  /// No description provided for @tourShelvesBody.
  ///
  /// In ru, this message translates to:
  /// **'Категории показываются полками: видно цвет, число записей и фотографии из ветки. Нажатие уводит вглубь, значок списка показывает записи самой полки. Кто привык к дереву — переключатель рядом с заголовком.'**
  String get tourShelvesBody;

  /// No description provided for @tourSearchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Найти за секунду'**
  String get tourSearchTitle;

  /// No description provided for @tourSearchBody.
  ///
  /// In ru, this message translates to:
  /// **'Поиск идёт по названиям и по тексту заметок. Фильтры по типу, категории, отношению и тегам прячутся за кнопкой «Фильтры», а включённые подсвечиваются.'**
  String get tourSearchBody;

  /// No description provided for @tourSearchHintDesktop.
  ///
  /// In ru, this message translates to:
  /// **'Ctrl + F — перейти в поиск'**
  String get tourSearchHintDesktop;

  /// No description provided for @tourBulkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разом, а не по одной'**
  String get tourBulkTitle;

  /// No description provided for @tourBulkBodyDesktop.
  ///
  /// In ru, this message translates to:
  /// **'Ctrl + нажатие выделяет записи. Выделенным можно сразу назначить категорию, добавить тег, положить в подборку или убрать в архив. Правая кнопка открывает меню записи.'**
  String get tourBulkBodyDesktop;

  /// No description provided for @tourBulkBodyMobile.
  ///
  /// In ru, this message translates to:
  /// **'Долгое нажатие включает выделение. Выделенным можно сразу назначить категорию, добавить тег, положить в подборку или убрать в архив.'**
  String get tourBulkBodyMobile;

  /// No description provided for @tourSafetyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не пропадает'**
  String get tourSafetyTitle;

  /// No description provided for @tourSafetyBody.
  ///
  /// In ru, this message translates to:
  /// **'Убранное уходит в архив и возвращается оттуда целым. Каждое изменение записи сохраняется отдельной версией. В настройках есть резервные копии — их можно создать и развернуть обратно.'**
  String get tourSafetyBody;

  /// No description provided for @searchClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить поиск'**
  String get searchClear;

  /// No description provided for @catalogFilters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get catalogFilters;

  /// No description provided for @categoryDefaultType.
  ///
  /// In ru, this message translates to:
  /// **'Тип по умолчанию'**
  String get categoryDefaultType;

  /// No description provided for @categoryDefaultTypeHint.
  ///
  /// In ru, this message translates to:
  /// **'С него начинается новая запись в этой ветке'**
  String get categoryDefaultTypeHint;

  /// No description provided for @categoryDefaultTypeNone.
  ///
  /// In ru, this message translates to:
  /// **'Не задан'**
  String get categoryDefaultTypeNone;

  /// No description provided for @categoryDefaultTypeFrom.
  ///
  /// In ru, this message translates to:
  /// **'Тип взят из «{name}»'**
  String categoryDefaultTypeFrom(String name);

  /// No description provided for @categoryDefaultTypeSuggest.
  ///
  /// In ru, this message translates to:
  /// **'В ветке чаще всего «{name}». Сделать типом по умолчанию?'**
  String categoryDefaultTypeSuggest(String name);

  /// No description provided for @categoryDefaultTypeApply.
  ///
  /// In ru, this message translates to:
  /// **'Сделать'**
  String get categoryDefaultTypeApply;

  /// No description provided for @categoryPrimary.
  ///
  /// In ru, this message translates to:
  /// **'Основная категория'**
  String get categoryPrimary;

  /// No description provided for @categoryExtra.
  ///
  /// In ru, this message translates to:
  /// **'Ещё категории'**
  String get categoryExtra;

  /// No description provided for @categoryExtraAdd.
  ///
  /// In ru, this message translates to:
  /// **'Положить ещё на полку'**
  String get categoryExtraAdd;

  /// No description provided for @categoryExtraRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать с этой полки'**
  String get categoryExtraRemove;

  /// No description provided for @categoryExtraBadge.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительная категория'**
  String get categoryExtraBadge;

  /// No description provided for @categoryMerge.
  ///
  /// In ru, this message translates to:
  /// **'Объединить с…'**
  String get categoryMerge;

  /// No description provided for @categoryMergeTitle.
  ///
  /// In ru, this message translates to:
  /// **'С какой веткой объединить'**
  String get categoryMergeTitle;

  /// No description provided for @categoryMergeMessage.
  ///
  /// In ru, this message translates to:
  /// **'Записи и подкатегории переедут в выбранную ветку, а «{name}» уйдёт в архив. Отменить одним нажатием будет нельзя.'**
  String categoryMergeMessage(String name);

  /// No description provided for @categoryMergeAction.
  ///
  /// In ru, this message translates to:
  /// **'Объединить'**
  String get categoryMergeAction;

  /// No description provided for @categoryMergeDone.
  ///
  /// In ru, this message translates to:
  /// **'Ветки объединены'**
  String get categoryMergeDone;

  /// No description provided for @categoryMoveChildren.
  ///
  /// In ru, this message translates to:
  /// **'Перенести подкатегории…'**
  String get categoryMoveChildren;

  /// No description provided for @categoryMoveEntries.
  ///
  /// In ru, this message translates to:
  /// **'Перенести записи…'**
  String get categoryMoveEntries;

  /// No description provided for @categoryMovedCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Перенесена {count} ветка} few{Перенесено {count} ветки} many{Перенесено {count} веток} other{Перенесено {count} веток}}'**
  String categoryMovedCount(int count);

  /// No description provided for @categoryMovedEntries.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Перенесена {count} запись} few{Перенесено {count} записи} many{Перенесено {count} записей} other{Перенесено {count} записей}}'**
  String categoryMovedEntries(int count);

  /// No description provided for @categoryDragHint.
  ///
  /// In ru, this message translates to:
  /// **'Перетащите, чтобы переместить'**
  String get categoryDragHint;

  /// No description provided for @categoryMovedTo.
  ///
  /// In ru, this message translates to:
  /// **'Перенесено в «{name}»'**
  String categoryMovedTo(String name);

  /// No description provided for @categoryAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get categoryAppearance;

  /// No description provided for @categoryColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get categoryColor;

  /// No description provided for @categoryColorInherit.
  ///
  /// In ru, this message translates to:
  /// **'Как у родителя'**
  String get categoryColorInherit;

  /// No description provided for @categoryCover.
  ///
  /// In ru, this message translates to:
  /// **'Обложка ветки'**
  String get categoryCover;

  /// No description provided for @categoryCoverFromEntry.
  ///
  /// In ru, this message translates to:
  /// **'Взять из записи'**
  String get categoryCoverFromEntry;

  /// No description provided for @categoryCoverFromFile.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать файл'**
  String get categoryCoverFromFile;

  /// No description provided for @categoryCoverRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать обложку'**
  String get categoryCoverRemove;

  /// No description provided for @categoryCoverPick.
  ///
  /// In ru, this message translates to:
  /// **'Выберите фотографию из этой ветки'**
  String get categoryCoverPick;

  /// No description provided for @categoryCoverNone.
  ///
  /// In ru, this message translates to:
  /// **'В этой ветке пока нет фотографий'**
  String get categoryCoverNone;

  /// No description provided for @categoryDescriptionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get categoryDescriptionLabel;

  /// No description provided for @categoryDescriptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Что кладут на эту полку'**
  String get categoryDescriptionHint;

  /// No description provided for @categoryIconSearch.
  ///
  /// In ru, this message translates to:
  /// **'Найти значок'**
  String get categoryIconSearch;

  /// No description provided for @categoryScopeHere.
  ///
  /// In ru, this message translates to:
  /// **'Только здесь'**
  String get categoryScopeHere;

  /// No description provided for @categoryScopeBranch.
  ///
  /// In ru, this message translates to:
  /// **'Вся ветка'**
  String get categoryScopeBranch;

  /// No description provided for @categoryShowMore.
  ///
  /// In ru, this message translates to:
  /// **'Показать ещё'**
  String get categoryShowMore;

  /// No description provided for @categoryOpenTree.
  ///
  /// In ru, this message translates to:
  /// **'Показать дерево'**
  String get categoryOpenTree;

  /// No description provided for @categoryShelfEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Внутри пока пусто'**
  String get categoryShelfEmptyTitle;

  /// No description provided for @categoryShelfEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте подкатегорию или заведите сюда первую запись.'**
  String get categoryShelfEmptyMessage;

  /// No description provided for @errorStateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось показать этот раздел'**
  String get errorStateTitle;

  /// No description provided for @errorStateMessage.
  ///
  /// In ru, this message translates to:
  /// **'Данные на месте — сбой произошёл при их чтении. Попробуйте перейти в раздел заново или перезапустить приложение.'**
  String get errorStateMessage;

  /// No description provided for @errorStateDetails.
  ///
  /// In ru, this message translates to:
  /// **'Подробности'**
  String get errorStateDetails;

  /// No description provided for @catalogSearchChip.
  ///
  /// In ru, this message translates to:
  /// **'Поиск: {query}'**
  String catalogSearchChip(String query);

  /// No description provided for @purgeAction.
  ///
  /// In ru, this message translates to:
  /// **'Удалить навсегда'**
  String get purgeAction;

  /// No description provided for @purgeConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{title}» навсегда?'**
  String purgeConfirmTitle(String title);

  /// No description provided for @purgeConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Это не архивирование: запись, её версии и фотографии будут стёрты. Отменить будет нельзя — вернуть можно только из резервной копии.'**
  String get purgeConfirmMessage;

  /// No description provided for @purgeDone.
  ///
  /// In ru, this message translates to:
  /// **'Удалено навсегда'**
  String get purgeDone;

  /// No description provided for @purgeCategoryHasChildren.
  ///
  /// In ru, this message translates to:
  /// **'Сначала разберитесь с подкатегориями: удалять ветку целиком нельзя.'**
  String get purgeCategoryHasChildren;

  /// No description provided for @photoMakeCover.
  ///
  /// In ru, this message translates to:
  /// **'Сделать обложкой'**
  String get photoMakeCover;

  /// No description provided for @photoIsCover.
  ///
  /// In ru, this message translates to:
  /// **'Обложка записи'**
  String get photoIsCover;

  /// No description provided for @photoDropHint.
  ///
  /// In ru, this message translates to:
  /// **'Перетащите изображения сюда'**
  String get photoDropHint;

  /// No description provided for @profilesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профили'**
  String get profilesTitle;

  /// No description provided for @profileCreate.
  ///
  /// In ru, this message translates to:
  /// **'Новый профиль'**
  String get profileCreate;

  /// No description provided for @profileSwitchTo.
  ///
  /// In ru, this message translates to:
  /// **'Сделать активным'**
  String get profileSwitchTo;

  /// No description provided for @profileActiveBadge.
  ///
  /// In ru, this message translates to:
  /// **'Активный'**
  String get profileActiveBadge;

  /// No description provided for @profileTypePrimary.
  ///
  /// In ru, this message translates to:
  /// **'Мой основной профиль'**
  String get profileTypePrimary;

  /// No description provided for @profileTypeOtherDevice.
  ///
  /// In ru, this message translates to:
  /// **'Мой профиль на другом устройстве'**
  String get profileTypeOtherDevice;

  /// No description provided for @profileTypeExternal.
  ///
  /// In ru, this message translates to:
  /// **'Внешний профиль'**
  String get profileTypeExternal;

  /// No description provided for @profileTypeExternalArchived.
  ///
  /// In ru, this message translates to:
  /// **'Архивный внешний профиль'**
  String get profileTypeExternalArchived;

  /// No description provided for @profileLocalSettings.
  ///
  /// In ru, this message translates to:
  /// **'Локальные настройки'**
  String get profileLocalSettings;

  /// No description provided for @profileLocalHint.
  ///
  /// In ru, this message translates to:
  /// **'Эти данные видны только вам и не передаются при экспорте.'**
  String get profileLocalHint;

  /// No description provided for @profileLocalName.
  ///
  /// In ru, this message translates to:
  /// **'Локальное имя'**
  String get profileLocalName;

  /// No description provided for @profileLocalNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Саша с работы'**
  String get profileLocalNameHint;

  /// No description provided for @profileLocalNote.
  ///
  /// In ru, this message translates to:
  /// **'Заметка о человеке'**
  String get profileLocalNote;

  /// No description provided for @profileEntriesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись} few{{count} записи} many{{count} записей} other{{count} записей}}'**
  String profileEntriesCount(int count);

  /// No description provided for @compareTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение профилей'**
  String get compareTitle;

  /// No description provided for @compareFirst.
  ///
  /// In ru, this message translates to:
  /// **'Первый профиль'**
  String get compareFirst;

  /// No description provided for @compareSecond.
  ///
  /// In ru, this message translates to:
  /// **'Второй профиль'**
  String get compareSecond;

  /// No description provided for @compareNeedTwo.
  ///
  /// In ru, this message translates to:
  /// **'Нужны два разных профиля'**
  String get compareNeedTwo;

  /// No description provided for @compareNeedTwoMessage.
  ///
  /// In ru, this message translates to:
  /// **'Создайте или импортируйте ещё один профиль, чтобы сравнивать предпочтения.'**
  String get compareNeedTwoMessage;

  /// No description provided for @compareModeOnlyFirst.
  ///
  /// In ru, this message translates to:
  /// **'Есть у первого, нет у второго'**
  String get compareModeOnlyFirst;

  /// No description provided for @compareModeOnlySecond.
  ///
  /// In ru, this message translates to:
  /// **'Есть у второго, нет у первого'**
  String get compareModeOnlySecond;

  /// No description provided for @compareModeBoth.
  ///
  /// In ru, this message translates to:
  /// **'Есть у обоих'**
  String get compareModeBoth;

  /// No description provided for @compareModeBothLike.
  ///
  /// In ru, this message translates to:
  /// **'Нравится обоим'**
  String get compareModeBothLike;

  /// No description provided for @compareModeRatingDiffers.
  ///
  /// In ru, this message translates to:
  /// **'Оценки сильно отличаются'**
  String get compareModeRatingDiffers;

  /// No description provided for @compareModeRecommended.
  ///
  /// In ru, this message translates to:
  /// **'Первый рекомендует, второй не добавил'**
  String get compareModeRecommended;

  /// No description provided for @compareEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Совпадений нет'**
  String get compareEmpty;

  /// No description provided for @compareEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте другой режим сравнения или профили.'**
  String get compareEmptyMessage;

  /// No description provided for @compareSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String compareSelected(int count);

  /// No description provided for @compareTransferSelected.
  ///
  /// In ru, this message translates to:
  /// **'Добавить выбранное себе'**
  String get compareTransferSelected;

  /// No description provided for @compareTransferred.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено записей: {count}'**
  String compareTransferred(int count);

  /// No description provided for @compareNoEntry.
  ///
  /// In ru, this message translates to:
  /// **'Нет записи'**
  String get compareNoEntry;

  /// No description provided for @transferTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в мой профиль'**
  String get transferTitle;

  /// No description provided for @transferDone.
  ///
  /// In ru, this message translates to:
  /// **'Запись добавлена в ваш профиль'**
  String get transferDone;

  /// No description provided for @transferAlreadyHave.
  ///
  /// In ru, this message translates to:
  /// **'У вас уже есть запись об этом объекте'**
  String get transferAlreadyHave;

  /// No description provided for @exportTitle.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт профиля'**
  String get exportTitle;

  /// No description provided for @exportAction.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировать'**
  String get exportAction;

  /// No description provided for @exportIncludePhotos.
  ///
  /// In ru, this message translates to:
  /// **'С фотографиями'**
  String get exportIncludePhotos;

  /// No description provided for @exportProtect.
  ///
  /// In ru, this message translates to:
  /// **'Защитить паролем'**
  String get exportProtect;

  /// No description provided for @exportPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль пакета'**
  String get exportPassword;

  /// No description provided for @exportComposition.
  ///
  /// In ru, this message translates to:
  /// **'Что войдёт в файл'**
  String get exportComposition;

  /// No description provided for @exportEntries.
  ///
  /// In ru, this message translates to:
  /// **'Записей'**
  String get exportEntries;

  /// No description provided for @exportCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категорий'**
  String get exportCategories;

  /// No description provided for @exportSubcategories.
  ///
  /// In ru, this message translates to:
  /// **'из них подкатегорий'**
  String get exportSubcategories;

  /// No description provided for @exportObjects.
  ///
  /// In ru, this message translates to:
  /// **'Объектов'**
  String get exportObjects;

  /// No description provided for @exportRevisions.
  ///
  /// In ru, this message translates to:
  /// **'Версий'**
  String get exportRevisions;

  /// No description provided for @exportPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фотографий'**
  String get exportPhotos;

  /// No description provided for @exportExcludedPrivate.
  ///
  /// In ru, this message translates to:
  /// **'Исключено приватных записей'**
  String get exportExcludedPrivate;

  /// No description provided for @exportForbidden.
  ///
  /// In ru, this message translates to:
  /// **'Владелец запретил повторную передачу этого профиля'**
  String get exportForbidden;

  /// No description provided for @fileSaved.
  ///
  /// In ru, this message translates to:
  /// **'Файл сохранён: {path}'**
  String fileSaved(String path);

  /// No description provided for @fileShared.
  ///
  /// In ru, this message translates to:
  /// **'Файл готов и передан выбранному приложению'**
  String get fileShared;

  /// No description provided for @fileSaveCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение отменено'**
  String get fileSaveCancelled;

  /// No description provided for @fileSaveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить: {error}'**
  String fileSaveFailed(String error);

  /// No description provided for @importTitle.
  ///
  /// In ru, this message translates to:
  /// **'Импорт профиля'**
  String get importTitle;

  /// No description provided for @importPickFile.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать файл'**
  String get importPickFile;

  /// No description provided for @importDropHint.
  ///
  /// In ru, this message translates to:
  /// **'Перетащите файл профиля сюда или выберите его'**
  String get importDropHint;

  /// No description provided for @importPreviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Предварительный просмотр'**
  String get importPreviewTitle;

  /// No description provided for @importProfileLine.
  ///
  /// In ru, this message translates to:
  /// **'Профиль: {name}'**
  String importProfileLine(String name);

  /// No description provided for @importFingerprintLine.
  ///
  /// In ru, this message translates to:
  /// **'Отпечаток: {value}'**
  String importFingerprintLine(String value);

  /// No description provided for @importTrustQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Новый профиль. Доверять этому профилю?'**
  String get importTrustQuestion;

  /// No description provided for @importVerified.
  ///
  /// In ru, this message translates to:
  /// **'Профиль подтверждён, подпись файла корректна'**
  String get importVerified;

  /// No description provided for @importNoChanges.
  ///
  /// In ru, this message translates to:
  /// **'Этот пакет уже был импортирован. Новых изменений нет.'**
  String get importNoChanges;

  /// No description provided for @importNewEntries.
  ///
  /// In ru, this message translates to:
  /// **'Новых записей'**
  String get importNewEntries;

  /// No description provided for @importChangedEntries.
  ///
  /// In ru, this message translates to:
  /// **'Изменённых записей'**
  String get importChangedEntries;

  /// No description provided for @importNewCategories.
  ///
  /// In ru, this message translates to:
  /// **'Новых категорий'**
  String get importNewCategories;

  /// No description provided for @importMovedCategories.
  ///
  /// In ru, this message translates to:
  /// **'Перемещённых категорий'**
  String get importMovedCategories;

  /// No description provided for @importNewImages.
  ///
  /// In ru, this message translates to:
  /// **'Новых изображений'**
  String get importNewImages;

  /// No description provided for @importUnchanged.
  ///
  /// In ru, this message translates to:
  /// **'Без изменений'**
  String get importUnchanged;

  /// No description provided for @importApply.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать'**
  String get importApply;

  /// No description provided for @importDone.
  ///
  /// In ru, this message translates to:
  /// **'Импорт завершён'**
  String get importDone;

  /// No description provided for @importBackupCreated.
  ///
  /// In ru, this message translates to:
  /// **'Создана резервная копия перед импортом'**
  String get importBackupCreated;

  /// No description provided for @importPasswordNeeded.
  ///
  /// In ru, this message translates to:
  /// **'Пакет защищён паролем'**
  String get importPasswordNeeded;

  /// No description provided for @importErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Импорт не выполнен'**
  String get importErrorTitle;

  /// No description provided for @backupsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Резервные копии'**
  String get backupsTitle;

  /// No description provided for @backupCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать копию'**
  String get backupCreate;

  /// No description provided for @backupCreated.
  ///
  /// In ru, this message translates to:
  /// **'Копия создана'**
  String get backupCreated;

  /// No description provided for @backupVerifyOk.
  ///
  /// In ru, this message translates to:
  /// **'Копия цела'**
  String get backupVerifyOk;

  /// No description provided for @backupVerifyFailed.
  ///
  /// In ru, this message translates to:
  /// **'Копия повреждена'**
  String get backupVerifyFailed;

  /// No description provided for @backupReasonManual.
  ///
  /// In ru, this message translates to:
  /// **'вручную'**
  String get backupReasonManual;

  /// No description provided for @backupReasonAuto.
  ///
  /// In ru, this message translates to:
  /// **'по расписанию'**
  String get backupReasonAuto;

  /// No description provided for @backupReasonBeforeImport.
  ///
  /// In ru, this message translates to:
  /// **'перед импортом'**
  String get backupReasonBeforeImport;

  /// No description provided for @backupReasonBeforeRestore.
  ///
  /// In ru, this message translates to:
  /// **'перед восстановлением'**
  String get backupReasonBeforeRestore;

  /// No description provided for @backupReasonBeforeEncrypt.
  ///
  /// In ru, this message translates to:
  /// **'перед сменой шифрования'**
  String get backupReasonBeforeEncrypt;

  /// No description provided for @backupAutoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Делать копию самому'**
  String get backupAutoTitle;

  /// No description provided for @backupAutoHint.
  ///
  /// In ru, this message translates to:
  /// **'Раз в неделю при запуске приложение сохраняет записи и фотографии в копию. Копии лежат на этом же устройстве, поэтому от его потери они не спасают — сохраните одну к себе кнопкой рядом с копией.'**
  String get backupAutoHint;

  /// No description provided for @backupSaveToFile.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить к себе'**
  String get backupSaveToFile;

  /// No description provided for @backupRestoreFromFile.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить из файла'**
  String get backupRestoreFromFile;

  /// No description provided for @backupOutsideHint.
  ///
  /// In ru, this message translates to:
  /// **'Копия лежит внутри приложения: удалите его — и копии не станет. Кнопка «Сохранить к себе» кладёт её туда, где вы её найдёте: на компьютере в выбранную папку, на телефоне через «Поделиться».'**
  String get backupOutsideHint;

  /// No description provided for @backupAutoOn.
  ///
  /// In ru, this message translates to:
  /// **'Копии будут создаваться сами'**
  String get backupAutoOn;

  /// No description provided for @backupAutoOff.
  ///
  /// In ru, this message translates to:
  /// **'Копии создаются только вручную'**
  String get backupAutoOff;

  /// No description provided for @backupEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Резервных копий пока нет'**
  String get backupEmpty;

  /// No description provided for @backupVerify.
  ///
  /// In ru, this message translates to:
  /// **'Проверить целостность'**
  String get backupVerify;

  /// No description provided for @backupSizeLabel.
  ///
  /// In ru, this message translates to:
  /// **'{size} КБ'**
  String backupSizeLabel(String size);

  /// No description provided for @backupRetentionHint.
  ///
  /// In ru, this message translates to:
  /// **'Автоматические копии создаются раз в неделю, а также перед импортом и восстановлением. Хранятся последние 7 автоматических и 20 созданных вручную.'**
  String get backupRetentionHint;

  /// No description provided for @backupRestore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get backupRestore;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить из копии?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Все записи, категории и фотографии будут заменены содержимым копии от {date}. Копия нынешнего состояния будет создана автоматически, так что вернуться будет куда.'**
  String backupRestoreConfirmMessage(String date);

  /// No description provided for @backupRestoreFileConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Все записи, категории и фотографии будут заменены содержимым файла «{name}». Копия нынешнего состояния будет создана автоматически, так что вернуться будет куда.'**
  String backupRestoreFileConfirmMessage(String name);

  /// No description provided for @backupRestoreDoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Копия восстановлена'**
  String get backupRestoreDoneTitle;

  /// No description provided for @backupRestoreDoneMessage.
  ///
  /// In ru, this message translates to:
  /// **'Данные заменены. Закройте приложение и откройте снова — работать с восстановленной базой можно только после перезапуска.'**
  String get backupRestoreDoneMessage;

  /// No description provided for @backupRestoreQuit.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть приложение'**
  String get backupRestoreQuit;

  /// No description provided for @backupRestoreNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Файл копии не найден'**
  String get backupRestoreNotFound;

  /// No description provided for @backupRestoreTooNew.
  ///
  /// In ru, this message translates to:
  /// **'Копия сделана более новой версией приложения. Обновите приложение и попробуйте снова.'**
  String get backupRestoreTooNew;

  /// No description provided for @backupEncryptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Защищать копии паролем'**
  String get backupEncryptionTitle;

  /// No description provided for @backupEncryptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Копия, унесённая с устройства, без пароля не читается. На этом устройстве копии открываются сами — пароль спрашивают только чужие.'**
  String get backupEncryptionHint;

  /// No description provided for @backupEncryptionOn.
  ///
  /// In ru, this message translates to:
  /// **'Копии защищены паролем'**
  String get backupEncryptionOn;

  /// No description provided for @backupEncryptionOff.
  ///
  /// In ru, this message translates to:
  /// **'Защита копий выключена'**
  String get backupEncryptionOff;

  /// No description provided for @backupEncryptionChange.
  ///
  /// In ru, this message translates to:
  /// **'Сменить пароль'**
  String get backupEncryptionChange;

  /// No description provided for @backupEncryptionUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Хранилище ключей операционной системы недоступно — защитить копии нечем.'**
  String get backupEncryptionUnavailable;

  /// No description provided for @backupPasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пароль для копий'**
  String get backupPasswordTitle;

  /// No description provided for @backupPasswordMessage.
  ///
  /// In ru, this message translates to:
  /// **'Забытый пароль означает потерю копий: восстановить их будет нечем. Запишите его там же, где остальные важные пароли.'**
  String get backupPasswordMessage;

  /// No description provided for @backupPasswordField.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get backupPasswordField;

  /// No description provided for @backupPasswordRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Ещё раз'**
  String get backupPasswordRepeat;

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get backupPasswordMismatch;

  /// No description provided for @backupPasswordShort.
  ///
  /// In ru, this message translates to:
  /// **'Не короче восьми знаков'**
  String get backupPasswordShort;

  /// No description provided for @backupPasswordChangedNote.
  ///
  /// In ru, this message translates to:
  /// **'Уже созданные копии продолжат открываться прежним паролем: он записан в каждом файле и задним числом не меняется.'**
  String get backupPasswordChangedNote;

  /// No description provided for @backupDisableTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выключить защиту копий?'**
  String get backupDisableTitle;

  /// No description provided for @backupDisableMessage.
  ///
  /// In ru, this message translates to:
  /// **'Новые копии будут создаваться без пароля. Уже созданные по-прежнему потребуют старый пароль.'**
  String get backupDisableMessage;

  /// No description provided for @backupUnlockTitle.
  ///
  /// In ru, this message translates to:
  /// **'Копия защищена паролем'**
  String get backupUnlockTitle;

  /// No description provided for @backupUnlockMessage.
  ///
  /// In ru, this message translates to:
  /// **'Эта копия сделана на другом устройстве или до переустановки, поэтому ключа к ней здесь нет.'**
  String get backupUnlockMessage;

  /// No description provided for @backupWrongPassword.
  ///
  /// In ru, this message translates to:
  /// **'Неверный пароль'**
  String get backupWrongPassword;

  /// No description provided for @backupEncryptedBadge.
  ///
  /// In ru, this message translates to:
  /// **'под паролем'**
  String get backupEncryptedBadge;

  /// No description provided for @quickAddTypeVsCategory.
  ///
  /// In ru, this message translates to:
  /// **'Тип задаёт набор полей записи, категория — вашу полку в дереве.'**
  String get quickAddTypeVsCategory;

  /// No description provided for @entryRatingOf.
  ///
  /// In ru, this message translates to:
  /// **'оценка {value}'**
  String entryRatingOf(Object value);

  /// No description provided for @a11yCategoryShelf.
  ///
  /// In ru, this message translates to:
  /// **'{name}, {count}'**
  String a11yCategoryShelf(Object count, Object name);

  /// No description provided for @a11ySummaryItem.
  ///
  /// In ru, this message translates to:
  /// **'{label}: {value}'**
  String a11ySummaryItem(Object label, Object value);

  /// No description provided for @errorLogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Журнал ошибок'**
  String get errorLogTitle;

  /// No description provided for @errorLogHint.
  ///
  /// In ru, this message translates to:
  /// **'Сбои записываются на этом устройстве и никуда не отправляются. Если приложение повело себя странно, скопируйте журнал и приложите к сообщению об ошибке.'**
  String get errorLogHint;

  /// No description provided for @errorLogEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сбоев не было'**
  String get errorLogEmpty;

  /// No description provided for @errorLogCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись} few{{count} записи} many{{count} записей} other{{count} записи}}'**
  String errorLogCount(num count);

  /// No description provided for @errorLogShow.
  ///
  /// In ru, this message translates to:
  /// **'Показать'**
  String get errorLogShow;

  /// No description provided for @errorLogCopy.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get errorLogCopy;

  /// No description provided for @errorLogCopied.
  ///
  /// In ru, this message translates to:
  /// **'Журнал скопирован в буфер обмена'**
  String get errorLogCopied;

  /// No description provided for @errorLogClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get errorLogClear;

  /// No description provided for @errorLogCleared.
  ///
  /// In ru, this message translates to:
  /// **'Журнал очищен'**
  String get errorLogCleared;

  /// No description provided for @settingsAdvanced.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительно'**
  String get settingsAdvanced;

  /// No description provided for @settingsAdvancedHint.
  ///
  /// In ru, this message translates to:
  /// **'Настраивают один раз или не трогают вовсе'**
  String get settingsAdvancedHint;

  /// No description provided for @whatsNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что нового'**
  String get whatsNewTitle;

  /// No description provided for @whatsNewVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String whatsNewVersion(String version);

  /// No description provided for @whatsNewOpen.
  ///
  /// In ru, this message translates to:
  /// **'Что нового в этой версии'**
  String get whatsNewOpen;

  /// No description provided for @whatsNewNothing.
  ///
  /// In ru, this message translates to:
  /// **'Для этой версии описания нет'**
  String get whatsNewNothing;

  /// No description provided for @savedFiltersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отборы'**
  String get savedFiltersTitle;

  /// No description provided for @savedFiltersSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить отбор'**
  String get savedFiltersSave;

  /// No description provided for @savedFiltersName.
  ///
  /// In ru, this message translates to:
  /// **'Название отбора'**
  String get savedFiltersName;

  /// No description provided for @savedFiltersEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сохранённых отборов пока нет'**
  String get savedFiltersEmpty;

  /// No description provided for @savedFiltersSaved.
  ///
  /// In ru, this message translates to:
  /// **'Отбор сохранён'**
  String get savedFiltersSaved;

  /// No description provided for @recentSearches.
  ///
  /// In ru, this message translates to:
  /// **'Недавние запросы'**
  String get recentSearches;

  /// No description provided for @recentEntries.
  ///
  /// In ru, this message translates to:
  /// **'Недавно открытые'**
  String get recentEntries;

  /// No description provided for @commandPaletteHint.
  ///
  /// In ru, this message translates to:
  /// **'Раздел, категория, запись или действие'**
  String get commandPaletteHint;

  /// No description provided for @commandPaletteSections.
  ///
  /// In ru, this message translates to:
  /// **'Разделы'**
  String get commandPaletteSections;

  /// No description provided for @commandPaletteCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get commandPaletteCategories;

  /// No description provided for @entrySimilar.
  ///
  /// In ru, this message translates to:
  /// **'Похожее рядом'**
  String get entrySimilar;

  /// No description provided for @barcodeBatchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать подряд'**
  String get barcodeBatchTitle;

  /// No description provided for @barcodeBatchNext.
  ///
  /// In ru, this message translates to:
  /// **'Взять и сканировать дальше'**
  String get barcodeBatchNext;

  /// No description provided for @barcodeBatchFinish.
  ///
  /// In ru, this message translates to:
  /// **'Хватит'**
  String get barcodeBatchFinish;

  /// No description provided for @barcodeBatchCollected.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Собран {count} код} few{Собрано {count} кода} many{Собрано {count} кодов} other{Собрано {count} кодов}}'**
  String barcodeBatchCollected(int count);

  /// No description provided for @barcodeBatchQueue.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Осталось ещё {count} код} few{Осталось ещё {count} кода} many{Осталось ещё {count} кодов} other{Осталось ещё {count} кодов}}'**
  String barcodeBatchQueue(int count);

  /// No description provided for @entryDuplicate.
  ///
  /// In ru, this message translates to:
  /// **'Дублировать'**
  String get entryDuplicate;

  /// No description provided for @csvImportTitle.
  ///
  /// In ru, this message translates to:
  /// **'Список из таблицы'**
  String get csvImportTitle;

  /// No description provided for @csvImportHint.
  ///
  /// In ru, this message translates to:
  /// **'Перенести записи из CSV — своей же выгрузки или таблицы из другого приложения. Недостающие типы и категории заведутся сами.'**
  String get csvImportHint;

  /// No description provided for @csvImportPick.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать таблицу'**
  String get csvImportPick;

  /// No description provided for @csvImportFound.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Готова {count} запись} few{Готовы {count} записи} many{Готово {count} записей} other{Готово {count} записей}}'**
  String csvImportFound(int count);

  /// No description provided for @csvImportSkipped.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} строка без названия пропущена} few{{count} строки без названия пропущены} many{{count} строк без названия пропущено} other{{count} строк без названия пропущено}}'**
  String csvImportSkipped(int count);

  /// No description provided for @csvImportColumns.
  ///
  /// In ru, this message translates to:
  /// **'Колонки: {columns}'**
  String csvImportColumns(String columns);

  /// No description provided for @csvImportApply.
  ///
  /// In ru, this message translates to:
  /// **'Перенести'**
  String get csvImportApply;

  /// No description provided for @csvImportNothing.
  ///
  /// In ru, this message translates to:
  /// **'В таблице не нашлось ни одной записи с названием'**
  String get csvImportNothing;

  /// No description provided for @csvImportDone.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Перенесена {count} запись} few{Перенесено {count} записи} many{Перенесено {count} записей} other{Перенесено {count} записей}}'**
  String csvImportDone(int count);

  /// No description provided for @backupMirrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Класть копию ещё и сюда'**
  String get backupMirrorTitle;

  /// No description provided for @backupMirrorHint.
  ///
  /// In ru, this message translates to:
  /// **'Копии лежат рядом с базой: потеряли устройство — потеряли и копии. Папка на флешке или в облачном клиенте переживёт устройство.'**
  String get backupMirrorHint;

  /// No description provided for @backupMirrorChoose.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать папку'**
  String get backupMirrorChoose;

  /// No description provided for @backupMirrorClear.
  ///
  /// In ru, this message translates to:
  /// **'Не класть'**
  String get backupMirrorClear;

  /// No description provided for @backupMirrorOff.
  ///
  /// In ru, this message translates to:
  /// **'Копии никуда не дублируются'**
  String get backupMirrorOff;

  /// No description provided for @doctorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверка данных'**
  String get doctorTitle;

  /// No description provided for @doctorHint.
  ///
  /// In ru, this message translates to:
  /// **'Сверяет фотографии, версии записей, связи и поисковый индекс. Ничего не удаляет из того, что несёт смысл.'**
  String get doctorHint;

  /// No description provided for @doctorRun.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get doctorRun;

  /// No description provided for @doctorRepair.
  ///
  /// In ru, this message translates to:
  /// **'Починить'**
  String get doctorRepair;

  /// No description provided for @doctorClean.
  ///
  /// In ru, this message translates to:
  /// **'Расхождений не найдено'**
  String get doctorClean;

  /// No description provided for @doctorFixed.
  ///
  /// In ru, this message translates to:
  /// **'Починено'**
  String get doctorFixed;

  /// No description provided for @doctorOrphanFiles.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} лишний файл фотографии} few{{count} лишних файла фотографий} many{{count} лишних файлов фотографий} other{{count} лишних файлов фотографий}}'**
  String doctorOrphanFiles(int count);

  /// No description provided for @doctorMissingFiles.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} фотография потеряна} few{{count} фотографии потеряны} many{{count} фотографий потеряно} other{{count} фотографий потеряно}}'**
  String doctorMissingFiles(int count);

  /// No description provided for @doctorEntriesWithoutRevision.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись без текущей версии} few{{count} записи без текущей версии} many{{count} записей без текущей версии} other{{count} записей без текущей версии}}'**
  String doctorEntriesWithoutRevision(int count);

  /// No description provided for @doctorDanglingCategories.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} связь с исчезнувшей категорией} few{{count} связи с исчезнувшими категориями} many{{count} связей с исчезнувшими категориями} other{{count} связей с исчезнувшими категориями}}'**
  String doctorDanglingCategories(int count);

  /// No description provided for @doctorDanglingCollectionEntries.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись подборки указывает в пустоту} few{{count} записи подборки указывают в пустоту} many{{count} записей подборки указывают в пустоту} other{{count} записей подборки указывают в пустоту}}'**
  String doctorDanglingCollectionEntries(int count);

  /// No description provided for @doctorSearchOutOfSync.
  ///
  /// In ru, this message translates to:
  /// **'Поисковый индекс отстал от записей'**
  String get doctorSearchOutOfSync;

  /// No description provided for @settingsSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по настройкам'**
  String get settingsSearch;

  /// No description provided for @settingsSearchEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не нашлось'**
  String get settingsSearchEmpty;

  /// No description provided for @settingsSearchEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте другое слово: например, «копии» или «тема».'**
  String get settingsSearchEmptyHint;

  /// No description provided for @settingsWordsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'тема цвет вид тёмная светлая оформление плотность'**
  String get settingsWordsAppearance;

  /// No description provided for @settingsWordsBehaviour.
  ///
  /// In ru, this message translates to:
  /// **'поведение подкатегории перенос записей обучение'**
  String get settingsWordsBehaviour;

  /// No description provided for @settingsWordsBackups.
  ///
  /// In ru, this message translates to:
  /// **'копии резервные восстановление пароль шифрование расписание'**
  String get settingsWordsBackups;

  /// No description provided for @settingsWordsNetwork.
  ///
  /// In ru, this message translates to:
  /// **'сеть интернет штрихкод источники обновления'**
  String get settingsWordsNetwork;

  /// No description provided for @settingsWordsTypes.
  ///
  /// In ru, this message translates to:
  /// **'типы объектов поля'**
  String get settingsWordsTypes;

  /// No description provided for @settingsWordsTags.
  ///
  /// In ru, this message translates to:
  /// **'теги метки'**
  String get settingsWordsTags;

  /// No description provided for @settingsWordsDevices.
  ///
  /// In ru, this message translates to:
  /// **'устройства обмен'**
  String get settingsWordsDevices;

  /// No description provided for @settingsWordsKeyStorage.
  ///
  /// In ru, this message translates to:
  /// **'ключ хранилище шифрование'**
  String get settingsWordsKeyStorage;

  /// No description provided for @settingsWordsDoctor.
  ///
  /// In ru, this message translates to:
  /// **'проверка целостность данные починить фотографии индекс'**
  String get settingsWordsDoctor;

  /// No description provided for @settingsWordsErrorLog.
  ///
  /// In ru, this message translates to:
  /// **'ошибки журнал сбои'**
  String get settingsWordsErrorLog;

  /// No description provided for @settingsWordsAbout.
  ///
  /// In ru, this message translates to:
  /// **'о приложении версия лицензия горячие клавиши'**
  String get settingsWordsAbout;

  /// No description provided for @settingsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settingsTheme;

  /// No description provided for @settingsBehaviour.
  ///
  /// In ru, this message translates to:
  /// **'Поведение'**
  String get settingsBehaviour;

  /// No description provided for @settingsShowSubcategoriesDefault.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию показывать записи из подкатегорий'**
  String get settingsShowSubcategoriesDefault;

  /// No description provided for @settingsTransferMode.
  ///
  /// In ru, this message translates to:
  /// **'При переносе записей'**
  String get settingsTransferMode;

  /// No description provided for @settingsTransferSuggest.
  ///
  /// In ru, this message translates to:
  /// **'Предлагать совпадающий путь'**
  String get settingsTransferSuggest;

  /// No description provided for @settingsTransferAutoCreate.
  ///
  /// In ru, this message translates to:
  /// **'Автоматически создавать отсутствующие категории'**
  String get settingsTransferAutoCreate;

  /// No description provided for @settingsTransferAlwaysAsk.
  ///
  /// In ru, this message translates to:
  /// **'Всегда спрашивать'**
  String get settingsTransferAlwaysAsk;

  /// No description provided for @settingsTransferNoCategory.
  ///
  /// In ru, this message translates to:
  /// **'Сохранять без категории'**
  String get settingsTransferNoCategory;

  /// No description provided for @settingsAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyNote.
  ///
  /// In ru, this message translates to:
  /// **'Записи, фотографии и ключи хранятся только на устройстве: без сервера, облака, регистрации, аналитики и телеметрии. В сеть уходят лишь штрихкод при поиске товара и запрос списка выпусков при проверке обновлений — оба отключаются выше.'**
  String get settingsPrivacyNote;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык интерфейса'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Язык системы'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRu;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @tagsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Теги'**
  String get tagsTitle;

  /// No description provided for @tagsHint.
  ///
  /// In ru, this message translates to:
  /// **'Теги — свободные метки без вложенности, они не заменяют категории.'**
  String get tagsHint;

  /// No description provided for @tagsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Тегов пока нет'**
  String get tagsEmpty;

  /// No description provided for @tagNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название тега'**
  String get tagNameLabel;

  /// No description provided for @tagRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать тег'**
  String get tagRename;

  /// No description provided for @tagDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить тег'**
  String get tagDelete;

  /// No description provided for @tagUsage.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{нет записей} one{{count} запись} few{{count} записи} other{{count} записей}}'**
  String tagUsage(int count);

  /// No description provided for @tagDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить тег?'**
  String get tagDeleteTitle;

  /// No description provided for @tagDeleteMessage.
  ///
  /// In ru, this message translates to:
  /// **'Тег «{name}» будет снят со всех записей и удалён. Записи останутся на месте. Сейчас им помечено {count, plural, =0{ничего} one{{count} запись} few{{count} записи} other{{count} записей}}.'**
  String tagDeleteMessage(String name, int count);

  /// No description provided for @tagMerged.
  ///
  /// In ru, this message translates to:
  /// **'Теги объединены в «{name}»'**
  String tagMerged(String name);

  /// No description provided for @typesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Типы объектов'**
  String get typesTitle;

  /// No description provided for @typeRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать тип'**
  String get typeRename;

  /// No description provided for @typeHide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get typeHide;

  /// No description provided for @typeShow.
  ///
  /// In ru, this message translates to:
  /// **'Показать'**
  String get typeShow;

  /// No description provided for @typeNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название типа'**
  String get typeNameLabel;

  /// No description provided for @typeHidden.
  ///
  /// In ru, this message translates to:
  /// **'Скрыт'**
  String get typeHidden;

  /// No description provided for @typeCreate.
  ///
  /// In ru, this message translates to:
  /// **'Новый тип'**
  String get typeCreate;

  /// No description provided for @typeEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Типов пока нет'**
  String get typeEmpty;

  /// No description provided for @devicesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Устройства'**
  String get devicesTitle;

  /// No description provided for @deviceThis.
  ///
  /// In ru, this message translates to:
  /// **'Это устройство'**
  String get deviceThis;

  /// No description provided for @deviceRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать устройство'**
  String get deviceRename;

  /// No description provided for @deviceNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название устройства'**
  String get deviceNameLabel;

  /// No description provided for @deviceRegisteredAt.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрировано {date}'**
  String deviceRegisteredAt(String date);

  /// No description provided for @deviceEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Устройств пока нет'**
  String get deviceEmpty;

  /// No description provided for @tagsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Теги'**
  String get tagsLabel;

  /// No description provided for @tagAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить тег'**
  String get tagAdd;

  /// No description provided for @privacyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Доступность'**
  String get privacyLabel;

  /// No description provided for @privacyOnlyMe.
  ///
  /// In ru, this message translates to:
  /// **'Только мне'**
  String get privacyOnlyMe;

  /// No description provided for @privacyShareable.
  ///
  /// In ru, this message translates to:
  /// **'Можно передавать'**
  String get privacyShareable;

  /// No description provided for @privacyNoNote.
  ///
  /// In ru, this message translates to:
  /// **'Передавать без заметки'**
  String get privacyNoNote;

  /// No description provided for @privacyNoPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Передавать без фотографий'**
  String get privacyNoPhotos;

  /// No description provided for @privacyBasic.
  ///
  /// In ru, this message translates to:
  /// **'Передавать только основную информацию'**
  String get privacyBasic;

  /// No description provided for @duplicateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Возможные дубли'**
  String get duplicateTitle;

  /// No description provided for @duplicateMessage.
  ///
  /// In ru, this message translates to:
  /// **'Похожие объекты уже есть. Связать их или оставить раздельно?'**
  String get duplicateMessage;

  /// No description provided for @duplicateKeepSeparate.
  ///
  /// In ru, this message translates to:
  /// **'Оставить раздельно'**
  String get duplicateKeepSeparate;

  /// No description provided for @duplicateUseExisting.
  ///
  /// In ru, this message translates to:
  /// **'Использовать существующий'**
  String get duplicateUseExisting;

  /// No description provided for @exportModeFull.
  ///
  /// In ru, this message translates to:
  /// **'Весь профиль'**
  String get exportModeFull;

  /// No description provided for @exportModeBranch.
  ///
  /// In ru, this message translates to:
  /// **'Ветка категории'**
  String get exportModeBranch;

  /// No description provided for @exportModeCollection.
  ///
  /// In ru, this message translates to:
  /// **'Подборка'**
  String get exportModeCollection;

  /// No description provided for @exportModeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Что экспортировать'**
  String get exportModeLabel;

  /// No description provided for @hotkeysTitle.
  ///
  /// In ru, this message translates to:
  /// **'Горячие клавиши'**
  String get hotkeysTitle;

  /// No description provided for @hotkeyNewEntry.
  ///
  /// In ru, this message translates to:
  /// **'Новая запись'**
  String get hotkeyNewEntry;

  /// No description provided for @hotkeySearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get hotkeySearch;

  /// No description provided for @hotkeyImport.
  ///
  /// In ru, this message translates to:
  /// **'Импорт'**
  String get hotkeyImport;

  /// No description provided for @hotkeyExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт'**
  String get hotkeyExport;

  /// No description provided for @hotkeyProfiles.
  ///
  /// In ru, this message translates to:
  /// **'Переключатель профилей'**
  String get hotkeyProfiles;

  /// No description provided for @hotkeyClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть диалог'**
  String get hotkeyClose;

  /// No description provided for @hotkeyScan.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать штрихкод'**
  String get hotkeyScan;

  /// No description provided for @hotkeySettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get hotkeySettings;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Храните предпочтения, рекомендации и коллекции. Всё локально, без сети и регистрации.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingCreateProfile.
  ///
  /// In ru, this message translates to:
  /// **'Создать профиль'**
  String get onboardingCreateProfile;

  /// No description provided for @onboardingProfileNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Как вас зовут?'**
  String get onboardingProfileNameHint;

  /// No description provided for @onboardingProfileNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get onboardingProfileNameLabel;

  /// No description provided for @onboardingLastNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия (необязательно)'**
  String get onboardingLastNameLabel;

  /// No description provided for @onboardingNicknameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Псевдоним (необязательно)'**
  String get onboardingNicknameLabel;

  /// No description provided for @onboardingNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите имя'**
  String get onboardingNameRequired;

  /// No description provided for @onboardingStarterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Стартовая структура'**
  String get onboardingStarterTitle;

  /// No description provided for @onboardingStarterSubcategories.
  ///
  /// In ru, this message translates to:
  /// **'Создать примерные подкатегории'**
  String get onboardingStarterSubcategories;

  /// No description provided for @onboardingStarterHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Продукты → Колбасы, Сыры, Напитки. Всё можно переименовать или удалить позже.'**
  String get onboardingStarterHint;

  /// No description provided for @onboardingCreating.
  ///
  /// In ru, this message translates to:
  /// **'Создаём профиль…'**
  String get onboardingCreating;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @relationLove.
  ///
  /// In ru, this message translates to:
  /// **'Обожаю'**
  String get relationLove;

  /// No description provided for @relationLike.
  ///
  /// In ru, this message translates to:
  /// **'Нравится'**
  String get relationLike;

  /// No description provided for @relationNeutral.
  ///
  /// In ru, this message translates to:
  /// **'Нейтрально'**
  String get relationNeutral;

  /// No description provided for @relationDislike.
  ///
  /// In ru, this message translates to:
  /// **'Не нравится'**
  String get relationDislike;

  /// No description provided for @relationAvoid.
  ///
  /// In ru, this message translates to:
  /// **'Избегаю'**
  String get relationAvoid;

  /// No description provided for @relationWantToTry.
  ///
  /// In ru, this message translates to:
  /// **'Хочу попробовать'**
  String get relationWantToTry;

  /// No description provided for @entryAddToMyProfile.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в мой профиль'**
  String get entryAddToMyProfile;

  /// No description provided for @breadcrumbObjectSeparator.
  ///
  /// In ru, this message translates to:
  /// **' / '**
  String get breadcrumbObjectSeparator;

  /// No description provided for @categorySearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Найти категорию'**
  String get categorySearchHint;

  /// No description provided for @categoryExpandAll.
  ///
  /// In ru, this message translates to:
  /// **'Развернуть всё'**
  String get categoryExpandAll;

  /// No description provided for @categoryCollapseAll.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть всё'**
  String get categoryCollapseAll;

  /// No description provided for @categoryIcon.
  ///
  /// In ru, this message translates to:
  /// **'Значок категории'**
  String get categoryIcon;

  /// No description provided for @typeIcon.
  ///
  /// In ru, this message translates to:
  /// **'Значок типа'**
  String get typeIcon;

  /// No description provided for @categorySubcategoriesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} подкатегория} few{{count} подкатегории} many{{count} подкатегорий} other{{count} подкатегорий}}'**
  String categorySubcategoriesCount(int count);

  /// No description provided for @categoryDirectCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} прямо здесь} few{{count} прямо здесь} many{{count} прямо здесь} other{{count} прямо здесь}}'**
  String categoryDirectCount(int count);

  /// No description provided for @categoryBranchCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись в ветке} few{{count} записи в ветке} many{{count} записей в ветке} other{{count} записей в ветке}}'**
  String categoryBranchCount(int count);

  /// No description provided for @categorySubcategoriesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подкатегории'**
  String get categorySubcategoriesTitle;

  /// No description provided for @categoryEntriesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Записи'**
  String get categoryEntriesTitle;

  /// No description provided for @categoryBranchEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В этой ветке пока нет записей'**
  String get categoryBranchEmpty;

  /// No description provided for @categoryPickTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию'**
  String get categoryPickTitle;

  /// No description provided for @categoryPickMessage.
  ///
  /// In ru, this message translates to:
  /// **'Выберите ветку слева, чтобы увидеть, что в ней лежит: её подкатегории и её записи.'**
  String get categoryPickMessage;

  /// No description provided for @catalogTypeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get catalogTypeLabel;

  /// No description provided for @catalogCategoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get catalogCategoryLabel;

  /// No description provided for @catalogRelationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отношение'**
  String get catalogRelationLabel;

  /// No description provided for @searchGlobalHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по записям'**
  String get searchGlobalHint;

  /// No description provided for @headerNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get headerNotifications;

  /// No description provided for @notificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Новых событий нет'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся входящие изменения, обновления и итоги импорта.'**
  String get notificationsEmptyHint;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In ru, this message translates to:
  /// **'Отметить всё прочитанным'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationIncomingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Входящие изменения'**
  String get notificationIncomingTitle;

  /// No description provided for @notificationIncomingBody.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} изменение в импортированных профилях} few{{count} изменения в импортированных профилях} many{{count} изменений в импортированных профилях} other{{count} изменений в импортированных профилях}}'**
  String notificationIncomingBody(int count);

  /// No description provided for @notificationUpdateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доступна новая версия'**
  String get notificationUpdateTitle;

  /// No description provided for @notificationUpdateBody.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version} готова к установке'**
  String notificationUpdateBody(String version);

  /// No description provided for @notificationProductsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сведения о товарах обновлены'**
  String get notificationProductsTitle;

  /// No description provided for @notificationProductsBody.
  ///
  /// In ru, this message translates to:
  /// **'Дополнено карточек: {count}'**
  String notificationProductsBody(int count);

  /// No description provided for @notificationImportTitle.
  ///
  /// In ru, this message translates to:
  /// **'Импорт завершён'**
  String get notificationImportTitle;

  /// No description provided for @notificationImportBody.
  ///
  /// In ru, this message translates to:
  /// **'Пакет от {date}'**
  String notificationImportBody(String date);

  /// No description provided for @notificationBackupTitle.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия создана'**
  String get notificationBackupTitle;

  /// No description provided for @notificationBackupBody.
  ///
  /// In ru, this message translates to:
  /// **'Последняя копия от {date}'**
  String notificationBackupBody(String date);

  /// No description provided for @collectionPickTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить записи'**
  String get collectionPickTitle;

  /// No description provided for @collectionPickEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В профиле пока нет записей, которые можно добавить'**
  String get collectionPickEmpty;

  /// No description provided for @collectionPickSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String collectionPickSelected(int count);

  /// No description provided for @profilesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{count} из {max} возможных'**
  String profilesSubtitle(int count, int max);

  /// No description provided for @profileMenuManage.
  ///
  /// In ru, this message translates to:
  /// **'Все профили'**
  String get profileMenuManage;

  /// No description provided for @profileMenuSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки приложения'**
  String get profileMenuSettings;

  /// No description provided for @barcodeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить по штрихкоду'**
  String get barcodeTitle;

  /// No description provided for @barcodeHintMobile.
  ///
  /// In ru, this message translates to:
  /// **'Наведите камеру на штрихкод или QR-код либо введите цифры вручную.'**
  String get barcodeHintMobile;

  /// No description provided for @barcodeHintDesktop.
  ///
  /// In ru, this message translates to:
  /// **'Введите код вручную, отсканируйте USB-сканером или распознайте с фотографии.'**
  String get barcodeHintDesktop;

  /// No description provided for @barcodeCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Штрихкод или QR'**
  String get barcodeCodeLabel;

  /// No description provided for @barcodeLookup.
  ///
  /// In ru, this message translates to:
  /// **'Найти'**
  String get barcodeLookup;

  /// No description provided for @barcodeUseCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get barcodeUseCamera;

  /// No description provided for @barcodePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Сфотографировать'**
  String get barcodePhoto;

  /// No description provided for @barcodeFromFile.
  ///
  /// In ru, this message translates to:
  /// **'Распознать с изображения'**
  String get barcodeFromFile;

  /// No description provided for @barcodeNotRecognized.
  ///
  /// In ru, this message translates to:
  /// **'Код на изображении не найден. Попробуйте снимок покрупнее и без бликов.'**
  String get barcodeNotRecognized;

  /// No description provided for @barcodeUseResult.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get barcodeUseResult;

  /// No description provided for @barcodeFoundIn.
  ///
  /// In ru, this message translates to:
  /// **'Источник: {source}'**
  String barcodeFoundIn(String source);

  /// No description provided for @barcodeNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Товар не найден ни в одной базе'**
  String get barcodeNotFound;

  /// No description provided for @barcodeLookupFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось связаться с базами товаров'**
  String get barcodeLookupFailed;

  /// No description provided for @barcodeFillManually.
  ///
  /// In ru, this message translates to:
  /// **'Код сохранится в карточке — название можно ввести вручную.'**
  String get barcodeFillManually;

  /// No description provided for @barcodeTorch.
  ///
  /// In ru, this message translates to:
  /// **'Подсветка'**
  String get barcodeTorch;

  /// No description provided for @barcodeScanAction.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать код'**
  String get barcodeScanAction;

  /// No description provided for @settingsNetworkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Товарные базы и обновления'**
  String get settingsNetworkTitle;

  /// No description provided for @settingsNetworkHint.
  ///
  /// In ru, this message translates to:
  /// **'Единственные сетевые запросы приложения. Наружу уходит только штрихкод и номер версии.'**
  String get settingsNetworkHint;

  /// No description provided for @settingsBarcodeLookup.
  ///
  /// In ru, this message translates to:
  /// **'Искать товар по штрихкоду'**
  String get settingsBarcodeLookup;

  /// No description provided for @settingsBarcodeSources.
  ///
  /// In ru, this message translates to:
  /// **'Источники данных'**
  String get settingsBarcodeSources;

  /// No description provided for @settingsProductAutoUpdate.
  ///
  /// In ru, this message translates to:
  /// **'Дополнять карточки товаров автоматически'**
  String get settingsProductAutoUpdate;

  /// No description provided for @settingsProductAutoUpdateHint.
  ///
  /// In ru, this message translates to:
  /// **'Не чаще раза в сутки. Введённые вручную названия не заменяются.'**
  String get settingsProductAutoUpdateHint;

  /// No description provided for @settingsProductRefreshNow.
  ///
  /// In ru, this message translates to:
  /// **'Обновить сейчас'**
  String get settingsProductRefreshNow;

  /// No description provided for @settingsProductRefreshed.
  ///
  /// In ru, this message translates to:
  /// **'Проверено {checked}, дополнено {updated}'**
  String settingsProductRefreshed(int checked, int updated);

  /// No description provided for @settingsAppUpdateCheck.
  ///
  /// In ru, this message translates to:
  /// **'Проверять обновления приложения'**
  String get settingsAppUpdateCheck;

  /// No description provided for @settingsAppUpdateNow.
  ///
  /// In ru, this message translates to:
  /// **'Проверить сейчас'**
  String get settingsAppUpdateNow;

  /// No description provided for @settingsUpToDate.
  ///
  /// In ru, this message translates to:
  /// **'Установлена последняя версия'**
  String get settingsUpToDate;

  /// No description provided for @settingsUpdateUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Список версий недоступен. Возможно, репозиторий закрыт — тогда обновляйте приложение вручную со страницы выпусков.'**
  String get settingsUpdateUnavailable;

  /// No description provided for @settingsUpdateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить обновления. Проверьте подключение к интернету и попробуйте позже.'**
  String get settingsUpdateFailed;

  /// No description provided for @updateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обновление приложения'**
  String get updateTitle;

  /// No description provided for @updateAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступна версия {version}'**
  String updateAvailable(String version);

  /// No description provided for @updateDownload.
  ///
  /// In ru, this message translates to:
  /// **'Скачать установщик'**
  String get updateDownload;

  /// No description provided for @updateOpenPage.
  ///
  /// In ru, this message translates to:
  /// **'Открыть страницу выпуска'**
  String get updateOpenPage;

  /// No description provided for @updateLater.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get updateLater;

  /// No description provided for @updateSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить эту версию'**
  String get updateSkip;

  /// No description provided for @updateInstallNow.
  ///
  /// In ru, this message translates to:
  /// **'Установить'**
  String get updateInstallNow;

  /// No description provided for @updateInstallHint.
  ///
  /// In ru, this message translates to:
  /// **'Приложение закроется, обновится и запустится снова.'**
  String get updateInstallHint;

  /// No description provided for @updateInstallHintAndroid.
  ///
  /// In ru, this message translates to:
  /// **'Приложение скачает обновление и передаст его системе. В первый раз Android попросит разрешить установку из этого источника.'**
  String get updateInstallHintAndroid;

  /// No description provided for @updateDownloading.
  ///
  /// In ru, this message translates to:
  /// **'Скачивание: {percent}%'**
  String updateDownloading(int percent);

  /// No description provided for @updateDownloadingUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Скачивание…'**
  String get updateDownloadingUnknown;

  /// No description provided for @updateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить'**
  String get updateFailed;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In ru, this message translates to:
  /// **'Ваши вкусы, а не чужие оценки'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Body.
  ///
  /// In ru, this message translates to:
  /// **'Продукты, блюда, фильмы, книги, места — всё, о чём хочется помнить, понравилось оно или нет. Для новой записи хватает названия.'**
  String get onboardingStep1Body;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In ru, this message translates to:
  /// **'Мнение отдельно от вещи'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Body.
  ///
  /// In ru, this message translates to:
  /// **'«Интерстеллар» — один объект на всех. Ваша оценка и оценка близкого человека — две разные записи. Поэтому профилями можно обмениваться: чужое мнение не перепишет ваше.'**
  String get onboardingStep2Body;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In ru, this message translates to:
  /// **'Всё остаётся у вас'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In ru, this message translates to:
  /// **'Без аккаунта, сервера и облака. Поделиться можно файлом, который вы создаёте сами и передаёте кому хотите.'**
  String get onboardingStep3Body;

  /// No description provided for @onboardingStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get onboardingStart;

  /// No description provided for @exportReadable.
  ///
  /// In ru, this message translates to:
  /// **'Для чтения'**
  String get exportReadable;

  /// No description provided for @exportCsv.
  ///
  /// In ru, this message translates to:
  /// **'Таблица CSV'**
  String get exportCsv;

  /// No description provided for @exportMarkdown.
  ///
  /// In ru, this message translates to:
  /// **'Текст Markdown'**
  String get exportMarkdown;

  /// No description provided for @insightsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get insightsTitle;

  /// No description provided for @insightsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{По {count} записи} few{По {count} записям} many{По {count} записям} other{По {count} записям}}'**
  String insightsSubtitle(int count);

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нечего показывать'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте несколько записей — здесь появятся распределение оценок, отношения и динамика по месяцам.'**
  String get insightsEmptyMessage;

  /// No description provided for @insightsTotal.
  ///
  /// In ru, this message translates to:
  /// **'Записей'**
  String get insightsTotal;

  /// No description provided for @insightsAverage.
  ///
  /// In ru, this message translates to:
  /// **'Средняя оценка'**
  String get insightsAverage;

  /// No description provided for @insightsWithPhotos.
  ///
  /// In ru, this message translates to:
  /// **'С фотографиями'**
  String get insightsWithPhotos;

  /// No description provided for @insightsWithNotes.
  ///
  /// In ru, this message translates to:
  /// **'С заметками'**
  String get insightsWithNotes;

  /// No description provided for @insightsRatings.
  ///
  /// In ru, this message translates to:
  /// **'Распределение оценок'**
  String get insightsRatings;

  /// No description provided for @insightsRelations.
  ///
  /// In ru, this message translates to:
  /// **'Отношение'**
  String get insightsRelations;

  /// No description provided for @insightsPeriodYear.
  ///
  /// In ru, this message translates to:
  /// **'За год'**
  String get insightsPeriodYear;

  /// No description provided for @insightsPeriodAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё время'**
  String get insightsPeriodAll;

  /// No description provided for @insightsScopeAll.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get insightsScopeAll;

  /// No description provided for @insightsScopeEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В этом срезе записей нет'**
  String get insightsScopeEmpty;

  /// No description provided for @insightsCategories.
  ///
  /// In ru, this message translates to:
  /// **'Самые заполненные категории'**
  String get insightsCategories;

  /// No description provided for @insightsTimeline.
  ///
  /// In ru, this message translates to:
  /// **'Добавления по месяцам'**
  String get insightsTimeline;

  /// No description provided for @wishlistTitle.
  ///
  /// In ru, this message translates to:
  /// **'Хочу попробовать'**
  String get wishlistTitle;

  /// No description provided for @wishlistSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} задумка} few{{count} задумки} many{{count} задумок} other{{count} задумок}}'**
  String wishlistSubtitle(int count);

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Список пуст'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Отмечайте отношением «Хочу попробовать» то, до чего ещё не дошли руки, — оно соберётся здесь.'**
  String get wishlistEmptyMessage;

  /// No description provided for @wishlistMarkTried.
  ///
  /// In ru, this message translates to:
  /// **'Попробовал'**
  String get wishlistMarkTried;

  /// No description provided for @wishlistRatingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как впечатления?'**
  String get wishlistRatingTitle;

  /// No description provided for @wishlistRatingHint.
  ///
  /// In ru, this message translates to:
  /// **'Отношение подставится по оценке, дата впечатления — сегодняшняя. Всё можно изменить в карточке.'**
  String get wishlistRatingHint;

  /// No description provided for @archiveTitle.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get archiveTitle;

  /// No description provided for @archiveSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} убранный объект} few{{count} убранных объекта} many{{count} убранных объектов} other{{count} убранных объектов}}'**
  String archiveSubtitle(int count);

  /// No description provided for @archiveEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Архив пуст'**
  String get archiveEmptyTitle;

  /// No description provided for @archiveEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появляется всё, что вы убрали из работы. Ничего не удаляется — любое можно вернуть.'**
  String get archiveEmptyMessage;

  /// No description provided for @archiveEntries.
  ///
  /// In ru, this message translates to:
  /// **'Записи'**
  String get archiveEntries;

  /// No description provided for @archiveCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get archiveCategories;

  /// No description provided for @archiveCollections.
  ///
  /// In ru, this message translates to:
  /// **'Подборки'**
  String get archiveCollections;

  /// No description provided for @archiveCategoryLevel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень вложенности: {level}'**
  String archiveCategoryLevel(int level);

  /// No description provided for @archiveRestoredMany.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись возвращена} few{{count} записи возвращены} many{{count} записей возвращено} other{{count} записей возвращено}}'**
  String archiveRestoredMany(int count);

  /// No description provided for @archivePurgeConfirmMany.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Удалить {count} запись навсегда?} few{Удалить {count} записи навсегда?} many{Удалить {count} записей навсегда?} other{Удалить {count} записей навсегда?}}'**
  String archivePurgeConfirmMany(int count);

  /// No description provided for @incomingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Входящие изменения'**
  String get incomingTitle;

  /// No description provided for @incomingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Что изменилось в импортированных профилях'**
  String get incomingSubtitle;

  /// No description provided for @incomingEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменений нет'**
  String get incomingEmptyTitle;

  /// No description provided for @incomingEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'После импорта обновлённого профиля здесь появится список того, что изменилось.'**
  String get incomingEmptyMessage;

  /// No description provided for @incomingMarkSeen.
  ///
  /// In ru, this message translates to:
  /// **'Отметить просмотренным'**
  String get incomingMarkSeen;

  /// No description provided for @incomingMarkAllSeen.
  ///
  /// In ru, this message translates to:
  /// **'Отметить все просмотренными'**
  String get incomingMarkAllSeen;

  /// No description provided for @incomingKindEntry.
  ///
  /// In ru, this message translates to:
  /// **'Запись'**
  String get incomingKindEntry;

  /// No description provided for @incomingKindObject.
  ///
  /// In ru, this message translates to:
  /// **'Объект'**
  String get incomingKindObject;

  /// No description provided for @incomingKindCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get incomingKindCategory;

  /// No description provided for @incomingReceivedAt.
  ///
  /// In ru, this message translates to:
  /// **'Получено {date}'**
  String incomingReceivedAt(String date);

  /// No description provided for @incomingNewBadge.
  ///
  /// In ru, this message translates to:
  /// **'Новое'**
  String get incomingNewBadge;

  /// No description provided for @fieldsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поля типа'**
  String get fieldsTitle;

  /// No description provided for @fieldsHint.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительные поля, которые появятся у записей этого типа.'**
  String get fieldsHint;

  /// No description provided for @fieldsAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить поле'**
  String get fieldsAdd;

  /// No description provided for @fieldsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Своих полей пока нет'**
  String get fieldsEmpty;

  /// No description provided for @fieldsNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название поля'**
  String get fieldsNameLabel;

  /// No description provided for @fieldsKindLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип значения'**
  String get fieldsKindLabel;

  /// No description provided for @fieldsKindText.
  ///
  /// In ru, this message translates to:
  /// **'Текст'**
  String get fieldsKindText;

  /// No description provided for @fieldsKindNumber.
  ///
  /// In ru, this message translates to:
  /// **'Число'**
  String get fieldsKindNumber;

  /// No description provided for @fieldsKindDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get fieldsKindDate;

  /// No description provided for @fieldsKindBool.
  ///
  /// In ru, this message translates to:
  /// **'Да или нет'**
  String get fieldsKindBool;

  /// No description provided for @fieldsKindChoice.
  ///
  /// In ru, this message translates to:
  /// **'Выбор из списка'**
  String get fieldsKindChoice;

  /// No description provided for @fieldsChoicesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Варианты через запятую'**
  String get fieldsChoicesLabel;

  /// No description provided for @fieldsRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить поле'**
  String get fieldsRemove;

  /// No description provided for @fieldsEditFor.
  ///
  /// In ru, this message translates to:
  /// **'Поля типа «{type}»'**
  String fieldsEditFor(String type);

  /// No description provided for @fieldsValuesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительно'**
  String get fieldsValuesTitle;

  /// No description provided for @quickAddBarcodeHint.
  ///
  /// In ru, this message translates to:
  /// **'Заполнено по штрихкоду {code}'**
  String quickAddBarcodeHint(String code);

  /// No description provided for @lockTitle.
  ///
  /// In ru, this message translates to:
  /// **'База под паролем'**
  String get lockTitle;

  /// No description provided for @lockMessage.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль, чтобы открыть записи.'**
  String get lockMessage;

  /// No description provided for @lockPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get lockPasswordLabel;

  /// No description provided for @lockOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get lockOpen;

  /// No description provided for @lockWrongPassword.
  ///
  /// In ru, this message translates to:
  /// **'Неверный пароль'**
  String get lockWrongPassword;

  /// No description provided for @lockRemember.
  ///
  /// In ru, this message translates to:
  /// **'Помнить на этом устройстве'**
  String get lockRemember;

  /// No description provided for @lockStaleKey.
  ///
  /// In ru, this message translates to:
  /// **'Запомненный ключ не подходит к нынешней базе. Так бывает после восстановления копии, сделанной под другим паролем.'**
  String get lockStaleKey;

  /// No description provided for @lockForgotWarning.
  ///
  /// In ru, this message translates to:
  /// **'Забытый пароль восстановить нечем: данные откроются только из резервной копии, снятой до включения.'**
  String get lockForgotWarning;

  /// No description provided for @lockQuit.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть приложение'**
  String get lockQuit;

  /// No description provided for @dbEncryptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Шифровать базу паролем'**
  String get dbEncryptionTitle;

  /// No description provided for @dbEncryptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Файл базы становится нечитаемым без пароля: унесённый ноутбук, вытащенный диск или скопированный файл не выдадут записи. От того, кто сидит за вашим разблокированным устройством, это не защищает.'**
  String get dbEncryptionHint;

  /// No description provided for @dbEncryptionOn.
  ///
  /// In ru, this message translates to:
  /// **'База зашифрована'**
  String get dbEncryptionOn;

  /// No description provided for @dbEncryptionOff.
  ///
  /// In ru, this message translates to:
  /// **'База не зашифрована'**
  String get dbEncryptionOff;

  /// No description provided for @dbEncryptionEnable.
  ///
  /// In ru, this message translates to:
  /// **'Включить'**
  String get dbEncryptionEnable;

  /// No description provided for @dbEncryptionDisable.
  ///
  /// In ru, this message translates to:
  /// **'Выключить'**
  String get dbEncryptionDisable;

  /// No description provided for @dbEncryptionChange.
  ///
  /// In ru, this message translates to:
  /// **'Сменить пароль'**
  String get dbEncryptionChange;

  /// No description provided for @dbEncryptionConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Включить шифрование базы?'**
  String get dbEncryptionConfirmTitle;

  /// No description provided for @dbEncryptionConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Забытый пароль означает потерю всех записей: восстановить их будет нечем, и это свойство шифрования, а не недоработка. Запишите пароль там же, где остальные важные пароли. Перед перешифровкой приложение сделает резервную копию.'**
  String get dbEncryptionConfirmMessage;

  /// No description provided for @dbEncryptionConfirmAccept.
  ///
  /// In ru, this message translates to:
  /// **'Пароль записан, продолжить'**
  String get dbEncryptionConfirmAccept;

  /// No description provided for @dbEncryptionDisableTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выключить шифрование?'**
  String get dbEncryptionDisableTitle;

  /// No description provided for @dbEncryptionDisableMessage.
  ///
  /// In ru, this message translates to:
  /// **'База снова станет обычным файлом: скопировавший его прочитает записи без пароля.'**
  String get dbEncryptionDisableMessage;

  /// No description provided for @dbEncryptionDone.
  ///
  /// In ru, this message translates to:
  /// **'База зашифрована'**
  String get dbEncryptionDone;

  /// No description provided for @dbEncryptionOffDone.
  ///
  /// In ru, this message translates to:
  /// **'Шифрование выключено'**
  String get dbEncryptionOffDone;

  /// No description provided for @dbEncryptionRestartMessage.
  ///
  /// In ru, this message translates to:
  /// **'Закройте приложение и откройте снова — работать с перешифрованной базой можно только после перезапуска.'**
  String get dbEncryptionRestartMessage;

  /// No description provided for @dbEncryptionFailed.
  ///
  /// In ru, this message translates to:
  /// **'Перешифровать не удалось. База осталась в прежнем виде, резервная копия на месте.'**
  String get dbEncryptionFailed;

  /// No description provided for @dbEncryptionRememberTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не спрашивать пароль на этом устройстве'**
  String get dbEncryptionRememberTitle;

  /// No description provided for @dbEncryptionRememberHint.
  ///
  /// In ru, this message translates to:
  /// **'Ключ ляжет в хранилище системы рядом с ключом профиля. Удобно, но тогда пароль защищает только от чужого устройства, а не от вашего же включённого.'**
  String get dbEncryptionRememberHint;

  /// No description provided for @settingsWordsDbEncryption.
  ///
  /// In ru, this message translates to:
  /// **'шифрование база пароль защита диск'**
  String get settingsWordsDbEncryption;

  /// No description provided for @keyStorageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Хранение закрытого ключа'**
  String get keyStorageTitle;

  /// No description provided for @keyStorageOs.
  ///
  /// In ru, this message translates to:
  /// **'Отдельно от базы, под защитой системы'**
  String get keyStorageOs;

  /// No description provided for @keyStorageOsWindows.
  ///
  /// In ru, this message translates to:
  /// **'Файл зашифрован средствами Windows (DPAPI) на вашу учётную запись: на другом компьютере он бесполезен.'**
  String get keyStorageOsWindows;

  /// No description provided for @keyStorageOsMobile.
  ///
  /// In ru, this message translates to:
  /// **'Файл лежит в защищённом каталоге приложения и не попадает в резервные копии.'**
  String get keyStorageOsMobile;

  /// No description provided for @keyStorageDb.
  ///
  /// In ru, this message translates to:
  /// **'В базе приложения — без защиты на диске'**
  String get keyStorageDb;

  /// No description provided for @keyStorageDbHint.
  ///
  /// In ru, this message translates to:
  /// **'Секрет лежит в той же базе, что и зашифрованный им ключ, поэтому шифрование ключа сейчас ничего не даёт: скопировав файл базы, его можно прочитать. Перенесите секрет в хранилище системы.'**
  String get keyStorageDbHint;

  /// No description provided for @keyStorageMove.
  ///
  /// In ru, this message translates to:
  /// **'Перенести в хранилище ОС'**
  String get keyStorageMove;

  /// No description provided for @keyStorageMoved.
  ///
  /// In ru, this message translates to:
  /// **'Ключ перенесён в хранилище операционной системы'**
  String get keyStorageMoved;

  /// No description provided for @keyStorageMoveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Хранилище системы недоступно — секрет остался в базе'**
  String get keyStorageMoveFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
