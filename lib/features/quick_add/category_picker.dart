import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/app_icons.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/db/database.dart';
import '../../design_system/design_system.dart';
import '../categories/category_providers.dart';

/// Результат выбора категории: либо выбранная категория, либо явный сброс.
class CategoryPickResult {
  const CategoryPickResult(this.category, {this.cleared = false});
  final CategoryRow? category;
  final bool cleared;
}

/// Выбор категории из дерева профиля с быстрым поиском (§11).
class CategoryPicker extends ConsumerStatefulWidget {
  const CategoryPicker({
    super.key,
    this.title,
    this.allowClear = true,
    this.excludeIds = const {},
  });

  /// Заголовок. По умолчанию — «Выбрать категорию».
  final String? title;

  /// Показывать ли «Без категории». При выборе цели переноса выбирать нечего:
  /// перенести «в никуда» нельзя.
  final bool allowClear;

  /// Что не предлагать: например саму ветку и её потомков при объединении.
  final Set<String> excludeIds;

  static Future<CategoryPickResult?> show(
    BuildContext context, {
    String? title,
    bool allowClear = true,
    Set<String> excludeIds = const {},
  }) {
    return showDialog<CategoryPickResult>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 480,
          height: 560,
          child: CategoryPicker(
            title: title,
            allowClear: allowClear,
            excludeIds: excludeIds,
          ),
        ),
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
                  widget.title ?? l10n.quickAddPickCategory,
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
        if (widget.allowClear)
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
            loading: () => const SkeletonList(count: 5),
            error: (e, _) => ErrorState(error: e),
            data: (list) {
              final byId = {for (final cat in list) cat.id: cat};
              final allowed = widget.excludeIds.isEmpty
                  ? list
                  : [
                      for (final cat in list)
                        if (!widget.excludeIds.contains(cat.id)) cat,
                    ];
              final filtered = _query.isEmpty
                  ? allowed
                  : [
                      for (final cat in allowed)
                        if (cat.normalizedName.contains(_query)) cat,
                    ];
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
