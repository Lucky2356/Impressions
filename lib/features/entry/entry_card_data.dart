import 'package:flutter/widgets.dart';

import '../../core/domain/relation.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../design_system/design_system.dart';

/// Запись каталога в том виде, в каком её показывает карточка.
///
/// Перевод был написан трижды — в каталоге, в ветке категорий и в подборке, —
/// и уже начал расходиться: в подборке карточки теряли отношение, потому что
/// в третьей копии эту строку забыли.
EntryCardData entryCardData(
  BuildContext context,
  EntryView entry, {
  bool hero = false,
}) {
  return EntryCardData(
    title: entry.title,
    subtitle: entry.subtitle,
    categoryPath: entry.categoryPath,
    relation: Relation.byName(entry.relation),
    rating: entry.rating,
    statusLabel: entryStatusText(context, entry),
    imagePath: entry.coverPath,
    seedColor: context.colors.profileColorFor(entry.objectId),
    // Метку просит сам экран: она обязана быть единственной, а на главной
    // одна и та же запись встречается в двух блоках сразу.
    heroTag: hero ? entryHeroTag(entry.entryId) : null,
    visitCount: entry.visitCount,
  );
}

/// Метка перелёта обложки для записи.
///
/// В одном месте, потому что её задают на карточке в списке, а принимают в
/// карточке записи — разойдись они, перелёта просто не будет, и понять почему
/// будет неоткуда.
String entryHeroTag(String entryId) => 'entry-cover-$entryId';

/// Стадия записи вместе с прогрессом одной строкой: «Читаю · 3 страница из 320».
///
/// Прогресс без стадии бессмыслен, а стадия без прогресса — обычное дело,
/// поэтому склеиваются они здесь, а не в двух местах на карточке.
String? entryStatusText(BuildContext context, EntryView entry) {
  final l10n = AppLocalizations.of(context);
  final unit = entry.progressUnit;
  final current = entry.progressCurrent;
  final total = entry.progressTotal;

  final progress = (unit == null || unit.isEmpty || current == null)
      ? null
      : (total == null
            ? l10n.progressCurrentOnly(current, unit)
            : l10n.progressOf(current, unit, total));

  final parts = [?entry.statusLabel, ?progress];
  return parts.isEmpty ? null : parts.join(' · ');
}
