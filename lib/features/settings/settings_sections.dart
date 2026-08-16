import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/utils/normalize.dart';
import 'backups_section.dart';
import 'db_encryption_section.dart';
import 'devices_section.dart';
import 'doctor_section.dart';
import 'error_log_section.dart';
import 'network_section.dart';
import 'settings_screen.dart';
import 'tags_section.dart';
import 'types_section.dart';

/// Раздел настроек: чем он назван, чем ищется, чем помечен и что показывает.
///
/// Всё это объявлено в одном месте, а не внутри каждого виджета: иначе список
/// поиска расходится с показанным, как когда-то разошлись справка и настройки
/// по горячим клавишам ([appHotkeys]). Значок и подпись здесь по той же
/// причине — по ним человек выбирает, куда идти, и они обязаны совпадать с
/// тем, что он там найдёт.
typedef SettingsSection = ({
  String id,
  String title,
  String subtitle,
  String words,
  IconData icon,
  Widget widget,
});

/// Разделы, за которыми сюда заходят.
///
/// Порядок — по тому, как часто настройку меняют: вид, поведение списков,
/// сохранность данных, обновления.
List<SettingsSection> mainSettingsSections(AppLocalizations l10n) => [
  (
    id: 'appearance',
    title: l10n.settingsAppearance,
    subtitle: l10n.settingsSubtitleAppearance,
    words: l10n.settingsWordsAppearance,
    icon: Icons.palette_outlined,
    widget: const AppearanceSection(),
  ),
  (
    id: 'behaviour',
    title: l10n.settingsBehaviour,
    subtitle: l10n.settingsSubtitleBehaviour,
    words: l10n.settingsWordsBehaviour,
    icon: Icons.tune_rounded,
    widget: const BehaviourSection(),
  ),
  (
    id: 'backups',
    title: l10n.backupsTitle,
    subtitle: l10n.settingsSubtitleBackups,
    words: l10n.settingsWordsBackups,
    icon: Icons.backup_outlined,
    widget: const BackupsSection(),
  ),
  (
    id: 'network',
    title: l10n.settingsNetworkTitle,
    subtitle: l10n.settingsSubtitleNetwork,
    words: l10n.settingsWordsNetwork,
    icon: Icons.cloud_download_outlined,
    widget: const NetworkSection(),
  ),
];

/// Разделы под чертой «Дополнительно»: настраивают один раз или никогда.
List<SettingsSection> advancedSettingsSections(AppLocalizations l10n) => [
  (
    id: 'types',
    title: l10n.typesTitle,
    subtitle: l10n.settingsSubtitleTypes,
    words: l10n.settingsWordsTypes,
    icon: Icons.category_outlined,
    widget: const TypesSection(),
  ),
  (
    id: 'tags',
    title: l10n.tagsTitle,
    subtitle: l10n.settingsSubtitleTags,
    words: l10n.settingsWordsTags,
    icon: Icons.sell_outlined,
    widget: const TagsSection(),
  ),
  (
    id: 'devices',
    title: l10n.devicesTitle,
    subtitle: l10n.settingsSubtitleDevices,
    words: l10n.settingsWordsDevices,
    icon: Icons.devices_outlined,
    widget: const DevicesSection(),
  ),
  (
    id: 'dbEncryption',
    title: l10n.dbEncryptionTitle,
    subtitle: l10n.settingsSubtitleDbEncryption,
    words: l10n.settingsWordsDbEncryption,
    icon: Icons.lock_outline_rounded,
    widget: const DbEncryptionSection(),
  ),
  (
    id: 'keyStorage',
    title: l10n.keyStorageTitle,
    subtitle: l10n.settingsSubtitleKeyStorage,
    words: l10n.settingsWordsKeyStorage,
    icon: Icons.key_outlined,
    widget: const KeyStorageSection(),
  ),
  (
    id: 'doctor',
    title: l10n.doctorTitle,
    subtitle: l10n.settingsSubtitleDoctor,
    words: l10n.settingsWordsDoctor,
    icon: Icons.health_and_safety_outlined,
    widget: const DoctorSection(),
  ),
  (
    id: 'errorLog',
    title: l10n.errorLogTitle,
    subtitle: l10n.settingsSubtitleErrorLog,
    words: l10n.settingsWordsErrorLog,
    icon: Icons.bug_report_outlined,
    widget: const ErrorLogSection(),
  ),
  (
    id: 'about',
    title: l10n.settingsAbout,
    subtitle: l10n.settingsSubtitleAbout,
    words: l10n.settingsWordsAbout,
    icon: Icons.info_outline_rounded,
    widget: const AboutSection(),
  ),
];

/// Раздел по идентификатору — или null, если такого больше нет.
///
/// Выбранный раздел живёт в настройках отдельно от списка, и после обновления
/// приложения запомненный идентификатор может ни на что не показывать.
SettingsSection? settingsSectionById(AppLocalizations l10n, String? id) {
  if (id == null) return null;
  for (final section in [
    ...mainSettingsSections(l10n),
    ...advancedSettingsSections(l10n),
  ]) {
    if (section.id == id) return section;
  }
  return null;
}

/// Подходит ли раздел под запрос.
///
/// Слова запроса ищутся по названию, подписи и объявленным словам: «копи»
/// находит резервные копии, «ёлк» и «елк» — одно и то же.
bool matchesSettingsSection(SettingsSection section, String query) {
  final q = Normalize.forMatch(query);
  if (q.isEmpty) return true;
  final haystack = Normalize.forMatch(
    '${section.title} ${section.subtitle} ${section.words}',
  );
  return q.split(' ').every(haystack.contains);
}
