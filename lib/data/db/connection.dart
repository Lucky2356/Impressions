import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database_cipher.dart';

/// Ключ, которым открывается база в этом запуске.
///
/// Задаётся один раз при старте — до того, как кто-либо возьмётся за данные.
/// `null` означает незашифрованную базу: так работали все версии до 1.15.0 и
/// так остаётся у всех, кто шифрование не включал.
List<int>? databaseKey;

/// Открывает подключение к локальному файлу БД в каталоге приложения.
///
/// Файл лежит в `getApplicationSupportDirectory()` — приватном каталоге
/// приложения на Windows и Android. Работа в фоне (`createInBackground`), чтобы
/// не блокировать UI (§29).
QueryExecutor openConnection() {
  final key = databaseKey;
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, DatabaseCipher.databaseFileName));
    if (key == null) return NativeDatabase.createInBackground(file);

    // Ключ уходит первым запросом: до него база не отдаёт ничего, даже
    // списка таблиц.
    final statement = DatabaseCipher.openStatement(key);
    return NativeDatabase.createInBackground(
      file,
      setup: (db) => db.execute(statement),
    );
  });
}
