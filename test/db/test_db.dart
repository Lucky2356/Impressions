import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:impressions/data/db/database.dart';

/// Создаёт изолированную in-memory базу для тестов.
///
/// В тестах каждая база использует собственный executor, поэтому штатное
/// предупреждение drift о нескольких экземплярах здесь неактуально.
AppDatabase openTestDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase.forTesting(NativeDatabase.memory());
}
