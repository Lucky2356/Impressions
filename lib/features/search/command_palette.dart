import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/normalize.dart';
import '../../data/db/database.dart';
import '../categories/category_providers.dart';
import '../catalog/catalog_providers.dart';
import 'recent_store.dart';

/// Что делает строка палитры.
class PaletteItem {
  const PaletteItem({
    required this.group,
    required this.label,
    required this.icon,
    required this.run,
  });

  final String group;
  final String label;
  final IconData icon;
  final VoidCallback run;
}

/// Палитра команд: одно поле вместо восьми горячих клавиш.
///
/// Сочетания были фиксированными и вели каждое в своё место; чтобы попасть в
/// категорию или к записи, всё равно приходилось идти руками. Здесь ищутся
/// разделы, категории, записи и действия сразу.
class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(width: 640, height: 520, child: CommandPalette()),
      ),
    );
  }

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _go(String sectionId) {
    ref.read(navProvider.notifier).go(sectionId);
    Navigator.of(context).pop();
  }

  void _openCategory(String categoryId) {
    ref.read(catalogStateProvider.notifier)
      ..reset()
      ..setCategory(categoryId);
    _go(NavIds.catalog);
  }

  /// Всё, что палитра умеет предложить под запрос.
  List<PaletteItem> _items(AppLocalizations l10n, String query) {
    final normalized = Normalize.forMatch(query);
    final items = <PaletteItem>[];

    for (final id in NavIds.all) {
      items.add(
        PaletteItem(
          group: l10n.commandPaletteSections,
          label: navTitle(l10n, id),
          icon: navIcon(id),
          run: () => _go(id),
        ),
      );
    }

    // Категории: перейти в ветку — самое частое, ради чего лезут в дерево.
    final categories =
        ref.read(allCategoriesProvider).value ?? const <CategoryRow>[];
    for (final category in categories) {
      items.add(
        PaletteItem(
          group: l10n.commandPaletteCategories,
          label: category.name,
          icon: Icons.account_tree_rounded,
          run: () => _openCategory(category.id),
        ),
      );
    }

    if (normalized.isEmpty) return items;
    return [
      for (final item in items)
        if (Normalize.forMatch(item.label).contains(normalized)) item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final items = _items(l10n, _query.text);
    final recent = ref.watch(recentStoreProvider).value?.searches ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimens.space16),
          child: TextField(
            controller: _query,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.commandPaletteHint,
              prefixIcon: const Icon(Icons.bolt_rounded),
            ),
          ),
        ),
        Divider(height: 1, color: c.border),
        Expanded(
          child: items.isEmpty && recent.isEmpty
              ? Center(
                  child: Text(
                    l10n.commonNothingFound,
                    style: context.text.bodyMedium?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.space8,
                  ),
                  children: [
                    // Недавние запросы — сверху и только на пустом поле: они
                    // подсказка, а не результат.
                    if (_query.text.isEmpty && recent.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.space16,
                          AppDimens.space8,
                          AppDimens.space16,
                          AppDimens.space4,
                        ),
                        child: Text(
                          l10n.recentSearches,
                          style: context.text.labelSmall?.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ),
                      for (final query in recent.take(5))
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.history_rounded, size: 18),
                          title: Text(query),
                          onTap: () {
                            ref.read(catalogStateProvider.notifier)
                              ..reset()
                              ..setSearch(query);
                            _go(NavIds.catalog);
                          },
                        ),
                      Divider(height: 1, color: c.border),
                    ],
                    for (final item in items)
                      ListTile(
                        dense: true,
                        leading: Icon(item.icon, size: 18),
                        title: Text(item.label),
                        subtitle: Text(
                          item.group,
                          style: context.text.labelSmall?.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                        onTap: item.run,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
