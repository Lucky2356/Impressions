import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/design_system/design_system.dart';

import 'screens_test.dart' show app;

/// График в полосе сводки рисуется только при настоящей истории значения.
void main() {
  Future<void> pumpTrend(WidgetTester tester, List<double> trend) async {
    // Шире 560: на узком экране графиков нет вовсе, и проверять было бы нечего.
    tester.view.physicalSize = const Size(900, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      app(
        SummaryStrip(
          items: [
            SummaryItem(
              label: 'Записей',
              value: '7',
              icon: Icons.article_rounded,
              color: Colors.green,
              trend: trend,
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('две точки — ещё не тренд', (tester) async {
    await pumpTrend(tester, const [3, 5]);
    expect(find.byType(Sparkline), findsNothing);
  });

  testWidgets('три точки — уже история, график рисуется', (tester) async {
    await pumpTrend(tester, const [3, 5, 4]);
    expect(find.byType(Sparkline), findsOneWidget);
  });
}
