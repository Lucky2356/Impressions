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
import '../../core/theme/app_layout.dart';
import '../../core/theme/theme_context.dart';
import '../../core/utils/normalize.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/changelog_service.dart';
import '../../design_system/design_system.dart';
import '../onboarding/app_tour.dart';
import 'network_section.dart';
import 'settings_sections.dart';
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

/// Ширина списка разделов в широкой раскладке.
const double _settingsListWidth = 320;

/// Какой раздел настроек открыт; null — открыт список.
///
/// В провайдере, а не в `State`: разделы живут в `KeyedSubtree` внутри
/// `AnimatedSwitcher` и при переходе уничтожаются вместе со своим состоянием.
final selectedSettingsSectionProvider =
    NotifierProvider<SelectedSettingsSection, String?>(
      SelectedSettingsSection.new,
    );

class SelectedSettingsSection extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;

  /// Возврат к списку. false — возвращаться было некуда.
  bool back() {
    if (state == null) return false;
    state = null;
    return true;
  }
}

/// Настройки приложения: список разделов, раздел открывается отдельно.
///
/// До 1.18.0 все двенадцать разделов лежали в одной ленте раскрытыми: чтобы
/// дойти до «Типов объектов», надо было прокрутить резервные копии и товарные
/// базы целиком. Поиск это спасал только тогда, когда знаешь нужное слово.
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
    final c = context.colors;
    final layout = context.layout;
    final selected = settingsSectionById(
      l10n,
      ref.watch(selectedSettingsSectionProvider),
    );

    if (layout.isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: _settingsListWidth, child: _list(l10n)),
          VerticalDivider(width: 1, color: c.border),
          Expanded(
            child: selected == null
                ? EmptyState(
                    icon: Icons.settings_rounded,
                    title: l10n.settingsPickTitle,
                    message: l10n.settingsPickMessage,
                  )
                : _SectionPage(section: selected),
          ),
        ],
      );
    }

    if (selected != null) {
      return _SectionPage(
        section: selected,
        onBack: () => ref.read(selectedSettingsSectionProvider.notifier).back(),
      );
    }
    return _list(l10n);
  }

  Widget _list(AppLocalizations l10n) {
    final query = _search.text;
    final main = [
      for (final s in mainSettingsSections(l10n))
        if (matchesSettingsSection(s, query)) s,
    ];
    final advanced = [
      for (final s in advancedSettingsSections(l10n))
        if (matchesSettingsSection(s, query)) s,
    ];
    final searching = Normalize.forMatch(query).isNotEmpty;
    final selectedId = ref.watch(selectedSettingsSectionProvider);

    // Список ширину не ограничивает: в широкой раскладке он и так стоит в
    // колонке в 320 точек, а на телефоне занимает экран целиком.
    return ScreenScaffold(
      header: ScreenHeader(
        title: l10n.navSettings,
        constrain: false,
        bottom: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: AppSearchField(
            controller: _search,
            hint: l10n.settingsSearch,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      constrain: false,
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
          for (final (i, s) in main.indexed) ...[
            Appear(
              index: i,
              child: _SectionTile(section: s, selected: s.id == selectedId),
            ),
            const SizedBox(height: AppDimens.space8),
          ],
          // При поиске черта «Дополнительно» только мешает: разделов на
          // экране и так один-два.
          if (advanced.isNotEmpty && !searching) ...[
            const SizedBox(height: AppDimens.space8),
            const _AdvancedHeader(),
            const SizedBox(height: AppDimens.space16),
          ],
          for (final (i, s) in advanced.indexed) ...[
            Appear(
              // Продолжаем очередь основных разделов, а не начинаем заново:
              // иначе после черты список появлялся бы вторым заходом.
              index: main.length + i,
              child: _SectionTile(section: s, selected: s.id == selectedId),
            ),
            const SizedBox(height: AppDimens.space8),
          ],
          const SizedBox(height: AppDimens.space16),
        ],
      ),
    );
  }
}

/// Строка списка: значок, название и чем этот раздел занимается.
///
/// Подпись здесь не украшение: без неё «Проверка данных» и «Журнал ошибок»
/// различаются только на слух, и выбирать пришлось бы наугад.
class _SectionTile extends ConsumerWidget {
  const _SectionTile({required this.section, required this.selected});

  final SettingsSection section;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return AppCard(
      onTap: () =>
          ref.read(selectedSettingsSectionProvider.notifier).select(section.id),
      padding: const EdgeInsets.all(AppDimens.space16),
      selected: selected,
      child: Row(
        children: [
          Icon(
            section.icon,
            size: 22,
            color: selected ? c.accentPrimary : c.textSecondary,
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(section.title, style: context.text.titleMedium),
                const SizedBox(height: AppDimens.space2),
                Text(
                  section.subtitle,
                  style: context.text.labelSmall?.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textMuted),
        ],
      ),
    );
  }
}

/// Открытый раздел: своя шапка и содержимое под ней.
class _SectionPage extends StatelessWidget {
  const _SectionPage({required this.section, this.onBack});

  final SettingsSection section;

  /// Возврат к списку — только в узкой раскладке, где список не виден.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenScaffold(
      maxWidth: _settingsMaxWidth,
      header: ScreenHeader(
        title: section.title,
        maxWidth: _settingsMaxWidth,
        leading: onBack == null
            ? null
            : AppIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: l10n.commonBack,
                onPressed: onBack!,
              ),
      ),
      child: ListView(
        // У каждого раздела своё положение прокрутки: вернулись в «Резервные
        // копии» — и они там же, где их оставили.
        key: PageStorageKey('settings-${section.id}'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space24,
          vertical: AppDimens.space16,
        ),
        children: [
          section.widget,
          const SizedBox(height: AppDimens.space40),
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

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

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

class BehaviourSection extends ConsumerWidget {
  const BehaviourSection({super.key});

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

class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

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
