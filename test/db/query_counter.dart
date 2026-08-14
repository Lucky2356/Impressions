import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:impressions/data/db/database.dart';

/// Считает, сколько раз приложение сходило в базу.
///
/// «Стало быстрее» на глаз не проверяется, а замер времени в тестах шаток:
/// он зависит от машины и от того, что делает соседний процесс. Число
/// обращений — то же самое, но детерминированно: цикл с запросом на каждую
/// запись отличается от одного запроса на всю пачку в сотни раз.
class QueryCounter extends QueryInterceptor {
  /// Отдельные запросы: выборки, вставки, обновления, удаления.
  int statements = 0;

  /// Команды внутри пакетов — их SQLite готовит один раз и повторяет.
  int batched = 0;

  /// Настоящие транзакции: каждая — это отдельная запись в журнал и ожидание
  /// диска. Вложенные не считаются: внутри уже открытой транзакции drift
  /// ставит точку сохранения, и до диска дело не доходит.
  int transactions = 0;

  /// Вложенные транзакции — точки сохранения.
  int savepoints = 0;

  /// Текст запросов — по нему видно, к какой таблице ходили и сколько раз.
  final List<String> sql = [];

  /// Сколько запросов содержало эту подстроку.
  int matching(String part) => sql.where((s) => s.contains(part)).length;

  void reset() {
    statements = 0;
    batched = 0;
    transactions = 0;
    savepoints = 0;
    sql.clear();
  }

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    if (parent is TransactionExecutor) {
      savepoints++;
    } else {
      transactions++;
    }
    return super.beginTransaction(parent);
  }

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) {
    batched += statements.arguments.length;
    sql.addAll(statements.statements);
    return super.runBatched(executor, statements);
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    statements++;
    sql.add(statement);
    return super.runSelect(executor, statement, args);
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    statements++;
    sql.add(statement);
    return super.runInsert(executor, statement, args);
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    statements++;
    sql.add(statement);
    return super.runUpdate(executor, statement, args);
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    statements++;
    sql.add(statement);
    return super.runDelete(executor, statement, args);
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    statements++;
    sql.add(statement);
    return super.runCustom(executor, statement, args);
  }
}

/// База в памяти со счётчиком обращений.
(AppDatabase, QueryCounter) openCountingDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final counter = QueryCounter();
  return (
    AppDatabase.forTesting(NativeDatabase.memory().interceptWith(counter)),
    counter,
  );
}
