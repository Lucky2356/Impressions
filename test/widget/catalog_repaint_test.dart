import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/models/entry_view.dart';
import 'package:impressions/design_system/design_system.dart';
import 'package:impressions/features/catalog/catalog_selection.dart';
import 'package:impressions/features/catalog/entry_tile.dart';

import 'screens_test.dart' show app, entryView;

/// Чего стоит показ каталога.
///
/// Карточки трогали диск на каждом кадре (`existsSync` на обложку) и
/// перестраивались все разом на любое изменение выделения. Вместе это давало
/// десятки синхронных обращений к файловой системе на одно нажатие.
void main() {
  testWidgets('пропавшая обложка рисует заглушку, а не ошибку', (tester) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 220,
          child: CoverImage(
            title: 'Папа может',
            imagePath: 'C:/такого/файла/нет.jpg',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    // Заглушка — первая буква названия: она лежит фоном и видна, пока снимка
    // нет. Проверять существование файла для этого не требуется.
    expect(find.text('П'), findsOneWidget);
    // Снимок при этом всё равно заведён: путь не проверяется заранее, пропажа
    // просто не закрывает заглушку.
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('пропавшая миниатюра оставляет значок', (tester) async {
    await tester.pumpWidget(
      app(
        const EntryThumb(
          icon: Icons.fastfood_rounded,
          color: Colors.orange,
          imagePath: 'C:/такого/файла/нет.jpg',
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.fastfood_rounded), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('выделение одной записи не перестраивает остальные', (
    tester,
  ) async {
    final builds = <String, int>{};
    final container = ProviderContainer();
    addTearDown(container.dispose);

    Widget tile(EntryView entry) => EntryTile(
      entry: entry,
      selectionActive: false,
      order: const ['e1', 'e2'],
      builder: (onTap) {
        builds[entry.entryId] = (builds[entry.entryId] ?? 0) + 1;
        return SizedBox(
          height: 60,
          child: EntryCardCompact(
            data: EntryCardData(title: entry.title),
            onTap: onTap,
          ),
        );
      },
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: app(
          Column(
            children: [
              tile(entryView(id: 'e1', title: 'Первая')),
              tile(entryView(id: 'e2', title: 'Вторая')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final before = Map.of(builds);
    container.read(catalogSelectionProvider.notifier).toggle('e1');
    await tester.pumpAndSettle();

    // Отметку показывает только своя карточка: соседняя не перестраивается,
    // а с ней не перестраивается и её обложка.
    expect(builds['e1'], before['e1']! + 1);
    expect(builds['e2'], before['e2']);
  });
}
