import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Формат даты на языке интерфейса.
///
/// Язык берётся из окружения виджета, а не задаётся жёстко: в английском
/// интерфейсе «12 августа 2026» стояло бы посреди английского текста.
/// Числовые форматы вроде `dd.MM.yyyy` в этом не нуждаются — там нет слов.
DateFormat localeDate(BuildContext context, String pattern) =>
    DateFormat(pattern, Localizations.localeOf(context).languageCode);
