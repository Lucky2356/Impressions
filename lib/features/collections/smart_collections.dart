import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../catalog/catalog_providers.dart';

/// Живые подборки: подборка, состав которой задан условием, а не руками (§27).
///
/// Условие — это сохранённый отбор каталога целиком, тот же `CatalogState`,
/// который каталог и так умеет записывать и читать. Своего формата у подборки
/// нет намеренно: два описания одного и того же разошлись бы при первом же
/// новом фильтре.
///
/// До 1.16.0 сохранённые отборы жили в настройках отдельным механизмом и
/// умели ровно одно — применяться к каталогу. Показать их составом, положить
/// на них обложку или открыть как список было нельзя.

/// Разбирает условие подборки; null — подборка ручная или условие испорчено.
///
/// Испорченное условие — это «ничего не находится», а не авария: подборка
/// могла приехать из пакета, собранного другой версией.
CatalogState? smartFilterOf(CollectionRow collection) {
  final raw = collection.filterJson;
  if (raw == null || raw.isEmpty) return null;
  try {
    final json = jsonDecode(raw);
    if (json is! Map<String, Object?>) return null;
    return CatalogState.fromJson(json, const CatalogState());
  } on FormatException {
    return null;
  }
}

/// Записи живой подборки — те, что подходят под её условие прямо сейчас.
Future<List<EntryView>> smartEntriesOf(
  Ref ref,
  String profileId,
  CatalogState filter, {
  int? limit,
}) async {
  return ref
      .read(entryRepositoryProvider)
      .entryViews(
        profileId,
        categoryIds: await categoryScopeOf(ref, filter),
        tagIds: filter.tagIds.isEmpty ? null : filter.tagIds,
        relation: filter.relation,
        status: filter.status,
        typeId: filter.typeId,
        sort: filter.sort,
        reverseSort: filter.reverseSort,
        withoutRating: filter.withoutRating,
        withoutCategory: filter.withoutCategory,
        withoutPhoto: filter.withoutPhoto,
        recommendedOnly: filter.recommendedOnly,
        limit: limit,
      );
}

/// Сколько записей подходит под условие.
///
/// Спрашиваем у базы счёт, а не длину списка: на экране подборок счётчик —
/// единственное, что нужно, а сами записи там не показываются.
Future<int> smartCountOf(Ref ref, String profileId, CatalogState filter) async {
  final page = await ref
      .read(entryRepositoryProvider)
      .entryPage(
        profileId,
        categoryIds: await categoryScopeOf(ref, filter),
        tagIds: filter.tagIds.isEmpty ? null : filter.tagIds,
        relation: filter.relation,
        status: filter.status,
        typeId: filter.typeId,
        sort: filter.sort,
        reverseSort: filter.reverseSort,
        withoutRating: filter.withoutRating,
        withoutCategory: filter.withoutCategory,
        withoutPhoto: filter.withoutPhoto,
        recommendedOnly: filter.recommendedOnly,
        limit: 1,
      );
  return page.total;
}

/// Условие подборки словами: «Продукты · Нравится · без оценки».
///
/// Живая подборка обязана объяснять, почему в ней именно это: список,
/// меняющийся сам по себе и не говорящий почему, читается как сбой.
/// Категории и теги называются по имени, поэтому их приходится передавать —
/// сами по себе в отборе лежат только идентификаторы.
List<String> smartFilterWords(
  CatalogState filter,
  AppLocalizations l10n, {
  String? typeName,
  String? categoryName,
  List<String> tagNames = const [],
  String? relationLabel,
  String? statusLabel,
}) => [
  ?typeName,
  ?categoryName,
  ?relationLabel,
  ?statusLabel,
  ...tagNames,
  if (filter.withoutRating) l10n.catalogWithoutRating,
  if (filter.withoutCategory) l10n.catalogWithoutCategory,
  if (filter.withoutPhoto) l10n.catalogWithoutPhoto,
  if (filter.recommendedOnly) l10n.catalogRecommended,
];

/// Разовый переезд сохранённых отборов в живые подборки.
///
/// Отбор и подборка отвечали на один и тот же вопрос «покажи вот эти записи»,
/// но жили в разных местах и умели разное. После переезда настройка стирается:
/// иначе следующий запуск завёл бы те же подборки заново.
///
/// Возвращает, сколько подборок завела.
Future<int> migrateSavedFiltersToCollections({
  required String profileId,
  required SettingsRepository settings,
  required CollectionRepository collections,
}) async {
  final raw = await settings.get(SettingKeys.catalogSavedFilters);
  if (raw == null || raw.isEmpty) return 0;

  final List<Object?> saved;
  try {
    final json = jsonDecode(raw);
    if (json is! List) {
      await settings.set(SettingKeys.catalogSavedFilters, '');
      return 0;
    }
    saved = json;
  } on FormatException {
    // Настройку написала другая версия — переносить нечего, но и держать её
    // дальше незачем.
    await settings.set(SettingKeys.catalogSavedFilters, '');
    return 0;
  }

  final existing = {
    for (final view in await collections.listWithCounts(profileId))
      view.collection.name.toLowerCase(),
  };

  var created = 0;
  for (final item in saved) {
    if (item is! Map) continue;
    final name = item['name'];
    final filters = item['filters'];
    if (name is! String || name.isEmpty || filters is! Map) continue;
    // Одноимённая подборка уже есть — второй такой же не заводим.
    if (!existing.add(name.toLowerCase())) continue;

    await collections.create(profileId, name, filterJson: jsonEncode(filters));
    created++;
  }

  await settings.set(SettingKeys.catalogSavedFilters, '');
  return created;
}
