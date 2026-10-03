import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/providers.dart';
import '../../data/repositories/year_review.dart';

/// Какой год показывают итоги.
///
/// По умолчанию — прошедший в январе и текущий в остальное время: в первые
/// недели года «итоги» означают именно прошлый год, а к марту — уже этот.
class YearReviewYear extends Notifier<int> {
  @override
  int build() {
    final now = DateTime.now();
    return now.month == 1 ? now.year - 1 : now.year;
  }

  void set(int year) => state = year;
}

final yearReviewYearProvider = NotifierProvider<YearReviewYear, int>(
  YearReviewYear.new,
);

/// Итоги выбранного года для активного профиля.
final yearReviewProvider = FutureProvider<YearReview>((ref) async {
  ref.watchData(DataKind.entries);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return YearReview.empty;
  return ref
      .watch(entryRepositoryProvider)
      .yearReview(profile.id, ref.watch(yearReviewYearProvider));
});

/// Цель на год и сколько по ней пройдено.
///
/// Считается от того же числа, что стоит на карточке года: цель не должна
/// расходиться с итогами, по которым её и проверяют.
class YearGoal {
  const YearGoal({
    required this.year,
    required this.goal,
    required this.done,
    required this.now,
  });

  final int year;

  /// Сколько задумано. Больше нуля — цель поставлена.
  final int goal;

  /// Сколько впечатлений за год уже случилось.
  final int done;

  /// Сегодняшний день — от него считаются остатки.
  final DateTime now;

  bool get reached => done >= goal;

  /// Сколько осталось. Перевыполненная цель отдаёт ноль, а не минус.
  int get left => reached ? 0 : goal - done;

  /// Доля пройденного, от нуля до единицы: полоса не уезжает за край.
  double get share => goal <= 0 ? 0 : (done / goal).clamp(0, 1);

  /// Сколько дней осталось до конца года. Для прошлых лет — ноль: там
  /// осталось нисколько, и обещать время было бы неправдой.
  int get daysLeft {
    final end = DateTime(year + 1);
    if (!end.isAfter(now)) return 0;
    final start = DateTime(now.year, now.month, now.day);
    return end.difference(start).inDays;
  }
}

/// Цель на год, который показывают итоги; null — цель не поставлена.
///
/// Пройденное берётся из самих итогов, уже посчитанных для этого экрана.
final yearGoalProvider = FutureProvider<YearGoal?>((ref) async {
  ref.watchData(DataKind.settings);
  final year = ref.watch(yearReviewYearProvider);
  final goal = await ref.read(settingsRepositoryProvider).yearGoal(year);
  if (goal <= 0) return null;
  final review = await ref.watch(yearReviewProvider.future);
  return YearGoal(
    year: year,
    goal: goal,
    done: review.year == year ? review.total : 0,
    now: DateTime.now(),
  );
});

/// Цель нынешнего года — для главной.
///
/// Нынешнего, а не выбранного на экране итогов: главная показывает, как идут
/// дела сейчас, и не должна меняться от того, что человек листал прошлые
/// годы.
final currentYearGoalProvider = FutureProvider<YearGoal?>((ref) async {
  ref.watchData(DataKind.settings);
  ref.watchData(DataKind.entries);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return null;

  final now = DateTime.now();
  final goal = await ref.read(settingsRepositoryProvider).yearGoal(now.year);
  if (goal <= 0) return null;

  final done = await ref
      .read(entryRepositoryProvider)
      .yearCount(profile.id, now.year);
  return YearGoal(year: now.year, goal: goal, done: done, now: now);
});
