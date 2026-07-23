import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Счётчик изменений данных.
///
/// Провайдеры-запросы наблюдают его, а операции записи вызывают [bump],
/// чтобы списки и счётчики перечитались. Простая и предсказуемая замена
/// ручной инвалидации по всему приложению.
class DataRefresh extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final dataRefreshProvider = NotifierProvider<DataRefresh, int>(DataRefresh.new);
