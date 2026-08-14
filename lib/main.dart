import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/diagnostics/error_log.dart';
import 'data/services/database_lock_service.dart';
import 'features/lock/unlock_screen.dart';
import 'design_system/design_system.dart';

Future<void> main(List<String> args) async {
  // Путь к файлу, по которому щёлкнули в «Проводнике», приходит аргументом:
  // Flutter сам его никуда не отдаёт.
  launchArguments = args;

  // Всё приложение работает под перехватом аварий: и дерево виджетов, и
  // асинхронный код. Записи ложатся в локальный журнал (настройки →
  // «Дополнительно» → «Журнал ошибок»), наружу не уходит ничего.
  ErrorLog.guard(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Вместо серого прямоугольника — то же понятное сообщение, что и на
    // экранах, где не загрузились данные.
    ErrorWidget.builder = (details) => ErrorState(error: details.exception);

    // Локальные данные форматирования дат для обоих языков интерфейса
    // (без сети): названия месяцев берутся отсюда.
    await initializeDateFormatting('ru');
    await initializeDateFormatting('en');
    // Приложение рисует под системными панелями Android, а отступы под них
    // берёт из MediaQuery: так шапка не оказывается под часами, а фон уходит
    // под панель навигации, а не обрывается серой полосой.
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Ключ к базе выясняется до первого обращения к данным: drift открывает
    // файл лениво, но открывает его уже с ключом или без — поменять это
    // потом нельзя.
    const lock = DatabaseLockService();
    final status = await lock.prepare();
    switch (status) {
      case LockStatus.open:
      case LockStatus.unlocked:
        runApp(const ProviderScope(child: ImpressionsApp()));
      case LockStatus.needsPassword:
      case LockStatus.staleKey:
        runApp(
          UnlockApp(
            stale: status == LockStatus.staleKey,
            onUnlocked: () =>
                runApp(const ProviderScope(child: ImpressionsApp())),
          ),
        );
    }
  });
}
