import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/services/revision_service.dart';

/// Подробности записи для карточки: сама запись, объект, тип, путь категории
/// и история версий.
class EntryDetail {
  const EntryDetail({
    required this.entry,
    required this.object,
    required this.type,
    required this.categoryPath,
    required this.extraCategories,
    required this.history,
    this.recommendedBy,
  });

  final ProfileEntryRow entry;
  final ObjectRow object;

  /// Тип записи целиком, а не одно название: у него же лежат набор стадий и
  /// единица прогресса, и второй запрос за ними был бы запросом за тем, что
  /// уже прочитано.
  final ObjectTypeRow type;

  String get typeName => type.name;

  final List<String> categoryPath;

  /// Дополнительные категории (§7.2): запись лежит и здесь тоже.
  ///
  /// Схема их поддерживала с самого начала, но интерфейс знал только про
  /// основную: положить запись на две полки было нечем.
  final List<CategoryRow> extraCategories;

  final List<ProfileEntryRevisionRow> history;

  /// Имя того, кто посоветовал эту запись; null — завели сами.
  ///
  /// Приложение помечало перенесённые записи с самого начала, но нигде этого не
  /// показывало: «медиатека предпочтений и рекомендаций» писала рекомендации
  /// в стол.
  final String? recommendedBy;
}

final entryDetailProvider = FutureProvider.family<EntryDetail?, String>((
  ref,
  entryId,
) async {
  ref.watch(dataRefreshProvider);
  final db = ref.watch(appDatabaseProvider);

  final entry = await (db.select(
    db.profileEntries,
  )..where((e) => e.id.equals(entryId))).getSingleOrNull();
  if (entry == null) return null;

  final object = await (db.select(
    db.objects,
  )..where((o) => o.id.equals(entry.objectId))).getSingle();
  final type = await (db.select(
    db.objectTypes,
  )..where((t) => t.id.equals(object.typeId))).getSingle();

  // Путь основной категории.
  final links = await (db.select(
    db.entryCategories,
  )..where((ec) => ec.entryId.equals(entryId))).get();
  final primary = links.where((l) => l.isPrimary).firstOrNull;

  // Путь берём крошками: они читают саму категорию и её предков по
  // материализованному пути. Раньше сюда поднимались все категории профиля —
  // сотни строк ради одного-трёх названий, и так на каждое открытие карточки.
  final path = primary == null
      ? const <String>[]
      : (await CategoryRepository(
          db,
        ).breadcrumb(primary.categoryId)).map((c) => c.name).toList();

  final extraIds = [
    for (final l in links)
      if (!l.isPrimary) l.categoryId,
  ];
  final extras = extraIds.isEmpty
      ? const <CategoryRow>[]
      : await (db.select(
          db.categories,
        )..where((c) => c.id.isIn(extraIds))).get();

  final history = await RevisionService(db).entryHistory(entryId);

  final source = entry.recommendedByProfileId;
  final recommender = source == null
      ? null
      : await (db.select(
          db.profiles,
        )..where((p) => p.id.equals(source))).getSingleOrNull();

  return EntryDetail(
    entry: entry,
    object: object,
    type: type,
    categoryPath: path,
    extraCategories: extras,
    history: history,
    recommendedBy: recommender?.firstName,
  );
});

/// Записи, похожие на открытую: тот же тип, близкая оценка или общий тег.
///
/// Приложение знало о вкусах больше, чем показывало: связей между записями на
/// экране не было вовсе.
final similarEntriesProvider = FutureProvider.family<List<EntryView>, String>((
  ref,
  entryId,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(entryRepositoryProvider).similarTo(profile.id, entryId);
});
