import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/features/catalog/catalog_providers.dart';

EntryView _entry(int i) => EntryView(
  entryId: 'e$i',
  objectId: 'o$i',
  title: 'Запись $i',
  typeName: 'Продукты',
  categoryPath: const [],
);

void main() {
  group('Постраничная выдача каталога', () {
    test('страница короче полного результата, а всего считается по нему', () {
      final all = [for (var i = 0; i < 150; i++) _entry(i)];
      final page = CatalogResults(
        items: all.take(catalogPageSize).toList(),
        total: all.length,
      );

      expect(page.items, hasLength(catalogPageSize));
      // Счётчик в заголовке показывает всё найденное, а не загруженное.
      expect(page.total, 150);
      expect(page.hasMore, isTrue);
    });

    test('когда всё поместилось, подгружать нечего', () {
      final results = CatalogResults.of([
        for (var i = 0; i < 5; i++) _entry(i),
      ]);
      expect(results.total, 5);
      expect(results.hasMore, isFalse);
    });

    test('пустой результат не считается незавершённым', () {
      final results = CatalogResults.of(const []);
      expect(results.total, 0);
      expect(results.hasMore, isFalse);
    });
  });
}
