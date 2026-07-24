import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:impressions/core/domain/relation.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/design_system/design_system.dart';

/// Что читает экранный диктор.
///
/// Карточки составлены из значков, чисел и обрезанных строк: по отдельности
/// диктор произносил их как несвязанный набор — «Продукты», «Папа может»,
/// «7». Каждая карточка должна называть себя одной осмысленной фразой.
void main() {
  Widget app(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ru'),
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  testWidgets('карточка записи называет себя одной фразой', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      app(
        SizedBox(
          width: 200,
          height: 340,
          child: EntryCard(
            data: const EntryCardData(
              title: 'Папа может',
              categoryPath: ['Продукты', 'Колбасы'],
              relation: Relation.like,
              rating: 7,
            ),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Папа может, Колбасы, Нравится, оценка 7.0'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('карточка без оценки не выдумывает её', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      app(
        SizedBox(
          width: 200,
          height: 340,
          child: EntryCard(
            data: const EntryCardData(title: 'Молоко'),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Молоко'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('полка категории читается вместе со счётчиком', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      app(
        SizedBox(
          width: 220,
          height: categoryShelfHeight,
          child: CategoryShelfCard(
            name: 'Продукты',
            icon: Icons.shopping_cart_rounded,
            color: Colors.orange,
            count: 12,
            countLabel: '12 записей',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Продукты, 12 записей'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('счётчик на главной читается подписью и значением', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      app(
        SummaryStrip(
          items: [
            SummaryItem(
              label: 'Записей',
              value: '7',
              icon: Icons.article_rounded,
              color: Colors.green,
              onTap: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.bySemanticsLabel('Записей: 7'), findsOneWidget);
    handle.dispose();
  });
}
