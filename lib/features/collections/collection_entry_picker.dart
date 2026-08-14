import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';

/// Выбор записей для подборки (§27).
///
/// Раньше запись можно было положить в подборку только из её карточки, поэтому
/// пустая подборка выглядела бесполезной: открыв её, добавить было нечего.
/// Здесь список всех записей профиля с отметками — набирается сразу пачкой.
class CollectionEntryPicker extends ConsumerStatefulWidget {
  const CollectionEntryPicker({super.key, required this.collectionId});

  final String collectionId;

  /// Возвращает true, если состав подборки изменился.
  static Future<bool> show(BuildContext context, String collectionId) async {
    final wide =
        MediaQuery.sizeOf(context).width >= AppDimens.breakpointExpanded;
    final result = wide
        ? await showDialog<bool>(
            context: context,
            builder: (_) => Dialog(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 560,
                height: 620,
                child: CollectionEntryPicker(collectionId: collectionId),
              ),
            ),
          )
        : await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => CollectionEntryPicker(collectionId: collectionId),
          );
    return result ?? false;
  }

  @override
  ConsumerState<CollectionEntryPicker> createState() =>
      _CollectionEntryPickerState();
}

class _CollectionEntryPickerState extends ConsumerState<CollectionEntryPicker> {
  final _search = TextEditingController();
  String _query = '';
  Timer? _debounce;

  /// Поиск с задержкой: отбор идёт в базе, и дёргать её на каждый символ
  /// незачем — так же, как в каталоге.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value);
    });
  }

  /// Записи, отмеченные в этом сеансе; изначально — уже входящие в подборку.
  Set<String>? _selected;
  Set<String> _initial = const {};
  bool _busy = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final selected = _selected;
    if (selected == null) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(collectionRepositoryProvider);
      await repo.addEntries(
        widget.collectionId,
        selected.difference(_initial).toList(),
      );
      await repo.removeEntries(
        widget.collectionId,
        _initial.difference(selected).toList(),
      );
      ref.read(dataRefreshProvider.notifier).bump();
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final profile = ref.watch(activeProfileProvider);
    final found = ref.watch(_pickerEntriesProvider(_query));
    final current = ref.watch(
      _entriesInCollectionProvider(widget.collectionId),
    );

    // Первая загрузка задаёт исходный набор отметок.
    final currentIds = current.value;
    if (_selected == null && currentIds != null) {
      _initial = currentIds;
      _selected = {...currentIds};
    }
    final selected = _selected ?? const <String>{};

    final entries = found.value ?? const <EntryView>[];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space20,
                AppDimens.space20,
                AppDimens.space12,
                AppDimens.space12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.collectionPickTitle,
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space20,
              ),
              child: AppSearchField(
                hint: l10n.catalogSearchHint,
                controller: _search,
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: AppDimens.space12),
            Divider(height: 1, color: c.divider),
            Flexible(
              child: profile == null || entries.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppDimens.space32),
                      child: Text(
                        l10n.collectionPickEmpty,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.space8,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (context, i) {
                        final e = entries[i];
                        final checked = selected.contains(e.entryId);
                        return CheckboxListTile(
                          value: checked,
                          onChanged: (v) => setState(() {
                            final next = {...selected};
                            if (v ?? false) {
                              next.add(e.entryId);
                            } else {
                              next.remove(e.entryId);
                            }
                            _selected = next;
                          }),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            e.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyLarge,
                          ),
                          subtitle: e.categoryPath.isEmpty
                              ? null
                              : Text(
                                  e.categoryPath.join(' / '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.labelSmall?.copyWith(
                                    color: c.textMuted,
                                  ),
                                ),
                        );
                      },
                    ),
            ),
            Divider(height: 1, color: c.divider),
            Padding(
              padding: const EdgeInsets.all(AppDimens.space20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.collectionPickSelected(selected.length),
                      style: context.text.labelSmall?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Сколько записей показывать в списке выбора.
///
/// Дальше двухсот отметок глазами всё равно не наберёшь — там ищут по
/// названию. Отметки, поставленные раньше, от сужения списка не теряются:
/// снимается только то, что человек снял руками.
const int _pickerLimit = 200;

/// Записи, подходящие под запрос, — источник для выбора.
///
/// Раньше сюда поднимался весь профиль с обложками: чтобы поставить одну
/// галочку, приложение читало все записи. Отбор и предел теперь в базе, а
/// значит, и поиск идёт по тем же правилам, что в каталоге, — по началу слова
/// в названии, авторе и заметках.
final _pickerEntriesProvider = FutureProvider.family<List<EntryView>, String>((
  ref,
  query,
) async {
  ref.watch(dataRefreshProvider);
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];

  final page = await ref
      .watch(entryRepositoryProvider)
      .entryPage(
        profile.id,
        search: query.trim().isEmpty ? null : query,
        limit: _pickerLimit,
      );
  return page.items;
});

/// Идентификаторы записей, уже входящих в подборку.
final _entriesInCollectionProvider = FutureProvider.family<Set<String>, String>(
  (ref, collectionId) async {
    ref.watch(dataRefreshProvider);
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return const {};
    final entries = ref.watch(entryRepositoryProvider);
    final list = await ref
        .watch(collectionRepositoryProvider)
        .entriesOf(
          collectionId,
          profile.id,
          entriesLoader: (ids) => entries.entryViews(profile.id, entryIds: ids),
        );
    return list.map((e) => e.entryId).toSet();
  },
);
