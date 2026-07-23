import '../l10n/gen/app_localizations.dart';

/// Сочетание клавиш и что оно делает.
typedef Hotkey = ({String keys, String label});

/// Горячие клавиши приложения (§4.1) — единый список.
///
/// Раньше он был записан дважды: в справке и в настройках. Списки разошлись,
/// и в настройках не хватало добавленных позже сочетаний.
List<Hotkey> appHotkeys(AppLocalizations l10n) => [
  (keys: 'Ctrl + N', label: l10n.hotkeyNewEntry),
  (keys: 'Ctrl + B', label: l10n.hotkeyScan),
  (keys: 'Ctrl + F', label: l10n.hotkeySearch),
  (keys: 'Ctrl + I', label: l10n.hotkeyImport),
  (keys: 'Ctrl + E', label: l10n.hotkeyExport),
  (keys: 'Ctrl + P', label: l10n.hotkeyProfiles),
  (keys: 'Ctrl + ,', label: l10n.hotkeySettings),
  (keys: 'Escape', label: l10n.hotkeyClose),
];
