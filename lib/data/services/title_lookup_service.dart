import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Поиск сведений о книге, фильме, сериале или игре по названию.
///
/// Второе и последнее место, которое обращается в сеть, — рядом с поиском по
/// штрихкоду и по тем же правилам: только по явному действию человека, только
/// открытые источники без ключей, наружу уходит одно название. Отключается в
/// настройках сети.
///
/// Появилось потому, что у товаров подстановка была, а у фильмов, книг и игр —
/// нет: двадцатый фильм заводился целиком руками, тогда как колбаса
/// подтягивалась по коду за секунду.

/// Что ищем. Тип записи в приложении заводит человек и может переименовать,
/// поэтому вид поиска выбирается отдельно, а не выводится из названия типа.
enum LookupKind { book, film, series, game }

/// Один найденный вариант.
///
/// Вариантов всегда несколько: «Солярис» — это фильм 1968 года, фильм
/// Тарковского 1972-го и фильм Содерберга 2002-го. Выбирает человек.
class TitleMatch {
  const TitleMatch({
    required this.title,
    required this.source,
    this.creator,
    this.year,
  });

  final String title;

  /// Автор, режиссёр или разработчик — смотря что искали.
  final String? creator;

  final int? year;

  /// Откуда сведения: показывается человеку, чтобы источник не был безымянным.
  final String source;

  /// Подпись под названием: «Кристофер Нолан · 2014».
  String get subtitle {
    final parts = <String>[
      if (creator != null && creator!.trim().isNotEmpty) creator!.trim(),
      if (year != null) '$year',
    ];
    return parts.join(' · ');
  }
}

/// Запрос к Wikidata: поиском по названию, а не перебором меток.
///
/// Перебор `FILTER(CONTAINS(...))` по всем фильмам — полный проход, который
/// упирается в тайм-аут. `wikibase:mwapi` ищет через тот же поиск, что и сайт.
///
/// Агрегат обязателен: без него одна картина даёт столько строк, сколько у неё
/// дат публикации. У «Интерстеллара» их две — прокат 2014 и повторный 2025, —
/// и `LIMIT 5` уходил на один фильм целиком.
///
/// Год берётся из даты публикации, а при её отсутствии из даты начала: у
/// сериалов `P577` обычно пуст, и оба «Твин Пикса», 1990 и 2017, оказывались
/// без года и неотличимы друг от друга.
const _sparql = '''
SELECT ?item ?itemLabel (MIN(?year) AS ?firstYear) (SAMPLE(?creatorLabel) AS ?creator) WHERE {
  SERVICE wikibase:mwapi {
    bd:serviceParam wikibase:endpoint "www.wikidata.org";
                    wikibase:api "EntitySearch";
                    mwapi:search "{query}";
                    mwapi:language "ru".
    ?item wikibase:apiOutputItem mwapi:item.
  }
  ?item wdt:P31/wdt:P279* wd:{kind}.
  OPTIONAL { ?item wdt:P577|wdt:P580 ?date. BIND(YEAR(?date) AS ?year) }
  OPTIONAL { ?item wdt:{creator} ?creator0. }
  SERVICE wikibase:label {
    bd:serviceParam wikibase:language "ru,en".
    ?item rdfs:label ?itemLabel.
    ?creator0 rdfs:label ?creatorLabel.
  }
}
GROUP BY ?item ?itemLabel
LIMIT 8
''';

/// Класс сущности и свойство автора для каждого вида.
///
/// `P57` — режиссёр, `P178` — разработчик. У сериалов режиссёр указан чаще,
/// чем создатель, поэтому там тоже `P57`.
const _wikidata = {
  LookupKind.film: ('Q11424', 'P57'),
  LookupKind.series: ('Q5398426', 'P57'),
  LookupKind.game: ('Q7889', 'P178'),
};

/// Разбор ответа Wikidata SPARQL.
List<TitleMatch> _parseWikidata(String body) {
  final json = jsonDecode(body);
  if (json is! Map) return const [];
  final results = json['results'];
  if (results is! Map) return const [];
  final bindings = results['bindings'];
  if (bindings is! List) return const [];

  final out = <TitleMatch>[];
  for (final row in bindings) {
    if (row is! Map) continue;
    String? value(String key) {
      final cell = row[key];
      if (cell is! Map) return null;
      final v = cell['value'];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      return null;
    }

    final title = value('itemLabel');
    if (title == null) continue;
    // Метка без перевода приходит идентификатором: «Q13417189» человеку
    // ничего не говорит, и подставлять такое в название нельзя.
    if (RegExp(r'^Q\d+$').hasMatch(title)) continue;

    out.add(
      TitleMatch(
        title: title,
        creator: value('creator'),
        year: int.tryParse(value('firstYear') ?? ''),
        source: 'Wikidata',
      ),
    );
  }
  return out;
}

/// Разбор ответа OpenLibrary.
///
/// `first_publish_year` и `language` есть не у всех записей, а `author_name` —
/// список: у «Войны и мира» первым ответом идёт запись вообще без года.
List<TitleMatch> _parseOpenLibrary(String body) {
  final json = jsonDecode(body);
  if (json is! Map) return const [];
  final docs = json['docs'];
  if (docs is! List) return const [];

  final out = <TitleMatch>[];
  for (final doc in docs) {
    if (doc is! Map) continue;
    final title = doc['title'];
    if (title is! String || title.trim().isEmpty) continue;

    final authors = doc['author_name'];
    final creator = authors is List && authors.isNotEmpty
        ? authors.first.toString()
        : null;
    final year = doc['first_publish_year'];

    out.add(
      TitleMatch(
        title: title.trim(),
        creator: creator,
        year: year is int ? year : int.tryParse('$year'),
        source: 'Open Library',
      ),
    );
  }
  return out;
}

/// Ищет сведения по названию в открытых источниках.
class TitleLookupService {
  TitleLookupService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 15);

  static const _headers = {
    // Оба источника просят представляться; Wikidata без этого ограничивает.
    'User-Agent': 'Impressions/1.1 (local personal library)',
    'Accept': 'application/json, application/sparql-results+json',
  };

  /// Адрес запроса для вида поиска. Открыт для проверки в тестах.
  static Uri uriFor(String query, LookupKind kind) {
    final text = query.trim();
    if (kind == LookupKind.book) {
      return Uri.https('openlibrary.org', '/search.json', {
        'title': text,
        'limit': '8',
        'fields': 'title,author_name,first_publish_year',
      });
    }
    final (entity, creator) = _wikidata[kind]!;
    final sparql = _sparql
        // Кавычка в названии оборвала бы строку в запросе и сломала разбор.
        .replaceAll('{query}', text.replaceAll('"', r'\"'))
        .replaceAll('{kind}', entity)
        .replaceAll('{creator}', creator);
    return Uri.https('query.wikidata.org', '/sparql', {
      'query': sparql,
      'format': 'json',
    });
  }

  /// Ищет варианты. Пустой список — ничего не нашлось или источник не ответил:
  /// подставлять при этом нечего, а падать незачем.
  Future<List<TitleMatch>> lookup(String query, LookupKind kind) async {
    if (query.trim().isEmpty) return const [];
    try {
      final response = await _client
          .get(uriFor(query, kind), headers: _headers)
          .timeout(_timeout);
      if (response.statusCode != 200) return const [];
      final body = utf8.decode(response.bodyBytes);
      return kind == LookupKind.book
          ? _parseOpenLibrary(body)
          : _parseWikidata(body);
    } on TimeoutException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  void dispose() => _client.close();
}
