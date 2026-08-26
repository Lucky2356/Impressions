import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/design_system/design_system.dart';

import 'screens_test.dart' show app;

/// Появление карточек не должно мешать прокрутке.
///
/// Ленивый список заводит ячейку заново каждый раз, когда она входит в область
/// показа. Пока `Appear` ничего не помнил, это значило контроллер анимации и
/// таймер на каждую вплывающую ячейку — и пустую клетку, ждущую своей очереди
/// до 300 мс.
void main() {
  /// Сколько карточек прямо сейчас проступают.
  ///
  /// Считаются только свои переходы: `MaterialApp` заводит собственные, и по
  /// всему дереву их всегда несколько.
  int animating(WidgetTester tester) => tester
      .widgetList(
        find.descendant(
          of: find.byType(Appear),
          matching: find.byType(FadeTransition),
        ),
      )
      .length;

  Widget list({required List<String> ids, bool scoped = true}) {
    final view = ListView.builder(
      itemCount: ids.length,
      itemExtent: 100,
      itemBuilder: (context, i) =>
          Appear(index: i, id: ids[i], child: Text(ids[i])),
    );
    return app(scoped ? AppearScope(child: view) : view);
  }

  testWidgets('карточка появляется один раз, а не на каждый проход', (
    tester,
  ) async {
    final ids = [for (var i = 0; i < 60; i++) 'e$i'];
    await tester.pumpWidget(list(ids: ids));
    await tester.pump();

    expect(
      animating(tester),
      greaterThan(0),
      reason: 'при первом показе список проступает',
    );
    await tester.pumpAndSettle();

    // Уходим вниз и возвращаемся: первые карточки заводятся заново.
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 2000);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, 2000), 2000);
    await tester.pumpAndSettle();
    expect(find.text('e0'), findsOneWidget);

    expect(
      animating(tester),
      0,
      reason: 'показанное однажды больше не проступает',
    );
  });

  testWidgets('без памяти списка карточка проступает заново', (tester) async {
    final ids = [for (var i = 0; i < 60; i++) 'e$i'];
    await tester.pumpWidget(list(ids: ids, scoped: false));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(ListView), const Offset(0, -2000), 2000);
    await tester.pump();
    expect(
      animating(tester),
      greaterThan(0),
      reason: 'короткие списки с постоянным составом ведут себя как прежде',
    );
    await tester.pumpAndSettle();
  });

  testWidgets('при выключенной анимации не заводится даже контроллер', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: list(ids: const ['a', 'b', 'c']),
      ),
    );
    await tester.pump();

    expect(animating(tester), 0);
    expect(find.text('a'), findsOneWidget);
  });
}
