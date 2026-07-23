import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../categories/category_providers.dart';

/// Результат выбора категории: либо выбранная категория, либо явный сброс.
class CategoryPickResult {
  const CategoryPickResult(this.category, {this.cleared = false});
  final CategoryRow? category;
  final bool cleared;
}

/// Выбор категории из дерева профиля с быстрым поиском (§11).
class CategoryPicker extends ConsumerStatefulWidget {
  const CategoryPicker({super.key});

  static Future<CategoryPickResult?> show(BuildContext context) {
    return showDialog<CategoryPickResult>(
      context: context,
      builder: (_) => const Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(width: 480, height: 560, child: CategoryPicker()),
      ),
    );
  }

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final categories = ref.watch(allCategoriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimens.space16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.quickAddPickCategory,
                  style: context.text.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.quickAddSearchCategory,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
            ),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        const SizedBox(height: AppDimens.space8),
        ListTile(
          leading: Icon(Icons.block_rounded, color: c.textMuted),
          title: Text(l10n.quickAddNoCategory),
          onTap: () => Navigator.of(
            context,
          ).pop(const CategoryPickResult(null, cleared: true)),
        ),
        Divider(height: 1, color: c.divider),
        Expanded(
          child: categories.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) {
              final byId = {for (final cat in list) cat.id: cat};
              final filtered = _query.isEmpty
                  ? list
                  : list
                        .where((cat) => cat.normalizedName.contains(_query))
                        .toList();
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    l10n.commonNothingFound,
                    style: context.text.bodyMedium?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final cat = filtered[i];
                  final pathNames = [
                    for (final id in cat.path.split('/'))
                      if (byId[id] != null) byId[id]!.name,
                  ];
                  return ListTile(
                    leading: Icon(
                      AppIcons.byKey(cat.icon),
                      color: c.textSecondary,
                      size: 20,
                    ),
                    title: Text(cat.name),
                    subtitle: pathNames.length > 1
                        ? Text(
                            pathNames
                                .sublist(0, pathNames.length - 1)
                                .join(' / '),
                          )
                        : null,
                    contentPadding: EdgeInsets.only(
                      left: AppDimens.space16 + cat.level * 16.0,
                      right: AppDimens.space16,
                    ),
                    onTap: () =>
                        Navigator.of(context).pop(CategoryPickResult(cat)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
