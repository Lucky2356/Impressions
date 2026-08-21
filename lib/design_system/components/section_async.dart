import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_state.dart';
import 'skeleton.dart';

/// Блок экрана, ждущий данных: заглушка, ошибка или содержимое.
///
/// Три десятка мест читали провайдер как `.value ?? const []` — и отказ базы
/// становился неотличим от пустоты. Главная на этом предлагала завести первую
/// запись человеку, у которого их тысяча, а список резервных копий сообщал,
/// что копий нет.
///
/// Ошибка внутри блока показывается компактно: раздел состоит из нескольких
/// блоков, и падать целиком из-за одного он не должен.
class SectionAsync<T> extends StatelessWidget {
  const SectionAsync({
    super.key,
    required this.value,
    required this.builder,
    this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;

  /// Что показать, пока идёт запрос. По умолчанию — список-заглушка.
  final Widget? loading;

  /// Перечитать то, что не прочиталось: обычно `ref.invalidate(провайдер)`.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      loading: () => loading ?? const SkeletonList(count: 2),
      error: (error, _) =>
          ErrorState(error: error, compact: true, onRetry: onRetry),
    );
  }
}
