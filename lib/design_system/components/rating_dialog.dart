import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'rating_picker.dart';
import 'rating_view.dart';

/// Оценка одним движением.
///
/// Жила внутри «Хочу попробовать», а нужна везде, где оценку ставят, не
/// открывая карточку: в списке отмечают попробованное и в контекстном меню
/// каталога.
class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.title, this.initial = 7});

  /// Название записи — чтобы было видно, что именно оценивают.
  final String title;
  final double initial;

  /// Показывает диалог; возвращает null, если отказались.
  static Future<double?> show(
    BuildContext context, {
    required String title,
    double initial = 7,
  }) {
    return showDialog<double>(
      context: context,
      builder: (_) => RatingDialog(title: title, initial: initial),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AlertDialog(
      title: Text(l10n.wishlistRatingTitle),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: context.text.titleMedium),
            const SizedBox(height: AppDimens.space16),
            Row(
              children: [
                Text(
                  l10n.quickAddRatingLabel,
                  style: context.text.labelSmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const Spacer(),
                RatingView(value: _rating, compact: true),
              ],
            ),
            RatingPicker(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            Text(
              l10n.wishlistRatingHint,
              style: context.text.labelSmall?.copyWith(color: c.textMuted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_rating),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
