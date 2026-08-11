import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/services/launch_service.dart';

/// С чем приложение открыли.
///
/// Присланный файл обмена нельзя было отдать приложению вовсе: ни двойным
/// щелчком из «Проводника», ни через «Поделиться» — каждый раз приходилось
/// заходить в «Импорт» и искать файл вручную.
void main() {
  late Directory dir;

  setUp(() async {
    // Канал запуска — платформенный, поэтому нужна привязка теста: без неё
    // любое обращение к нему падает ещё до ответа.
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp('impressions-launch');
  });

  tearDown(() => dir.delete(recursive: true));

  File make(String name) => File('${dir.path}/$name')..writeAsStringSync('x');

  test('файл обмена из аргументов открывается', () {
    final file = make('Александр.impressions');

    expect(LaunchService.fileFromArguments([file.path]), file.path);
  });

  test('ключи командной строки за файл не принимаются', () {
    expect(
      LaunchService.fileFromArguments(['--observatory-port=1234', '-v']),
      isNull,
    );
  });

  test('чужие расширения не открываются', () {
    final alien = make('заметки.txt');

    expect(LaunchService.fileFromArguments([alien.path]), isNull);
  });

  test('несуществующий путь не открывается', () {
    expect(
      LaunchService.fileFromArguments(['${dir.path}/нет.impressions']),
      isNull,
    );
  });

  test('запуск без аргументов ничего не открывает', () async {
    final request = await const LaunchService().initial(const []);

    expect(request.isEmpty, isTrue);
    expect(request.file, isNull);
    expect(request.action, isNull);
  });

  test('ярлык со значка приходит действием, а не файлом', () async {
    const channel = MethodChannel(LaunchService.channelName);
    // Подменяем платформенную сторону: на телефоне её заполняет активность.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => call.method == 'consumeLaunch'
              ? {'file': null, 'action': 'scan'}
              : null,
        );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final request = await const LaunchService().initial(const []);

    expect(request.action, 'scan');
    expect(request.file, isNull);
  });
}
