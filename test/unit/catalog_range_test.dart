import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/features/catalog/catalog_selection.dart';

/// Выделение диапазона Shift+кликом.
///
/// Каталог умел Ctrl+клик и долгое нажатие, а привычного Shift+клика не было:
/// убрать в архив тридцать записей подряд означало тридцать нажатий, при том
/// что массовые операции ради этого и сделаны.
void main() {
  late ProviderContainer container;

  /// Порядок, в котором записи показаны на экране.
  const order = ['e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8'];

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  CatalogSelection selection() =>
      container.read(catalogSelectionProvider.notifier);
  Set<String> selected() => container.read(catalogSelectionProvider);

  test('от третьей к седьмой выделяются пять записей', () {
    selection()
      ..toggle('e3')
      ..selectTo('e7', order);

    expect(selected(), {'e3', 'e4', 'e5', 'e6', 'e7'});
  });

  test('обратный порядок работает так же', () {
    selection()
      ..toggle('e7')
      ..selectTo('e3', order);

    expect(selected(), {'e3', 'e4', 'e5', 'e6', 'e7'});
  });

  test('якорь остаётся на месте: тянуть можно в обе стороны', () {
    selection()
      ..toggle('e5')
      ..selectTo('e7', order)
      ..selectTo('e3', order);

    // Второй Shift+клик тянет от той же пятой, а не от седьмой, — и раньше
    // выделенное не пропадает.
    expect(selected(), {'e3', 'e4', 'e5', 'e6', 'e7'});
  });

  test('без якоря Shift+клик просто выделяет запись', () {
    selection().selectTo('e4', order);

    expect(selected(), {'e4'});
  });

  test('уехавший из выборки якорь не мешает', () {
    // Отметили запись, сменили фильтры — прежней записи в списке больше нет.
    selection()
      ..toggle('нет-такой')
      ..selectTo('e2', order);

    expect(selected(), {'нет-такой', 'e2'});
  });

  test('снятие выделения сбрасывает якорь', () {
    selection()
      ..toggle('e2')
      ..clear()
      ..selectTo('e5', order);

    expect(selected(), {'e5'});
  });
}
