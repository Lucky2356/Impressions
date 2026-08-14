import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/dates.dart';
import '../../data/db/database.dart';
import '../../design_system/design_system.dart';
import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../data/providers.dart';
import '../collections/collection_providers.dart';

/// Полоска о восстановленном черновике.
///
/// Не диалог: продолжить недописанное человек хочет почти всегда, а спрашивать
/// об этом до того, как он увидел форму, — лишний шаг. Полоска говорит, что
/// произошло, и даёт начать с чистого листа.
class DraftBanner extends StatelessWidget {
  const DraftBanner({super.key, required this.onDiscard});

  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space12,
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: AppDimens.brMd,
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 18, color: c.accentPrimary),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.quickAddDraftRestored, style: context.text.bodySmall),
                Text(
                  l10n.quickAddDraftNoPhotos,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDiscard,
            child: Text(l10n.quickAddDraftDiscard),
          ),
        ],
      ),
    );
  }
}

class CategoryField extends StatelessWidget {
  const CategoryField({
    super.key,
    required this.category,
    required this.onPick,
  });

  final CategoryRow? category;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return InkWell(
      onTap: onPick,
      borderRadius: AppDimens.brMd,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.quickAddCategoryLabel,
          suffixIcon: const Icon(Icons.chevron_right_rounded),
        ),
        child: Text(
          category?.name ?? l10n.quickAddNoCategory,
          style: context.text.bodyMedium?.copyWith(
            color: category == null ? c.textMuted : c.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Что решили насчёт найденных похожих объектов (§26).
class DuplicateAnswer {
  const DuplicateAnswer.useExisting(ObjectRow object)
    : chosen = object,
      cancelled = false;
  const DuplicateAnswer.keepSeparate() : chosen = null, cancelled = false;
  const DuplicateAnswer.cancelled() : chosen = null, cancelled = true;

  /// Выбранный объект; null — заводим новый.
  final ObjectRow? chosen;

  /// Диалог закрыли, ничего не решив: сохранение отменяется.
  final bool cancelled;
}

/// Выбор среди похожих объектов.
class DuplicateDialog extends StatefulWidget {
  const DuplicateDialog({super.key, required this.candidates});

  final List<ObjectRow> candidates;

  @override
  State<DuplicateDialog> createState() => DuplicateDialogState();
}

class DuplicateDialogState extends State<DuplicateDialog> {
  /// Ничего не выбрано заранее: подставленный выбор человек принимает не
  /// глядя, а объединение объектов — не то, что стоит делать за него.
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = widget.candidates
        .where((o) => o.id == _selectedId)
        .firstOrNull;

    return AlertDialog(
      title: Text(l10n.duplicateTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.duplicateMessage),
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
          onPressed: () =>
              Navigator.of(context).pop(const DuplicateAnswer.keepSeparate()),
          child: Text(l10n.duplicateKeepSeparate),
        ),
        FilledButton(
          onPressed: selected == null
              ? null
              : () => Navigator.of(
                  context,
                ).pop(DuplicateAnswer.useExisting(selected)),
          child: Text(l10n.duplicateUseExisting),
        ),
      ],
    );
  }
}

/// Теги новой записи (§7.2).
class TagsField extends StatelessWidget {
  const TagsField({
    super.key,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.tagsLabel, style: context.text.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.tagAdd),
            ),
          ],
        ),
        if (tags.isEmpty)
          Text(
            l10n.tagsHint,
            style: context.text.labelSmall?.copyWith(color: c.textMuted),
          )
        else
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: [
              for (final tag in tags)
                InputChip(
                  label: Text(tag),
                  onDeleted: () => onRemove(tag),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                ),
            ],
          ),
      ],
    );
  }
}

/// Подборка, в которую запись попадёт сразу после сохранения (§27).
class CollectionField extends ConsumerWidget {
  const CollectionField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileProvider);
    final collections = ref.watch(collectionsProvider).value ?? const [];

    Future<void> create() async {
      if (profile == null) return;
      final name = await TextInputDialog.show(
        context,
        title: l10n.collectionCreate,
        label: l10n.collectionNameLabel,
      );
      if (name == null) return;
      final created = await ref
          .read(collectionRepositoryProvider)
          .create(profile.id, name);
      ref.read(dataRefreshProvider.notifier).bump();
      onChanged(created.id);
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            initialValue: collections.any((c) => c.collection.id == value)
                ? value
                : null,
            decoration: InputDecoration(labelText: l10n.collectionAddTo),
            menuMaxHeight: 320,
            borderRadius: AppDimens.brMd,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.quickAddNoCategory),
              ),
              for (final v in collections)
                DropdownMenuItem(
                  value: v.collection.id,
                  child: Text(v.collection.name),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppDimens.space8),
        AppIconButton(
          icon: Icons.add_rounded,
          tooltip: l10n.collectionCreate,
          onPressed: create,
        ),
      ],
    );
  }
}

/// Выбор даты впечатления в форме добавления.
class ImpressionDateField extends StatelessWidget {
  const ImpressionDateField({
    super.key,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return InkWell(
      onTap: onPick,
      borderRadius: AppDimens.brMd,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.entryImpressionDate,
          suffixIcon: value == null
              ? const Icon(Icons.event_rounded)
              : IconButton(
                  tooltip: l10n.entryImpressionDateClear,
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
        child: Text(
          value == null
              ? l10n.entryImpressionDateNone
              : localeDate(context, 'd MMMM y').format(value!),
          style: context.text.bodyMedium?.copyWith(
            color: value == null ? c.textMuted : c.textPrimary,
          ),
        ),
      ),
    );
  }
}
