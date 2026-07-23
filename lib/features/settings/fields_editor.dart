import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/domain/custom_fields.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/ids.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';

/// Редактор пользовательских полей типа объекта (§9).
///
/// Модель данных под это была готова с самого начала, но интерфейса не было —
/// поля нельзя было завести. Здесь схема правится списком и сохраняется в
/// `object_types.fields_schema`.
class FieldsEditor extends ConsumerStatefulWidget {
  const FieldsEditor({super.key, required this.type});

  final ObjectTypeRow type;

  static Future<void> show(BuildContext context, ObjectTypeRow type) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(width: 560, child: FieldsEditor(type: type)),
      ),
    );
  }

  @override
  ConsumerState<FieldsEditor> createState() => _FieldsEditorState();
}

class _FieldsEditorState extends ConsumerState<FieldsEditor> {
  late List<CustomField> _fields = CustomField.decodeSchema(
    widget.type.fieldsSchema,
  );
  bool _dirty = false;

  Future<void> _save() async {
    final db = ref.read(appDatabaseProvider);
    await (db.update(
      db.objectTypes,
    )..where((t) => t.id.equals(widget.type.id))).write(
      ObjectTypesCompanion(
        fieldsSchema: Value(CustomField.encodeSchema(_fields)),
      ),
    );
    ref.read(dataRefreshProvider.notifier).bump();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _edit({CustomField? existing}) async {
    final result = await showDialog<CustomField>(
      context: context,
      builder: (_) => _FieldDialog(field: existing),
    );
    if (result == null) return;
    setState(() {
      _dirty = true;
      final index = _fields.indexWhere((f) => f.key == result.key);
      if (index >= 0) {
        _fields[index] = result;
      } else {
        _fields = [..._fields, result];
      }
    });
  }

  void _remove(CustomField field) {
    setState(() {
      _dirty = true;
      _fields = _fields.where((f) => f.key != field.key).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.space20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.fieldsEditFor(widget.type.name),
                  style: context.text.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: l10n.commonClose,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space4),
          Text(
            l10n.fieldsHint,
            style: context.text.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space20),

          if (_fields.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.space24),
              child: Text(
                l10n.fieldsEmpty,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: c.textMuted),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _fields.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppDimens.space8),
                itemBuilder: (context, i) {
                  final field = _fields[i];
                  return AppCard(
                    elevated: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space12,
                      vertical: AppDimens.space8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _iconFor(field.kind),
                          size: 18,
                          color: c.textSecondary,
                        ),
                        const SizedBox(width: AppDimens.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(field.name, style: context.text.titleMedium),
                              Text(
                                _kindLabel(field.kind, l10n),
                                style: context.text.labelSmall?.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppIconButton(
                          icon: Icons.edit_rounded,
                          tooltip: l10n.commonEdit,
                          onPressed: () => _edit(existing: field),
                        ),
                        AppIconButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: l10n.fieldsRemove,
                          danger: true,
                          onPressed: () => _remove(field),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: AppDimens.space16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.fieldsAdd),
            ),
          ),
          const SizedBox(height: AppDimens.space20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: FilledButton(
                  onPressed: _dirty ? _save : null,
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(FieldKind kind) => switch (kind) {
  FieldKind.text => Icons.short_text_rounded,
  FieldKind.number => Icons.numbers_rounded,
  FieldKind.date => Icons.event_rounded,
  FieldKind.boolean => Icons.toggle_on_rounded,
  FieldKind.choice => Icons.list_rounded,
};

String _kindLabel(FieldKind kind, AppLocalizations l10n) => switch (kind) {
  FieldKind.text => l10n.fieldsKindText,
  FieldKind.number => l10n.fieldsKindNumber,
  FieldKind.date => l10n.fieldsKindDate,
  FieldKind.boolean => l10n.fieldsKindBool,
  FieldKind.choice => l10n.fieldsKindChoice,
};

/// Диалог создания и правки одного поля.
class _FieldDialog extends StatefulWidget {
  const _FieldDialog({this.field});
  final CustomField? field;

  @override
  State<_FieldDialog> createState() => _FieldDialogState();
}

class _FieldDialogState extends State<_FieldDialog> {
  late final _name = TextEditingController(text: widget.field?.name ?? '');
  late final _choices = TextEditingController(
    text: widget.field?.choices.join(', ') ?? '',
  );
  late FieldKind _kind = widget.field?.kind ?? FieldKind.text;

  @override
  void dispose() {
    _name.dispose();
    _choices.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.field == null ? l10n.fieldsAdd : l10n.commonEdit),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.fieldsNameLabel),
            ),
            const SizedBox(height: AppDimens.space16),
            DropdownButtonFormField<FieldKind>(
              initialValue: _kind,
              decoration: InputDecoration(labelText: l10n.fieldsKindLabel),
              items: [
                for (final kind in FieldKind.values)
                  DropdownMenuItem(
                    value: kind,
                    child: Text(_kindLabel(kind, l10n)),
                  ),
              ],
              onChanged: (v) => setState(() => _kind = v ?? FieldKind.text),
            ),
            if (_kind == FieldKind.choice) ...[
              const SizedBox(height: AppDimens.space16),
              TextField(
                controller: _choices,
                decoration: InputDecoration(labelText: l10n.fieldsChoicesLabel),
              ),
            ],
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
            final name = _name.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(
              CustomField(
                // Ключ существующего поля сохраняется, иначе значения потеряются.
                key: widget.field?.key ?? Ids.newId(),
                name: name,
                kind: _kind,
                choices: _kind == FieldKind.choice
                    ? _choices.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList()
                    : const [],
              ),
            );
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
