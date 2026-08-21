import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/normalize.dart';
import '../../data/db/database.dart';
import '../../design_system/design_system.dart';
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
/// категорию, всё равно приходилось идти руками. Здесь ищутся разделы и
/// категории профиля, а на пустом поле сверху стоят недавние запросы.
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
  final _scroll = ScrollController();

  /// Куда указывают стрелки. Палитру открывают с клавиатуры, а водила по ней
  /// до 1.21.0 только мышь.
  int _selected = 0;

  /// Строка, до которой надо долистать после ближайшей отрисовки.
  final _selectedKey = GlobalKey();

  @override
  void dispose() {
    _query.dispose();
    _scroll.dispose();
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

  void _search(String query) {
    ref.read(catalogStateProvider.notifier)
      ..reset()
      ..setSearch(query);
    _go(NavIds.catalog);
  }

  /// Всё, что палитра умеет предложить под запрос, одним списком.
  ///
  /// Недавние запросы — такие же строки, как остальные: иначе выделение
  /// стрелками пришлось бы вести по двум спискам сразу.
  List<PaletteItem> _items(AppLocalizations l10n, String query) {
    final normalized = Normalize.forMatch(query);
    final items = <PaletteItem>[];

    // Недавнее — подсказка, а не результат: показываем только на пустом поле.
    if (normalized.isEmpty) {
      final recent = ref.watch(recentStoreProvider).value?.searches ?? const [];
      for (final text in recent.take(5)) {
        items.add(
          PaletteItem(
            group: l10n.recentSearches,
            label: text,
            icon: Icons.history_rounded,
            run: () => _search(text),
          ),
        );
      }
    }

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

  void _move(int delta, int count) {
    if (count == 0) return;
    setState(() => _selected = (_selected + delta) % count);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _selectedKey.currentContext;
      if (box != null) Scrollable.ensureVisible(box, alignment: 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final items = _items(l10n, _query.text);
    if (_selected >= items.length) _selected = 0;

    // Строки собираются построителем: палитра знает все разделы и все
    // категории профиля, и раньше каждая из них становилась виджетом на
    // каждый набранный символ — при том что на экране их помещается десяток.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _move(1, items.length),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _move(-1, items.length),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.space16),
            child: AppSearchField(
              controller: _query,
              autofocus: true,
              hint: l10n.commandPaletteHint,
              onChanged: (_) => setState(() => _selected = 0),
              onSubmitted: (_) {
                if (_selected < items.length) items[_selected].run();
              },
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: l10n.commonNothingFound,
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.space8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final selected = i == _selected;
                      final newGroup =
                          i == 0 || items[i - 1].group != item.group;
                      return Column(
                        key: selected ? _selectedKey : null,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (newGroup)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppDimens.space16,
                                AppDimens.space8,
                                AppDimens.space16,
                                AppDimens.space4,
                              ),
                              child: Text(
                                item.group,
                                style: context.text.labelSmall?.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ),
                          ListTile(
                            dense: true,
                            selected: selected,
                            selectedTileColor: c.navActiveBg,
                            leading: Icon(item.icon, size: 18),
                            title: Text(item.label),
                            onTap: item.run,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
