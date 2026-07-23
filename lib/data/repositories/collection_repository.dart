import 'package:drift/drift.dart';

import '../../core/utils/ids.dart';
import '../db/database.dart';
import '../models/entry_view.dart';

/// Подборка с числом записей — для списков.
class CollectionView {
  const CollectionView({required this.collection, required this.entryCount});
  final CollectionRow collection;
  final int entryCount;
}

/// Репозиторий подборок (§27). Подборки создаются внутри профиля и не
/// заменяют категории: это ручные списки с собственным порядком.
class CollectionRepository {
  CollectionRepository(this.db);
  final AppDatabase db;

  Future<CollectionRow> create(
    String profileId,
    String name, {
    String? description,
    int? color,
  }) async {
    final id = Ids.newId();
    final maxOrder = await _nextSortOrder(profileId);
    await db
        .into(db.collections)
        .insert(
          CollectionsCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            description: Value(description),
            color: Value(color),
            sortOrder: Value(maxOrder),
            createdAt: DateTime.now(),
          ),
        );
    return (db.select(
      db.collections,
    )..where((c) => c.id.equals(id))).getSingle();
  }

  Future<int> _nextSortOrder(String profileId) async {
    final rows = await (db.select(
      db.collections,
    )..where((c) => c.profileId.equals(profileId))).get();
    if (rows.isEmpty) return 0;
    return rows.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> rename(String id, String name) {
    return (db.update(db.collections)..where((c) => c.id.equals(id))).write(
      CollectionsCompanion(name: Value(name)),
    );
  }

  Future<void> archive(String id) {
    return (db.update(db.collections)..where((c) => c.id.equals(id))).write(
      CollectionsCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  Future<void> restore(String id) {
    return (db.update(db.collections)..where((c) => c.id.equals(id))).write(
      const CollectionsCompanion(archivedAt: Value(null)),
    );
  }

  /// Подборки профиля с количеством записей.
  Future<List<CollectionView>> listWithCounts(String profileId) async {
    final collections =
        await (db.select(db.collections)
              ..where(
                (c) => c.profileId.equals(profileId) & c.archivedAt.isNull(),
              )
              ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
            .get();
    if (collections.isEmpty) return const [];

    final counts = <String, int>{};
    final rows = await db
        .customSelect(
          'SELECT collection_id AS cid, COUNT(*) AS cnt '
          'FROM collection_entries GROUP BY collection_id',
          readsFrom: {db.collectionEntries},
        )
        .get();
    for (final r in rows) {
      counts[r.read<String>('cid')] = r.read<int>('cnt');
    }

    return [
      for (final c in collections)
        CollectionView(collection: c, entryCount: counts[c.id] ?? 0),
    ];
  }

  /// Добавляет запись в подборку (в конец, с сохранением ручного порядка).
  Future<void> addEntry(String collectionId, String entryId) async {
    final existing =
        await (db.select(db.collectionEntries)..where(
              (ce) =>
                  ce.collectionId.equals(collectionId) &
                  ce.entryId.equals(entryId),
            ))
            .getSingleOrNull();
    if (existing != null) return;

    final rows = await (db.select(
      db.collectionEntries,
    )..where((ce) => ce.collectionId.equals(collectionId))).get();
    final next = rows.isEmpty
        ? 0
        : rows.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    await db
        .into(db.collectionEntries)
        .insert(
          CollectionEntriesCompanion.insert(
            collectionId: collectionId,
            entryId: entryId,
            sortOrder: Value(next),
            addedAt: DateTime.now(),
          ),
        );
  }

  Future<void> removeEntry(String collectionId, String entryId) {
    return (db.delete(db.collectionEntries)..where(
          (ce) =>
              ce.collectionId.equals(collectionId) & ce.entryId.equals(entryId),
        ))
        .go();
  }

  /// Переставляет запись внутри подборки (§27).
  ///
  /// Порядок хранился с самого начала, но задать его было нечем. Записываем
  /// весь новый порядок одной транзакцией, чтобы номера не разъезжались при
  /// нескольких перестановках подряд.
  Future<void> reorder(String collectionId, List<String> entryIdsInOrder) {
    return db.transaction(() async {
      for (var i = 0; i < entryIdsInOrder.length; i++) {
        await (db.update(db.collectionEntries)..where(
              (ce) =>
                  ce.collectionId.equals(collectionId) &
                  ce.entryId.equals(entryIdsInOrder[i]),
            ))
            .write(CollectionEntriesCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// Записи подборки в ручном порядке, в виде готовых представлений.
  /// Записи подборки в ручном порядке (§27).
  ///
  /// [entriesLoader] получает только нужные идентификаторы: раньше сюда
  /// передавали загрузчик всех записей профиля, и десяток строк в подборке
  /// стоил чтения всего каталога.
  Future<List<EntryView>> entriesOf(
    String collectionId,
    String profileId, {
    required Future<List<EntryView>> Function(List<String> entryIds)
    entriesLoader,
  }) async {
    final links =
        await (db.select(db.collectionEntries)
              ..where((ce) => ce.collectionId.equals(collectionId))
              ..orderBy([(ce) => OrderingTerm(expression: ce.sortOrder)]))
            .get();
    if (links.isEmpty) return const [];

    final order = {for (var i = 0; i < links.length; i++) links[i].entryId: i};
    final selected = await entriesLoader(order.keys.toList());
    selected.sort((a, b) => order[a.entryId]!.compareTo(order[b.entryId]!));
    return selected;
  }

  /// В каких подборках состоит запись.
  Future<Set<String>> collectionsOfEntry(String entryId) async {
    final rows = await (db.select(
      db.collectionEntries,
    )..where((ce) => ce.entryId.equals(entryId))).get();
    return rows.map((r) => r.collectionId).toSet();
  }
}
