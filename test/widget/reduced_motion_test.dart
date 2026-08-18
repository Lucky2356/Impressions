import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/design_system/design_system.dart';

import 'screens_test.dart' show app;

/// Системное «убрать анимацию».
///
/// Это не пожелание, а требование доступности (§30): у части людей от движения
/// на экране кружится голова. До 1.19.0 флаг не читался нигде, и появление
/// карточек шло своим чередом независимо от настройки системы.
void main() {
  Future<void> pump(WidgetTester tester, {required bool disable}) async {
    await tester.pumpWidget(
      app(
        MediaQuery(
          data: MediaQueryData(disableAnimations: disable),
          child: const Appear(index: 5, child: Text('Запись')),
        ),
      ),
    );
  }

  testWidgets('с выключенной анимацией содержимое видно сразу', (tester) async {
    await pump(tester, disable: true);
    // Один кадр без единого продвижения часов: карточка уже на месте и уже
    // непрозрачна.
    await tester.pump();

    expect(find.text('Запись'), findsOneWidget);
    // Ищем только внутри Appear: у самого MaterialApp есть свои переходы.
    expect(
      find.descendant(
        of: find.byType(Appear),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
  });

  testWidgets('с включённой анимацией появление отложено', (tester) async {
    await pump(tester, disable: false);
    await tester.pump();

    final inside = find.descendant(
      of: find.byType(Appear),
      matching: find.byType(FadeTransition),
    );

    // Виджет в дереве есть, но пока прозрачен — его выводит FadeTransition.
    expect(tester.widget<FadeTransition>(inside).opacity.value, 0.0);

    // Задержка очереди — обычный Timer: пока он не сработал, кадры никто не
    // планирует, и pumpAndSettle сам по себе вернулся бы сразу.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(inside).opacity.value, 1.0);
  });
}
