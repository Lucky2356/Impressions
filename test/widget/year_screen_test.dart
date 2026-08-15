import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/data/providers.dart';
import 'package:impressions/data/repositories/year_review.dart';
import 'package:impressions/data/services/file_delivery_service.dart';
import 'package:impressions/features/year/year_providers.dart';
import 'package:impressions/features/year/year_screen.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

/// Итоги года: карточки листаются, картинка сохраняется.

/// Выдача файла, которая никуда его не отдаёт, а запоминает содержимое.
///
/// Сам путь выдачи — диалог сохранения на Windows и «Поделиться» на Android —
/// проверяется в `file_delivery_test`. Здесь важно другое: что карточка
/// действительно превращается в картинку.
class _RecordingDelivery implements FileDeliveryService {
  Uint8List? bytes;
  String? fileName;

  @override
  Future<FileDelivery> deliver({
    required String fileName,
    required String typeLabel,
    required String extension,
    required Future<void> Function(File file) write,
  }) async {
    this.fileName = fileName;
    final file = File(
      p.join(Directory.systemTemp.createTempSync('year-img').path, fileName),
    );
    await write(file);
    bytes = file.readAsBytesSync();
    return FileDelivery.saved(file.path);
  }

  @override
  SharePlus? get share => null;

  @override
  Directory? get stagingDirectory => null;
}

void main() {
  EntryView entry(String title, {double? rating}) => EntryView(
    entryId: 'e-$title',
    objectId: 'o-$title',
    title: title,
    typeName: 'Фильмы',
    rating: rating,
    impressionDate: DateTime(2025, 3, 14),
  );

  YearReview review({
    int total = 42,
    List<EntryView> best = const [],
    ({String id, String name, int count})? topCategory,
  }) => YearReview(
    year: 2025,
    total: total,
    rated: 30,
    averageRating: 7.4,
    best: best,
    first: total == 0 ? null : entry('Первое'),
    last: total == 0 ? null : entry('Последнее'),
    topCategory: topCategory,
    busiestMonth: (month: DateTime(0, 3), count: 12),
    byRelation: const {'love': 10},
    newCategories: 3,
    finished: 18,
  );

  Future<void> pump(
    WidgetTester tester,
    YearReview data, {
    FileDeliveryService? delivery,
  }) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          yearReviewProvider.overrideWith((ref) async => data),
          if (delivery != null)
            fileDeliveryProvider.overrideWithValue(delivery),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          theme: AppTheme.light(),
          home: const YearScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('первая карточка — итог года', (tester) async {
    await pump(tester, review());

    expect(find.text('Ваш 2025'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    // Год вспоминают событиями, а не долями: рядом с числом сразу видно, что
    // из начатого доведено до конца.
    expect(find.textContaining('Доведено до конца: 18'), findsOneWidget);
  });

  testWidgets('карточки листаются', (tester) async {
    await pump(
      tester,
      review(
        best: [entry('Лучшее', rating: 9.5)],
        topCategory: (id: 'c1', name: 'Кино', count: 20),
      ),
    );

    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Лучшее за год'), findsOneWidget);
    expect(find.text('Лучшее'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Кино'), findsOneWidget);
    expect(find.text('март'), findsOneWidget);
  });

  testWidgets('пустой год объясняет, а не показывает нули', (tester) async {
    await pump(tester, YearReview.empty);

    expect(find.text('Год пока пуст'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('картинка собирается и уходит наружу', (tester) async {
    final delivery = _RecordingDelivery();
    await pump(tester, review(), delivery: delivery);

    // Последняя карточка — та, которой делятся.
    for (var i = 0; i < 4; i++) {
      await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
      await tester.pumpAndSettle();
    }

    // Снимок собирает движок, а запись файла — система: под поддельными
    // часами тестов ни то, ни другое не завершается никогда.
    await tester.runAsync(() async {
      await tester.tap(find.text('Сохранить картинкой'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(delivery.fileName, 'impressions-2025.png');
    // Файл именно картинка, а не пустышка: PNG начинается со своей подписи.
    expect(delivery.bytes!.take(4), [137, 80, 78, 71]);
  });
}
