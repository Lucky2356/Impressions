import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';

/// Выбор подборки — с возможностью завести новую прямо здесь.
///
/// Раньше каждое место выбирало по-своему, и там, где подборок ещё нет,
/// кнопка «В подборку» просто ничего не делала: список пуст, обработчик
/// молча выходил. Заводить первую подборку приходилось догадываться уйти в
/// отдельный раздел.
class CollectionPicker {
  const CollectionPicker._();

  /// Показывает список подборок и возвращает выбранную.
  ///
  /// Возвращает null, если отказались. Подборки из [disabled] показаны с
  /// галочкой и не выбираются: запись в них уже лежит.
  static Future<String?> show(
    BuildContext context,
    WidgetRef ref, {
    Set<String> disabled = const {},
  }) async {
    final l10n = AppLocalizations.of(context);
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return null;

    final repo = ref.read(collectionRepositoryProvider);
    final existing = await repo.listWithCounts(profile.id);
    if (!context.mounted) return null;

    const createValue = '__new__';
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.collectionAddTo),
        children: [
          if (existing.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space24,
                0,
                AppDimens.space24,
                AppDimens.space12,
              ),
              child: Text(
                l10n.collectionEmptyMessage,
                style: ctx.text.bodySmall?.copyWith(
                  color: ctx.colors.textMuted,
                ),
              ),
            ),
          for (final v in existing)
            SimpleDialogOption(
              onPressed: disabled.contains(v.collection.id)
                  ? null
                  : () => Navigator.of(ctx).pop(v.collection.id),
              child: Row(
                children: [
                  Icon(
                    disabled.contains(v.collection.id)
                        ? Icons.check_rounded
                        : Icons.collections_bookmark_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(child: Text(v.collection.name)),
                ],
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(createValue),
            child: Row(
              children: [
                const Icon(Icons.add_rounded, size: 18),
                const SizedBox(width: AppDimens.space12),
                Expanded(child: Text(l10n.collectionCreate)),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null || !context.mounted) return null;
    if (chosen != createValue) return chosen;

    final name = await TextInputDialog.show(
      context,
      title: l10n.collectionCreate,
      label: l10n.collectionNameLabel,
    );
    if (name == null || name.trim().isEmpty) return null;
    final created = await repo.create(profile.id, name.trim());
    return created.id;
  }
}
