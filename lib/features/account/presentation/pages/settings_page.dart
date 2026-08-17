import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/app/settings_controller.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<UserPreferences>? _preferencesFuture =
      _canUseAccountPreferences ? _loadPreferences() : null;
  bool _savingPreferences = false;

  bool get _canUseAccountPreferences {
    final user = getIt<AuthRepository>().currentUser;
    return user != null && !user.isGuest;
  }

  Future<UserPreferences> _loadPreferences() =>
      getIt<EtzanBackendRepository>().getUserPreferences();

  void _reloadPreferences() {
    if (!_canUseAccountPreferences) return;
    setState(() {
      _preferencesFuture = _loadPreferences();
    });
  }

  Future<void> _updatePreferences(UserPreferences preferences) async {
    setState(() => _savingPreferences = true);
    try {
      final updated =
          await getIt<EtzanBackendRepository>().updateUserPreferences(
        preferences,
      );
      setState(() {
        _preferencesFuture = Future.value(updated);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.notificationPreferencesSaveError.tr(context: context),
          ),
        ),
      );
      _reloadPreferences();
    } finally {
      if (mounted) setState(() => _savingPreferences = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final canUseAccountPreferences = _canUseAccountPreferences;
    return EtzanPage(
      title: LocaleKeys.settings.tr(context: context),
      child: ListView(
        children: [
          EtzanSectionTitle(
            title: LocaleKeys.appPreferences.tr(context: context),
          ),
          const SizedBox(height: AppSpacing.sm),
          EtzanCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(LocaleKeys.language.tr(context: context)),
                  subtitle: Text(settings.locale.languageCode == 'ar'
                      ? LocaleKeys.arabic.tr(context: context)
                      : LocaleKeys.english.tr(context: context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageSheet(context, settings),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: Text(LocaleKeys.appearance.tr(context: context)),
                  subtitle: Text(_themeModeLabel(context, settings.themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeSheet(context, settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EtzanSectionTitle(
            title: LocaleKeys.notificationSettings.tr(context: context),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!canUseAccountPreferences)
            EtzanEmptyState(
              title: LocaleKeys.signInRequiredTitle.tr(context: context),
              body: LocaleKeys.guestNotificationSettingsBody.tr(
                context: context,
              ),
              action: EtzanPrimaryButton(
                label: LocaleKeys.createAccountToContinue.tr(context: context),
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.signUp,
                ),
              ),
            )
          else
            FutureBuilder<UserPreferences>(
              future: _preferencesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const EtzanLoadingCard(height: 190);
                }

                if (snapshot.hasError) {
                  return EtzanEmptyState(
                    title: LocaleKeys.notificationPreferencesLoadError.tr(
                      context: context,
                    ),
                    body:
                        LocaleKeys.checkSupabaseConnection.tr(context: context),
                    action: EtzanPrimaryButton(
                      label: LocaleKeys.retry.tr(context: context),
                      onPressed: _reloadPreferences,
                    ),
                  );
                }

                final preferences = snapshot.data!;
                return EtzanCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(LocaleKeys.reminders.tr(context: context)),
                        value: preferences.remindersEnabled,
                        onChanged: _savingPreferences
                            ? null
                            : (value) => _updatePreferences(
                                  preferences.copyWith(
                                    remindersEnabled: value,
                                  ),
                                ),
                      ),
                      SwitchListTile(
                        title: Text(
                          LocaleKeys.motivationalMessages.tr(context: context),
                        ),
                        value: preferences.motivationEnabled,
                        onChanged: _savingPreferences
                            ? null
                            : (value) => _updatePreferences(
                                  preferences.copyWith(
                                    motivationEnabled: value,
                                  ),
                                ),
                      ),
                      SwitchListTile(
                        title:
                            Text(LocaleKeys.offersUpdates.tr(context: context)),
                        value: preferences.offersEnabled,
                        onChanged: _savingPreferences
                            ? null
                            : (value) => _updatePreferences(
                                  preferences.copyWith(offersEnabled: value),
                                ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.lg),
          EtzanSectionTitle(
            title: LocaleKeys.privacyAndSecurity.tr(context: context),
          ),
          const SizedBox(height: AppSpacing.sm),
          EtzanCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(LocaleKeys.privacy.tr(context: context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: Text(LocaleKeys.changePassword.tr(context: context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EtzanSectionTitle(title: LocaleKeys.support.tr(context: context)),
          const SizedBox(height: AppSpacing.sm),
          EtzanCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(LocaleKeys.helpCenter.tr(context: context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(LocaleKeys.contactUs.tr(context: context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(LocaleKeys.aboutEtzan.tr(context: context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: canUseAccountPreferences
                ? () async {
                    try {
                      await getIt<AuthRepository>().signOut();
                    } finally {
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    }
                  }
                : () => Navigator.of(context).pushNamed(AppRoutes.login),
            icon: Icon(
              canUseAccountPreferences ? Icons.logout : Icons.login,
              color: AppColors.danger,
            ),
            label: Text(
              canUseAccountPreferences
                  ? LocaleKeys.logout.tr(context: context)
                  : LocaleKeys.signInToContinue.tr(context: context),
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(BuildContext context, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => LocaleKeys.light.tr(context: context),
      ThemeMode.dark => LocaleKeys.dark.tr(context: context),
      ThemeMode.system => LocaleKeys.system.tr(context: context),
    };
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    AppSettingsController settings,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: RadioGroup<String>(
          groupValue: context.locale.languageCode,
          onChanged: (value) async {
            if (value != null) {
              final locale = Locale(value);
              await context.setLocale(locale);
              if (!context.mounted) return;
              settings.setLocale(locale);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'ar',
                title: Text(LocaleKeys.arabic.tr(context: context)),
              ),
              RadioListTile<String>(
                value: 'en',
                title: Text(LocaleKeys.english.tr(context: context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showThemeSheet(
    BuildContext context,
    AppSettingsController settings,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: settings.themeMode,
          onChanged: (value) {
            if (value != null) {
              settings.setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values
                .map(
                  (mode) => RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(_themeModeLabel(context, mode)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
