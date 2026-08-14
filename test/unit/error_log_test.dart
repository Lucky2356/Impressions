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
    // Подрезка идёт не на каждой записи, а когда их накопилось: авария в
    // отрисовке повторяется каждый кадр, и переписывать весь журнал по кругу
    // означало добить и без того сломанное приложение. Поэтому записей может
    // быть немного больше предела, но старые всё равно вытесняются.
    const total = ErrorLog.maxRecords * 2 + 25;
    for (var i = 0; i < total; i++) {
      await ErrorLog.record(StateError('сбой $i'), null);
    }

    final text = await ErrorLog.read();
    expect(
      await ErrorLog.count(),
      lessThanOrEqualTo(ErrorLog.maxRecords * 2),
      reason: 'между подрезками накапливается не больше двух пределов',
    );
    expect(text, isNot(contains('сбой 0 ')));
    expect(text, contains('сбой ${total - 1}'));
  });

  test('одна огромная авария не раздувает журнал', () async {
    // Счёт записей размера не ограничивает: у сообщения об аварии длины нет.
    final long = 'ы' * 200000;
    for (var i = 0; i < 12; i++) {
      await ErrorLog.record(StateError('сбой $i $long'), null);
    }

    final text = await ErrorLog.read();
    expect(text.length, lessThan(1024 * 1024));
    expect(text, contains('сбой 11 '));
  });

  test('очистка убирает записи', () async {
    await ErrorLog.record(StateError('сбой'), null);
    await ErrorLog.clear();
    expect(await ErrorLog.count(), 0);
  });
}
