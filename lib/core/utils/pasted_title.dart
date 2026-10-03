/// Название, которое стоит предложить вставить из буфера обмена.
///
/// Названия почти всегда откуда-то копируют: из каталога магазина, из
/// сообщения, из списка на странице. В буфере при этом оказывается не чистое
/// название, а то, что было вокруг него: перевод строки, кавычки, неразрывные
/// пробелы, автор и год следующей строкой.
///
/// Возвращает `null`, когда предлагать нечего: пустой буфер, ссылка, абзац
/// текста или строка без единой буквы и цифры. Молча подставлять ничего
/// нельзя — в буфере может лежать пароль, и человек должен увидеть, что ему
/// предлагают, прежде чем согласиться.
library;

/// Длиннее этого — уже не название, а абзац.
///
/// Самое длинное название в жизни короче: даже полное имя книги с подзаголовком
/// укладывается в сотню знаков. Отрезать лишнее нельзя — обрезок посреди слова
/// выглядел бы как название, которым он не является.
const int _maxLength = 120;

final RegExp _blank = RegExp(r'[\s ]+');
// Невидимое: нулевой ширины, метки направления письма, BOM. Из страниц оно
// копируется вместе с текстом и делает «Дюна» и «Дюна» двумя разными
// названиями, одинаковыми на вид.
final RegExp _invisible = RegExp(r'[​-‏﻿]');
final RegExp _letterOrDigit = RegExp(r'[\p{L}\p{N}]', unicode: true);
final RegExp _link = RegExp(r'^(\w+://|www\.)', caseSensitive: false);

/// Кавычки и скобки, которыми название обрамляют при цитировании.
const String _wrappers = '«»"“”„‘’\'`()[]';

String? pastedTitle(String? clipboard) {
  if (clipboard == null) return null;

  // Первая непустая строка, а не весь буфер: копируют обычно блоком, где под
  // названием стоят автор и год. Склеенные в одну строку, они дали бы
  // «Дюна Фрэнк Герберт 1965» — предлагать такое незачем.
  final first = clipboard
      .replaceAll(_invisible, '')
      .split('\n')
      .map((line) => line.replaceAll(_blank, ' ').trim())
      .where((line) => line.isNotEmpty)
      .firstOrNull;
  if (first == null) return null;

  var title = first;
  // Обрамление снимается с обеих сторон сразу и столько раз, сколько надето:
  // «„Дюна“» встречается ровно так.
  var trimmed = true;
  while (trimmed && title.length > 1) {
    trimmed = false;
    if (_wrappers.contains(title[0])) {
      title = title.substring(1).trim();
      trimmed = true;
    }
    if (title.length > 1 && _wrappers.contains(title[title.length - 1])) {
      title = title.substring(0, title.length - 1).trim();
      trimmed = true;
    }
  }

  if (title.isEmpty || title.length > _maxLength) return null;
  // Ссылка — это не название. Вставить её значило бы завести запись с именем
  // в три строки адреса; название с такой страницы человек всё равно наберёт
  // или найдёт поиском сведений.
  if (_link.hasMatch(title)) return null;
  if (!_letterOrDigit.hasMatch(title)) return null;

  return title;
}
