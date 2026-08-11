import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_card.dart';

/// Раздел настроек: заголовок, необязательное действие справа и карточка
/// с содержимым.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: context.text.titleLarge)),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppDimens.space12),
        // Содержимое прижато к левому краю: по умолчанию Column центрирует
        // детей по горизонтали, из-за чего одиночные подписи и пустые
        // состояния оказывались посреди карточки и выглядели как ошибка.
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}

/// Строка настройки: подпись слева, управляющий элемент справа.
///
/// Когда элемент не помещается рядом с подписью, он переносится под неё.
/// Без этого переключатель темы наезжал на слово «Тема» и разбивал его по
/// одной букве на строку.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    required this.control,
    this.description,
    this.minControlWidth = 120,
  });

  final String label;
  final Widget control;

  /// Пояснение под подписью.
  final String? description;

  /// Сколько места элементу нужно, чтобы остаться в одной строке с подписью.
  final double minControlWidth;

  /// Шире этого элемент не растягивается.
  ///
  /// Ширину надо задать явно: в строке элемент стоял без ограничения, то есть
  /// получал бесконечную ширину. Всё, что внутри делит место (переключатель
  /// темы, списки), в отладке падало на этом с «unbounded width», а в сборке
  /// раскладывалось как придётся.
  static const double maxControlWidth = 360;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget text() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: context.text.bodyMedium),
        if (description != null) ...[
          const SizedBox(height: AppDimens.space4),
          Text(
            description!,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, cns) {
        // Подписи нужно хотя бы немного места: иначе переносить бессмысленно.
        final fits = cns.maxWidth - minControlWidth >= 140;
        if (fits) {
          // Место под элемент — остаток строки, но не больше предела: иначе
          // трёхсегментный переключатель растягивался бы на полстраницы.
          final room = cns.maxWidth - 140 - AppDimens.space12;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: text()),
              const SizedBox(width: AppDimens.space12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: room < maxControlWidth ? room : maxControlWidth,
                ),
                child: control,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            text(),
            const SizedBox(height: AppDimens.space12),
            control,
          ],
        );
      },
    );
  }
}
