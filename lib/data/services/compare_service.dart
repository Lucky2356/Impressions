import '../db/database.dart';
import '../models/entry_view.dart';
import '../repositories/entry_repository.dart';

/// Режимы сравнения профилей (§13).
enum CompareMode {
  onlyFirst,
  onlySecond,
  both,
  bothLike,
  ratingDiffers,
  recommendedNotAdded,
}

/// Строка сравнения: один объект и мнения двух профилей о нём.
class CompareRow {
  const CompareRow({
    required this.objectId,
    required this.title,
    required this.typeName,
    this.left,
    this.right,
  });

  final String objectId;
  final String title;
  final String typeName;

  /// Запись первого профиля (может отсутствовать).
  final EntryView? left;

  /// Запись второго профиля (может отсутствовать).
  final EntryView? right;
}

/// Сравнение двух профилей (§13). Сравнение ведётся по общему объекту:
/// один объект — разные записи разных профилей (§6).
class CompareService {
  CompareService(this.db) : _entries = EntryRepository(db);

  final AppDatabase db;
  final EntryRepository _entries;

  /// Насколько должны различаться оценки, чтобы попасть в «оценки сильно
  /// отличаются».
  static const double ratingGap = 3.0;

  /// Отношения, считающиеся положительными.
  static const Set<String> positiveRelations = {'love', 'like'};

  Future<List<CompareRow>> compare({
    required String firstProfileId,
    required String secondProfileId,
    required CompareMode mode,
    String? typeId,
    String? search,
  }) async {
    final left = await _entries.entryViews(
      firstProfileId,
      typeId: typeId,
      search: search,
    );
    final right = await _entries.entryViews(
      secondProfileId,
      typeId: typeId,
      search: search,
    );

    final leftByObject = {for (final e in left) e.objectId: e};
    final rightByObject = {for (final e in right) e.objectId: e};
    final objectIds = <String>{...leftByObject.keys, ...rightByObject.keys};

    final rows = <CompareRow>[];
    for (final objectId in objectIds) {
      final l = leftByObject[objectId];
      final r = rightByObject[objectId];
      final sample = l ?? r!;
      rows.add(
        CompareRow(
          objectId: objectId,
          title: sample.title,
          typeName: sample.typeName,
          left: l,
          right: r,
        ),
      );
    }

    return rows.where((row) => _matches(row, mode)).toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  bool _matches(CompareRow row, CompareMode mode) {
    final l = row.left;
    final r = row.right;
    return switch (mode) {
      CompareMode.onlyFirst => l != null && r == null,
      CompareMode.onlySecond => r != null && l == null,
      CompareMode.both => l != null && r != null,
      CompareMode.bothLike =>
        l != null &&
            r != null &&
            positiveRelations.contains(l.relation) &&
            positiveRelations.contains(r.relation),
      CompareMode.ratingDiffers =>
        l != null &&
            r != null &&
            l.rating != null &&
            r.rating != null &&
            (l.rating! - r.rating!).abs() >= ratingGap,
      // Первый выразил положительное отношение, у второго записи ещё нет.
      CompareMode.recommendedNotAdded =>
        l != null && r == null && positiveRelations.contains(l.relation),
    };
  }
}
