import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/collection_repository.dart';

/// Подборки активного профиля с числом записей.
///
/// Лежит отдельно от экрана: подборку выбирают и в форме добавления записи.
final collectionsProvider = FutureProvider<List<CollectionView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(collectionRepositoryProvider).listWithCounts(profile.id);
});

/// Записи выбранной подборки в ручном порядке (§27).
final collectionEntriesProvider =
    FutureProvider.family<List<EntryView>, String>((ref, collectionId) async {
      ref.watch(dataRefreshProvider);
      final profile = ref.watch(activeProfileProvider);
      if (profile == null) return const [];
      final entries = ref.watch(entryRepositoryProvider);
      return ref
          .watch(collectionRepositoryProvider)
          .entriesOf(
            collectionId,
            profile.id,
            entriesLoader: (ids) =>
                entries.entryViews(profile.id, entryIds: ids),
          );
    });
