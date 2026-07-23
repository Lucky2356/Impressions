import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/relation.dart';
import 'package:impressions/core/l10n/gen/app_localizations.dart';
import 'package:impressions/core/theme/app_theme.dart';
import 'package:impressions/design_system/design_system.dart';

/// Проверка компонентов на данных, которые ломают вёрстку: очень длинные
/// названия, глубокие пути, все поля разом. Переполнение в тестах Flutter
/// считается ошибкой, поэтому такие тесты ловят обрезанные и вылезающие блоки.
///
/// Размер тестового экрана задаётся явно: по умолчанию он 800×600, и расчёты
/// сетки под широкое окно проверялись бы на несуществующей раскладке.
void _surface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

const _longTitle =
    'Колбаса варёно-копчёная высшего сорта «Папа может» в натуральной '
    'оболочке с чесноком и чёрным перцем, 420 грамм';

const _longPath = [
  'Продукты питания и напитки',
  'Мясные изделия',
  'Колбасные изделия',
  'Варёно-копчёные колбасы',
];

EntryCardData _fullData({String? title}) => EntryCardData(
  title: title ?? _longTitle,
  subtitle: 'Очень длинный подзаголовок, который тоже должен обрезаться',
  categoryPath: _longPath,
  relation: Relation.love,
  rating: 9.5,
  seedColor: const Color(0xFFF5822B),
);

void main() {
  group('Карточка записи в сетке', () {
    for (final columns in [2, 4, 6, 8]) {
      testWidgets('не переполняется при $columns колонках', (tester) async {
        _surface(tester, const Size(1600, 1000));
        const available = 1600.0;
        const gutter = 24.0;
        final ratio = entryCardAspectRatio(
          availableWidth: available,
          columns: columns,
          outerPadding: gutter * 2,
        );

        await tester.pumpWidget(
          _host(
            SizedBox(
              width: available,
              height: 900,
              child: GridView.builder(
                padding: const EdgeInsets.all(gutter),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: ratio,
                ),
                itemCount: columns * 2,
                itemBuilder: (_, _) => EntryCard(data: _fullData()),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('плотный режим не переполняется', (tester) async {
      _surface(tester, const Size(1600, 1000));
      final ratio = entryCardAspectRatio(
        availableWidth: 1600,
        columns: 8,
        outerPadding: 48,
        dense: true,
      );
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 1600,
            height: 700,
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: ratio,
              ),
              itemCount: 16,
              itemBuilder: (_, _) => EntryCard(dense: true, data: _fullData()),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('пустое название не роняет обложку', (tester) async {
      _surface(tester, const Size(800, 600));
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            height: 320,
            child: EntryCard(data: const EntryCardData(title: '')),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Компактная карточка', () {
    // В ветке категорий карточки лежат в сетке с фиксированной высотой:
    // если содержимое выше — Flutter сообщит о переполнении.
    testWidgets('помещается в ячейку ветки категорий', (tester) async {
      _surface(tester, const Size(1400, 800));
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 1200,
            height: 600,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: entryCardCompactHeight,
              ),
              itemCount: 6,
              itemBuilder: (_, _) => EntryCardCompact(data: _fullData()),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('узкая колонка не ломает строку метаданных', (tester) async {
      _surface(tester, const Size(400, 400));
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            height: 140,
            child: EntryCardCompact(data: _fullData()),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Управляющие элементы', () {
    testWidgets('переключатель во всю ширину не ломает раскладку', (
      tester,
    ) async {
      _surface(tester, const Size(600, 400));
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 240,
            child: SegmentedToggle<int>(
              value: 1,
              expand: true,
              onChanged: (_) {},
              segments: const [
                SegmentData(value: 1, icon: Icons.light_mode, tooltip: 'a'),
                SegmentData(value: 2, icon: Icons.dark_mode, tooltip: 'b'),
                SegmentData(
                  value: 3,
                  icon: Icons.brightness_auto,
                  tooltip: 'c',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('счётчик уведомлений с большим числом не вылезает', (
      tester,
    ) async {
      _surface(tester, const Size(600, 400));
      await tester.pumpWidget(
        _host(
          IconActionButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Уведомления',
            badgeCount: 1234,
            onPressed: () {},
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('длинный заголовок раздела обрезается, а не ломает шапку', (
      tester,
    ) async {
      _surface(tester, const Size(600, 500));
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 420,
            child: ScreenHeader(
              title: _longTitle,
              subtitle: _longTitle,
              constrain: false,
              actions: [
                FilledButton(onPressed: () {}, child: const Text('Добавить')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
