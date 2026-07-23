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
  /// **'{count} зап.'**
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
  /// **'Найдено: {count}'**
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

  /// No description provided for @entryArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архивировать запись'**
  String get entryArchive;

  /// No description provided for @entryArchived.
  ///
  /// In ru, this message translates to:
  /// **'Запись архивирована'**
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
  /// **'{count} зап.'**
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
  /// **'{count} зап.'**
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
  /// **'Автоматические копии создаются перед импортом. Хранятся последние 7, копии, созданные вручную, не удаляются.'**
  String get backupRetentionHint;

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
  /// **'Приложение работает полностью локально: без сервера, облака, регистрации, аналитики и сетевых запросов.'**
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
