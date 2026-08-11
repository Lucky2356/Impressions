import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// С чем приложение открыли.
///
/// Файл обмена или резервную копию присылают из «Проводника», из «Поделиться»
/// и двойным щелчком на компьютере. Раньше приложение об этом не знало вовсе:
/// присланный файл приходилось искать вручную в разделе «Импорт».
class LaunchRequest {
  const LaunchRequest({this.file, this.action});

  /// Путь к присланному файлу.
  final String? file;

  /// Быстрое действие со значка: `add` или `scan`.
  final String? action;

  bool get isEmpty => file == null && action == null;
}

/// Откуда приложение узнаёт о запуске с файлом или ярлыком.
class LaunchService {
  const LaunchService({this.channel = const MethodChannel(channelName)});

  static const channelName = 'club.impressions/launch';

  final MethodChannel channel;

  /// Что пришло с холодным стартом.
  ///
  /// На компьютере файл приходит аргументом командной строки, на Android —
  /// через интент, который активность кладёт в канал.
  Future<LaunchRequest> initial(List<String> arguments) async {
    final fromArgs = fileFromArguments(arguments);
    if (fromArgs != null) return LaunchRequest(file: fromArgs);
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const LaunchRequest();
    }

    try {
      final result = await channel.invokeMapMethod<String, Object?>(
        'consumeLaunch',
      );
      return LaunchRequest(
        file: result?['file'] as String?,
        action: result?['action'] as String?,
      );
    } on MissingPluginException {
      // Канала нет — например, в тестах и на других платформах.
      return const LaunchRequest();
    }
  }

  /// Запуски, приходящие в уже открытое приложение.
  Stream<LaunchRequest> get incoming {
    final controller = StreamController<LaunchRequest>.broadcast();
    channel.setMethodCallHandler((call) async {
      if (call.method != 'launch') return null;
      final data = (call.arguments as Map?)?.cast<String, Object?>();
      controller.add(
        LaunchRequest(
          file: data?['file'] as String?,
          action: data?['action'] as String?,
        ),
      );
      return null;
    });
    return controller.stream;
  }

  /// Файл из аргументов командной строки.
  ///
  /// Двойной щелчок по `.impressions` на Windows запускает приложение с путём
  /// к файлу. Чужие ключи и несуществующие пути игнорируем: открывать по
  /// первому попавшемуся аргументу нельзя.
  static String? fileFromArguments(List<String> arguments) {
    for (final argument in arguments) {
      if (argument.startsWith('-')) continue;
      if (!argument.toLowerCase().endsWith('.impressions')) continue;
      if (!File(argument).existsSync()) continue;
      return argument;
    }
    return null;
  }
}
