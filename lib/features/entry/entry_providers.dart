import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/services/revision_service.dart';

/// Подробности записи для карточки: сама запись, объект, тип, путь категории
/// и история версий.
class EntryDetail {
  const EntryDetail({
    required this.entry,
    required this.object,
    required this.typeName,
    required this.categoryPath,
    required this.history,
    this.recommendedBy,
  });

  final ProfileEntryRow entry;
  final ObjectRow object;
  final String typeName;
  final List<String> categoryPath;
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

  var path = <String>[];
  if (primary != null) {
    final cats = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(entry.profileId))).get();
    final byId = {for (final c in cats) c.id: c};
    final selected = byId[primary.categoryId];
    if (selected != null) {
      path = [
        for (final id in selected.path.split('/'))
          if (byId[id] != null) byId[id]!.name,
      ];
    }
  }

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
    typeName: type.name,
    categoryPath: path,
    history: history,
    recommendedBy: recommender?.firstName,
  );
});
