import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/core/diagnostics/error_log.dart';

/// Журнал аварий.
///
/// Раньше сбой в релизе не оставлял следов: серый прямоугольник на экране и
/// ничего в файлах. Журнал — единственный источник подробностей, потому что
/// наружу приложение ничего не отправляет.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('impressions_errorlog');
    // path_provider на тестовой платформе не отвечает — подменяем каталог.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => temp.path,
        );
    await ErrorLog.clear();
  });

  tearDown(() async {
    await ErrorLog.clear();
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });

  test('пустой журнал не содержит записей', () async {
    expect(await ErrorLog.count(), 0);
    expect((await ErrorLog.read()).trim(), isEmpty);
  });

  test('записанная авария читается вместе с текстом ошибки', () async {
    await ErrorLog.record(StateError('колбаса кончилась'), StackTrace.current);

    expect(await ErrorLog.count(), 1);
    expect(await ErrorLog.read(), contains('колбаса кончилась'));
  });

  test('источник аварии виден в записи', () async {
    await ErrorLog.record(Exception('сбой'), null, context: 'виджет');
    expect(await ErrorLog.read(), contains('виджет'));
  });

  test('журнал не растёт без предела', () async {
    for (var i = 0; i < ErrorLog.maxRecords + 25; i++) {
      await ErrorLog.record(StateError('сбой $i'), null);
    }

    expect(await ErrorLog.count(), ErrorLog.maxRecords);
    final text = await ErrorLog.read();
    // Вытесняются самые старые, последние остаются.
    expect(text, isNot(contains('сбой 0')));
    expect(text, contains('сбой ${ErrorLog.maxRecords + 24}'));
  });

  test('очистка убирает записи', () async {
    await ErrorLog.record(StateError('сбой'), null);
    await ErrorLog.clear();
    expect(await ErrorLog.count(), 0);
  });
}
