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
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return YearReview.empty;
  return ref
      .watch(entryRepositoryProvider)
      .yearReview(profile.id, ref.watch(yearReviewYearProvider));
});
