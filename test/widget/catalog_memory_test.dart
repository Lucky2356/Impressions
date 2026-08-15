import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/app/app_state.dart';
import 'package:impressions/app/navigation.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';

import '../db/test_db.dart';

/// Раздел и отбор каталога переживают перезапуск.
///
/// Сохранялись только режим отображения и переключатель подкатегорий: тип,
/// категория, отношение и теги сбрасывались при каждом запуске, а приложение
/// всегда открывалось на главной.
void main() {
  late AppDatabase db;

  setUp(() => db = openTestDb());
  tearDown(() => db.close());

  /// Новый «запуск»: провайдеры создаются заново на той же базе.
  ///
  /// Провайдер строится при первом обращении, и только тогда начинает читать
  /// настройки, — поэтому оба трогаем сразу, как это делает интерфейс.
  ProviderContainer restart() {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    container.read(navProvider);
    container.read(catalogStateProvider);
    return container;
  }

  /// Провайдеры читают и пишут настройки не сразу — даём базе дочитать.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('фильтры каталога возвращаются при следующем запуске', () async {
    final first = restart();
    first.read(catalogStateProvider.notifier)
      ..setType('t1')
      ..setRelation('love')
      ..setStatus('inProgress')
      ..setSort(EntrySort.rating)
      ..toggleSortDirection()
      ..setWithoutRating(true);
    await settle();

    final second = restart();
    await settle();
    final state = second.read(catalogStateProvider);

    expect(state.typeId, 't1');
    expect(state.relation, 'love');
    expect(state.status, 'inProgress');
    expect(state.sort, EntrySort.rating);
    expect(state.reverseSort, isTrue);
    expect(state.withoutRating, isTrue);
  });

  test('запрос в поиске не восстанавливается', () async {
    final first = restart();
    first.read(catalogStateProvider.notifier)
      ..setType('t1')
      ..setSearch('колбаса');
    await settle();

    final second = restart();
    await settle();
    expect(second.read(catalogStateProvider).search, isEmpty);
    expect(second.read(catalogStateProvider).typeId, 't1');
  });

  test('«Сбросить фильтры» стирает и сохранённое', () async {
    final first = restart();
    first.read(catalogStateProvider.notifier)
      ..setType('t1')
      ..setWithoutPhoto(true);
    await settle();
    first.read(catalogStateProvider.notifier).reset();
    await settle();

    final second = restart();
    await settle();
    expect(second.read(catalogStateProvider).typeId, isNull);
    expect(second.read(catalogStateProvider).withoutPhoto, isFalse);
  });

  test('раздел открывается тот же, что закрыли', () async {
    final first = restart();
    first.read(navProvider.notifier).go(NavIds.wishlist);
    await settle();

    final second = restart();
    await settle();
    expect(second.read(navProvider), NavIds.wishlist);
  });

  test('несуществующий раздел из настроек не открывается', () async {
    final first = restart();
    await first
        .read(settingsRepositoryProvider)
        .set('last_section', 'разделКоторогоНет');
    await settle();

    final second = restart();
    await settle();
    expect(second.read(navProvider), NavIds.home);
  });
}
