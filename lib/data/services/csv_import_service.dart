import 'dart:convert';
import 'dart:typed_data';

import '../../core/utils/normalize.dart';
import '../db/database.dart';
import '../repositories/category_repository.dart';
import '../repositories/entry_repository.dart';

/// Какая колонка таблицы что означает.
///
/// Названия колонок у чужих таблиц какие угодно, поэтому сопоставление
/// человек подтверждает глазами — приложение лишь предлагает угаданное.
enum CsvField { title, type, category, relation, rating, impressionDate, note }

/// Одна строка будущей записи.
class CsvRow {
  const CsvRow({
    required this.title,
    this.type,
    this.category,
    this.relation,
    this.rating,
    this.impressionDate,
    this.note,
  });

  final String title;
  final String? type;

  /// Путь категории целиком: «Продукты / Колбасы».
  final String? category;
  final String? relation;
  final double? rating;
  final DateTime? impressionDate;
  final String? note;
}

/// Что удалось прочитать из файла.
class CsvPreview {
  const CsvPreview({
    required this.headers,
    required this.mapping,
    required this.rows,
    required this.skipped,
  });

  /// Заголовки исходного файла, в исходном порядке.
  final List<String> headers;

  /// Что приложение угадало: поле → номер колонки.
  final Map<CsvField, int> mapping;

  /// Разобранные строки — уже по угаданному сопоставлению.
  final List<CsvRow> rows;

  /// Сколько строк пропущено: без названия записи не бывает.
  final int skipped;

  bool get isEmpty => rows.isEmpty;
}

/// Чем кончился перенос таблицы.
class CsvImportResult {
  const CsvImportResult({
    required this.created,
    required this.categoriesCreated,
    required this.typesCreated,
  });

  final int created;
  final int categoriesCreated;
  final int typesCreated;
}

/// Чтение таблицы CSV.
///
/// Выгрузка в таблицу была, обратного пути не было: список из Excel или из
/// другого приложения переносили руками. Формат тот же, что у выгрузки, но
/// разбор рассчитан и на чужие файлы — с запятой вместо точки с запятой, без
/// BOM и с любым порядком колонок.
class CsvImportService {
  const CsvImportService();

  /// Слова, по которым узнаём колонку. Сравниваются нормализованно.
  static const _hints = {
    CsvField.title: ['название', 'наименование', 'title', 'name'],
    CsvField.type: ['тип', 'type'],
    CsvField.category: ['категория', 'категории', 'category', 'path'],
    CsvField.relation: ['отношение', 'relation'],
    CsvField.rating: ['оценка', 'рейтинг', 'rating', 'score'],
    CsvField.impressionDate: ['дата впечатления', 'дата', 'date', 'impression'],
    CsvField.note: ['заметка', 'комментарий', 'note', 'comment'],
  };

  /// Разбирает файл и предлагает сопоставление колонок.
  CsvPreview inspect(Uint8List bytes) {
    final table = parse(utf8.decode(bytes, allowMalformed: true));
    if (table.isEmpty) {
      return const CsvPreview(headers: [], mapping: {}, rows: [], skipped: 0);
    }

    final headers = table.first;
    final mapping = guessMapping(headers);
    final rows = <CsvRow>[];
    var skipped = 0;

    for (final line in table.skip(1)) {
      final row = rowFrom(line, mapping);
      if (row == null) {
        skipped++;
        continue;
      }
      rows.add(row);
    }

    return CsvPreview(
      headers: headers,
      mapping: mapping,
      rows: rows,
      skipped: skipped,
    );
  }

  /// Собирает строку по заданному сопоставлению.
  ///
  /// Возвращает null, если названия нет: запись без названия — это пустая
  /// строка таблицы, а не потерянные данные.
  CsvRow? rowFrom(List<String> cells, Map<CsvField, int> mapping) {
    String? cell(CsvField field) {
      final index = mapping[field];
      if (index == null || index >= cells.length) return null;
      final value = cells[index].trim();
      return value.isEmpty ? null : value;
    }

    final title = cell(CsvField.title);
    if (title == null) return null;

    return CsvRow(
      title: title,
      type: cell(CsvField.type),
      category: cell(CsvField.category),
      relation: cell(CsvField.relation),
      rating: _rating(cell(CsvField.rating)),
      impressionDate: _date(cell(CsvField.impressionDate)),
      note: cell(CsvField.note),
    );
  }

  /// Угадывает, где какая колонка.
  Map<CsvField, int> guessMapping(List<String> headers) {
    final mapping = <CsvField, int>{};
    for (var i = 0; i < headers.length; i++) {
      final name = Normalize.forMatch(headers[i]);
      if (name.isEmpty) continue;
      for (final entry in _hints.entries) {
        if (mapping.containsKey(entry.key)) continue;
        if (entry.value.any((hint) => name == hint || name.contains(hint))) {
          mapping[entry.key] = i;
          break;
        }
      }
    }
    // Совсем чужой файл: если названия не нашлось, берём первую колонку —
    // в таблицах слева обычно оно и стоит.
    if (!mapping.containsKey(CsvField.title) && headers.isNotEmpty) {
      mapping[CsvField.title] = 0;
    }
    return mapping;
  }

  /// Заводит записи по разобранным строкам.
  ///
  /// Недостающие типы и категории создаются: перенос списка не должен упираться
  /// в то, что «Колбас» ещё нет. Категория берётся путём целиком, поэтому
  /// «Продукты / Колбасы» ложится в ту же ветку, что и при ручном заведении.
  Future<CsvImportResult> apply({
    required String profileId,
    required List<CsvRow> rows,
    required EntryRepository entries,
    required CategoryRepository categories,
  }) async {
    if (rows.isEmpty) {
      return const CsvImportResult(
        created: 0,
        categoriesCreated: 0,
        typesCreated: 0,
      );
    }

    final types = {
      for (final t in await entries.objectTypes(profileId))
        Normalize.name(t.name): t,
    };
    var typesCreated = 0;
    var categoriesCreated = 0;
    var created = 0;

    Future<ObjectTypeRow> typeFor(String? name) async {
      final wanted = Normalize.name(name ?? '');
      if (wanted.isNotEmpty && types.containsKey(wanted)) return types[wanted]!;
      if (wanted.isEmpty) {
        // Тип обязателен: без явного берём первый заведённый, а если типов нет
        // вовсе — заводим «Разное», чтобы перенос не упирался в это.
        if (types.isNotEmpty) return types.values.first;
      }
      final createdType = await entries.createObjectType(
        profileId,
        name?.trim().isNotEmpty == true ? name!.trim() : 'Разное',
        sortOrder: types.length,
      );
      types[Normalize.name(createdType.name)] = createdType;
      typesCreated++;
      return createdType;
    }

    // Дерево категорий профиля целиком — один раз до цикла. Прежде на каждый
    // сегмент пути каждой строки шёл запрос за соседями: у таблицы в две
    // тысячи строк с путями в два уровня это четыре тысячи запросов, из
    // которых почти все спрашивали одно и то же.
    String branchKey(String? parentId, String normalizedName) =>
        '${parentId ?? ''} $normalizedName';

    final tree = <String, CategoryRow>{};
    for (final c in await categories.allOf(profileId)) {
      // Порядок запроса — тот же, что у соседей, поэтому при одинаковых
      // названиях выбирается первая из них, как и раньше.
      tree.putIfAbsent(branchKey(c.parentId, c.normalizedName), () => c);
    }

    /// Категория по пути «Продукты / Колбасы»: чего нет — заводится.
    Future<String?> categoryFor(String? path) async {
      final parts = (path ?? '')
          .split(RegExp(r'[/>]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isEmpty) return null;

      CategoryRow? parent;
      for (final name in parts) {
        final wanted = Normalize.name(name);
        final found = tree[branchKey(parent?.id, wanted)];
        if (found != null) {
          parent = found;
          continue;
        }
        parent = parent == null
            ? await categories.createRoot(profileId, name)
            : await categories.createChild(parent.id, name);
        tree[branchKey(parent.parentId, parent.normalizedName)] = parent;
        categoriesCreated++;
      }
      return parent?.id;
    }

    // Весь перенос — одной транзакцией. Раньше транзакцию открывала каждая
    // строка, а с ней шли запись в журнал и ожидание диска.
    await entries.db.transaction(() async {
      for (final row in rows) {
        final type = await typeFor(row.type);
        final object = await entries.createObject(
          typeId: type.id,
          title: row.title,
        );
        await entries.createEntry(
          profileId: profileId,
          objectId: object.id,
          relation: relationOf(row.relation),
          rating: row.rating,
          detailedNote: row.note,
          impressionDate: row.impressionDate,
          primaryCategoryId: await categoryFor(row.category),
        );
        created++;
      }
    });

    return CsvImportResult(
      created: created,
      categoriesCreated: categoriesCreated,
      typesCreated: typesCreated,
    );
  }

  /// Отношение из текста: и русская метка, и внутреннее имя.
  ///
  /// Метки живут в локализации, а разбор — в слое данных, поэтому слова
  /// перечислены здесь: файл может прийти из любого приложения, и точное
  /// совпадение с интерфейсом всё равно не гарантировано.
  static String? relationOf(String? value) {
    if (value == null) return null;
    final normalized = Normalize.forMatch(value);
    if (normalized.isEmpty) return null;

    const words = {
      'love': ['обожаю', 'love', 'любимое'],
      'like': ['нравится', 'like', 'хорошо'],
      'neutral': ['нейтрально', 'neutral', 'нормально'],
      'dislike': ['не нравится', 'dislike', 'плохо'],
      'avoid': ['избегаю', 'avoid'],
      'wantToTry': ['хочу попробовать', 'want', 'попробовать'],
    };

    for (final entry in words.entries) {
      if (Normalize.forMatch(entry.key) == normalized) return entry.key;
      if (entry.value.any((w) => normalized == w || normalized.contains(w))) {
        return entry.key;
      }
    }
    return null;
  }

  /// Разбор CSV по RFC 4180 с автоопределением разделителя.
  ///
  /// Русский Excel пишет через точку с запятой, остальные — через запятую;
  /// файл из другого приложения может прийти в любом виде.
  List<List<String>> parse(String text) {
    final clean = text.startsWith('﻿') ? text.substring(1) : text;
    if (clean.trim().isEmpty) return const [];

    final separator = _separatorOf(clean);
    final rows = <List<String>>[];
    var cells = <String>[];
    final cell = StringBuffer();
    var quoted = false;

    for (var i = 0; i < clean.length; i++) {
      final char = clean[i];

      if (quoted) {
        if (char != '"') {
          cell.write(char);
          continue;
        }
        // Удвоенная кавычка внутри поля — это одна кавычка.
        if (i + 1 < clean.length && clean[i + 1] == '"') {
          cell.write('"');
          i++;
          continue;
        }
        quoted = false;
        continue;
      }

      if (char == '"') {
        quoted = true;
      } else if (char == separator) {
        cells.add(cell.toString());
        cell.clear();
      } else if (char == '\n' || char == '\r') {
        // \r\n — один перенос, а не два.
        if (char == '\r' && i + 1 < clean.length && clean[i + 1] == '\n') i++;
        cells.add(cell.toString());
        cell.clear();
        if (cells.any((c) => c.trim().isNotEmpty)) rows.add(cells);
        cells = <String>[];
      } else {
        cell.write(char);
      }
    }

    cells.add(cell.toString());
    if (cells.any((c) => c.trim().isNotEmpty)) rows.add(cells);
    return rows;
  }

  /// Чем разделены поля: считаем по первой строке, вне кавычек.
  String _separatorOf(String text) {
    final firstLine = text.split(RegExp('[\r\n]')).first;
    var semicolons = 0;
    var commas = 0;
    var tabs = 0;
    var quoted = false;
    for (final char in firstLine.split('')) {
      if (char == '"') {
        quoted = !quoted;
      } else if (!quoted) {
        if (char == ';') semicolons++;
        if (char == ',') commas++;
        if (char == '\t') tabs++;
      }
    }
    if (tabs > semicolons && tabs > commas) return '\t';
    return commas > semicolons ? ',' : ';';
  }

  /// Оценка: и «7,5», и «7.5», и «8 из 10».
  static double? _rating(String? value) {
    if (value == null) return null;
    final match = RegExp(r'\d+([.,]\d+)?').firstMatch(value);
    if (match == null) return null;
    final parsed = double.tryParse(match.group(0)!.replaceAll(',', '.'));
    if (parsed == null) return null;
    return parsed.clamp(0, 10).toDouble();
  }

  /// Дата: «31.12.2026», «2026-12-31» и то же самое через дробь.
  static DateTime? _date(String? value) {
    if (value == null) return null;

    final iso = DateTime.tryParse(value);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);

    final match = RegExp(
      r'^(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{4})$',
    ).firstMatch(value.trim());
    if (match == null) return null;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }
}
