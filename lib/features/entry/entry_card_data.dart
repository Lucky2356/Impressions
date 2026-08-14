import 'package:flutter/widgets.dart';

import '../../core/domain/relation.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/entry_view.dart';
import '../../design_system/design_system.dart';

/// Запись каталога в том виде, в каком её показывает карточка.
///
/// Перевод был написан трижды — в каталоге, в ветке категорий и в подборке, —
/// и уже начал расходиться: в подборке карточки теряли отношение, потому что
/// в третьей копии эту строку забыли.
EntryCardData entryCardData(BuildContext context, EntryView entry) {
  return EntryCardData(
    title: entry.title,
    subtitle: entry.subtitle,
    categoryPath: entry.categoryPath,
    relation: Relation.byName(entry.relation),
    rating: entry.rating,
    imagePath: entry.coverPath,
    seedColor: context.colors.profileColorFor(entry.objectId),
  );
}
