import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../home/home_providers.dart';
import 'category_picker.dart';

/// Быстрое добавление записи (§11).
///
/// Обязательное поле — только название. Остальное раскрывается по кнопке
/// «Добавить подробности». Открывается диалогом на широком экране и нижним
/// листом на узком.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  /// Показывает форму подходящим для платформы способом.
  static Future<bool> show(BuildContext context) async {
    final wide =
        MediaQuery.sizeOf(context).width >= AppDimens.breakpointExpanded;
    final result = wide
        ? await showDialog<bool>(
            context: context,
            builder: (_) => const Dialog(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(width: 560, child: QuickAddSheet()),
            ),
          )
        : await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const QuickAddSheet(),
          );
    return result ?? false;
  }

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();

  String? _typeId;
  CategoryRow? _category;
  Relation? _relation;
  double? _rating;
  bool _showDetails = false;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = ref.read(activeProfileProvider);
    final typeId = _typeId;
    if (profile == null || typeId == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(entryRepositoryProvider);
      final title = _title.text.trim();

      // Поиск возможных дублей (§26): автоматически ничего не объединяем,
      // только предлагаем использовать существующий объект.
      final candidates = await repo.findDuplicateCandidates(typeId, title);
      var objectId = <String>[];
      if (candidates.isNotEmpty && mounted) {
        final chosen = await _askDuplicate(candidates);
        if (chosen == _DuplicateChoice.cancelled) return;
        if (chosen == _DuplicateChoice.useExisting) {
          objectId = [candidates.first.id];
        }
      }

      final object = objectId.isNotEmpty
          ? candidates.firstWhere((o) => o.id == objectId.first)
          : await repo.createObject(typeId: typeId, title: title);
      await repo.createEntry(
        profileId: profile.id,
        objectId: object.id,
        relation: _relation?.name,
        rating: _rating,
        detailedNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
        primaryCategoryId: _category?.id,
      );
      ref.read(dataRefreshProvider.notifier).bump();
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Спрашивает, что делать с найденными похожими объектами (§26).
  Future<_DuplicateChoice> _askDuplicate(List<ObjectRow> candidates) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<_DuplicateChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.duplicateTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.duplicateMessage),
            const SizedBox(height: AppDimens.space12),
            for (final o in candidates.take(5))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 16),
                    const SizedBox(width: AppDimens.space8),
                    Expanded(child: Text(o.title)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_DuplicateChoice.keepSeparate),
            child: Text(l10n.duplicateKeepSeparate),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_DuplicateChoice.useExisting),
            child: Text(l10n.duplicateUseExisting),
          ),
        ],
      ),
    );
    return result ?? _DuplicateChoice.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final types = ref.watch(objectTypesProvider);

    // Подставляем первый тип по умолчанию.
    final typeList = types.value ?? const <ObjectTypeRow>[];
    if (_typeId == null && typeList.isNotEmpty) {
      _typeId = typeList.first.id;
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.space20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.quickAddTitle,
                        style: context.text.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.commonClose,
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space16),
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.quickAddNameLabel,
                    hintText: l10n.quickAddNameHint,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.quickAddNameRequired
                      : null,
                ),
                const SizedBox(height: AppDimens.space16),
                DropdownButtonFormField<String>(
                  initialValue: _typeId,
                  decoration: InputDecoration(
                    labelText: l10n.quickAddTypeLabel,
                  ),
                  items: [
                    for (final t in typeList)
                      DropdownMenuItem(value: t.id, child: Text(t.name)),
                  ],
                  onChanged: (v) => setState(() => _typeId = v),
                ),
                const SizedBox(height: AppDimens.space16),
                _CategoryField(
                  category: _category,
                  onPick: () async {
                    final picked = await CategoryPicker.show(context);
                    if (picked != null) {
                      setState(
                        () =>
                            _category = picked.cleared ? null : picked.category,
                      );
                    }
                  },
                ),
                const SizedBox(height: AppDimens.space16),
                Text(
                  l10n.quickAddRelationLabel,
                  style: context.text.labelSmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.space8),
                Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  children: [
                    for (final r in Relation.values)
                      ChoiceChip(
                        selected: _relation == r,
                        onSelected: (s) =>
                            setState(() => _relation = s ? r : null),
                        avatar: Icon(
                          r.icon,
                          size: 16,
                          color: _relation == r ? r.accent(c) : c.textSecondary,
                        ),
                        label: Text(r.label(l10n)),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.space16),
                if (!_showDetails)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showDetails = true),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text(l10n.quickAddDetails),
                    ),
                  ),
                if (_showDetails) ...[
                  Row(
                    children: [
                      Text(
                        l10n.quickAddRatingLabel,
                        style: context.text.labelSmall?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _rating == null
                            ? l10n.quickAddRatingNone
                            : _rating!.toStringAsFixed(1),
                        style: context.text.labelMedium,
                      ),
                    ],
                  ),
                  Slider(
                    value: _rating ?? 0,
                    min: 0,
                    max: 10,
                    divisions: 20,
                    label: (_rating ?? 0).toStringAsFixed(1),
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                  if (_rating != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setState(() => _rating = null),
                        child: Text(l10n.quickAddRatingNone),
                      ),
                    ),
                  const SizedBox(height: AppDimens.space8),
                  TextFormField(
                    controller: _note,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.quickAddNoteLabel,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.space24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.commonCancel),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy || typeList.isEmpty ? null : _save,
                        child: Text(l10n.commonSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.category, required this.onPick});

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

/// Что делать с найденными похожими объектами (§26).
enum _DuplicateChoice { useExisting, keepSeparate, cancelled }
