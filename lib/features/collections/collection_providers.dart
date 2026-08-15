import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/collection_repository.dart';
import '../categories/category_providers.dart';
import 'smart_collections.dart';

/// Подборки активного профиля с числом записей.
///
/// Лежит отдельно от экрана: подборку выбирают и в форме добавления записи.
///
/// У живых подборок счётчик считается по условию: в `collection_entries` у них
/// пусто, и без этого они все показывали бы «0 записей».
final collectionsProvider = FutureProvider<List<CollectionView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  // Отбор живой подборки может опираться на ветку категорий — значит зависит
  // от дерева.
  ref.watch(allCategoriesProvider);

  final list = await ref
      .watch(collectionRepositoryProvider)
      .listWithCounts(profile.id);

  return [
    for (final view in list)
      if (smartFilterOf(view.collection) case final filter?)
        CollectionView(
          collection: view.collection,
          entryCount: await smartCountOf(ref, profile.id, filter),
        )
      else
        view,
  ];
});

/// Записи выбранной подборки (§27).
///
/// У ручной — в заданном руками порядке, у живой — те, что подходят под её
/// условие прямо сейчас.
final collectionEntriesProvider =
    FutureProvider.family<List<EntryView>, String>((ref, collectionId) async {
      ref.watch(dataRefreshProvider);
      final profile = ref.watch(activeProfileProvider);
      if (profile == null) return const [];
      ref.watch(allCategoriesProvider);

      final collections = ref.watch(collectionRepositoryProvider);
      final entries = ref.watch(entryRepositoryProvider);

      final row = await collections.byId(collectionId);
      final filter = row == null ? null : smartFilterOf(row);
      if (filter != null) return smartEntriesOf(ref, profile.id, filter);

      return collections.entriesOf(
        collectionId,
        profile.id,
        entriesLoader: (ids) => entries.entryViews(profile.id, entryIds: ids),
      );
    });
