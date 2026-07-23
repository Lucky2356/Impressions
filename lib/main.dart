import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Локальные данные форматирования дат для русской локали (без сети).
  await initializeDateFormatting('ru');
  // Приложение рисует под системными панелями Android, а отступы под них
  // берёт из MediaQuery: так шапка не оказывается под часами, а фон уходит
  // под панель навигации, а не обрывается серой полосой.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: ImpressionsApp()));
}
