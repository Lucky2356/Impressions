import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:impressions/data/services/title_lookup_service.dart';

/// Поиск сведений по названию (§2 плана).
///
/// У товаров подстановка по штрихкоду была, у фильмов, книг и игр — нет.
///
/// Образцы ответов сняты с настоящих источников, а не сочинены: разбор,
/// проверенный на выдуманном JSON, доказывает только соответствие выдумке.
void main() {
  /// Ответ Wikidata на «Солярис»: три разных фильма под одним названием —
  /// ровно тот случай, ради которого человеку показывают выбор.
  const wikidataSolaris = r'''
{
 "head": {
  "vars": [
   "item",
   "itemLabel",
   "firstYear",
   "creator"
  ]
 },
 "results": {
  "bindings": [
   {
    "item": {
     "type": "uri",
     "value": "http://www.wikidata.org/entity/Q125672"
    },
    "itemLabel": {
     "xml:lang": "ru",
     "type": "literal",
     "value": "Солярис"
    },
    "firstYear": {
     "datatype": "http://www.w3.org/2001/XMLSchema#integer",
     "type": "literal",
     "value": "1968"
    },
    "creator": {
     "xml:lang": "ru",
     "type": "literal",
     "value": "Лидия Сергеевна Ишимбаева"
    }
   },
   {
    "item": {
     "type": "uri",
     "value": "http://www.wikidata.org/entity/Q125772"
    },
    "itemLabel": {
     "xml:lang": "ru",
     "type": "literal",
     "value": "Солярис"
    },
    "firstYear": {
     "datatype": "http://www.w3.org/2001/XMLSchema#integer",
     "type": "literal",
     "value": "1972"
    },
    "creator": {
     "xml:lang": "ru",
     "type": "literal",
     "value": "Андрей Тарковский"
    }
   }
  ]
 }
}
''';

  /// Ответ Open Library на «Война и мир». Первая запись без года и языка:
  /// поля необязательные, и разбор обязан это переживать.
  const openLibraryWarAndPeace = r'''
{
 "numFound": 8,
 "start": 0,
 "numFoundExact": true,
 "num_found": 8,
 "documentation_url": "https://openlibrary.org/dev/docs/api/search",
 "q": "",
 "offset": null,
 "docs": [
  {
   "author_name": [
    "Лев Толстой"
   ],
   "title": "Война и мир / Voĭna i mir"
  },
  {
   "author_name": [
    "И. И. Бендерский"
   ],
   "first_publish_year": 2021,
   "language": [
    "rus"
   ],
   "title": "\"Война и мир\""
  }
 ]
}
''';

  http.Client answering(String body, {int status = 200}) =>
      MockClient((_) async => http.Response.bytes(utf8.encode(body), status));

  group('Wikidata', () {
    test('несколько экранизаций одного названия различимы', () async {
      final service = TitleLookupService(client: answering(wikidataSolaris));
      final found = await service.lookup('Солярис', LookupKind.film);

      expect(found, hasLength(2));
      expect(found[0].title, 'Солярис');
      expect(found[0].year, 1968);
      expect(found[1].creator, 'Андрей Тарковский');
      expect(found[1].year, 1972);
      // Подпись — то, по чему человек и выбирает.
      expect(found[1].subtitle, 'Андрей Тарковский · 1972');
      expect(found[0].source, 'Wikidata');
    });
  });

  group('Open Library', () {
    test('запись без года и автора не теряется', () async {
      final service = TitleLookupService(
        client: answering(openLibraryWarAndPeace),
      );
      final found = await service.lookup('Война и мир', LookupKind.book);

      expect(found, hasLength(2));
      // У первой год отсутствует — она всё равно в списке, просто без года.
      expect(found[0].creator, 'Лев Толстой');
      expect(found[0].year, isNull);
      expect(found[0].subtitle, 'Лев Толстой');
      expect(found[1].year, 2021);
      expect(found[0].source, 'Open Library');
    });
  });

  group('адрес запроса', () {
    test('книги идут в Open Library, остальное в Wikidata', () {
      expect(
        TitleLookupService.uriFor('Дюна', LookupKind.book).host,
        'openlibrary.org',
      );
      expect(
        TitleLookupService.uriFor('Дюна', LookupKind.film).host,
        'query.wikidata.org',
      );
    });

    test('вид поиска задаёт класс сущности и свойство автора', () {
      String query(LookupKind kind) =>
          TitleLookupService.uriFor('Дюна', kind).queryParameters['query']!;

      // Q11424 — фильм, Q5398426 — сериал, Q7889 — игра.
      expect(query(LookupKind.film), contains('wd:Q11424'));
      expect(query(LookupKind.series), contains('wd:Q5398426'));
      expect(query(LookupKind.game), contains('wd:Q7889'));
      // P57 — режиссёр, P178 — разработчик.
      expect(query(LookupKind.film), contains('wdt:P57 '));
      expect(query(LookupKind.game), contains('wdt:P178 '));
    });

    test('год берётся и из даты начала — иначе у сериалов его нет', () {
      final query = TitleLookupService.uriFor(
        'Твин Пикс',
        LookupKind.series,
      ).queryParameters['query']!;

      expect(query, contains('wdt:P577|wdt:P580'));
    });

    test('запрос агрегирован — иначе одна картина занимает всю выдачу', () {
      // У «Интерстеллара» две даты публикации, и без GROUP BY он давал пять
      // одинаковых строк, съедая LIMIT целиком.
      final query = TitleLookupService.uriFor(
        'Интерстеллар',
        LookupKind.film,
      ).queryParameters['query']!;

      expect(query, contains('GROUP BY'));
      expect(query, contains('MIN(?year)'));
    });

    test('кавычка в названии не рвёт запрос', () {
      final query = TitleLookupService.uriFor(
        'Кто-то сказал "да"',
        LookupKind.film,
      ).queryParameters['query']!;

      expect(query, contains(r'\"да\"'));
    });
  });

  group('когда подставлять нечего', () {
    test('пустой запрос в сеть не идёт', () async {
      var asked = false;
      final service = TitleLookupService(
        client: MockClient((_) async {
          asked = true;
          return http.Response('{}', 200);
        }),
      );

      expect(await service.lookup('   ', LookupKind.book), isEmpty);
      expect(asked, isFalse);
    });

    test('ошибка источника не роняет форму', () async {
      final service = TitleLookupService(
        client: answering('nope', status: 503),
      );

      expect(await service.lookup('Дюна', LookupKind.film), isEmpty);
    });

    test('мусор вместо JSON не роняет форму', () async {
      final service = TitleLookupService(client: answering('<html>'));

      expect(await service.lookup('Дюна', LookupKind.film), isEmpty);
    });

    test('метка без перевода не подставляется как название', () async {
      // Без метки на нужном языке Wikidata возвращает идентификатор.
      const raw =
          '{"results":{"bindings":[{"itemLabel":{"value":"Q13417189"}}]}}';
      final service = TitleLookupService(client: answering(raw));

      expect(await service.lookup('Дюна', LookupKind.film), isEmpty);
    });
  });
}
