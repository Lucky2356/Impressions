import 'package:flutter/material.dart';

import '../../core/domain/app_icons.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import 'app_controls.dart';

/// Выбор значка с поиском.
///
/// Раньше это был диалог со всеми значками подряд одной кучей: пока их два
/// десятка, найти нужный можно и глазами, но подписей у значков нет, и уже на
/// третьем десятке выбор превращается в перебор.
class IconPickerSheet extends StatefulWidget {
  const IconPickerSheet({
    super.key,
    required this.title,
    required this.searchHint,
    this.selected,
    this.tone,
  });

  final String title;
  final String searchHint;
  final String? selected;

  /// Цвет выбранного значка — тот же, каким он будет выглядеть на месте.
  final Color? tone;

  /// Показывает выбор и возвращает ключ значка или `null`, если отказались.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String searchHint,
    String? selected,
    Color? tone,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => IconPickerSheet(
        title: title,
        searchHint: searchHint,
        selected: selected,
        tone: tone,
      ),
    );
  }

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = widget.tone ?? c.accentPrimary;
    final keys = AppIcons.search(_query);

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
        AppDimens.space20,
        AppDimens.space8,
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSearchField(
              hint: widget.searchHint,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: AppDimens.space16),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  children: [
                    for (final key in keys)
                      _IconTile(
                        icon: AppIcons.byKey(key),
                        tone: tone,
                        selected: key == widget.selected,
                        onTap: () => Navigator.of(context).pop(key),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: selected ? tone.withValues(alpha: 0.16) : c.surfaceMuted,
      borderRadius: AppDimens.brMd,
      child: InkWell(
        borderRadius: AppDimens.brMd,
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: AppDimens.brMd,
            border: Border.all(
              color: selected ? tone : c.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Icon(icon, size: 22, color: selected ? tone : c.textSecondary),
        ),
      ),
    );
  }
}
