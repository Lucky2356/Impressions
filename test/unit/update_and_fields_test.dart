import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/domain/custom_fields.dart';
import 'package:impressions/data/services/update_service.dart';

void main() {
  group('Сравнение версий приложения', () {
    test('видит более новую версию', () {
      expect(UpdateService.isNewer('1.1.0', '1.0.0'), isTrue);
      expect(UpdateService.isNewer('1.0.1', '1.0.0'), isTrue);
      expect(UpdateService.isNewer('2.0.0', '1.9.9'), isTrue);
    });

    test('не предлагает откат и повтор той же версии', () {
      expect(UpdateService.isNewer('1.0.0', '1.0.0'), isFalse);
      expect(UpdateService.isNewer('1.0.0', '1.1.0'), isFalse);
      expect(UpdateService.isNewer('0.9.9', '1.0.0'), isFalse);
    });

    test('понимает префикс v и суффикс сборки', () {
      expect(UpdateService.isNewer('v1.2.0', '1.1.0'), isTrue);
      expect(UpdateService.isNewer('1.1.0+5', '1.1.0'), isFalse);
    });
  });

  group('Пользовательские поля типов', () {
    test('схема переживает запись и чтение', () {
      const fields = [
        CustomField(key: 'k1', name: 'Крепость', kind: FieldKind.number),
        CustomField(
          key: 'k2',
          name: 'Обжарка',
          kind: FieldKind.choice,
          choices: ['светлая', 'средняя', 'тёмная'],
        ),
      ];
      final decoded = CustomField.decodeSchema(
        CustomField.encodeSchema(fields),
      );

      expect(decoded, hasLength(2));
      expect(decoded[0].name, 'Крепость');
      expect(decoded[0].kind, FieldKind.number);
      expect(decoded[1].choices, ['светлая', 'средняя', 'тёмная']);
    });

    test('повреждённая схема не роняет экран', () {
      expect(CustomField.decodeSchema('не json'), isEmpty);
      expect(CustomField.decodeSchema('{"не":"список"}'), isEmpty);
      expect(CustomField.decodeSchema(null), isEmpty);
      // Запись без обязательных полей просто пропускается.
      expect(CustomField.decodeSchema('[{"name":"без ключа"}]'), isEmpty);
    });

    test('пустые значения не сохраняются', () {
      final encoded = CustomField.encodeValues({
        'k1': ' 60 ',
        'k2': '   ',
        'k3': '',
      });
      final decoded = CustomField.decodeValues(encoded);
      expect(decoded, {'k1': '60'});
    });
  });
}
