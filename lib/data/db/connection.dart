import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Открывает подключение к локальному файлу БД в каталоге приложения.
///
/// Файл лежит в `getApplicationSupportDirectory()` — приватном каталоге
/// приложения на Windows и Android. Работа в фоне (`createInBackground`), чтобы
/// не блокировать UI (§29).
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'impressions.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
