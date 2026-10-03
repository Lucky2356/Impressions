/// Разделитель колонок в выгрузках.
///
/// Точка с запятой: русский Excel по умолчанию понимает именно её, а запятая
/// внутри чисел ломала бы колонки.
const String csvSeparator = ';';

/// Метка кодировки в начале файла.
///
/// Без неё Excel открывает файл в системной кодировке и портит кириллицу.
const String csvBom = '\u{feff}';

/// Экранирование поля по RFC 4180.
///
/// Кавычки удваиваются, поле берётся в кавычки, если содержит разделитель,
/// кавычку или перенос строки. Общее для всех выгрузок: одна таблица с
/// экранированием и другая без него открывались бы в Excel по-разному.
String csvCell(String value) {
  final escaped = value.replaceAll('"', '""');
  final needsQuotes =
      value.contains(csvSeparator) ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  return needsQuotes ? '"$escaped"' : escaped;
}

/// Строка таблицы из полей.
String csvRow(Iterable<String> cells) => cells.map(csvCell).join(csvSeparator);
