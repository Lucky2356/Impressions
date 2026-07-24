import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/diagnostics/error_log.dart';
import 'design_system/design_system.dart';

Future<void> main() async {
  // Всё приложение работает под перехватом аварий: и дерево виджетов, и
  // асинхронный код. Записи ложатся в локальный журнал (настройки →
  // «Дополнительно» → «Журнал ошибок»), наружу не уходит ничего.
  ErrorLog.guard(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Вместо серого прямоугольника — то же понятное сообщение, что и на
    // экранах, где не загрузились данные.
    ErrorWidget.builder = (details) => ErrorState(error: details.exception);

    // Локальные данные форматирования дат для русской локали (без сети).
    await initializeDateFormatting('ru');
    // Приложение рисует под системными панелями Android, а отступы под них
    // берёт из MediaQuery: так шапка не оказывается под часами, а фон уходит
    // под панель навигации, а не обрывается серой полосой.
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    runApp(const ProviderScope(child: ImpressionsApp()));
  });
}
