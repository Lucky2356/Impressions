import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/app_colors.dart';

/// Отношение профиля к объекту (§10).
///
/// Отвечает только на вопрос «понравилось ли». «Хочу попробовать» жило здесь
/// же и отвечало на другой — «дошли ли вы до этого», — из-за чего запись не
/// могла быть одновременно начатой и без мнения. Это переехало в стадию
/// (`EntryStatus`), а у запланированной записи отношения просто нет.
///
/// Внутренние значения английские, интерфейс — русский (метки берутся из l10n).
enum Relation {
  love,
  like,
  neutral,
  dislike,
  avoid;

  /// Отношение по его записанному в базе имени; null — не задано или чужое.
  ///
  /// В базе лежит строка, а экранам нужен разбор — и каждый писал его сам.
  static Relation? byName(String? name) {
    if (name == null) return null;
    for (final relation in values) {
      if (relation.name == name) return relation;
    }
    return null;
  }

  /// Локализованная метка.
  String label(AppLocalizations l10n) => switch (this) {
    Relation.love => l10n.relationLove,
    Relation.like => l10n.relationLike,
    Relation.neutral => l10n.relationNeutral,
    Relation.dislike => l10n.relationDislike,
    Relation.avoid => l10n.relationAvoid,
  };

  /// Акцентный цвет отношения (не единственный носитель смысла — §30: рядом
  /// всегда есть текстовая метка и иконка).
  Color accent(AppColors c) => switch (this) {
    Relation.love => c.coral,
    Relation.like => c.sage,
    Relation.neutral => c.textMuted,
    Relation.dislike => c.sand,
    Relation.avoid => c.lavender,
  };

  IconData get icon => switch (this) {
    Relation.love => Icons.favorite_rounded,
    Relation.like => Icons.thumb_up_alt_rounded,
    Relation.neutral => Icons.remove_rounded,
    Relation.dislike => Icons.thumb_down_alt_rounded,
    Relation.avoid => Icons.block_rounded,
  };
}
