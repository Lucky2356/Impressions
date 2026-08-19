import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';

/// Результат правки описания объекта.
typedef ObjectEdit = ({
  String title,
  String? altTitle,
  String? summary,
  String? creator,
  int? year,
});

/// Диалог правки названия, бренда и года объекта.
/// Выбор объекта, с которым сводить.
class MergeDialog extends StatefulWidget {
  const MergeDialog({super.key, required this.candidates});

  final List<ObjectRow> candidates;

  @override
  State<MergeDialog> createState() => MergeDialogState();
}

class MergeDialogState extends State<MergeDialog> {
  /// Заранее ничего не выбрано: объединение необратимо, и подставленный выбор
  /// человек принимает не глядя.
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = widget.candidates
        .where((o) => o.id == _selectedId)
        .firstOrNull;

    return AlertDialog(
      title: Text(l10n.entryMergeTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.entryMergeMessage),
            const SizedBox(height: AppDimens.space12),
            RadioGroup<String>(
              groupValue: _selectedId,
              onChanged: (v) => setState(() => _selectedId = v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final o in widget.candidates)
                    RadioListTile<String>(
                      value: o.id,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        o.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: o.creator == null ? null : Text(o.creator!),
                    ),
                ],
              ),
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
          onPressed: selected == null
              ? null
              : () => Navigator.of(context).pop(selected),
          child: Text(l10n.entryMergeAction),
        ),
      ],
    );
  }
}

class ObjectEditDialog extends StatefulWidget {
  const ObjectEditDialog({super.key, required this.object});
  final ObjectRow object;

  @override
  State<ObjectEditDialog> createState() => ObjectEditDialogState();
}

class ObjectEditDialogState extends State<ObjectEditDialog> {
  late final _title = TextEditingController(text: widget.object.title);
  late final _creator = TextEditingController(
    text: widget.object.creator ?? '',
  );
  late final _year = TextEditingController(
    text: widget.object.year?.toString() ?? '',
  );
  late final _altTitle = TextEditingController(
    text: widget.object.altTitle ?? '',
  );
  late final _summary = TextEditingController(
    text: widget.object.summary ?? '',
  );

  @override
  void dispose() {
    _title.dispose();
    _creator.dispose();
    _year.dispose();
    _altTitle.dispose();
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AlertDialog(
      title: Text(l10n.entryEditObject),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.entryEditObjectHint,
              style: context.text.labelSmall?.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: AppDimens.space16),
            TextField(
              controller: _title,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.quickAddNameLabel),
            ),
            const SizedBox(height: AppDimens.space16),
            const SizedBox(height: AppDimens.space16),
            // Оригинальное название хранилось в базе с самого начала и нигде
            // не показывалось: «Твин Пикс» и «Twin Peaks» — один и тот же
            // сериал, и искать его хочется обоими написаниями.
            TextField(
              controller: _altTitle,
              decoration: InputDecoration(
                labelText: l10n.objectAltTitle,
                hintText: l10n.objectAltTitleHint,
              ),
            ),
            const SizedBox(height: AppDimens.space16),
            TextField(
              controller: _creator,
              decoration: InputDecoration(labelText: l10n.entryCreatorLabel),
            ),
            const SizedBox(height: AppDimens.space16),
            TextField(
              controller: _year,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.entryYearLabel),
            ),
            const SizedBox(height: AppDimens.space16),
            // Краткое описание уже подставлялось подзаголовком в списках,
            // когда у объекта нет бренда, — а ввести его было негде.
            TextField(
              controller: _summary,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                labelText: l10n.objectSummary,
                hintText: l10n.objectSummaryHint,
              ),
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
          onPressed: () {
            final title = _title.text.trim();
            if (title.isEmpty) return;
            // Пустое поле — это «стереть», а не «оставить как было»: форма
            // показывает всё сразу, и очистить её человек может нарочно.
            String? orNull(String value) {
              final text = value.trim();
              return text.isEmpty ? null : text;
            }

            Navigator.of(context).pop((
              title: title,
              altTitle: orNull(_altTitle.text),
              summary: orNull(_summary.text),
              creator: orNull(_creator.text),
              year: int.tryParse(_year.text.trim()),
            ));
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
