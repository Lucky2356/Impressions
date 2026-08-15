import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/domain/entry_status.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';

/// Редактор стадий типа объекта (§10).
///
/// Столбец `profile_entries.status` в базе был с самого начала и не читался ни
/// одним экраном: стадию изображало отношение «Хочу попробовать», и сказать
/// «уже смотрю, но пока без мнения» было нечем.
///
/// Названия стадий у каждого типа свои — «Прочитал» и «Попробовал» про разное,
/// — а ключи общие: иначе отбор «что сейчас в процессе» пришлось бы задавать
/// отдельно для книг, фильмов и продуктов.
class StatusesEditor extends ConsumerStatefulWidget {
  const StatusesEditor({super.key, required this.type});

  final ObjectTypeRow type;

  static Future<void> show(BuildContext context, ObjectTypeRow type) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(width: 560, child: StatusesEditor(type: type)),
      ),
    );
  }

  @override
  ConsumerState<StatusesEditor> createState() => _StatusesEditorState();
}

class _StatusesEditorState extends ConsumerState<StatusesEditor> {
  late List<EntryStatus> _statuses = EntryStatus.decode(
    widget.type.statusesJson,
  );
  late final _unit = TextEditingController(
    text: widget.type.progressUnit ?? '',
  );
  bool _dirty = false;

  @override
  void dispose() {
    _unit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final db = ref.read(appDatabaseProvider);
    final unit = _unit.text.trim();
    await (db.update(
      db.objectTypes,
    )..where((t) => t.id.equals(widget.type.id))).write(
      ObjectTypesCompanion(
        statusesJson: Value(EntryStatus.encode(_statuses)),
        progressUnit: Value(unit.isEmpty ? null : unit),
      ),
    );
    ref.read(dataRefreshProvider.notifier).bump();
    if (mounted) Navigator.of(context).pop();
  }

  /// Ключи общие для всех типов, поэтому их не придумывают, а выбирают из
  /// трёх: задумано, в процессе, сделано.
  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final free = [
      for (final key in const [
        EntryStatus.planned,
        EntryStatus.inProgress,
        EntryStatus.doneKey,
      ])
        if (!_statuses.any((s) => s.key == key)) key,
    ];
    if (free.isEmpty) {
      showMessage(context, l10n.statusesAllUsed);
      return;
    }

    final key = free.first;
    final name = await TextInputDialog.show(
      context,
      title: _titleFor(l10n, key),
      label: l10n.statusNameLabel,
    );
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      _dirty = true;
      _statuses = [
        ..._statuses,
        EntryStatus(
          key: key,
          name: name.trim(),
          done: key == EntryStatus.doneKey,
        ),
      ]..sort((a, b) => _order(a.key).compareTo(_order(b.key)));
    });
  }

  Future<void> _rename(EntryStatus status) async {
    final name = await TextInputDialog.show(
      context,
      title: AppLocalizations.of(context).statusRename,
      label: AppLocalizations.of(context).statusNameLabel,
      initial: status.name,
    );
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      _dirty = true;
      _statuses = [
        for (final s in _statuses)
          if (s.key == status.key)
            EntryStatus(key: s.key, name: name.trim(), done: s.done)
          else
            s,
      ];
    });
  }

  void _remove(EntryStatus status) {
    setState(() {
      _dirty = true;
      _statuses = [
        for (final s in _statuses)
          if (s.key != status.key) s,
      ];
    });
  }

  static int _order(String key) => switch (key) {
    EntryStatus.planned => 0,
    EntryStatus.inProgress => 1,
    _ => 2,
  };

  static String _titleFor(AppLocalizations l10n, String key) => switch (key) {
    EntryStatus.planned => l10n.statusStagePlanned,
    EntryStatus.inProgress => l10n.statusStageInProgress,
    _ => l10n.statusStageDone,
  };

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
                  l10n.statusesEditFor(widget.type.name),
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
            l10n.statusesHint,
            style: context.text.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space20),
          if (_statuses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.space24),
              child: Text(
                l10n.statusesEmpty,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: c.textMuted),
              ),
            )
          else
            for (final status in _statuses)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.space8),
                child: AppCard(
                  elevated: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space12,
                    vertical: AppDimens.space8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        status.done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: AppDimens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(status.name, style: context.text.titleMedium),
                            Text(
                              _titleFor(l10n, status.key),
                              style: context.text.labelSmall?.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.edit_rounded,
                        tooltip: l10n.statusRename,
                        onPressed: () => _rename(status),
                      ),
                      AppIconButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: l10n.statusRemove,
                        danger: true,
                        onPressed: () => _remove(status),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: AppDimens.space8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.statusAdd),
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          TextField(
            controller: _unit,
            onChanged: (_) => setState(() => _dirty = true),
            decoration: InputDecoration(
              labelText: l10n.progressUnitLabel,
              hintText: l10n.progressUnitHint,
            ),
          ),
          const SizedBox(height: AppDimens.space20),
          FilledButton(
            onPressed: _dirty ? _save : null,
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
