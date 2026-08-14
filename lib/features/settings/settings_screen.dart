import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../app/data_refresh.dart';
import '../../app/locale_controller.dart';
import '../../app/theme_controller.dart';
import '../../core/config/app_config.dart';
import '../../core/domain/hotkeys.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/normalize.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/changelog_service.dart';
import '../../design_system/design_system.dart';
import '../onboarding/app_tour.dart';
import 'backups_section.dart';
import 'db_encryption_section.dart';
import 'devices_section.dart';
import 'doctor_section.dart';
import 'error_log_section.dart';
import 'network_section.dart';
import 'tags_section.dart';
import 'types_section.dart';
import 'whats_new_dialog.dart';

/// Значение настройки «при переносе записей» (§7.4).
final transferModeProvider = FutureProvider<String>((ref) async {
  ref.watch(dataRefreshProvider);
  final value = await ref
      .read(settingsRepositoryProvider)
      .get(SettingKeys.transferMode);
  return value ?? 'suggestMatch';
});

/// Значение настройки «показывать записи из подкатегорий» (§7.5).
final includeSubcategoriesProvider = FutureProvider<bool>((ref) async {
  ref.watch(dataRefreshProvider);
  return ref
      .read(settingsRepositoryProvider)
      .getBool(SettingKeys.catalogIncludeSubcategories, defaultValue: true);
});

/// Ширина колонки настроек: формы шире читать неудобно.
const double _settingsMaxWidth = 880;

/// Раздел настроек: название, слова для поиска и сам виджет.
///
/// Названия и слова объявлены здесь, рядом со списком разделов, а не внутри
/// каждого виджета: иначе список поиска расходится с показанным, как когда-то
/// разошлись справка и настройки по горячим клавишам ([appHotkeys]).
typedef _Section = ({String title, String words, Widget widget});

/// Разделы в порядке показа.
///
/// Порядок — по тому, как часто настройку меняют. Сверху то, за чем сюда
/// заходят: вид, поведение списков, сохранность данных и обновления. Ниже —
/// то, что настраивают один раз или никогда. Сведения в конце.
List<_Section> _mainSections(AppLocalizations l10n) => [
  (
    title: l10n.settingsAppearance,
    words: l10n.settingsWordsAppearance,
    widget: const _AppearanceSection(),
  ),
  (
    title: l10n.settingsBehaviour,
    words: l10n.settingsWordsBehaviour,
    widget: const _BehaviourSection(),
  ),
  (
    title: l10n.backupsTitle,
    words: l10n.settingsWordsBackups,
    widget: const BackupsSection(),
  ),
  (
    title: l10n.settingsNetworkTitle,
    words: l10n.settingsWordsNetwork,
    widget: const NetworkSection(),
  ),
];

/// Разделы под чертой «Дополнительно».
List<_Section> _advancedSections(AppLocalizations l10n) => [
  (
    title: l10n.typesTitle,
    words: l10n.settingsWordsTypes,
    widget: const TypesSection(),
  ),
  (
    title: l10n.tagsTitle,
    words: l10n.settingsWordsTags,
    widget: const TagsSection(),
  ),
  (
    title: l10n.devicesTitle,
    words: l10n.settingsWordsDevices,
    widget: const DevicesSection(),
  ),
  (
    title: l10n.dbEncryptionTitle,
    words: l10n.settingsWordsDbEncryption,
    widget: const DbEncryptionSection(),
  ),
  (
    title: l10n.keyStorageTitle,
    words: l10n.settingsWordsKeyStorage,
    widget: const KeyStorageSection(),
  ),
  (
    title: l10n.doctorTitle,
    words: l10n.settingsWordsDoctor,
    widget: const DoctorSection(),
  ),
  (
    title: l10n.errorLogTitle,
    words: l10n.settingsWordsErrorLog,
    widget: const ErrorLogSection(),
  ),
  (
    title: l10n.settingsAbout,
    words: l10n.settingsWordsAbout,
    widget: const _AboutSection(),
  ),
];

/// Подходит ли раздел под запрос.
///
/// Слова запроса ищутся по названию и объявленным словам: «копи» находит
/// резервные копии, «ёлк» и «елк» — одно и то же.
bool _matches(_Section section, String query) {
  final q = Normalize.forMatch(query);
  if (q.isEmpty) return true;
  final haystack = Normalize.forMatch('${section.title} ${section.words}');
  return q.split(' ').every(haystack.contains);
}

/// Настройки приложения: оформление, поведение, данные, сведения.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _search.text;
    final main = [
      for (final s in _mainSections(l10n))
        if (_matches(s, query)) s,
    ];
    final advanced = [
      for (final s in _advancedSections(l10n))
        if (_matches(s, query)) s,
    ];
    final searching = Normalize.forMatch(query).isNotEmpty;

    // Настройки — колонка форм, она уже общей ширины контента. Одна и та же
    // ширина задаётся шапке и содержимому, иначе заголовок и группы стоят с
    // разным отступом слева.
    return ScreenScaffold(
      maxWidth: _settingsMaxWidth,
      header: ScreenHeader(
        title: l10n.navSettings,
        maxWidth: _settingsMaxWidth,
        // Разделов десять, и чтобы найти переключатель, надо было помнить, в
        // каком он из них, и прокручивать всю ленту.
        bottom: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: AppSearchField(
            controller: _search,
            hint: l10n.settingsSearch,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      // Ширину задаёт сам каркас: он же ставит колонку по общему левому краю.
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space24,
          vertical: AppDimens.space16,
        ),
        children: [
          if (main.isEmpty && advanced.isEmpty)
            EmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.settingsSearchEmpty,
              message: l10n.settingsSearchEmptyHint,
            ),
          for (final s in main) ...[
            s.widget,
            const SizedBox(height: AppDimens.space24),
          ],
          // При поиске черта «Дополнительно» только мешает: разделов на
          // экране и так один-два.
          if (advanced.isNotEmpty && !searching) ...[
            const SizedBox(height: AppDimens.space8),
            const _AdvancedHeader(),
            const SizedBox(height: AppDimens.space16),
          ],
          for (final s in advanced) ...[
            s.widget,
            const SizedBox(height: AppDimens.space24),
          ],
          const SizedBox(height: AppDimens.space16),
        ],
      ),
    );
  }
}

/// Граница между тем, что настраивают, и тем, что настраивать не приходится.
class _AdvancedHeader extends StatelessWidget {
  const _AdvancedHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: AppDimens.space24, color: c.divider),
        Text(l10n.settingsAdvanced, style: context.text.titleMedium),
        const SizedBox(height: AppDimens.space2),
        Text(
          l10n.settingsAdvancedHint,
          style: context.text.labelSmall?.copyWith(color: c.textMuted),
        ),
      ],
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final mode = ref.watch(themeModeProvider);

    // Переключатель с тремя подписями шире, чем остаётся места рядом с
    // заголовком на телефоне: там он наезжал на слово «Тема», разбивая его
    // по букве на строку. На узком экране он встаёт под заголовок.
    return SettingsGroup(
      title: l10n.settingsAppearance,
      children: [
        SettingsRow(
          label: l10n.settingsTheme,
          // Переключатель занимает ровно отведённую ширину и делит её поровну.
          // Раньше он держал свою естественную ширину и на телефоне вылезал
          // за края карточки; совсем узкой строке подписи не нужны — остаются
          // значки с подсказками.
          control: LayoutBuilder(
            builder: (context, cns) {
              final withLabels = cns.maxWidth >= 300;
              return SegmentedToggle<ThemeMode>(
                value: mode,
                expand: true,
                onChanged: (m) => ref.read(themeModeProvider.notifier).set(m),
                segments: [
                  SegmentData(
                    value: ThemeMode.light,
                    icon: Icons.light_mode_rounded,
                    tooltip: l10n.themeLight,
                    label: withLabels ? l10n.themeLight : null,
                  ),
                  SegmentData(
                    value: ThemeMode.dark,
                    icon: Icons.dark_mode_rounded,
                    tooltip: l10n.themeDark,
                    label: withLabels ? l10n.themeDark : null,
                  ),
                  SegmentData(
                    value: ThemeMode.system,
                    icon: Icons.brightness_auto_rounded,
                    tooltip: l10n.themeSystem,
                    label: withLabels ? l10n.themeSystem : null,
                  ),
                ],
              );
            },
          ),
          minControlWidth: 330,
        ),
        Divider(height: AppDimens.space24, color: c.divider),
        SettingsRow(label: l10n.settingsLanguage, control: _LanguagePicker()),
      ],
    );
  }
}

/// Выбор языка интерфейса.
///
/// Названия языков намеренно написаны на них самих: человек, включивший чужой
/// язык по ошибке, должен узнать свой в списке и вернуться обратно.
class _LanguagePicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final locale = ref.watch(localeProvider);

    String label(Locale? value) => switch (value?.languageCode) {
      'ru' => l10n.settingsLanguageRu,
      'en' => l10n.settingsLanguageEn,
      _ => l10n.settingsLanguageSystem,
    };

    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (code) =>
          ref.read(localeProvider.notifier).set(LocaleController.parse(code)),
      itemBuilder: (_) => [
        for (final value in <Locale?>[null, ...LocaleController.supported])
          PopupMenuItem(
            value: value?.languageCode ?? '',
            child: Text(label(value)),
          ),
      ],
      // Название языка сжимается: на телефоне «Язык интерфейса» и «Язык
      // системы» вместе шире строки, и без этого она переполнялась.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label(locale),
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(color: c.textSecondary),
            ),
          ),
          Icon(Icons.arrow_drop_down_rounded, color: c.textSecondary),
        ],
      ),
    );
  }
}

class _BehaviourSection extends ConsumerWidget {
  const _BehaviourSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final settings = ref.read(settingsRepositoryProvider);
    final includeSub = ref.watch(includeSubcategoriesProvider).value ?? true;
    final transferMode =
        ref.watch(transferModeProvider).value ?? 'suggestMatch';

    String label(String mode) => switch (mode) {
      'autoCreate' => l10n.settingsTransferAutoCreate,
      'alwaysAsk' => l10n.settingsTransferAlwaysAsk,
      'noCategory' => l10n.settingsTransferNoCategory,
      _ => l10n.settingsTransferSuggest,
    };

    return SettingsGroup(
      title: l10n.settingsBehaviour,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.settingsShowSubcategoriesDefault,
                style: context.text.bodyMedium,
              ),
            ),
            Switch.adaptive(
              value: includeSub,
              onChanged: (v) async {
                await settings.setBool(
                  SettingKeys.catalogIncludeSubcategories,
                  v,
                );
                ref.read(dataRefreshProvider.notifier).bump();
              },
            ),
          ],
        ),
        Divider(height: AppDimens.space24, color: c.divider),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsTransferMode,
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(
                    label(transferMode),
                    style: context.text.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: '',
              icon: Icon(Icons.edit_rounded, size: 18, color: c.textSecondary),
              onSelected: (v) async {
                await settings.set(SettingKeys.transferMode, v);
                ref.read(dataRefreshProvider.notifier).bump();
              },
              itemBuilder: (_) => [
                for (final mode in const [
                  'suggestMatch',
                  'autoCreate',
                  'alwaysAsk',
                  'noCategory',
                ])
                  PopupMenuItem(value: mode, child: Text(label(mode))),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Открывает «Что нового» для текущей версии.
///
/// Если раздела для этой версии в файле нет — сообщаем об этом строкой внизу,
/// а не показываем пустое окно.
Future<void> _openWhatsNew(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final version = await ref.read(appVersionProvider.future);
  final entry = await const ChangelogService().forVersion(version);
  if (!context.mounted) return;
  if (entry == null) {
    showMessage(context, l10n.whatsNewNothing);
    return;
  }
  await WhatsNewDialog.show(context, entry);
}

class _AboutSection extends ConsumerWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.text.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
          Text(value, style: context.text.labelMedium),
        ],
      ),
    );

    return SettingsGroup(
      title: l10n.settingsAbout,
      children: [
        row(l10n.settingsVersion, ref.watch(appVersionProvider).value ?? '—'),
        row('Формат обмена', AppConfig.profileFileExtensionDotted),
        row('Профилей максимум', '${AppConfig.maxProfiles}'),
        row('Глубина категорий', '${AppConfig.defaultMaxCategoryDepth}'),
        Divider(height: AppDimens.space24, color: c.divider),
        // Обучение показывается один раз при первом запуске — но забыть его
        // содержание проще, чем найти, где оно было.
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: [
              OutlinedButton.icon(
                onPressed: () => AppTour.show(context),
                icon: const Icon(Icons.school_outlined, size: 18),
                label: Text(l10n.tourRepeat),
              ),
              // То же окно, что показывается после обновления: перечитать его
              // должно быть откуда.
              OutlinedButton.icon(
                onPressed: () => _openWhatsNew(context, ref),
                icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                label: Text(l10n.whatsNewOpen),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.space16),
        Text(
          l10n.settingsPrivacyNote,
          style: context.text.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppDimens.space16),
        const _HotkeysHint(),
      ],
    );
  }
}

class _HotkeysHint extends StatelessWidget {
  const _HotkeysHint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final wide =
        MediaQuery.sizeOf(context).width >= AppDimens.breakpointExpanded;
    if (!wide) return const SizedBox.shrink();

    Widget key(String combo, String label) => Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.surfaceMuted,
              borderRadius: AppDimens.brSm,
              border: Border.all(color: c.border),
            ),
            child: Text(combo, style: context.text.labelSmall),
          ),
          const SizedBox(width: AppDimens.space12),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.hotkeysTitle, style: context.text.titleMedium),
        const SizedBox(height: AppDimens.space8),
        for (final hotkey in appHotkeys(l10n)) key(hotkey.keys, hotkey.label),
      ],
    );
  }
}
