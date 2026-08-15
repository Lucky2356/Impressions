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

/// Начатое: записи на стадии «В процессе».
///
/// Самый частый вопрос к приложению — «на чём я остановился», — и ответить на
/// него было нечем: стадия в базе была и не читалась ни одним экраном.
final inProgressEntriesProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref
      .watch(entryRepositoryProvider)
      .entryViews(profile.id, status: EntryStatus.inProgress, limit: 8);
});

/// Что случилось примерно год назад — по дате впечатления.
///
/// Окно в неделю в обе стороны: строго один день почти никогда не совпал бы, и
/// блок не показывался бы никогда. Дата впечатления, а не заведения записи:
/// впечатление могло случиться задолго до того, как его записали.
final yearAgoEntriesProvider = FutureProvider<List<EntryView>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];

  final now = DateTime.now();
  final target = DateTime(now.year - 1, now.month, now.day);
  return ref
      .watch(entryRepositoryProvider)
      .entryViews(
        profile.id,
        impressionFrom: target.subtract(const Duration(days: 7)),
        impressionTo: target.add(const Duration(days: 7)),
        sort: EntrySort.impressionDate,
        limit: 6,
      );
});

/// Одна задумка на сегодня — из тех, до чего ещё не дошли руки.
///
/// Выбирается по дню, а не случайно на каждую перерисовку: подсказка,
/// меняющаяся от прокрутки, — не подсказка. Завтра будет другая.
final dailySuggestionProvider = FutureProvider<EntryView?>((ref) async {
  final planned = await ref.watch(plannedSuggestionPoolProvider.future);
  if (planned.isEmpty) return null;

  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  return planned[dayOfYear % planned.length];
});

/// Из чего выбирается подсказка дня.
///
/// Отдельно от [plannedEntriesProvider]: тому хватает пяти записей для боковой
/// колонки, а подсказке нужен запас пошире — иначе изо дня в день предлагалось
/// бы одно и то же.
final plannedSuggestionPoolProvider = FutureProvider<List<EntryView>>((
  ref,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref
      .watch(entryRepositoryProvider)
      .entryViews(profile.id, status: EntryStatus.planned, limit: 50);
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
