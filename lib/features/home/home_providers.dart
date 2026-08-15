import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/entry_status.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../data/repositories/entry_stats.dart';

/// Сводка по активному профилю.
final profileStatsProvider = FutureProvider<ProfileStats?>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return null;
  return ref.watch(entryRepositoryProvider).stats(profile.id);
});

/// Сколько записей добавлялось по месяцам — для графика на плитке.
///
/// Раньше плитки рисовали «рост», вычисленный из текущего числа: линия шла
/// вверх независимо от того, что происходило на самом деле.
final entriesByMonthProvider = FutureProvider<List<double>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  final insights = await ref
      .watch(entryRepositoryProvider)
      .insights(profile.id);
  // Последний год: за более длинный срок точки на плитке уже не различить.
  final months = insights.byMonth.length > 12
      ? insights.byMonth.sublist(insights.byMonth.length - 12)
      : insights.byMonth;
  return [for (final m in months) m.count.toDouble()];
});

/// Недавние записи активного профиля.
final recentEntriesProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(entryRepositoryProvider).entryViews(profile.id, limit: 10);
});

/// Задуманное: записи на стадии «Задумано».
///
/// Раньше отбиралось по отношению «Хочу попробовать» — то есть по мнению,
/// которого у задумки как раз ещё нет.
final plannedEntriesProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref
      .watch(entryRepositoryProvider)
      .entryViews(profile.id, status: EntryStatus.planned, limit: 5);
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
