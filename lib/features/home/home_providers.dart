import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';

/// Сводка по активному профилю.
final profileStatsProvider = FutureProvider<ProfileStats?>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return null;
  return ref.watch(entryRepositoryProvider).stats(profile.id);
});

/// Недавние записи активного профиля.
final recentEntriesProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(entryRepositoryProvider).entryViews(profile.id, limit: 10);
});

/// Записи со статусом «Хочу попробовать».
final wantToTryProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref
      .watch(entryRepositoryProvider)
      .entryViews(profile.id, relation: 'wantToTry', limit: 5);
});

/// Корневые категории активного профиля.
final rootCategoriesProvider = FutureProvider<List<CategoryRow>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(categoryRepositoryProvider).roots(profile.id);
});

/// Типы объектов активного профиля.
final objectTypesProvider = FutureProvider<List<ObjectTypeRow>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(entryRepositoryProvider).objectTypes(profile.id);
});
