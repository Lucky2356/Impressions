// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNothingFound => 'Nothing found';

  @override
  String get navHome => 'Home';

  @override
  String get navCatalog => 'Catalogue';

  @override
  String get navCollections => 'Collections';

  @override
  String get navCompare => 'Compare';

  @override
  String get navSettings => 'Settings';

  @override
  String get navProfiles => 'Profiles';

  @override
  String get navImport => 'Import';

  @override
  String get navSectionMain => 'Sections';

  @override
  String get navSectionProfiles => 'Profiles and sharing';

  @override
  String get navSectionOther => 'More';

  @override
  String get navMore => 'More';

  @override
  String get navAllSections => 'All sections';

  @override
  String get headerHelp => 'Help';

  @override
  String get homeTitle => 'Home';

  @override
  String get statEntries => 'Entries';

  @override
  String get statCategories => 'Categories';

  @override
  String get sectionRecent => 'Recent entries';

  @override
  String get sectionWantToTry => 'Want to try';

  @override
  String get quickAddTitle => 'New entry';

  @override
  String get quickAddNameLabel => 'Title';

  @override
  String get quickAddNameHint => 'For example: Earl Grey tea';

  @override
  String get quickAddNameRequired => 'Enter a title';

  @override
  String get quickAddTypeLabel => 'Type';

  @override
  String get quickAddCategoryLabel => 'Category';

  @override
  String get quickAddNoCategory => 'No category';

  @override
  String get quickAddSaveAndMore => 'And another';

  @override
  String quickAddSavedInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries added in a row',
      one: '$count entry added in a row',
    );
    return '$_temp0';
  }

  @override
  String get quickAddRelationLabel => 'Attitude';

  @override
  String get quickAddDetails => 'Add details';

  @override
  String get quickAddDraftRestored => 'Picking up where you left off';

  @override
  String get quickAddDraftNoPhotos =>
      'Photos are not kept in a draft — pick them again';

  @override
  String get quickAddDraftDiscard => 'Start over';

  @override
  String get entryRateAction => 'Rate';

  @override
  String get quickAddRatingLabel => 'Rating';

  @override
  String get quickAddRatingNone => 'No rating';

  @override
  String get quickAddNoteLabel => 'Note';

  @override
  String get quickAddPickCategory => 'Pick a category';

  @override
  String get quickAddSearchCategory => 'Search categories';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoryAddRoot => 'New top-level category';

  @override
  String get categoryAddChild => 'Add a subcategory';

  @override
  String get categoryRename => 'Rename';

  @override
  String get categoryMove => 'Move';

  @override
  String get categoryMoveUp => 'Up';

  @override
  String get categoryMoveDown => 'Down';

  @override
  String get categoryMoveEdge => 'There is nowhere further to move';

  @override
  String get categoryArchive => 'Archive';

  @override
  String get categoryArchived => 'Category moved to the archive';

  @override
  String get categorySelectMany => 'Select several';

  @override
  String get categoryMoveSelected => 'Move the selected';

  @override
  String categorySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches selected',
      one: '$count branch selected',
    );
    return '$_temp0';
  }

  @override
  String categoryArchivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches moved to the archive',
      one: '$count branch moved to the archive',
    );
    return '$_temp0';
  }

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get categoryEmptyTitle => 'No categories yet';

  @override
  String get categoryEmptyMessage =>
      'Create your first category to start arranging entries on shelves.';

  @override
  String categoryEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String get categoryShowSubcategories => 'Show entries from subcategories';

  @override
  String get catalogEmptyTitle => 'No entries yet';

  @override
  String get catalogEmptyMessage =>
      'Add your first entry — it takes a few seconds.';

  @override
  String get catalogAllTypes => 'All types';

  @override
  String get catalogAllRelations => 'All attitudes';

  @override
  String get catalogAllCategories => 'All categories';

  @override
  String get catalogSearchHint => 'Search by title';

  @override
  String get catalogNothingFoundTitle => 'Nothing found';

  @override
  String get catalogNothingFoundMessage =>
      'Try changing the filters or the search query.';

  @override
  String get catalogResetFilters => 'Reset filters';

  @override
  String bulkSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries selected',
      one: '$count entry selected',
    );
    return '$_temp0';
  }

  @override
  String get bulkSelectAll => 'Select all';

  @override
  String get bulkSelectOne => 'Select';

  @override
  String get bulkCancel => 'Clear selection';

  @override
  String get bulkSetCategory => 'To category';

  @override
  String get bulkAddTag => 'Add tag';

  @override
  String get bulkAddToCollection => 'To collection';

  @override
  String get bulkRelation => 'Attitude';

  @override
  String get bulkRating => 'Rating';

  @override
  String get bulkRemoveTag => 'Remove tag';

  @override
  String get bulkRemoveTagEmpty => 'The selected entries have no tags';

  @override
  String get bulkMore => 'More';

  @override
  String bulkDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries changed',
      one: '$count entry changed',
    );
    return '$_temp0';
  }

  @override
  String get bulkArchive => 'To archive';

  @override
  String bulkArchived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries moved to the archive',
      one: '$count entry moved to the archive',
    );
    return '$_temp0';
  }

  @override
  String get entryOpen => 'Open';

  @override
  String get catalogAddedHiddenByFilters =>
      'The entry was added but does not match the current filters';

  @override
  String get catalogViewGrid => 'Large grid';

  @override
  String get catalogViewCompact => 'Compact grid';

  @override
  String get catalogViewList => 'List';

  @override
  String get catalogSortRecent => 'Recently added';

  @override
  String get catalogSortTitle => 'By title';

  @override
  String get catalogSortRating => 'By rating';

  @override
  String get catalogSortImpression => 'By impression date';

  @override
  String get catalogSortLabel => 'Sorting';

  @override
  String get catalogSortNatural => 'Normal order';

  @override
  String get catalogSortReversed => 'Reverse order';

  @override
  String get catalogWithoutRating => 'Without a rating';

  @override
  String get catalogWithoutCategory => 'Without a category';

  @override
  String get catalogWithoutPhoto => 'Without a photo';

  @override
  String get catalogRecommended => 'Recommended to me';

  @override
  String catalogFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries found',
      one: '$count entry found',
    );
    return '$_temp0';
  }

  @override
  String get entryDetailTitle => 'Entry';

  @override
  String get entryHistory => 'Change history';

  @override
  String get entryRestoreRevision => 'Restore this version';

  @override
  String get entryRestored => 'Version restored';

  @override
  String get entryNoteLabel => 'Note';

  @override
  String get entryEditObject => 'Edit description';

  @override
  String entryRecommendedBy(String name) {
    return 'Recommended by: $name';
  }

  @override
  String get entryEditObjectHint =>
      'The title, brand and year belong to the object itself and are visible in every profile that has it. The previous values stay in the history.';

  @override
  String get entryMerge => 'Merge with…';

  @override
  String get entryMergeTitle => 'What to merge with';

  @override
  String get entryMergeMessage =>
      'Entries about this object will move to the one you pick. Ratings, notes, photos and history stay with the entries.';

  @override
  String get entryMergeEmpty => 'No similar objects found';

  @override
  String get entryMergeDone => 'Objects merged';

  @override
  String get entryMergeAction => 'Merge';

  @override
  String get entryCreatorLabel => 'Brand, author or director';

  @override
  String get entryYearLabel => 'Year';

  @override
  String get entryImpressionDate => 'Impression date';

  @override
  String get entryImpressionDateNone => 'Not set';

  @override
  String get entryImpressionDateClear => 'Clear the date';

  @override
  String get entryArchive => 'Archive entry';

  @override
  String get entryArchived => 'Entry moved to the archive';

  @override
  String entryVersionAt(String date) {
    return 'Version from $date';
  }

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get collectionCreate => 'New collection';

  @override
  String get collectionNameLabel => 'Collection name';

  @override
  String get collectionEmptyTitle => 'No collections yet';

  @override
  String get collectionEmptyMessage =>
      'Collections are hand-made lists: “Watch together”, “Buy”, “Visit this summer”.';

  @override
  String collectionEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String get collectionOpenEmpty => 'This collection has no entries yet';

  @override
  String get collectionAddTo => 'Add to a collection';

  @override
  String get collectionRemoveFrom => 'Remove from the collection';

  @override
  String get collectionRename => 'Rename';

  @override
  String get collectionArchive => 'Archive collection';

  @override
  String get collectionArchived => 'Collection moved to the archive';

  @override
  String get collectionAdded => 'Added to the collection';

  @override
  String get yearTitle => 'Year in review';

  @override
  String get yearOpen => 'Year in review';

  @override
  String get yearPrevious => 'Previous year';

  @override
  String get yearNext => 'Next year';

  @override
  String yearYours(String year) {
    return 'Your $year';
  }

  @override
  String yearImpressions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count impressions',
      one: '$count impression',
    );
    return '$_temp0';
  }

  @override
  String yearAverage(String value, int count) {
    return 'Average rating $value across $count entries';
  }

  @override
  String yearFinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Finished: $count',
      one: 'Finished: $count',
    );
    return '$_temp0';
  }

  @override
  String yearNewCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new branches started',
      one: '$count new branch started',
    );
    return '$_temp0';
  }

  @override
  String get yearBest => 'The best of the year';

  @override
  String get yearWhereAndWhen => 'Where and when';

  @override
  String get yearTopCategory => 'Favourite branch';

  @override
  String get yearBusiestMonth => 'Busiest month';

  @override
  String get yearEdges => 'First and last';

  @override
  String get yearFirst => 'First impression of the year';

  @override
  String get yearLast => 'Last impression of the year';

  @override
  String get yearSaveImage => 'Save as an image';

  @override
  String get yearImageSaved => 'The image is ready';

  @override
  String get yearImageType => 'PNG image';

  @override
  String get yearEmptyTitle => 'This year is still empty';

  @override
  String yearEmptyMessage(String year) {
    return 'There are no entries for $year. Add the first one and the review will appear here.';
  }

  @override
  String get notificationYearTitle => 'Your year in review is ready';

  @override
  String notificationYearBody(String year) {
    return 'See what $year was like';
  }

  @override
  String get homeContinue => 'Pick up where you left off';

  @override
  String get homeYearAgo => 'A year ago';

  @override
  String get homeSuggestion => 'How about today?';

  @override
  String get homePinned => 'Pinned';

  @override
  String get homePin => 'Pin to the home screen';

  @override
  String get homeUnpin => 'Unpin';

  @override
  String get homePinnedDone => 'Pinned to the home screen';

  @override
  String get homeUnpinned => 'Unpinned';

  @override
  String get collectionAppearance => 'Collection look';

  @override
  String get collectionDescriptionLabel => 'Description';

  @override
  String get collectionDescriptionHint =>
      'What this collection is for, in one line';

  @override
  String get collectionColor => 'Colour';

  @override
  String get collectionColorAuto => 'Pick for me';

  @override
  String get collectionCover => 'Cover';

  @override
  String get collectionCoverNone => 'No photos in this collection yet';

  @override
  String get collectionSmart => 'Live collection';

  @override
  String get collectionSmartAll => 'Every entry in the profile';

  @override
  String get collectionSmartEmpty =>
      'Nothing matches the condition yet. Entries will show up here on their own once they do.';

  @override
  String get collectionSmartEditHint =>
      'A live collection\'s condition is edited in the catalogue: open it there, change the filters and save again.';

  @override
  String get collectionOpenInCatalog => 'Open in the catalogue';

  @override
  String get collectionFromFilter => 'Save as a collection';

  @override
  String collectionFromFilterSaved(String name) {
    return 'Collection “$name” assembled';
  }

  @override
  String get photoAdd => 'Add photo';

  @override
  String get photoSectionTitle => 'Photos';

  @override
  String get photoRejected => 'File rejected: unsupported or damaged format';

  @override
  String get photoDuplicate => 'This image has already been added';

  @override
  String get photoRemove => 'Delete photo';

  @override
  String get tourTitle => 'How to use it';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourNext => 'Next';

  @override
  String get tourFinish => 'Got it';

  @override
  String get tourRepeat => 'Take the tour again';

  @override
  String get tourAddTitle => 'Record an impression';

  @override
  String get tourAddBody =>
      'A title is enough for a new entry. Attitude, rating and photos are right in the form; the note, date, tags and collection hide behind “Add details”.';

  @override
  String get tourAddHintDesktop =>
      'Ctrl + N opens the form without taking your hands off the keyboard';

  @override
  String get tourAddHintMobile =>
      'The orange “+” button at the bottom right is available on every screen';

  @override
  String get tourScanTitle => 'A product by its barcode';

  @override
  String get tourScanBodyDesktop =>
      'A barcode can be typed by hand, read with a USB scanner or recognised from a photo. The title and brand are pulled from open product databases.';

  @override
  String get tourScanBodyMobile =>
      'Point the camera at a barcode — the title and brand are pulled from open product databases. Only the code itself leaves the device.';

  @override
  String get tourScanHintDesktop => 'Ctrl + B opens scanning';

  @override
  String get tourShelvesTitle => 'Shelves instead of a list';

  @override
  String get tourShelvesBody =>
      'Categories are shown as shelves: you see the colour, the number of entries and photos from the branch. Tapping goes deeper, the list icon shows the entries of the shelf itself. If you prefer a tree, the switch is next to the title.';

  @override
  String get tourSearchTitle => 'Find it in a second';

  @override
  String get tourSearchBody =>
      'Search covers titles and the text of notes. Filters by type, category, attitude and tags hide behind the “Filters” button, and the active ones are highlighted.';

  @override
  String get tourSearchHintDesktop => 'Ctrl + F jumps to search';

  @override
  String get tourBulkTitle => 'All at once, not one by one';

  @override
  String get tourBulkBodyDesktop =>
      'Ctrl + click selects entries. Selected entries can be given a category, tagged, put into a collection or archived straight away. Right-click opens the entry menu.';

  @override
  String get tourBulkBodyMobile =>
      'A long press turns on selection. Selected entries can be given a category, tagged, put into a collection or archived straight away.';

  @override
  String get tourSafetyTitle => 'Nothing gets lost';

  @override
  String get tourSafetyBody =>
      'Anything you put away goes to the archive and comes back whole. Every change to an entry is kept as a separate version. Settings hold backups — you can create one and roll it back.';

  @override
  String get searchClear => 'Clear search';

  @override
  String get catalogFilters => 'Filters';

  @override
  String get statusesTitle => 'Stages';

  @override
  String statusesEditFor(String name) {
    return 'Stages of “$name”';
  }

  @override
  String get statusesHint =>
      'A stage answers “have you got to it yet”, while the relation answers “did you like it”. Each type names its own.';

  @override
  String get statusesEmpty =>
      'This type has no stages: an entry counts as done right away.';

  @override
  String get statusesAllUsed => 'All three stages are already there';

  @override
  String get statusAdd => 'Add a stage';

  @override
  String get statusRemove => 'Remove the stage';

  @override
  String get statusRename => 'Rename the stage';

  @override
  String get statusNameLabel => 'Stage name';

  @override
  String get statusStagePlanned => 'Planned';

  @override
  String get statusStageInProgress => 'In progress';

  @override
  String get statusStageDone => 'Done';

  @override
  String get progressUnitLabel => 'What progress counts in';

  @override
  String get progressUnitHint =>
      'episode, page, hour — leave empty if there is nothing to count';

  @override
  String get statusLabel => 'Stage';

  @override
  String get statusNone => 'Not started';

  @override
  String get statusTypeHasNone =>
      'This type has no stages — you can set them up in the type settings';

  @override
  String get progressLabel => 'Progress';

  @override
  String progressOf(int current, String unit, int total) {
    return '$current $unit of $total';
  }

  @override
  String progressCurrentOnly(int current, String unit) {
    return '$current $unit';
  }

  @override
  String get progressCurrentLabel => 'Done';

  @override
  String get progressTotalLabel => 'Total';

  @override
  String get catalogStatusLabel => 'Stage';

  @override
  String get catalogAllStatuses => 'Any stage';

  @override
  String get bulkStatus => 'Stage';

  @override
  String get bulkStatusClear => 'Clear stage';

  @override
  String get categoryDefaultType => 'Default type';

  @override
  String get categoryDefaultTypeHint =>
      'New entries in this branch start with it';

  @override
  String get categoryDefaultTypeNone => 'Not set';

  @override
  String categoryDefaultTypeFrom(String name) {
    return 'Type taken from “$name”';
  }

  @override
  String categoryDefaultTypeSuggest(String name) {
    return 'Most entries here are “$name”. Make it the default type?';
  }

  @override
  String get categoryDefaultTypeApply => 'Set it';

  @override
  String get categoryPrimary => 'Primary category';

  @override
  String get categoryExtra => 'More categories';

  @override
  String get categoryExtraAdd => 'Put on another shelf';

  @override
  String get categoryExtraRemove => 'Take off this shelf';

  @override
  String get categoryExtraBadge => 'Extra category';

  @override
  String get categoryMerge => 'Merge with…';

  @override
  String get categoryMergeTitle => 'Which branch to merge into';

  @override
  String categoryMergeMessage(String name) {
    return 'Entries and subcategories will move to the branch you pick, and “$name” goes to the archive. This cannot be undone with one tap.';
  }

  @override
  String get categoryMergeAction => 'Merge';

  @override
  String get categoryMergeDone => 'Branches merged';

  @override
  String get categoryMoveChildren => 'Move subcategories…';

  @override
  String get categoryMoveEntries => 'Move entries…';

  @override
  String categoryMovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches moved',
      one: '$count branch moved',
    );
    return '$_temp0';
  }

  @override
  String categoryMovedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries moved',
      one: '$count entry moved',
    );
    return '$_temp0';
  }

  @override
  String get categoryDragHint => 'Drag to move';

  @override
  String categoryMovedTo(String name) {
    return 'Moved to “$name”';
  }

  @override
  String get categoryAppearance => 'Appearance';

  @override
  String get categoryColor => 'Colour';

  @override
  String get categoryColorInherit => 'Same as parent';

  @override
  String get categoryCover => 'Branch cover';

  @override
  String get categoryCoverFromEntry => 'Use a photo from here';

  @override
  String get categoryCoverFromFile => 'Choose a file';

  @override
  String get categoryCoverRemove => 'Remove cover';

  @override
  String get categoryCoverPick => 'Pick a photo from this branch';

  @override
  String get categoryCoverNone => 'No photos in this branch yet';

  @override
  String get categoryDescriptionLabel => 'Description';

  @override
  String get categoryDescriptionHint => 'What goes on this shelf';

  @override
  String get categoryIconSearch => 'Find an icon';

  @override
  String get categoryScopeHere => 'Here only';

  @override
  String get categoryScopeBranch => 'Whole branch';

  @override
  String get categoryShowMore => 'Show more';

  @override
  String get categoryOpenTree => 'Show tree';

  @override
  String get categoryShelfEmptyTitle => 'Nothing inside yet';

  @override
  String get categoryShelfEmptyMessage =>
      'Add a subcategory or put the first entry here.';

  @override
  String get errorStateTitle => 'This section could not be shown';

  @override
  String get errorStateMessage =>
      'Your data is intact — the failure happened while reading it. Try opening the section again or restarting the app.';

  @override
  String get errorStateDetails => 'Details';

  @override
  String catalogSearchChip(String query) {
    return 'Search: $query';
  }

  @override
  String get purgeAction => 'Delete forever';

  @override
  String purgeConfirmTitle(String title) {
    return 'Delete “$title” forever?';
  }

  @override
  String get purgeConfirmMessage =>
      'This is not archiving: the entry, its versions and photos will be erased. It cannot be undone — only a backup can bring it back.';

  @override
  String get purgeDone => 'Deleted forever';

  @override
  String get purgeCategoryHasChildren =>
      'Deal with the subcategories first: a whole branch cannot be deleted at once.';

  @override
  String get photoMakeCover => 'Make it the cover';

  @override
  String get photoIsCover => 'Entry cover';

  @override
  String get photoDropHint => 'Drop images here';

  @override
  String get profilesTitle => 'Profiles';

  @override
  String get profileCreate => 'New profile';

  @override
  String get profileSwitchTo => 'Make active';

  @override
  String get profileActiveBadge => 'Active';

  @override
  String get profileTypePrimary => 'My main profile';

  @override
  String get profileTypeOtherDevice => 'My profile on another device';

  @override
  String get profileTypeExternal => 'External profile';

  @override
  String get profileTypeExternalArchived => 'Archived external profile';

  @override
  String get profileLocalSettings => 'Local settings';

  @override
  String get profileLocalHint =>
      'This is visible only to you and is never included in an export.';

  @override
  String get profileLocalName => 'Local name';

  @override
  String get profileLocalNameHint => 'For example: Sam from work';

  @override
  String get profileLocalNote => 'Note about this person';

  @override
  String profileEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String get compareTitle => 'Compare profiles';

  @override
  String get compareFirst => 'First profile';

  @override
  String get compareSecond => 'Second profile';

  @override
  String get compareNeedTwo => 'Two different profiles are needed';

  @override
  String get compareNeedTwoMessage =>
      'Create or import one more profile to compare tastes.';

  @override
  String get compareModeOnlyFirst => 'The first has it, the second does not';

  @override
  String get compareModeOnlySecond => 'The second has it, the first does not';

  @override
  String get compareModeBoth => 'Both have it';

  @override
  String get compareModeBothLike => 'Both like it';

  @override
  String get compareModeRatingDiffers => 'Ratings differ a lot';

  @override
  String get compareModeRecommended =>
      'The first recommends, the second has not added it';

  @override
  String get compareEmpty => 'No matches';

  @override
  String get compareEmptyMessage =>
      'Try another comparison mode or other profiles.';

  @override
  String compareSelected(int count) {
    return 'Selected: $count';
  }

  @override
  String get compareTransferSelected => 'Add the selection to my profile';

  @override
  String compareTransferred(int count) {
    return 'Entries added: $count';
  }

  @override
  String get compareNoEntry => 'No entry';

  @override
  String get transferTitle => 'Add to my profile';

  @override
  String get transferDone => 'The entry was added to your profile';

  @override
  String get transferAlreadyHave =>
      'You already have an entry about this object';

  @override
  String get exportTitle => 'Export profile';

  @override
  String get exportAction => 'Export';

  @override
  String get exportIncludePhotos => 'With photos';

  @override
  String get exportProtect => 'Protect with a password';

  @override
  String get exportPassword => 'Package password';

  @override
  String get exportComposition => 'What goes into the file';

  @override
  String get exportEntries => 'Entries';

  @override
  String get exportCategories => 'Categories';

  @override
  String get exportSubcategories => 'of them subcategories';

  @override
  String get exportObjects => 'Objects';

  @override
  String get exportRevisions => 'Versions';

  @override
  String get exportPhotos => 'Photos';

  @override
  String get exportExcludedPrivate => 'Private entries excluded';

  @override
  String get exportForbidden =>
      'The owner has forbidden passing this profile on';

  @override
  String fileSaved(String path) {
    return 'File saved: $path';
  }

  @override
  String get fileShared => 'The file is ready and handed to the app you chose';

  @override
  String get fileSaveCancelled => 'Saving cancelled';

  @override
  String fileSaveFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String get importTitle => 'Import profile';

  @override
  String get importPickFile => 'Choose a file';

  @override
  String get importDropHint => 'Drop a profile file here or choose one';

  @override
  String get importPreviewTitle => 'Preview';

  @override
  String importProfileLine(String name) {
    return 'Profile: $name';
  }

  @override
  String importFingerprintLine(String value) {
    return 'Fingerprint: $value';
  }

  @override
  String get importTrustQuestion => 'A new profile. Do you trust it?';

  @override
  String get importVerified => 'Profile confirmed, the file signature is valid';

  @override
  String get importNoChanges =>
      'This package has already been imported. There are no new changes.';

  @override
  String get importNewEntries => 'New entries';

  @override
  String get importChangedEntries => 'Changed entries';

  @override
  String get importNewCategories => 'New categories';

  @override
  String get importMovedCategories => 'Moved categories';

  @override
  String get importNewImages => 'New images';

  @override
  String get importUnchanged => 'Unchanged';

  @override
  String get importApply => 'Import';

  @override
  String get importDone => 'Import finished';

  @override
  String get importBackupCreated => 'A backup was created before the import';

  @override
  String get importPasswordNeeded => 'The package is password-protected';

  @override
  String get importErrorTitle => 'The import did not go through';

  @override
  String get backupsTitle => 'Backups';

  @override
  String get backupCreate => 'Create a backup';

  @override
  String get backupCreated => 'Backup created';

  @override
  String get backupVerifyOk => 'The backup is intact';

  @override
  String get backupVerifyFailed => 'The backup is damaged';

  @override
  String get backupReasonManual => 'manually';

  @override
  String get backupReasonAuto => 'on schedule';

  @override
  String get backupReasonBeforeImport => 'before an import';

  @override
  String get backupReasonBeforeRestore => 'before a restore';

  @override
  String get backupReasonBeforeEncrypt => 'before an encryption change';

  @override
  String get backupAutoTitle => 'Back up on its own';

  @override
  String get backupAutoHint =>
      'Once a week at startup the app saves your entries and photos into a backup. Backups live on this same device, so they will not survive its loss — keep one for yourself with the button next to a backup.';

  @override
  String get backupSaveToFile => 'Save a copy for me';

  @override
  String get backupRestoreFromFile => 'Restore from a file';

  @override
  String get backupOutsideHint =>
      'A backup lives inside the app: delete the app and the backup goes with it. “Save a copy for me” puts it where you will find it: into a folder you choose on a computer, or through “Share” on a phone.';

  @override
  String get backupAutoOn => 'Backups will be created on their own';

  @override
  String get backupAutoOff => 'Backups are created only by hand';

  @override
  String get backupEmpty => 'No backups yet';

  @override
  String get backupVerify => 'Check integrity';

  @override
  String backupSizeLabel(String size) {
    return '$size KB';
  }

  @override
  String get backupRetentionHint =>
      'Automatic backups are made once a week, and also before an import and a restore. The last 7 automatic and 20 manual ones are kept.';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupRestoreConfirmTitle => 'Restore from this backup?';

  @override
  String backupRestoreConfirmMessage(String date) {
    return 'All entries, categories and photos will be replaced with the contents of the backup from $date. A backup of the current state will be created automatically, so there will be a way back.';
  }

  @override
  String backupRestoreFileConfirmMessage(String name) {
    return 'All entries, categories and photos will be replaced with the contents of the file “$name”. A backup of the current state will be created automatically, so there will be a way back.';
  }

  @override
  String get backupRestoreDoneTitle => 'Backup restored';

  @override
  String get backupRestoreDoneMessage =>
      'The data has been replaced. Close the app and open it again — the restored database can only be used after a restart.';

  @override
  String get backupRestoreQuit => 'Close the app';

  @override
  String get backupRestoreNotFound => 'The backup file was not found';

  @override
  String get backupRestoreTooNew =>
      'This backup was made by a newer version of the app. Update the app and try again.';

  @override
  String get backupEncryptionTitle => 'Protect backups with a password';

  @override
  String get backupEncryptionHint =>
      'A backup taken off this device cannot be read without the password. On this device backups open by themselves — only strangers are asked.';

  @override
  String get backupEncryptionOn => 'Backups are password-protected';

  @override
  String get backupEncryptionOff => 'Backup protection is off';

  @override
  String get backupEncryptionChange => 'Change the password';

  @override
  String get backupEncryptionUnavailable =>
      'The operating system key store is unavailable — there is nothing to protect backups with.';

  @override
  String get backupPasswordTitle => 'Password for backups';

  @override
  String get backupPasswordMessage =>
      'A forgotten password means losing the backups: there will be no way to recover them. Write it down where you keep your other important passwords.';

  @override
  String get backupPasswordField => 'Password';

  @override
  String get backupPasswordRepeat => 'Once more';

  @override
  String get backupPasswordMismatch => 'The passwords do not match';

  @override
  String get backupPasswordShort => 'At least eight characters';

  @override
  String get backupPasswordChangedNote =>
      'Backups that already exist will keep opening with the old password: it is written into each file and does not change retroactively.';

  @override
  String get backupDisableTitle => 'Turn off backup protection?';

  @override
  String get backupDisableMessage =>
      'New backups will be created without a password. The existing ones will still ask for the old one.';

  @override
  String get backupUnlockTitle => 'This backup is password-protected';

  @override
  String get backupUnlockMessage =>
      'It was made on another device or before a reinstall, so the key to it is not here.';

  @override
  String get backupWrongPassword => 'Wrong password';

  @override
  String get backupEncryptedBadge => 'protected';

  @override
  String get quickAddTypeVsCategory =>
      'The type decides which fields an entry has; the category is your shelf in the tree.';

  @override
  String entryRatingOf(Object value) {
    return 'rating $value';
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
  String get errorLogTitle => 'Error log';

  @override
  String get errorLogHint =>
      'Failures are recorded on this device and are not sent anywhere. If the app behaved strangely, copy the log and attach it to a bug report.';

  @override
  String get errorLogEmpty => 'No failures';

  @override
  String errorLogCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '$count record',
    );
    return '$_temp0';
  }

  @override
  String get errorLogShow => 'Show';

  @override
  String get errorLogCopy => 'Copy';

  @override
  String get errorLogCopied => 'The log was copied to the clipboard';

  @override
  String get errorLogClear => 'Clear';

  @override
  String get errorLogCleared => 'The log was cleared';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsAdvancedHint => 'Set once, or never touched at all';

  @override
  String get whatsNewTitle => 'What\'s new';

  @override
  String whatsNewVersion(String version) {
    return 'Version $version';
  }

  @override
  String get whatsNewOpen => 'What\'s new in this version';

  @override
  String get whatsNewNothing => 'There is no description for this version';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get recentEntries => 'Recently opened';

  @override
  String get commandPaletteHint =>
      'A section, a category, an entry or an action';

  @override
  String get commandPaletteSections => 'Sections';

  @override
  String get commandPaletteCategories => 'Categories';

  @override
  String get entrySimilar => 'Similar nearby';

  @override
  String get barcodeBatchTitle => 'Scan one after another';

  @override
  String get barcodeBatchNext => 'Take it and keep scanning';

  @override
  String get barcodeBatchFinish => 'That\'s enough';

  @override
  String barcodeBatchCollected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes collected',
      one: '$count code collected',
    );
    return '$_temp0';
  }

  @override
  String barcodeBatchQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes left',
      one: '$count code left',
    );
    return '$_temp0';
  }

  @override
  String get entryDuplicate => 'Duplicate';

  @override
  String get csvImportTitle => 'A list from a table';

  @override
  String get csvImportHint =>
      'Bring entries over from a CSV — your own export or a table from another app. Missing types and categories will be created automatically.';

  @override
  String get csvImportPick => 'Choose a table';

  @override
  String csvImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries ready',
      one: '$count entry ready',
    );
    return '$_temp0';
  }

  @override
  String csvImportSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows without a title were skipped',
      one: '$count row without a title was skipped',
    );
    return '$_temp0';
  }

  @override
  String csvImportColumns(String columns) {
    return 'Columns: $columns';
  }

  @override
  String get csvImportApply => 'Bring them over';

  @override
  String get csvImportNothing => 'The table has no rows with a title';

  @override
  String csvImportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries brought over',
      one: '$count entry brought over',
    );
    return '$_temp0';
  }

  @override
  String get backupMirrorTitle => 'Also put a copy here';

  @override
  String get backupMirrorHint =>
      'Backups live next to the database: lose the device and you lose the backups. A folder on a USB stick or in a cloud client will outlive the device.';

  @override
  String get backupMirrorChoose => 'Choose a folder';

  @override
  String get backupMirrorClear => 'Do not copy';

  @override
  String get backupMirrorOff => 'Backups are not duplicated anywhere';

  @override
  String get doctorTitle => 'Check the data';

  @override
  String get doctorHint =>
      'Checks photos, entry versions, links and the search index. It never deletes anything that carries meaning.';

  @override
  String get doctorRun => 'Check';

  @override
  String get doctorRepair => 'Repair';

  @override
  String get doctorClean => 'No discrepancies found';

  @override
  String get doctorFixed => 'Repaired';

  @override
  String doctorOrphanFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stray photo files',
      one: '$count stray photo file',
    );
    return '$_temp0';
  }

  @override
  String doctorMissingFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos are missing',
      one: '$count photo is missing',
    );
    return '$_temp0';
  }

  @override
  String doctorEntriesWithoutRevision(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries without a current version',
      one: '$count entry without a current version',
    );
    return '$_temp0';
  }

  @override
  String doctorDanglingCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count links to categories that are gone',
      one: '$count link to a category that is gone',
    );
    return '$_temp0';
  }

  @override
  String doctorDanglingCollectionEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count collection items point nowhere',
      one: '$count collection item points nowhere',
    );
    return '$_temp0';
  }

  @override
  String get doctorSearchOutOfSync =>
      'The search index has fallen behind the entries';

  @override
  String get settingsSearch => 'Search the settings';

  @override
  String get settingsSearchEmpty => 'Nothing found';

  @override
  String get settingsSearchEmptyHint =>
      'Try another word: “backups” or “theme”, for example.';

  @override
  String get settingsWordsAppearance =>
      'theme colour look dark light appearance density';

  @override
  String get settingsWordsBehaviour =>
      'behaviour subcategories transfer entries tour';

  @override
  String get settingsWordsBackups =>
      'backups copies restore password encryption schedule';

  @override
  String get settingsWordsNetwork => 'network internet barcode sources updates';

  @override
  String get settingsWordsTypes => 'object types fields';

  @override
  String get settingsWordsTags => 'tags labels';

  @override
  String get settingsWordsDevices => 'devices sharing';

  @override
  String get settingsWordsKeyStorage => 'key store encryption';

  @override
  String get settingsWordsDoctor => 'check integrity data repair photos index';

  @override
  String get settingsWordsErrorLog => 'errors log failures';

  @override
  String get settingsWordsAbout => 'about version licence hotkeys';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsBehaviour => 'Behaviour';

  @override
  String get settingsShowSubcategoriesDefault =>
      'Show entries from subcategories by default';

  @override
  String get settingsTransferMode => 'When transferring entries';

  @override
  String get settingsTransferSuggest => 'Suggest a matching path';

  @override
  String get settingsTransferAutoCreate =>
      'Create the missing categories automatically';

  @override
  String get settingsTransferAlwaysAsk => 'Always ask';

  @override
  String get settingsTransferNoCategory => 'Save without a category';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyNote =>
      'Entries, photos and keys are kept on this device only: no server, no cloud, no account, no analytics, no telemetry. The only things that go out are a barcode when looking up a product and a request for the list of releases when checking for updates — both can be switched off above.';

  @override
  String get settingsLanguage => 'Interface language';

  @override
  String get settingsLanguageSystem => 'System language';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get tagsHint =>
      'Tags are free-form labels without nesting; they do not replace categories.';

  @override
  String get tagsEmpty => 'No tags yet';

  @override
  String get tagNameLabel => 'Tag name';

  @override
  String get tagRename => 'Rename tag';

  @override
  String get tagDelete => 'Delete tag';

  @override
  String tagUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
      zero: 'no entries',
    );
    return '$_temp0';
  }

  @override
  String get tagDeleteTitle => 'Delete this tag?';

  @override
  String tagDeleteMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
      zero: 'nothing',
    );
    return 'The tag “$name” will be removed from every entry and deleted. The entries stay where they are. Right now it marks $_temp0.';
  }

  @override
  String tagMerged(String name) {
    return 'The tags were merged into “$name”';
  }

  @override
  String get typesTitle => 'Object types';

  @override
  String get typeRename => 'Rename type';

  @override
  String get typeHide => 'Hide';

  @override
  String get typeShow => 'Show';

  @override
  String get typeNameLabel => 'Type name';

  @override
  String get typeHidden => 'Hidden';

  @override
  String get typeCreate => 'New type';

  @override
  String get typeEmpty => 'No types yet';

  @override
  String get devicesTitle => 'Devices';

  @override
  String get deviceThis => 'This device';

  @override
  String get deviceRename => 'Rename device';

  @override
  String get deviceNameLabel => 'Device name';

  @override
  String deviceRegisteredAt(String date) {
    return 'Registered on $date';
  }

  @override
  String get deviceEmpty => 'No devices yet';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagAdd => 'Add tag';

  @override
  String get privacyLabel => 'Sharing';

  @override
  String get privacyOnlyMe => 'Only me';

  @override
  String get privacyShareable => 'Can be shared';

  @override
  String get privacyNoNote => 'Share without the note';

  @override
  String get privacyNoPhotos => 'Share without the photos';

  @override
  String get privacyBasic => 'Share only the basics';

  @override
  String get duplicateTitle => 'Possible duplicates';

  @override
  String get duplicateMessage =>
      'Similar objects already exist. Link them or keep them apart?';

  @override
  String get duplicateKeepSeparate => 'Keep them apart';

  @override
  String get duplicateUseExisting => 'Use the existing one';

  @override
  String get exportModeFull => 'The whole profile';

  @override
  String get exportModeBranch => 'A category branch';

  @override
  String get exportModeCollection => 'A collection';

  @override
  String get exportModeLabel => 'What to export';

  @override
  String get hotkeysTitle => 'Keyboard shortcuts';

  @override
  String get hotkeyNewEntry => 'New entry';

  @override
  String get hotkeySearch => 'Search';

  @override
  String get hotkeyImport => 'Import';

  @override
  String get hotkeyExport => 'Export';

  @override
  String get hotkeyProfiles => 'Profile switcher';

  @override
  String get hotkeyClose => 'Close a dialog';

  @override
  String get hotkeyScan => 'Scan a barcode';

  @override
  String get hotkeySettings => 'Settings';

  @override
  String get onboardingWelcomeSubtitle =>
      'Keep your preferences, recommendations and collections. All local, no network, no account.';

  @override
  String get onboardingCreateProfile => 'Create a profile';

  @override
  String get onboardingProfileNameHint => 'What is your name?';

  @override
  String get onboardingProfileNameLabel => 'First name';

  @override
  String get onboardingLastNameLabel => 'Last name (optional)';

  @override
  String get onboardingNicknameLabel => 'Nickname (optional)';

  @override
  String get onboardingNameRequired => 'Enter a name';

  @override
  String get onboardingStarterTitle => 'A starting structure';

  @override
  String get onboardingStarterSubcategories => 'Create example subcategories';

  @override
  String get onboardingStarterHint =>
      'For example: Groceries → Cheese, Sausages, Drinks. Everything can be renamed or deleted later.';

  @override
  String get onboardingCreating => 'Creating the profile…';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get relationLove => 'Love it';

  @override
  String get relationLike => 'Like it';

  @override
  String get relationNeutral => 'Neutral';

  @override
  String get relationDislike => 'Dislike it';

  @override
  String get relationAvoid => 'Avoid it';

  @override
  String get entryAddToMyProfile => 'Add to my profile';

  @override
  String get breadcrumbObjectSeparator => ' / ';

  @override
  String get categorySearchHint => 'Find a category';

  @override
  String get categoryExpandAll => 'Expand all';

  @override
  String get categoryCollapseAll => 'Collapse all';

  @override
  String get categoryIcon => 'Category icon';

  @override
  String get typeIcon => 'Type icon';

  @override
  String categorySubcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategories',
      one: '$count subcategory',
    );
    return '$_temp0';
  }

  @override
  String categoryDirectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count right here',
      one: '$count right here',
    );
    return '$_temp0';
  }

  @override
  String categoryBranchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries in the branch',
      one: '$count entry in the branch',
    );
    return '$_temp0';
  }

  @override
  String get categorySubcategoriesTitle => 'Subcategories';

  @override
  String get categoryEntriesTitle => 'Entries';

  @override
  String get categoryBranchEmpty => 'This branch has no entries yet';

  @override
  String get categoryPickTitle => 'Choose a category';

  @override
  String get categoryPickMessage =>
      'Pick a branch on the left to see what is inside it — its subcategories and its entries.';

  @override
  String get catalogTypeLabel => 'Type';

  @override
  String get catalogCategoryLabel => 'Category';

  @override
  String get catalogRelationLabel => 'Attitude';

  @override
  String get searchGlobalHint => 'Search entries';

  @override
  String get headerNotifications => 'Notifications';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'Nothing new';

  @override
  String get notificationsEmptyHint =>
      'Incoming changes, updates and import results will show up here.';

  @override
  String get notificationsMarkAllRead => 'Mark everything as read';

  @override
  String get notificationIncomingTitle => 'Incoming changes';

  @override
  String notificationIncomingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes in the imported profiles',
      one: '$count change in the imported profiles',
    );
    return '$_temp0';
  }

  @override
  String get notificationUpdateTitle => 'A new version is available';

  @override
  String notificationUpdateBody(String version) {
    return 'Version $version is ready to install';
  }

  @override
  String get notificationProductsTitle => 'Product details updated';

  @override
  String notificationProductsBody(int count) {
    return 'Cards filled in: $count';
  }

  @override
  String get notificationImportTitle => 'Import finished';

  @override
  String notificationImportBody(String date) {
    return 'Package from $date';
  }

  @override
  String get notificationBackupTitle => 'Backup created';

  @override
  String notificationBackupBody(String date) {
    return 'Latest backup from $date';
  }

  @override
  String get collectionPickTitle => 'Add entries';

  @override
  String get collectionPickEmpty =>
      'This profile has no entries that could be added yet';

  @override
  String collectionPickSelected(int count) {
    return 'Selected: $count';
  }

  @override
  String profilesSubtitle(int count, int max) {
    return '$count of $max possible';
  }

  @override
  String get profileMenuManage => 'All profiles';

  @override
  String get profileMenuSettings => 'App settings';

  @override
  String get barcodeTitle => 'Add by barcode';

  @override
  String get barcodeHintMobile =>
      'Point the camera at a barcode or QR code, or type the digits by hand.';

  @override
  String get barcodeHintDesktop =>
      'Type the code by hand, read it with a USB scanner or recognise it from a photo.';

  @override
  String get barcodeCodeLabel => 'Barcode or QR';

  @override
  String get barcodeLookup => 'Look up';

  @override
  String get barcodeUseCamera => 'Camera';

  @override
  String get barcodePhoto => 'Take a photo';

  @override
  String get barcodeFromFile => 'Recognise from an image';

  @override
  String get barcodeNotRecognized =>
      'No code was found in the image. Try a closer shot without glare.';

  @override
  String get barcodeUseResult => 'Add';

  @override
  String barcodeFoundIn(String source) {
    return 'Source: $source';
  }

  @override
  String get barcodeNotFound => 'The product was not found in any database';

  @override
  String get barcodeLookupFailed => 'Could not reach the product databases';

  @override
  String get barcodeFillManually =>
      'The code will be saved in the card — the title can be typed by hand.';

  @override
  String get barcodeTorch => 'Torch';

  @override
  String get barcodeScanAction => 'Scan a code';

  @override
  String get settingsNetworkTitle => 'Product databases and updates';

  @override
  String get settingsNetworkHint =>
      'The only network requests the app makes. Only the barcode and the version number leave the device.';

  @override
  String get settingsBarcodeLookup => 'Look products up by barcode';

  @override
  String get settingsBarcodeSources => 'Data sources';

  @override
  String get settingsProductAutoUpdate => 'Fill in product cards automatically';

  @override
  String get settingsProductAutoUpdateHint =>
      'No more than once a day. Titles you typed by hand are never replaced.';

  @override
  String get settingsProductRefreshNow => 'Refresh now';

  @override
  String settingsProductRefreshed(int checked, int updated) {
    return 'Checked $checked, filled in $updated';
  }

  @override
  String get settingsAppUpdateCheck => 'Check for app updates';

  @override
  String get settingsAppUpdateNow => 'Check now';

  @override
  String get settingsUpToDate => 'You have the latest version';

  @override
  String get settingsUpdateUnavailable =>
      'The list of versions is unavailable. The repository may be closed — in that case update the app by hand from the releases page.';

  @override
  String get settingsUpdateFailed =>
      'Could not check for updates. Check your internet connection and try again later.';

  @override
  String get updateTitle => 'App update';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get updateDownload => 'Download the installer';

  @override
  String get updateOpenPage => 'Open the release page';

  @override
  String get updateLater => 'Later';

  @override
  String get updateSkip => 'Skip this version';

  @override
  String get updateInstallNow => 'Install';

  @override
  String get updateInstallHint => 'The app will close, update and start again.';

  @override
  String get updateInstallHintAndroid =>
      'The app will download the update and hand it to the system. The first time, Android will ask you to allow installing from this source.';

  @override
  String updateDownloading(int percent) {
    return 'Downloading: $percent%';
  }

  @override
  String get updateDownloadingUnknown => 'Downloading…';

  @override
  String get updateFailed => 'The update failed';

  @override
  String get onboardingStep1Title => 'Your taste, not someone else\'s ratings';

  @override
  String get onboardingStep1Body =>
      'Groceries, dishes, films, books, places — anything worth remembering, whether you liked it or not. A title is enough for a new entry.';

  @override
  String get onboardingStep2Title => 'The opinion is separate from the thing';

  @override
  String get onboardingStep2Body =>
      '“Interstellar” is one object for everyone. Your rating and a friend\'s rating are two different entries. That is why profiles can be exchanged: someone else\'s opinion will never overwrite yours.';

  @override
  String get onboardingStep3Title => 'Everything stays with you';

  @override
  String get onboardingStep3Body =>
      'No account, no server, no cloud. You can share through a file that you create yourself and pass to whomever you want.';

  @override
  String get onboardingStart => 'Start';

  @override
  String get exportReadable => 'For reading';

  @override
  String get exportCsv => 'CSV table';

  @override
  String get exportMarkdown => 'Markdown text';

  @override
  String get insightsTitle => 'Insights';

  @override
  String insightsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Based on $count entries',
      one: 'Based on $count entry',
    );
    return '$_temp0';
  }

  @override
  String get insightsEmptyTitle => 'Nothing to show yet';

  @override
  String get insightsEmptyMessage =>
      'Add a few entries — the rating distribution, attitudes and the month-by-month picture will appear here.';

  @override
  String get insightsTotal => 'Entries';

  @override
  String get insightsAverage => 'Average rating';

  @override
  String get insightsWithPhotos => 'With photos';

  @override
  String get insightsWithNotes => 'With notes';

  @override
  String get insightsRatings => 'Rating distribution';

  @override
  String get insightsRelations => 'Attitude';

  @override
  String get insightsPeriodYear => 'This year';

  @override
  String get insightsPeriodAll => 'All time';

  @override
  String get insightsScopeAll => 'All categories';

  @override
  String get insightsScopeEmpty => 'There are no entries in this slice';

  @override
  String get insightsCategories => 'Fullest categories';

  @override
  String get insightsTimeline => 'Additions by month';

  @override
  String get wishlistTitle => 'Want to try';

  @override
  String wishlistSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ideas',
      one: '$count idea',
    );
    return '$_temp0';
  }

  @override
  String get wishlistEmptyTitle => 'The list is empty';

  @override
  String get wishlistEmptyMessage =>
      'Give the “Planned” stage to whatever you have not got round to and it will gather here.';

  @override
  String get wishlistMarkTried => 'Tried it';

  @override
  String get wishlistRatingTitle => 'How was it?';

  @override
  String get wishlistRatingHint =>
      'The attitude follows from the rating and the impression date is today. All of it can be changed in the card.';

  @override
  String get archiveTitle => 'Archive';

  @override
  String archiveSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items put away',
      one: '$count item put away',
    );
    return '$_temp0';
  }

  @override
  String get archiveEmptyTitle => 'The archive is empty';

  @override
  String get archiveEmptyMessage =>
      'Everything you put away shows up here. Nothing is deleted — any of it can come back.';

  @override
  String get archiveEntries => 'Entries';

  @override
  String get archiveCategories => 'Categories';

  @override
  String get archiveCollections => 'Collections';

  @override
  String archiveCategoryLevel(int level) {
    return 'Nesting level: $level';
  }

  @override
  String archiveRestoredMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries brought back',
      one: '$count entry brought back',
    );
    return '$_temp0';
  }

  @override
  String archivePurgeConfirmMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count entries forever?',
      one: 'Delete $count entry forever?',
    );
    return '$_temp0';
  }

  @override
  String get incomingTitle => 'Incoming changes';

  @override
  String get incomingSubtitle => 'What changed in the imported profiles';

  @override
  String get incomingEmptyTitle => 'No changes';

  @override
  String get incomingEmptyMessage =>
      'After you import an updated profile, the list of what changed will appear here.';

  @override
  String get incomingMarkSeen => 'Mark as seen';

  @override
  String get incomingMarkAllSeen => 'Mark all as seen';

  @override
  String get incomingKindEntry => 'Entry';

  @override
  String get incomingKindObject => 'Object';

  @override
  String get incomingKindCategory => 'Category';

  @override
  String incomingReceivedAt(String date) {
    return 'Received on $date';
  }

  @override
  String get incomingNewBadge => 'New';

  @override
  String get fieldsTitle => 'Type fields';

  @override
  String get fieldsHint => 'Extra fields that entries of this type will have.';

  @override
  String get fieldsAdd => 'Add a field';

  @override
  String get fieldsEmpty => 'No custom fields yet';

  @override
  String get fieldsNameLabel => 'Field name';

  @override
  String get fieldsKindLabel => 'Value type';

  @override
  String get fieldsKindText => 'Text';

  @override
  String get fieldsKindNumber => 'Number';

  @override
  String get fieldsKindDate => 'Date';

  @override
  String get fieldsKindBool => 'Yes or no';

  @override
  String get fieldsKindChoice => 'Choice from a list';

  @override
  String get fieldsChoicesLabel => 'Options, comma separated';

  @override
  String get fieldsRemove => 'Delete field';

  @override
  String fieldsEditFor(String type) {
    return 'Fields of the type “$type”';
  }

  @override
  String get fieldsValuesTitle => 'Additionally';

  @override
  String quickAddBarcodeHint(String code) {
    return 'Filled in from barcode $code';
  }

  @override
  String get lockTitle => 'The database is locked';

  @override
  String get lockMessage => 'Enter the password to open your entries.';

  @override
  String get lockPasswordLabel => 'Password';

  @override
  String get lockOpen => 'Open';

  @override
  String get lockWrongPassword => 'Wrong password';

  @override
  String get lockRemember => 'Remember on this device';

  @override
  String get lockStaleKey =>
      'The remembered key does not fit the current database. This happens after restoring a backup that was made under a different password.';

  @override
  String get lockForgotWarning =>
      'A forgotten password cannot be recovered: the data will only open from a backup made before you turned encryption on.';

  @override
  String get lockQuit => 'Close the app';

  @override
  String get dbEncryptionTitle => 'Encrypt the database with a password';

  @override
  String get dbEncryptionHint =>
      'The database file becomes unreadable without the password: a stolen laptop, a pulled-out drive or a copied file will not give up your entries. It does not protect you from someone sitting at your unlocked device.';

  @override
  String get dbEncryptionOn => 'The database is encrypted';

  @override
  String get dbEncryptionOff => 'The database is not encrypted';

  @override
  String get dbEncryptionEnable => 'Turn on';

  @override
  String get dbEncryptionDisable => 'Turn off';

  @override
  String get dbEncryptionChange => 'Change the password';

  @override
  String get dbEncryptionConfirmTitle => 'Encrypt the database?';

  @override
  String get dbEncryptionConfirmMessage =>
      'A forgotten password means losing every entry: there will be nothing to recover them from, and that is a property of encryption, not a shortcoming. Write the password down where you keep your other important ones. A backup is made before the database is re-encrypted.';

  @override
  String get dbEncryptionConfirmAccept =>
      'The password is written down, continue';

  @override
  String get dbEncryptionDisableTitle => 'Turn encryption off?';

  @override
  String get dbEncryptionDisableMessage =>
      'The database becomes an ordinary file again: anyone who copies it will read your entries without a password.';

  @override
  String get dbEncryptionDone => 'The database is encrypted';

  @override
  String get dbEncryptionOffDone => 'Encryption is off';

  @override
  String get dbEncryptionRestartMessage =>
      'Close the app and open it again — the re-encrypted database can only be used after a restart.';

  @override
  String get dbEncryptionFailed =>
      'Re-encryption failed. The database is unchanged and the backup is in place.';

  @override
  String get dbEncryptionRememberTitle =>
      'Do not ask for the password on this device';

  @override
  String get dbEncryptionRememberHint =>
      'The key goes into the system store, next to the profile key. Convenient — but then the password only protects you from another device, not from your own while it is unlocked.';

  @override
  String get settingsWordsDbEncryption =>
      'encryption database password protection disk';

  @override
  String get keyStorageTitle => 'Where the private key is kept';

  @override
  String get keyStorageOs => 'Apart from the database, protected by the system';

  @override
  String get keyStorageOsWindows =>
      'The file is encrypted by Windows (DPAPI) for your account: on another computer it is useless.';

  @override
  String get keyStorageOsMobile =>
      'The file lives in the app\'s protected directory and never goes into backups.';

  @override
  String get keyStorageDb => 'In the app database — unprotected on disk';

  @override
  String get keyStorageDbHint =>
      'The secret lives in the same database as the key it encrypts, so encrypting the key currently achieves nothing: copy the database file and it can be read. Move the secret into the system store.';

  @override
  String get keyStorageMove => 'Move to the OS store';

  @override
  String get keyStorageMoved =>
      'The key was moved into the operating system store';

  @override
  String get keyStorageMoveFailed =>
      'The system store is unavailable — the secret stayed in the database';
}
