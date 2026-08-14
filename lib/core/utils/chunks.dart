/// Режет список на куски, которые SQLite примет одним запросом.
///
/// `WHERE id IN (…)` подставляет по переменной на каждый элемент, а их число
/// ограничено самой библиотекой. Выделить в каталоге все записи и разом их
/// изменить — обычное дело, поэтому наборы идентификаторов ходят в запросы
/// только через это.
Iterable<List<T>> chunked<T>(List<T> items, [int size = 500]) sync* {
  for (var i = 0; i < items.length; i += size) {
    final end = i + size;
    yield items.sublist(i, end > items.length ? items.length : end);
  }
}
