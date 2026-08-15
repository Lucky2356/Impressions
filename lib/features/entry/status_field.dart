import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/domain/entry_status.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Выбор стадии записи (§10).
///
/// Один виджет на форму и на карточку: стадия — то же самое поле в обоих
/// местах, а два похожих ряда чипов разошлись бы, как разошлись когда-то три
/// копии карточки записи.
///
/// Набор стадий приходит от типа, поэтому пустой список — не ошибка: у
/// пользовательского типа стадий нет, пока их не заведут. Тогда вместо ряда
/// чипов показывается строчка о том, где их взять, — молча пропадающее поле
/// выглядело бы поломкой.
class StatusField extends StatelessWidget {
  const StatusField({
    super.key,
    required this.statuses,
    required this.value,
    required this.onChanged,
    this.showEmptyHint = true,
  });

  /// Стадии типа этой записи.
  final List<EntryStatus> statuses;

  /// Ключ выбранной стадии; null — не задана.
  final String? value;

  /// null в аргументе — стадию сняли.
  final ValueChanged<String?>? onChanged;

  /// Показывать ли подсказку, когда у типа стадий нет.
  final bool showEmptyHint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    if (statuses.isEmpty) {
      if (!showEmptyHint) return const SizedBox.shrink();
      return Text(
        l10n.statusTypeHasNone,
        style: context.text.labelSmall?.copyWith(color: c.textMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.statusLabel,
          style: context.text.labelSmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppDimens.space8),
        Wrap(
          spacing: AppDimens.space8,
          runSpacing: AppDimens.space8,
          children: [
            for (final status in statuses)
              ChoiceChip(
                selected: value == status.key,
                // Повторное нажатие снимает стадию: иначе поставленную по
                // ошибке пришлось бы «переставлять» на соседнюю, а «стадии
                // нет» — законное состояние записи.
                onSelected: onChanged == null
                    ? null
                    : (s) => onChanged!(s ? status.key : null),
                avatar: Icon(
                  status.done
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 16,
                  color: value == status.key
                      ? c.accentPrimary
                      : c.textSecondary,
                ),
                label: Text(status.name),
              ),
          ],
        ),
      ],
    );
  }
}

/// Прогресс: сколько пройдено и сколько всего — «3 серия из 12».
///
/// Поля отдаются вместе с контроллерами: форма читает набранное в момент
/// сохранения, а карточка записывает, когда курсор ушёл из поля. Своё
/// состояние здесь завело бы третий источник правды.
///
/// Показывается только у типов, где есть что считать: у продукта серий нет, и
/// пустая пара полей в его форме была бы вопросом без ответа.
class ProgressField extends StatelessWidget {
  const ProgressField({
    super.key,
    required this.unit,
    required this.current,
    required this.total,
    this.enabled = true,
    this.onEditingComplete,
  });

  /// В чём считаем: серия, страница, час.
  final String unit;

  final TextEditingController current;
  final TextEditingController total;
  final bool enabled;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    Widget field(TextEditingController controller, String label) => TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      // Только цифры: «двенадцатая» в числовой колонке превратилась бы в
      // молчаливый null, и прогресс просто не сохранился бы.
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(labelText: label),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              l10n.progressLabel,
              style: context.text.labelSmall?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(width: AppDimens.space8),
            Text(
              unit,
              style: context.text.labelSmall?.copyWith(color: c.textMuted),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space8),
        Row(
          children: [
            Expanded(child: field(current, l10n.progressCurrentLabel)),
            const SizedBox(width: AppDimens.space12),
            Expanded(child: field(total, l10n.progressTotalLabel)),
          ],
        ),
      ],
    );
  }
}

/// Число из поля прогресса; пустое поле значит «не задано».
int? progressValueOf(TextEditingController controller) {
  final text = controller.text.trim();
  return text.isEmpty ? null : int.tryParse(text);
}

/// Три общие стадии с обобщёнными названиями — для отбора и массовой смены.
///
/// В каталоге лежат записи всех типов сразу, а названия стадий у каждого типа
/// свои: «Прочитал» и «Попробовал» — про разное. Объединять все наборы в один
/// список нельзя — получилось бы десять почти одинаковых пунктов, — поэтому
/// отбор идёт по общим ключам, а подписи к ним нейтральные.
List<({String key, String label})> catalogStatusKeys(AppLocalizations l10n) => [
  (key: EntryStatus.planned, label: l10n.statusStagePlanned),
  (key: EntryStatus.inProgress, label: l10n.statusStageInProgress),
  (key: EntryStatus.doneKey, label: l10n.statusStageDone),
];
