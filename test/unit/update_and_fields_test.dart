import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:impressions/core/domain/custom_fields.dart';
import 'package:impressions/data/db/database.dart';
import 'package:impressions/data/services/update_service.dart';

/// Подставной HTTP-клиент: отвечает заранее заданным кодом и телом, в сеть не
/// ходит. Проверять разбор ответа на живом GitHub было бы и медленно, и
/// ненадёжно.
class _FakeClient extends http.BaseClient {
  _FakeClient(this.statusCode, [this.body = '']);
  final int statusCode;
  final String body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.value(utf8.encode(body)), statusCode);
  }
}

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

  group('Ручная проверка обновлений', () {
    UpdateService service(int status, [String body = '']) {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      return UpdateService(db, client: _FakeClient(status, body));
    }

    test('404 — репозиторий недоступен, а не «всё актуально»', () async {
      final result = await service(404).checkAppUpdateManually('1.0.0');
      expect(result.status, UpdateCheckStatus.unavailable);
    });

    test('ошибка сервера — «не смогли проверить»', () async {
      final result = await service(500).checkAppUpdateManually('1.0.0');
      expect(result.status, UpdateCheckStatus.failed);
    });

    test('та же версия — актуально', () async {
      final body = jsonEncode({'tag_name': 'v1.0.0', 'assets': []});
      final result = await service(200, body).checkAppUpdateManually('1.0.0');
      expect(result.status, UpdateCheckStatus.upToDate);
    });

    test('более новая версия — предложить обновление', () async {
      final body = jsonEncode({
        'tag_name': 'v1.5.0',
        'html_url': 'https://github.com/Lucky2356/Impressions/releases/v1.5.0',
        'assets': [
          {
            'name': 'Impressions-1.5.0-windows-x64-setup.exe',
            'browser_download_url':
                'https://github.com/Lucky2356/Impressions/releases/download/v1.5.0/Impressions-1.5.0-windows-x64-setup.exe',
          },
        ],
      });
      final result = await service(200, body).checkAppUpdateManually('1.0.0');
      expect(result.status, UpdateCheckStatus.updateAvailable);
      expect(result.release?.version, '1.5.0');
      expect(result.release?.installerUrl, endsWith('.exe'));
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
