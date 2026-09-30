import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:impressions/data/services/title_lookup_service.dart';
import 'package:impressions/features/quick_add/title_lookup_sheet.dart';

import 'screens_test.dart' show app;

/// Лист выбора сведений по названию: с какого вида он начинает и что отдаёт.
void main() {
  const books = '''
{"docs": [{"title": "Дюна", "author_name": ["Фрэнк Герберт"], "first_publish_year": 1965}]}
''';

  /// Сервис, который запоминает, к каким хостам обращались.
  TitleLookupService serviceRecording(List<String> hosts) {
    return TitleLookupService(
      client: MockClient((request) async {
        hosts.add(request.url.host);
        return http.Response.bytes(utf8.encode(books), 200);
      }),
    );
  }

  /// Открывает лист поверх экрана и возвращает то, чем он закрылся. С `pick:
  /// false` вариант не выбирается — нужен только первый запрос.
  Future<TitleLookupChoice?> Function() open(
    WidgetTester tester,
    TitleLookupService service, {
    LookupKind? initialKind,
    bool pick = true,
  }) {
    TitleLookupChoice? result;
    return () async {
      await tester.pumpWidget(
        ProviderScope(
          child: app(
            Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .push<TitleLookupChoice>(
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            body: TitleLookupSheet(
                              query: 'Дюна',
                              initialKind: initialKind,
                              service: service,
                            ),
                          ),
                        ),
                      )
                      .then((v) => result = v);
                },
                child: const Text('открыть'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('открыть'));
      await tester.pumpAndSettle();
      if (!pick) return null;
      // Название есть и в шапке листа, и в варианте: нажимаем именно вариант.
      await tester.tap(find.widgetWithText(ListTile, 'Дюна'));
      await tester.pumpAndSettle();
      return result;
    };
  }

  testWidgets('без запомненного вида поиск идёт по фильмам', (tester) async {
    final hosts = <String>[];
    await open(tester, serviceRecording(hosts), pick: false)();

    expect(hosts, ['query.wikidata.org']);
  });

  testWidgets('запомненный вид определяет первый запрос', (tester) async {
    final hosts = <String>[];
    await open(tester, serviceRecording(hosts), initialKind: LookupKind.book)();

    expect(hosts, ['openlibrary.org']);
  });

  testWidgets('выбор возвращается вместе с видом, которым найден', (
    tester,
  ) async {
    final choice = await open(
      tester,
      serviceRecording(<String>[]),
      initialKind: LookupKind.book,
    )();

    expect(choice, isNotNull);
    expect(choice!.kind, LookupKind.book);
    expect(choice.match.title, 'Дюна');
    expect(choice.match.creator, 'Фрэнк Герберт');
  });
}
