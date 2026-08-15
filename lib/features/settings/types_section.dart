import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import 'fields_editor.dart';
import 'statuses_editor.dart';

/// Типы объектов активного профиля, включая скрытые.
final allObjectTypesProvider = FutureProvider<List<ObjectTypeRow>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.objectTypes)
        ..where((t) => t.profileId.equals(profile.id))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .get();
});

/// Управление типами объектов (§8): переименование, иконка, скрытие, создание.
/// Встроенные типы — такие же редактируемые сущности, как пользовательские.
class TypesSection extends ConsumerWidget {
  const TypesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final types = ref.watch(allObjectTypesProvider).value ?? const [];

    Future<void> bump() async => ref.read(dataRefreshProvider.notifier).bump();

    Future<void> rename(ObjectTypeRow type) async {
      final name = await TextInputDialog.show(
        context,
        title: l10n.typeRename,
        label: l10n.typeNameLabel,
        initial: type.name,
      );
      if (name == null) return;
      final db = ref.read(appDatabaseProvider);
      await (db.update(db.objectTypes)..where((t) => t.id.equals(type.id)))
          .write(ObjectTypesCompanion(name: Value(name)));
      await bump();
    }

    Future<void> toggleHidden(ObjectTypeRow type) async {
      final db = ref.read(appDatabaseProvider);
      await (db.update(db.objectTypes)..where((t) => t.id.equals(type.id)))
          .write(ObjectTypesCompanion(hidden: Value(!type.hidden)));
      await bump();
    }

    Future<void> pickIcon(ObjectTypeRow type) async {
      final chosen = await showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(l10n.typeIcon),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
              ),
              child: Wrap(
                spacing: AppDimens.space8,
                runSpacing: AppDimens.space8,
                children: [
                  for (final key in AppIcons.allKeys)
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(key),
                      icon: Icon(AppIcons.byKey(key)),
                      isSelected: key == type.icon,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
      if (chosen == null) return;
      final db = ref.read(appDatabaseProvider);
      await (db.update(db.objectTypes)..where((t) => t.id.equals(type.id)))
          .write(ObjectTypesCompanion(icon: Value(chosen)));
      await bump();
    }

    Future<void> create() async {
      final profile = ref.read(activeProfileProvider);
      if (profile == null) return;
      final name = await TextInputDialog.show(
        context,
        title: l10n.typeCreate,
        label: l10n.typeNameLabel,
        confirmLabel: l10n.commonCreate,
      );
      if (name == null) return;
      await ref
          .read(entryRepositoryProvider)
          .createObjectType(profile.id, name, sortOrder: types.length);
      await bump();
    }

    return SettingsGroup(
      title: l10n.typesTitle,
      trailing: TextButton.icon(
        onPressed: create,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(l10n.typeCreate),
      ),
      children: [
        if (types.isEmpty)
          Text(
            l10n.typeEmpty,
            style: context.text.bodySmall?.copyWith(color: c.textMuted),
          )
        else
          for (var i = 0; i < types.length; i++) ...[
            Row(
              children: [
                IconButton(
                  tooltip: l10n.typeIcon,
                  onPressed: () => pickIcon(types[i]),
                  icon: Icon(
                    AppIcons.byKey(types[i].icon),
                    size: 20,
                    color: types[i].hidden ? c.textMuted : c.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    types[i].name,
                    style: context.text.bodyMedium?.copyWith(
                      color: types[i].hidden ? c.textMuted : c.textPrimary,
                    ),
                  ),
                ),
                if (types[i].hidden)
                  Padding(
                    padding: const EdgeInsets.only(right: AppDimens.space8),
                    child: Text(
                      l10n.typeHidden,
                      style: context.text.labelSmall?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ),
                AppIconButton(
                  icon: Icons.edit_rounded,
                  tooltip: l10n.typeRename,
                  onPressed: () => rename(types[i]),
                ),
                AppIconButton(
                  icon: Icons.list_alt_rounded,
                  tooltip: l10n.fieldsTitle,
                  onPressed: () => FieldsEditor.show(context, types[i]),
                ),
                AppIconButton(
                  icon: Icons.timeline_rounded,
                  tooltip: l10n.statusesTitle,
                  onPressed: () => StatusesEditor.show(context, types[i]),
                ),
                AppIconButton(
                  icon: types[i].hidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  tooltip: types[i].hidden ? l10n.typeShow : l10n.typeHide,
                  onPressed: () => toggleHidden(types[i]),
                ),
              ],
            ),
            if (i != types.length - 1)
              Divider(height: AppDimens.space8, color: c.divider),
          ],
      ],
    );
  }
}
