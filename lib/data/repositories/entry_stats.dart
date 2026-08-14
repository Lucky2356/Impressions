import 'package:drift/drift.dart';

import '../models/entry_view.dart';
import 'entry_repository.dart';

/// Сводки и разборы профиля: главная и «Итоги».
///
/// Живут расширением, а не внутри репозитория: это чтение поверх тех же
/// таблиц, а сам репозиторий и без них был на полторы тысячи строк.
extension EntryStats on EntryRepository {
  /// Сводка по профилю для главной.
  Future<ProfileStats> stats(String profileId) async {
    Future<int> countOf(Future<int> f) => f;

    final entriesCount = await countOf(
      (db.selectOnly(db.profileEntries)
            ..addColumns([db.profileEntries.id.count()])
            ..where(
              db.profileEntries.profileId.equals(profileId) &
                  db.profileEntries.archivedAt.isNull(),
            ))
          .map((r) => r.read(db.profileEntries.id.count()) ?? 0)
          .getSingle(),
    );

    final categoriesCount = await countOf(
      (db.selectOnly(db.categories)
            ..addColumns([db.categories.id.count()])
            ..where(
              db.categories.profileId.equals(profileId) &
                  db.categories.archivedAt.isNull(),
            ))
          .map((r) => r.read(db.categories.id.count()) ?? 0)
          .getSingle(),
    );

    final collectionsCount = await countOf(
      (db.selectOnly(db.collections)
            ..addColumns([db.collections.id.count()])
            ..where(
              db.collections.profileId.equals(profileId) &
                  db.collections.archivedAt.isNull(),
            ))
          .map((r) => r.read(db.collections.id.count()) ?? 0)
          .getSingle(),
    );

    final wantCount = await countOf(
      (db.selectOnly(db.profileEntries)
            ..addColumns([db.profileEntries.id.count()])
            ..where(
              db.profileEntries.profileId.equals(profileId) &
                  db.profileEntries.archivedAt.isNull() &
                  db.profileEntries.relation.equals('wantToTry'),
            ))
          .map((r) => r.read(db.profileEntries.id.count()) ?? 0)
          .getSingle(),
    );

    return ProfileStats(
      entries: entriesCount,
      categories: categoriesCount,
      collections: collectionsCount,
      wantToTry: wantCount,
    );
  }

  /// Развёрнутая статистика профиля (§14).
  ///
  /// Считается агрегатами в базе. Раньше сюда поднимались все записи профиля
  /// целиком, вместе с текстами заметок, и распределения складывались в Dart:
  /// экран статистики стоил столько же, сколько выгрузка всего профиля.
  /// [since] — считать только записи, заведённые не раньше этой даты.
  /// [categoryIds] — только записи из этих категорий (обычно вся ветка).
  Future<ProfileInsights> insights(
    String profileId, {
    DateTime? since,
    List<String>? categoryIds,
  }) async {
    final e = db.profileEntries;
    var live = e.profileId.equals(profileId) & e.archivedAt.isNull();

    // Разрезы: «что было за год» и «что в этой ветке». Данные для таких
    // вопросов были, а задать их было нечем — экран считал по всему профилю.
    if (since != null) {
      live = live & e.createdAt.isBiggerOrEqualValue(since);
    }
    if (categoryIds != null) {
      if (categoryIds.isEmpty) return ProfileInsights.empty;
      final links = await (db.select(
        db.entryCategories,
      )..where((ec) => ec.categoryId.isIn(categoryIds))).get();
      final ids = links.map((l) => l.entryId).toSet();
      if (ids.isEmpty) return ProfileInsights.empty;
      live = live & e.id.isIn(ids);
    }

    // Итоги: сколько всего, скольким поставлена оценка и их сумма.
    final total = e.id.count();
    final ratedCount = e.rating.count();
    final ratingSum = e.rating.sum();
    final summary =
        await (db.selectOnly(e)
              ..addColumns([total, ratedCount, ratingSum])
              ..where(live))
            .getSingle();

    final totalCount = summary.read(total) ?? 0;
    if (totalCount == 0) return ProfileInsights.empty;
    final rated = summary.read(ratedCount) ?? 0;
    final sum = summary.read(ratingSum) ?? 0;

    // Корзина — ближайший целый балл, как человек оценку и читает.
    final bucket = CustomExpression<int>(
      'CAST(ROUND(profile_entries.rating) AS INTEGER)',
    );
    final buckets = List<int>.filled(10, 0);
    final byBucket =
        await (db.selectOnly(e)
              ..addColumns([bucket, total])
              ..where(live & e.rating.isNotNull())
              ..groupBy([bucket]))
            .get();
    for (final row in byBucket) {
      final value = row.read(bucket);
      if (value == null) continue;
      buckets[(value - 1).clamp(0, 9)] += row.read(total) ?? 0;
    }

    final byRelation = <String, int>{};
    final relations =
        await (db.selectOnly(e)
              ..addColumns([e.relation, total])
              ..where(live & e.relation.isNotNull())
              ..groupBy([e.relation]))
            .get();
    for (final row in relations) {
      final name = row.read(e.relation);
      if (name != null) byRelation[name] = row.read(total) ?? 0;
    }

    // Месяц считается в местном времени — так же, как его прочитал бы человек.
    // Даты лежат секундами эпохи, отсюда `unixepoch`.
    final month = CustomExpression<String>(
      "strftime('%Y-%m', profile_entries.created_at, 'unixepoch', 'localtime')",
    );
    final monthly =
        await (db.selectOnly(e)
              ..addColumns([month, total])
              ..where(live)
              ..groupBy([month])
              ..orderBy([OrderingTerm(expression: month)]))
            .get();
    final byMonth = <({DateTime month, int count})>[];
    for (final row in monthly) {
      final key = row.read(month);
      if (key == null) continue;
      final parts = key.split('-');
      byMonth.add((
        month: DateTime(int.parse(parts[0]), int.parse(parts[1])),
        count: row.read(total) ?? 0,
      ));
    }

    // Заметка есть, если в ней что-то кроме пробелов.
    final withNotes =
        (await (db.selectOnly(e)
                  ..addColumns([total])
                  ..where(
                    live &
                        CustomExpression<bool>(
                          'TRIM(COALESCE(profile_entries.detailed_note, '
                          "profile_entries.short_note, '')) <> ''",
                        ),
                  ))
                .getSingle())
            .read(total) ??
        0;

    // Вложения привязаны к версии записи, поэтому идём через текущую. Считаем
    // записи, а не файлы: одна запись с пятью фотографиями — это одна запись
    // с фотографиями.
    final distinctEntries = e.id.count(distinct: true);
    final withPhotos =
        (await (db.selectOnly(e).join([
                    innerJoin(
                      db.revisionAttachments,
                      db.revisionAttachments.revisionId.equalsExp(
                            e.currentRevisionId,
                          ) &
                          db.revisionAttachments.entityKind.equals('entry'),
                    ),
                  ])
                  ..addColumns([distinctEntries])
                  ..where(live))
                .getSingle())
            .read(distinctEntries) ??
        0;

    // Категории: считаем по ветке, чтобы корневые не выглядели пустыми.
    final ec = db.entryCategories;
    final perPrimary =
        await (db.selectOnly(ec).join([
                innerJoin(e, e.id.equalsExp(ec.entryId)),
              ])
              ..addColumns([ec.categoryId, ec.entryId.count()])
              ..where(live & ec.isPrimary.equals(true))
              ..groupBy([ec.categoryId]))
            .get();

    final categories = await (db.select(
      db.categories,
    )..where((c) => c.profileId.equals(profileId))).get();
    final catById = {for (final c in categories) c.id: c};

    final perCategory = <String, int>{};
    for (final row in perPrimary) {
      final cat = catById[row.read(ec.categoryId)];
      if (cat == null) continue;
      final count = row.read(ec.entryId.count()) ?? 0;
      for (final ancestorId in cat.path.split('/')) {
        perCategory[ancestorId] = (perCategory[ancestorId] ?? 0) + count;
      }
    }
    final top =
        perCategory.entries
            .where((c) => catById[c.key] != null)
            .map((c) => (id: c.key, name: catById[c.key]!.name, count: c.value))
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));

    return ProfileInsights(
      total: totalCount,
      rated: rated,
      averageRating: rated == 0 ? null : sum / rated,
      ratingBuckets: buckets,
      byRelation: byRelation,
      topCategories: top.take(8).toList(),
      byMonth: byMonth,
      withPhotos: withPhotos,
      withNotes: withNotes,
    );
  }
}
