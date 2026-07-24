import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// Резервное имя приложения (основное — в AppConfig)
  ///
  /// In ru, this message translates to:
  /// **'Впечатления'**
  String get appNameFallback;

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonSaveAndClose.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить и закрыть'**
  String get commonSaveAndClose;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// No description provided for @commonArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать'**
  String get commonArchive;

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

  /// No description provided for @commonRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get commonRename;

  /// No description provided for @commonSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get commonSearch;

  /// No description provided for @commonImport.
  ///
  /// In ru, this message translates to:
  /// **'Импорт'**
  String get commonImport;

  /// No description provided for @commonExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт'**
  String get commonExport;

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

  /// No description provided for @commonDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get commonDone;

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

  /// No description provided for @commonNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get commonNo;

  /// No description provided for @commonNothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get commonNothingFound;

  /// No description provided for @commonLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка…'**
  String get commonLoading;

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

  /// No description provided for @headerSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по записям, категориям, профилям…'**
  String get headerSearchHint;

  /// No description provided for @homeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In ru, this message translates to:
  /// **'С возвращением'**
  String get homeGreeting;

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

  /// No description provided for @statProfiles.
  ///
  /// In ru, this message translates to:
  /// **'Профилей'**
  String get statProfiles;

  /// No description provided for @statCollections.
  ///
  /// In ru, this message translates to:
  /// **'Подборок'**
  String get statCollections;

  /// No description provided for @statUnitPieces.
  ///
  /// In ru, this message translates to:
  /// **'шт.'**
  String get statUnitPieces;

  /// No description provided for @sectionRecent.
  ///
  /// In ru, this message translates to:
  /// **'Недавние записи'**
  String get sectionRecent;

  /// No description provided for @sectionCollections.
  ///
  /// In ru, this message translates to:
  /// **'Подборки'**
  String get sectionCollections;

  /// No description provided for @sectionImpression.
  ///
  /// In ru, this message translates to:
  /// **'Последняя рекомендация'**
  String get sectionImpression;

  /// No description provided for @sectionWantToTry.
  ///
  /// In ru, this message translates to:
  /// **'Хочу попробовать'**
  String get sectionWantToTry;

  /// No description provided for @sectionShowAll.
  ///
  /// In ru, this message translates to:
  /// **'Показать все'**
  String get sectionShowAll;

  /// No description provided for @collectionNew.
  ///
  /// In ru, this message translates to:
  /// **'Новая подборка'**
  String get collectionNew;

  /// No description provided for @comingSoonTitle.
  ///
  /// In ru, this message translates to:
  /// **'Появится на следующих этапах'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonMessage.
  ///
  /// In ru, this message translates to:
  /// **'Этот раздел будет реализован в ходе разработки основных функций.'**
  String get comingSoonMessage;

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

  /// No description provided for @quickAddSaved.
  ///
  /// In ru, this message translates to:
  /// **'Запись добавлена'**
  String get quickAddSaved;

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

  /// No description provided for @categoryRestore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get categoryRestore;

  /// No description provided for @categoryNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название категории'**
  String get categoryNameLabel;

  /// No description provided for @categoryMoveToRoot.
  ///
  /// In ru, this message translates to:
  /// **'В корень'**
  String get categoryMoveToRoot;

  /// No description provided for @categoryMoveTarget.
  ///
  /// In ru, this message translates to:
  /// **'Куда переместить'**
  String get categoryMoveTarget;

  /// No description provided for @categoryArchiveConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать категорию вместе с подкатегориями? Записи не будут удалены.'**
  String get categoryArchiveConfirm;

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

  /// No description provided for @bulkArchive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get bulkArchive;

  /// No description provided for @bulkArchiveConfirm.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Убрать {count} запись в архив? Её можно будет вернуть.} few{Убрать {count} записи в архив? Их можно будет вернуть.} many{Убрать {count} записей в архив? Их можно будет вернуть.} other{Убрать {count} записей в архив? Их можно будет вернуть.}}'**
  String bulkArchiveConfirm(int count);

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

  /// No description provided for @entryContextHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите правой кнопкой для действий'**
  String get entryContextHint;

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

  /// No description provided for @entryEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить запись'**
  String get entryEdit;

  /// No description provided for @entryHistory.
  ///
  /// In ru, this message translates to:
  /// **'История изменений'**
  String get entryHistory;

  /// No description provided for @entryHistoryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Изменений пока нет'**
  String get entryHistoryEmpty;

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

  /// No description provided for @entryEditObjectHint.
  ///
  /// In ru, this message translates to:
  /// **'Название, бренд и год относятся к самому объекту и видны во всех профилях, где он есть. Прежние значения останутся в истории.'**
  String get entryEditObjectHint;

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

  /// No description provided for @categoryShowEntries.
  ///
  /// In ru, this message translates to:
  /// **'Показать записи'**
  String get categoryShowEntries;

  /// No description provided for @categoryViewShelves.
  ///
  /// In ru, this message translates to:
  /// **'Полками'**
  String get categoryViewShelves;

  /// No description provided for @categoryViewTree.
  ///
  /// In ru, this message translates to:
  /// **'Деревом'**
  String get categoryViewTree;

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

  /// No description provided for @profileSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get profileSaved;

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

  /// No description provided for @transferCategoryQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Что сделать с категорией?'**
  String get transferCategoryQuestion;

  /// No description provided for @transferSourcePath.
  ///
  /// In ru, this message translates to:
  /// **'Категория источника: {path}'**
  String transferSourcePath(String path);

  /// No description provided for @transferUseMatch.
  ///
  /// In ru, this message translates to:
  /// **'Использовать существующую категорию'**
  String get transferUseMatch;

  /// No description provided for @transferCreatePath.
  ///
  /// In ru, this message translates to:
  /// **'Создать недостающие категории'**
  String get transferCreatePath;

  /// No description provided for @transferNoCategory.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить без категории'**
  String get transferNoCategory;

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

  /// No description provided for @exportSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер'**
  String get exportSize;

  /// No description provided for @exportSaved.
  ///
  /// In ru, this message translates to:
  /// **'Файл сохранён: {path}'**
  String exportSaved(String path);

  /// No description provided for @exportCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт отменён'**
  String get exportCancelled;

  /// No description provided for @exportForbidden.
  ///
  /// In ru, this message translates to:
  /// **'Владелец запретил повторную передачу этого профиля'**
  String get exportForbidden;

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

  /// No description provided for @importChecking.
  ///
  /// In ru, this message translates to:
  /// **'Проверяем пакет…'**
  String get importChecking;

  /// No description provided for @importApplying.
  ///
  /// In ru, this message translates to:
  /// **'Применяем изменения…'**
  String get importApplying;

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
  /// **'Автоматические копии создаются перед импортом и восстановлением. Хранятся последние 7 автоматических и 20 созданных вручную.'**
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

  /// No description provided for @quickAddTypeVsCategory.
  ///
  /// In ru, this message translates to:
  /// **'Тип задаёт набор полей записи, категория — вашу полку в дереве.'**
  String get quickAddTypeVsCategory;

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

  /// No description provided for @settingsData.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get settingsData;

  /// No description provided for @settingsTypes.
  ///
  /// In ru, this message translates to:
  /// **'Типы объектов'**
  String get settingsTypes;

  /// No description provided for @settingsDevices.
  ///
  /// In ru, this message translates to:
  /// **'Устройства'**
  String get settingsDevices;

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

  /// No description provided for @settingsStorage.
  ///
  /// In ru, this message translates to:
  /// **'Хранилище'**
  String get settingsStorage;

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

  /// No description provided for @settingsLanguageRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRu;

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

  /// No description provided for @tagNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название тега'**
  String get tagNameLabel;

  /// No description provided for @tagRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать тег'**
  String get tagRemove;

  /// No description provided for @tagsHint.
  ///
  /// In ru, this message translates to:
  /// **'Теги — свободные метки без вложенности, они не заменяют категории.'**
  String get tagsHint;

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

  /// No description provided for @updatesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обновления'**
  String get updatesTitle;

  /// No description provided for @updatesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Новых изменений нет'**
  String get updatesEmpty;

  /// No description provided for @updatesEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся изменения, пришедшие с импортом чужих профилей.'**
  String get updatesEmptyMessage;

  /// No description provided for @updatesMarkSeen.
  ///
  /// In ru, this message translates to:
  /// **'Отметить просмотренным'**
  String get updatesMarkSeen;

  /// No description provided for @updatesFrom.
  ///
  /// In ru, this message translates to:
  /// **'Профиль: {name}'**
  String updatesFrom(String name);

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

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваш личный архив впечатлений'**
  String get onboardingWelcomeTitle;

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

  /// No description provided for @componentGalleryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Галерея компонентов'**
  String get componentGalleryTitle;

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

  /// No description provided for @emptyCatalogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Здесь пока пусто'**
  String get emptyCatalogTitle;

  /// No description provided for @emptyCatalogSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первую запись — это займёт несколько секунд.'**
  String get emptyCatalogSubtitle;

  /// No description provided for @entryAddToMyProfile.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в мой профиль'**
  String get entryAddToMyProfile;

  /// No description provided for @profileSwitcherActive.
  ///
  /// In ru, this message translates to:
  /// **'Активный профиль'**
  String get profileSwitcherActive;

  /// No description provided for @profileSwitcherTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профили'**
  String get profileSwitcherTitle;

  /// No description provided for @breadcrumbObjectSeparator.
  ///
  /// In ru, this message translates to:
  /// **' / '**
  String get breadcrumbObjectSeparator;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} категория в дереве} few{{count} категории в дереве} many{{count} категорий в дереве} other{{count} категорий в дереве}}'**
  String categoriesSubtitle(int count);

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

  /// No description provided for @categoryOpenInCatalog.
  ///
  /// In ru, this message translates to:
  /// **'Показать записи'**
  String get categoryOpenInCatalog;

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
  /// **'Слева — дерево категорий. Выберите ветку, чтобы увидеть, что в ней лежит.'**
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

  /// No description provided for @searchResultsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Результаты поиска'**
  String get searchResultsTitle;

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

  /// No description provided for @notificationsOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get notificationsOpen;

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

  /// No description provided for @profileMenuLocal.
  ///
  /// In ru, this message translates to:
  /// **'Локальные настройки'**
  String get profileMenuLocal;

  /// No description provided for @profileMenuExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировать профиль'**
  String get profileMenuExport;

  /// No description provided for @profileMenuSwitch.
  ///
  /// In ru, this message translates to:
  /// **'Переключиться'**
  String get profileMenuSwitch;

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

  /// No description provided for @updateCurrent.
  ///
  /// In ru, this message translates to:
  /// **'Установлена версия {version}'**
  String updateCurrent(String version);

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

  /// No description provided for @updateInstalling.
  ///
  /// In ru, this message translates to:
  /// **'Открываем установщик…'**
  String get updateInstalling;

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

  /// No description provided for @archiveRestored.
  ///
  /// In ru, this message translates to:
  /// **'Возвращено из архива'**
  String get archiveRestored;

  /// No description provided for @incomingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Входящие изменения'**
  String get incomingTitle;

  /// No description provided for @incomingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Что изменилось в импортированных профилях (§23)'**
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
  /// **'В базе приложения, зашифровано'**
  String get keyStorageDb;

  /// No description provided for @keyStorageDbHint.
  ///
  /// In ru, this message translates to:
  /// **'Секрет лежит рядом с зашифрованным ключом. Перенесите его, чтобы копия базы стала бесполезной без вашей учётной записи.'**
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
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
