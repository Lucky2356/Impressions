import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Свёрнутый раздел карточки записи: строка с названием, счётчиком и стрелкой.
///
/// В карточке шестнадцать блоков, и раньше все они были раскрыты сразу. Между
/// тем половина отвечает на вопросы, которые задают редко: какие теги, кому
/// видно, что похоже, как правилось. Держать их развёрнутыми — значит каждый
/// раз пролистывать мимо них то, ради чего карточку и открыли.
///
/// Раскрытое состояние живёт в самом виджете: оно про этот показ карточки, а
/// не про запись, и переживать закрытие ему незачем.
class EntryDisclosure extends StatefulWidget {
  const EntryDisclosure({
    super.key,
    required this.title,
    required this.child,
    this.badge,
    this.initiallyOpen = false,
  });

  final String title;

  /// Короткая подпись справа от названия: число тегов, число версий.
  /// По ней видно, есть ли внутри что-то, не раскрывая.
  final String? badge;

  final Widget child;
  final bool initiallyOpen;

  @override
  State<EntryDisclosure> createState() => _EntryDisclosureState();
}

class _EntryDisclosureState extends State<EntryDisclosure> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: AppDimens.brSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: context.text.titleMedium),
                ),
                if (widget.badge case final badge?) ...[
                  Text(
                    badge,
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                  const SizedBox(width: AppDimens.space8),
                ],
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: c.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.space12),
            child: widget.child,
          ),
        Divider(height: 1, color: c.divider),
      ],
    );
  }
}
