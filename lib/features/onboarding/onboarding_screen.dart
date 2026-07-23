import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';
import '../../data/providers.dart';

/// Первый запуск: создание собственного профиля и стартовой структуры (§8).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  /// Текущий шаг: сначала объясняем устройство приложения, потом просим имя.
  ///
  /// Раньше первый экран сразу требовал имя, и главная идея — что мнение
  /// отделено от объекта — не объяснялась нигде вообще.
  int _step = 0;

  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _nickname = TextEditingController();
  bool _starterSubcategories = true;
  bool _busy = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final profiles = ref.read(profileRepositoryProvider);
      final seed = ref.read(seedServiceProvider);
      final profile = await profiles.createOwnProfile(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim().isEmpty ? null : _lastName.text.trim(),
        nickname: _nickname.text.trim().isEmpty ? null : _nickname.text.trim(),
      );
      await seed.seedForProfile(
        profile.id,
        withStarterSubcategories: _starterSubcategories,
      );
      await ref.read(activeProfileIdProvider.notifier).setActive(profile.id);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;

    final steps = <({IconData icon, String title, String body})>[
      (
        icon: Icons.bookmark_rounded,
        title: l10n.onboardingStep1Title,
        body: l10n.onboardingStep1Body,
      ),
      (
        icon: Icons.compare_arrows_rounded,
        title: l10n.onboardingStep2Title,
        body: l10n.onboardingStep2Body,
      ),
      (
        icon: Icons.lock_outline_rounded,
        title: l10n.onboardingStep3Title,
        body: l10n.onboardingStep3Body,
      ),
    ];

    if (_step < steps.length) {
      final step = steps[_step];
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: c.accentSoft,
                        borderRadius: AppDimens.brLg,
                      ),
                      child: Icon(step.icon, size: 36, color: c.accentPrimary),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space32),
                  Text(
                    step.title,
                    textAlign: TextAlign.center,
                    style: context.text.headlineMedium,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  Text(
                    step.body,
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < steps.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _step ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == _step ? c.accentPrimary : c.border,
                            borderRadius: AppDimens.brPill,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space32),
                  FilledButton(
                    onPressed: () => setState(() => _step++),
                    child: Text(
                      _step == steps.length - 1
                          ? l10n.onboardingStart
                          : l10n.commonNext,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space8),
                  TextButton(
                    onPressed: () => setState(() => _step = steps.length),
                    child: Text(l10n.commonSkip),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.accentPrimary,
                        borderRadius: AppDimens.brLg,
                      ),
                      child: Icon(
                        Icons.bookmark_rounded,
                        size: 34,
                        color: c.accentPrimaryOn,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),
                  Text(
                    AppConfig.appName,
                    textAlign: TextAlign.center,
                    style: context.text.displayMedium,
                  ),
                  const SizedBox(height: AppDimens.space8),
                  Text(
                    l10n.onboardingWelcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space32),
                  TextFormField(
                    controller: _firstName,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.onboardingProfileNameLabel,
                      hintText: l10n.onboardingProfileNameHint,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.onboardingNameRequired
                        : null,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  TextFormField(
                    controller: _lastName,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.onboardingLastNameLabel,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space12),
                  TextFormField(
                    controller: _nickname,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _create(),
                    decoration: InputDecoration(
                      labelText: l10n.onboardingNicknameLabel,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    decoration: BoxDecoration(
                      color: c.surfaceMuted,
                      borderRadius: AppDimens.brMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.onboardingStarterTitle,
                          style: context.text.titleMedium,
                        ),
                        const SizedBox(height: AppDimens.space4),
                        Text(
                          l10n.onboardingStarterHint,
                          style: context.text.bodySmall?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.space12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.onboardingStarterSubcategories,
                                style: context.text.bodyMedium,
                              ),
                            ),
                            Switch.adaptive(
                              value: _starterSubcategories,
                              onChanged: (v) =>
                                  setState(() => _starterSubcategories = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),
                  FilledButton(
                    onPressed: _busy ? null : _create,
                    child: Text(
                      _busy
                          ? l10n.onboardingCreating
                          : l10n.onboardingCreateProfile,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
