import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_layout.dart';
import '../../data/db/database.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import '../quick_add/quick_add_sheet.dart';
import '../entry/entry_card_data.dart';
import 'catalog_filter_bar.dart';
import 'catalog_providers.dart';
import '../search/recent_store.dart';
import 'catalog_selection.dart';
import 'entry_tile.dart';

/// Теги активного профиля — источник для фильтра.
final profileTagsProvider = FutureProvider<List<TagRow>>((ref) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return ref.watch(entryRepositoryProvider).tagsOfProfile(profile.id);
});

/// Каталог записей (§15): режимы отображения, фильтры, сортировка, поиск.
/// Состояние режима и переключателя подкатегорий сохраняется.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  /// Развёрнута ли панель фильтров. На широком окне она открыта сразу, на
  /// телефоне прячется — иначе четыре списка занимают экран до первой записи.
  bool? _filtersExpanded;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(catalogStateProvider).search;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Поиск с задержкой, чтобы не дёргать базу на каждый символ (§29).
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(catalogStateProvider.notifier).setSearch(value);
      // Запрос попадает в недавние: часто повторяемый набирали заново.
      if (value.trim().length >= 3) {
        ref.read(recentStoreProvider.notifier).rememberSearch(value);
      }
    });
  }

  /// Добавление записи из каталога.
  ///
  /// Если включены фильтры, новая запись может под них не подойти и создаётся
  /// впечатление, что она не сохранилась. Поэтому предлагаем сбросить фильтры.
  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final added = await QuickAddSheet.show(context);
    if (!added || !mounted) return;

    if (!ref.read(catalogStateProvider).hasFilters) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.catalogAddedHiddenByFilters),
        action: SnackBarAction(
          label: l10n.catalogResetFilters,
          onPressed: () {
            _searchController.clear();
            ref.read(catalogStateProvider.notifier).reset();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(catalogStateProvider);
    final results = ref.watch(catalogResultsProvider);
    // Общее число под фильтрами, а не размер загруженной страницы.
    final count = results.value?.total;

    // На телефоне в каталог приходят по значку поиска: курсор ставим сразу,
    // иначе человек попадает сюда и снова ищет, куда нажать.
    ref.listen(
      catalogSearchFocusProvider,
      (_, _) => _searchFocus.requestFocus(),
    );

    // Строку поиска мог заполнить глобальный поиск в шапке — синхронизируем.
    if (_searchController.text != state.search &&
        (_debounce == null || !_debounce!.isActive)) {
      _searchController.text = state.search;
    }

    // Каталог держится той же колонки, что и остальные разделы: раньше он один
    // растягивался во всю ширину окна, и при переходе с главной содержимое
    // заметно «прыгало» по горизонтали на широком мониторе.
    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.navCatalog,
        subtitle: count == null ? null : l10n.catalogFound(count),
        actions: [
          FilledButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.commonAdd),
          ),
        ],
        bottom: FilterBar(
          searchController: _searchController,
          searchFocus: _searchFocus,
          onSearchChanged: _onSearchChanged,
          expanded: _filtersExpanded ?? context.layout.isWide,
          onToggleFilters: () => setState(
            () =>
                _filtersExpanded = !(_filtersExpanded ?? context.layout.isWide),
          ),
        ),
      ),
      child: results.when(
        // Заглушка повторяет выбранный вид: иначе при загрузке лента
        // подменялась бы сеткой и наоборот.
        loading: () => state.view == CatalogViewMode.grid
            ? const SkeletonGrid()
            : const SkeletonList(),
        error: (e, _) => ErrorState(error: e),
        data: (found) {
          final list = found.items;
          if (list.isEmpty) {
            final filtered = state.hasFilters;
            return EmptyState(
              icon: filtered
                  ? Icons.search_off_rounded
                  : Icons.auto_stories_rounded,
              title: filtered
                  ? l10n.catalogNothingFoundTitle
                  : l10n.catalogEmptyTitle,
              message: filtered
                  ? l10n.catalogNothingFoundMessage
                  : l10n.catalogEmptyMessage,
              action: filtered
                  ? OutlinedButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(catalogStateProvider.notifier).reset();
                      },
                      child: Text(l10n.catalogResetFilters),
                    )
                  : FilledButton.icon(
                      onPressed: () => QuickAddSheet.show(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(l10n.commonAdd),
                    ),
            );
          }
          return _CatalogShortcuts(
            entries: list,
            child: Column(
              children: [
                // Панель появляется по факту выделения, а не по его составу:
                // иначе весь экран перестраивался на каждое нажатие.
                if (ref.watch(
                  catalogSelectionProvider.select((s) => s.isNotEmpty),
                ))
                  BulkActionsBar(
                    onSelectAll: () => ref
                        .read(catalogSelectionProvider.notifier)
                        .selectAll(list.map((e) => e.entryId)),
                  ),
                Expanded(
                  child: _Results(
                    entries: list,
                    view: state.view,
                    hasMore: found.hasMore,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Каталог с клавиатурой и панелью массовых действий.
///
/// Стрелки и Enter работают через обычный обход фокуса Flutter: карточки
/// фокусируемы, поэтому отдельный обработчик нужен только для действий над
/// выделением.
class _CatalogShortcuts extends ConsumerWidget {
  const _CatalogShortcuts({required this.entries, required this.child});

  final List<EntryView> entries;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.read(catalogSelectionProvider.notifier);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyA, control: true): () =>
            selection.selectAll(entries.map((e) => e.entryId)),
        const SingleActivator(LogicalKeyboardKey.escape): selection.clear,
      },
      child: Focus(child: child),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.entries,
    required this.view,
    required this.hasMore,
  });

  final List<EntryView> entries;
  final CatalogViewMode view;

  /// Есть ли что подгружать дальше.
  final bool hasMore;

  /// Подгружает следующую страницу, когда до конца списка осталось немного.
  bool _onScroll(ScrollNotification n, WidgetRef ref) {
    if (!hasMore) return false;
    final metrics = n.metrics;
    if (metrics.pixels >= metrics.maxScrollExtent - 600) {
      ref.read(catalogFeedProvider.notifier).more();
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = context.layout;
    // Списку хватает знать, что выделение вообще есть: сами отметки карточки
    // читают по одной, иначе каждое нажатие перестраивало бы всю страницу.
    final selectionActive = ref.watch(
      catalogSelectionProvider.select((s) => s.isNotEmpty),
    );
    // Порядок, в котором записи показаны: по нему Shift+клик берёт диапазон.
    final order = [for (final e in entries) e.entryId];

    if (view == CatalogViewMode.list) {
      return NotificationListener<ScrollNotification>(
        onNotification: (n) => _onScroll(n, ref),
        child: ListView.separated(
          // Разделы живут в `KeyedSubtree` и при переключении уничтожаются:
          // без своего ключа в хранилище страницы каталог возвращался в
          // начало, и подгруженное приходилось докручивать заново.
          key: const PageStorageKey('catalog-list'),
          padding: EdgeInsets.fromLTRB(
            layout.gutter,
            AppDimens.space16,
            layout.gutter,
            AppDimens.space40,
          ),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppDimens.space8),
          itemBuilder: (context, i) => Appear(
            index: i,
            child: EntryTile(
              entry: entries[i],
              selectionActive: selectionActive,
              order: order,
              builder: (onTap) => EntryCardCompact(
                data: entryCardData(context, entries[i]),
                onTap: onTap,
              ),
            ),
          ),
        ),
      );
    }

    final dense = view == CatalogViewMode.compact;
    // Ширина ячейки берётся из раскладки: на 4K помещается заметно больше
    // карточек, а не растягиваются те же самые.
    final tile = dense ? layout.gridTileWidth * 0.78 : layout.gridTileWidth;

    return LayoutBuilder(
      builder: (context, cns) {
        final cols = layout.columnsFor(cns.maxWidth, tileWidth: tile);
        return NotificationListener<ScrollNotification>(
          onNotification: (n) => _onScroll(n, ref),
          child: GridView.builder(
            key: const PageStorageKey('catalog-grid'),
            padding: EdgeInsets.fromLTRB(
              layout.gutter,
              AppDimens.space16,
              layout.gutter,
              AppDimens.space40,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: AppDimens.space12,
              crossAxisSpacing: AppDimens.space12,
              childAspectRatio: entryCardAspectRatio(
                availableWidth: cns.maxWidth,
                columns: cols,
                outerPadding: layout.gutter * 2,
                dense: dense,
                textScale: MediaQuery.textScalerOf(context).scale(1),
              ),
            ),
            itemCount: entries.length,
            itemBuilder: (context, i) => Appear(
              index: i,
              child: EntryTile(
                entry: entries[i],
                selectionActive: selectionActive,
                order: order,
                builder: (onTap) => EntryCard(
                  dense: dense,
                  data: entryCardData(context, entries[i]),
                  onTap: onTap,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
