import 'package:drift/drift.dart';

import '../../core/domain/entry_status.dart';
import '../models/entry_view.dart';
import 'entry_repository.dart';

/// Итоги года (§14): ретроспектива вместо таблиц.
///
/// Экран статистики отвечает на вопрос «каковы мои вкусы», и отвечает
/// распределениями. Здесь другой вопрос — «каким был этот год», — и на него
/// отвечают не долями, а событиями: лучшее, первое, последнее, самый
/// насыщенный месяц.
class YearReview {
  const YearReview({
    required this.year,
    required this.total,
    required this.rated,
    required this.averageRating,
    required this.best,
    required this.first,
    required this.last,
    required this.topCategory,
    required this.busiestMonth,
    required this.byRelation,
    required this.newCategories,
    required this.finished,
    required this.returned,
  });

  static const empty = YearReview(
    year: 0,
    total: 0,
    rated: 0,
    averageRating: null,
    best: [],
    first: null,
    last: null,
    topCategory: null,
    busiestMonth: null,
    byRelation: {},
    newCategories: 0,
    finished: 0,
    returned: 0,
  );

  final int year;

  /// Сколько впечатлений случилось за год.
  final int total;
  final int rated;
  final double? averageRating;

  /// Лучшее по оценке — с обложками, поэтому целыми карточками.
  final List<EntryView> best;

  /// Первое и последнее впечатление года.
  final EntryView? first;
  final EntryView? last;

  /// Ветка, в которую за год попало больше всего.
  final ({String id, String name, int count})? topCategory;

  /// Самый насыщенный месяц года.
  final ({DateTime month, int count})? busiestMonth;

  final Map<String, int> byRelation;

  /// Сколько новых веток завели за год.
  final int newCategories;

  /// Сколько начатого довели до конца — записи на завершающей стадии.
  final int finished;

  /// К скольким записям в этом году возвращались не в первый раз (§10).
  ///
  /// Считается по повторам, а не по записям: «сходили в это кафе четвёртый
  /// раз» — про год, а не про то, когда кафе завели.
  final int returned;

  bool get isEmpty => total == 0;
}

/// Считает итоги года одним набором запросов.
///
/// Отдельным расширением, а не внутри [EntryStats]: тот про распределения по
/// всему профилю, этот — про один год, и общего у них только источник данных.
extension YearReviewStats on EntryRepository {
  /// Год записи: дата впечатления, а если её нет — когда запись завели.
  ///
  /// Иначе итоги считались бы только по тем записям, где дату проставили
  /// руками, — а её проставляют редко, и год выглядел бы пустым.
  static final _at = CustomExpression<DateTime>(
    'COALESCE(profile_entries.impression_date, profile_entries.created_at)',
  );

  Future<YearReview> yearReview(String profileId, int year) async {
    final e = db.profileEntries;
    final from = DateTime(year);
    final to = DateTime(year + 1);
    final inYear =
        e.profileId.equals(profileId) &
        e.archivedAt.isNull() &
        _at.isBiggerOrEqualValue(from) &
        _at.isSmallerThanValue(to);

    final total = e.id.count();
    final ratedCount = e.rating.count();
    final ratingSum = e.rating.sum();
    final summary =
        await (db.selectOnly(e)
              ..addColumns([total, ratedCount, ratingSum])
              ..where(inYear))
            .getSingle();

    final totalCount = summary.read(total) ?? 0;
    if (totalCount == 0) return YearReview.empty;

    final rated = summary.read(ratedCount) ?? 0;
    final sum = summary.read(ratingSum) ?? 0;

    final finished =
        (await (db.selectOnly(e)
                  ..addColumns([total])
                  ..where(inYear & e.status.equals(EntryStatus.doneKey)))
                .getSingle())
            .read(total) ??
        0;

    final byRelation = <String, int>{};
    final relations =
        await (db.selectOnly(e)
              ..addColumns([e.relation, total])
              ..where(inYear & e.relation.isNotNull())
              ..groupBy([e.relation]))
            .get();
    for (final row in relations) {
      final name = row.read(e.relation);
      if (name != null) byRelation[name] = row.read(total) ?? 0;
    }

    final busiestMonth = await _busiestMonth(inYear, total);
    final topCategory = await _topCategory(profileId, inYear);
    final newCategories = await _newCategories(profileId, from, to);
    final returned = await _returned(profileId, from, to);

    // Записи для карточек: лучшее, первое и последнее. Идентификаторы берём
    // отдельными запросами, а карточки собираем одним — иначе на три вопроса
    // ушло бы три полных выборки с обложками и путями категорий.
    final bestIds = await _ids(
      inYear & e.rating.isNotNull(),
      OrderingTerm(expression: e.rating, mode: OrderingMode.desc),
      limit: 5,
    );
    final firstId = await _ids(inYear, OrderingTerm(expression: _at), limit: 1);
    final lastId = await _ids(
      inYear,
      OrderingTerm(expression: _at, mode: OrderingMode.desc),
      limit: 1,
    );

    final wanted = {...bestIds, ...firstId, ...lastId}.toList();
    final views = wanted.isEmpty
        ? const <EntryView>[]
        : await entryViews(profileId, entryIds: wanted);
    final byId = {for (final v in views) v.entryId: v};

    return YearReview(
      year: year,
      total: totalCount,
      rated: rated,
      averageRating: rated == 0 ? null : sum / rated,
      best: [for (final id in bestIds) ?byId[id]],
      first: firstId.isEmpty ? null : byId[firstId.first],
      last: lastId.isEmpty ? null : byId[lastId.first],
      topCategory: topCategory,
      busiestMonth: busiestMonth,
      byRelation: byRelation,
      newCategories: newCategories,
      finished: finished,
      returned: returned,
    );
  }

  /// Идентификаторы записей под условием в заданном порядке.
  Future<List<String>> _ids(
    Expression<bool> where,
    OrderingTerm order, {
    required int limit,
  }) async {
    final rows =
        await (db.select(db.profileEntries)
              ..where((_) => where)
              ..orderBy([(_) => order])
              ..limit(limit))
            .get();
    return [for (final row in rows) row.id];
  }

  /// К скольким записям в этом году возвращались не в первый раз.
  ///
  /// Считаем записи, а не сами повторы: «возвращались к семи местам» понятнее,
  /// чем «было двадцать повторов». Первый раз не в счёт — иначе сюда попало бы
  /// всё, что человек когда-либо заводил.
  Future<int> _returned(String profileId, DateTime from, DateTime to) async {
    final rows = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM ('
          '  SELECT v.entry_id FROM entry_visits v'
          '  JOIN profile_entries e ON e.id = v.entry_id'
          '  WHERE e.profile_id = ?1 AND e.archived_at IS NULL'
          '    AND v.occurred_at >= ?2 AND v.occurred_at < ?3'
          '  GROUP BY v.entry_id HAVING COUNT(*) > 1'
          ')',
          variables: [
            Variable<String>(profileId),
            Variable<DateTime>(from),
            Variable<DateTime>(to),
          ],
          readsFrom: {db.entryVisits, db.profileEntries},
        )
        .getSingle();
    return rows.read<int>('c');
  }

  Future<({DateTime month, int count})?> _busiestMonth(
    Expression<bool> inYear,
    Expression<int> total,
  ) async {
    // Месяц считается в местном времени — так же, как его прочитал бы человек.
    final month = CustomExpression<String>(
      "strftime('%m', COALESCE(profile_entries.impression_date, "
      "profile_entries.created_at), 'unixepoch', 'localtime')",
    );
    final rows =
        await (db.selectOnly(db.profileEntries)
              ..addColumns([month, total])
              ..where(inYear)
              ..groupBy([month]))
            .get();

    ({DateTime month, int count})? best;
    for (final row in rows) {
      final key = row.read(month);
      final count = row.read(total) ?? 0;
      if (key == null) continue;
      if (best == null || count > best.count) {
        best = (month: DateTime(0, int.parse(key)), count: count);
      }
    }
    return best;
  }

  /// Ветка года: считаем по всей ветке, чтобы «Продукты» не выглядели пустыми,
  /// когда всё лежит в «Колбасах».
  Future<({String id, String name, int count})?> _topCategory(
    String profileId,
    Expression<bool> inYear,
  ) async {
    final ec = db.entryCategories;
    final rows =
        await (db.selectOnly(ec).join([
                innerJoin(
                  db.profileEntries,
                  db.profileEntries.id.equalsExp(ec.entryId),
                ),
              ])
              ..addColumns([ec.categoryId, ec.entryId.count()])
              ..where(inYear & ec.isPrimary.equals(true))
              ..groupBy([ec.categoryId]))
            .get();
    if (rows.isEmpty) return null;

    final categories = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(profileId))).get();
    final byId = {for (final c in categories) c.id: c};

    final perBranch = <String, int>{};
    for (final row in rows) {
      final cat = byId[row.read(ec.categoryId)];
      if (cat == null) continue;
      final count = row.read(ec.entryId.count()) ?? 0;
      for (final ancestorId in cat.path.split('/')) {
        perBranch[ancestorId] = (perBranch[ancestorId] ?? 0) + count;
      }
    }

    ({String id, String name, int count})? best;
    for (final entry in perBranch.entries) {
      final cat = byId[entry.key];
      if (cat == null) continue;
      if (best == null || entry.value > best.count) {
        best = (id: cat.id, name: cat.name, count: entry.value);
      }
    }
    return best;
  }

  Future<int> _newCategories(
    String profileId,
    DateTime from,
    DateTime to,
  ) async {
    final count = db.categories.id.count();
    final row =
        await (db.selectOnly(db.categories)
              ..addColumns([count])
              ..where(
                db.categories.profileId.equals(profileId) &
                    db.categories.createdAt.isBiggerOrEqualValue(from) &
                    db.categories.createdAt.isSmallerThanValue(to),
              ))
            .getSingle();
    return row.read(count) ?? 0;
  }
}
