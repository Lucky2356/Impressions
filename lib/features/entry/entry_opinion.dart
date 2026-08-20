import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/data_refresh.dart';
import '../../core/domain/entry_status.dart';
import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/dates.dart';
import '../../data/providers.dart';
import '../../design_system/design_system.dart';
import 'entry_providers.dart';
import 'status_field.dart';

/// То, ради чего карточку открывают: стадия, отношение, оценка, дата, заметка.
///
/// Одной карточкой, а не шестью блоками через черту. Раньше эти поля стояли
/// вперемешку со служебным — приватностью, тегами, историей версий, — и всё
/// было одного веса: чтобы поставить оценку, приходилось искать её глазами
/// среди прочего.
///
/// Виджет сам владеет полями ввода и сам пишет правки: раньше этим занималась
/// карточка целиком, и половина её кода была про сохранение заметки.
class EntryOpinionCard extends ConsumerStatefulWidget {
  const EntryOpinionCard({
    super.key,
    required this.detail,
    required this.editable,
  });

  final EntryDetail detail;

  /// Чужую запись править нельзя: мнение принадлежит её автору (§6.2).
  final bool editable;

  @override
  ConsumerState<EntryOpinionCard> createState() => EntryOpinionCardState();
}

class EntryOpinionCardState extends ConsumerState<EntryOpinionCard> {
  final _note = TextEditingController();
  final _noteFocus = FocusNode();

  /// Текст заметки, который уже лежит в базе.
  ///
  /// Заметка сохранялась только по кнопке: закрыли карточку крестиком, свайпом
  /// вниз или нажатием мимо — набранное пропадало молча. Отношение, оценка и
  /// дата рядом сохраняются сразу, поэтому и ожидание было такое же.
  String _savedNote = '';
  bool _noteInitialised = false;

  /// Прогресс: сколько пройдено и сколько всего.
  ///
  /// Записывается не на каждую цифру, а когда курсор ушёл из полей: иначе
  /// «12» из «120» успело бы стать отдельной версией записи (§18), и история
  /// заросла бы промежуточными числами.
  final _progressCurrent = TextEditingController();
  final _progressTotal = TextEditingController();
  final _progressFocus = FocusNode();
  bool _progressInitialised = false;
  String _savedProgress = '';

  String get _entryId => widget.detail.entry.id;

  @override
  void initState() {
    super.initState();
    _noteFocus.addListener(() {
      if (!_noteFocus.hasFocus) saveIfChanged();
    });
    _progressFocus.addListener(() {
      if (!_progressFocus.hasFocus) _saveProgressIfChanged();
    });
  }

  @override
  void didUpdateWidget(EntryOpinionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Запись могли откатить к прежней версии — тогда заметка и прогресс в базе
    // изменились не нами, и поля обязаны показать новое. Пока в поле лежит
    // несохранённое, не трогаем: это набранное человеком.
    final note = widget.detail.entry.detailedNote ?? '';
    if (note != _savedNote && _note.text.trim() == _savedNote.trim()) {
      _note.text = note;
      _savedNote = note;
    }

    final entry = widget.detail.entry;
    final progress =
        '${entry.progressCurrent ?? ''}/${entry.progressTotal ?? ''}';
    if (progress != _savedProgress && _progressKey() == _savedProgress) {
      _progressCurrent.text = entry.progressCurrent?.toString() ?? '';
      _progressTotal.text = entry.progressTotal?.toString() ?? '';
      _savedProgress = _progressKey();
    }
  }

  @override
  void dispose() {
    _noteFocus.dispose();
    _note.dispose();
    _progressFocus.dispose();
    _progressCurrent.dispose();
    _progressTotal.dispose();
    super.dispose();
  }

  void _bump() => ref.read(dataRefreshProvider.notifier).bump();

  /// Дописывает набранное, если его меняли.
  ///
  /// Карточку закрывают четырьмя способами, и все они снимают маршрут, поэтому
  /// зовётся это из [PopScope] карточки. Без сравнения с сохранённым каждое
  /// закрытие заводило бы новую версию записи (§18).
  void saveIfChanged() {
    _saveNoteIfChanged();
    _saveProgressIfChanged();
  }

  void _saveNoteIfChanged() {
    if (!_noteInitialised) return;
    if (_note.text.trim() == _savedNote.trim()) return;
    _saveNote();
  }

  Future<void> _saveNote() async {
    final text = _note.text.trim();
    _savedNote = text;
    // Репозиторий берём до `await`: карточку могли уже закрыть, и после
    // ожидания `ref` обращаться некуда.
    final repo = ref.read(entryRepositoryProvider);
    await repo.updateEntry(_entryId, detailedNote: text.isEmpty ? null : text);
    if (mounted) _bump();
  }

  String _progressKey() => '${_progressCurrent.text}/${_progressTotal.text}';

  void _saveProgressIfChanged() {
    if (!_progressInitialised) return;
    if (_progressKey() == _savedProgress) return;
    _savedProgress = _progressKey();

    ref
        .read(entryRepositoryProvider)
        .updateEntry(
          _entryId,
          progressCurrent: progressValueOf(_progressCurrent),
          progressTotal: progressValueOf(_progressTotal),
        )
        .then((_) {
          if (mounted) _bump();
        });
  }

  Future<void> _setRelation(Relation? r) async {
    await ref
        .read(entryRepositoryProvider)
        .updateEntry(_entryId, relation: r?.name);
    _bump();
  }

  Future<void> _setStatus(String? key) async {
    await ref.read(entryRepositoryProvider).updateEntry(_entryId, status: key);
    _bump();
  }

  Future<void> _setRating(double? value) async {
    await ref
        .read(entryRepositoryProvider)
        .updateEntry(_entryId, rating: value);
    _bump();
  }

  Future<void> _setImpressionDate(DateTime? date) async {
    await ref
        .read(entryRepositoryProvider)
        .updateEntry(
          _entryId,
          impressionDate: date,
          clearImpressionDate: date == null,
        );
    _bump();
  }

  Future<void> _pickImpressionDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.detail.entry.impressionDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: now,
    );
    if (picked == null) return;
    await _setImpressionDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final entry = widget.detail.entry;
    final editable = widget.editable;

    if (!_noteInitialised) {
      _note.text = entry.detailedNote ?? '';
      _savedNote = _note.text;
      _noteInitialised = true;
    }
    if (!_progressInitialised) {
      _progressCurrent.text = entry.progressCurrent?.toString() ?? '';
      _progressTotal.text = entry.progressTotal?.toString() ?? '';
      _savedProgress = _progressKey();
      _progressInitialised = true;
    }

    final statuses = EntryStatus.decode(widget.detail.type.statusesJson);
    final relation = Relation.byName(entry.relation);

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Стадия идёт перед отношением: сначала «дошли ли вы до этого»,
          // потом «понравилось ли».
          StatusField(
            statuses: statuses,
            value: entry.status,
            onChanged: editable ? _setStatus : null,
            showEmptyHint: editable,
          ),
          if (statuses.isNotEmpty) const SizedBox(height: AppDimens.space20),
          if (widget.detail.type.progressUnit case final unit?) ...[
            Focus(
              focusNode: _progressFocus,
              child: ProgressField(
                unit: unit,
                current: _progressCurrent,
                total: _progressTotal,
                enabled: editable,
                onEditingComplete: _saveProgressIfChanged,
              ),
            ),
            const SizedBox(height: AppDimens.space20),
          ],

          _Label(text: l10n.quickAddRelationLabel),
          const SizedBox(height: AppDimens.space8),
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: [
              for (final r in Relation.values)
                ChoiceChip(
                  selected: relation == r,
                  onSelected: editable
                      ? (s) => _setRelation(s ? r : null)
                      : null,
                  avatar: Icon(
                    r.icon,
                    size: 16,
                    color: relation == r ? r.accent(c) : c.textSecondary,
                  ),
                  label: Text(r.label(l10n)),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space20),

          Row(
            children: [
              _Label(text: l10n.quickAddRatingLabel),
              const Spacer(),
              RatingView(value: entry.rating, compact: true),
              if (entry.rating != null && editable)
                AppIconButton(
                  icon: Icons.close_rounded,
                  tooltip: l10n.quickAddRatingNone,
                  onPressed: () => _setRating(null),
                ),
            ],
          ),
          Slider(
            value: entry.rating ?? 0,
            min: 0,
            max: 10,
            divisions: 20,
            label: (entry.rating ?? 0).toStringAsFixed(1),
            onChanged: editable ? _setRating : null,
          ),
          const SizedBox(height: AppDimens.space8),

          // Дата впечатления (§10): по ней сортируется каталог. Подпись
          // сверху, как у стадии, отношения и оценки: в одну строку с
          // «1 августа 2026 г.» она не помещается в ширину телефона.
          _Label(text: l10n.entryImpressionDate),
          Row(
            children: [
              Flexible(
                child: TextButton(
                  onPressed: editable ? _pickImpressionDate : null,
                  child: Text(
                    entry.impressionDate == null
                        ? l10n.entryImpressionDateNone
                        : localeDate(
                            context,
                            'd MMMM y',
                          ).format(entry.impressionDate!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (entry.impressionDate != null && editable)
                AppIconButton(
                  icon: Icons.close_rounded,
                  tooltip: l10n.entryImpressionDateClear,
                  onPressed: () => _setImpressionDate(null),
                ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppDimens.space16),

          TextField(
            controller: _note,
            focusNode: _noteFocus,
            minLines: 3,
            maxLines: 8,
            readOnly: !editable,
            decoration: InputDecoration(labelText: l10n.entryNoteLabel),
            onEditingComplete: _saveNote,
          ),
        ],
      ),
    );
  }
}

/// Подпись поля — одинаковая у стадии, отношения, оценки и даты.
class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.text.labelSmall?.copyWith(
      color: context.colors.textSecondary,
    ),
  );
}
