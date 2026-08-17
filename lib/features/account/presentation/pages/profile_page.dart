import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_shell.dart';
import 'package:etzan_life_coaching/features/account/presentation/components/achievement_card.dart';
import 'package:etzan_life_coaching/features/account/presentation/components/edit_profile_name_dialog.dart';
import 'package:etzan_life_coaching/features/account/presentation/components/profile_header_card.dart';
import 'package:etzan_life_coaching/features/account/presentation/components/profile_shortcuts_grid.dart';
import 'package:etzan_life_coaching/features/account/presentation/components/weekly_progress_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileOverview> _future =
      getIt<EtzanBackendRepository>().getProfileOverview();

  void _reload() {
    setState(() {
      _future = getIt<EtzanBackendRepository>().getProfileOverview();
    });
  }

  Future<void> _editProfileName(ProfileOverview profile) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => EditProfileNameDialog(
        initialName: profile.fullName,
      ),
    );
    if (name == null || name.trim().isEmpty) return;

    try {
      await getIt<EtzanBackendRepository>().updateProfileName(name);
      _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.profileUpdateSuccess.tr(context: context)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.profileUpdateError.tr(context: context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtzanShell(
      currentIndex: 4,
      title: LocaleKeys.profile.tr(context: context),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      child: FutureBuilder<ProfileOverview>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              children: [
                const EtzanLoadingCard(height: 260),
                const SizedBox(height: AppSpacing.md),
                const EtzanLoadingCard(),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.profileLoadError.tr(context: context),
                  body: LocaleKeys.checkSessionAndSupabase.tr(context: context),
                ),
              ],
            );
          }

          final profile = snapshot.data!;
          return ListView(
            children: [
              ProfileHeaderCard(
                profile: profile,
                onEdit: () => _editProfileName(profile),
              ),
              const SizedBox(height: AppSpacing.lg),
              EtzanSectionTitle(
                title: LocaleKeys.achievements.tr(context: context),
                action: LocaleKeys.seeAll.tr(context: context),
                onAction: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              AdaptiveGrid(
                phone: 3,
                tablet: 3,
                desktop: 3,
                children: [
                  AchievementCard(
                    icon: Icons.rocket_launch,
                    label: LocaleKeys.newBeginning.tr(context: context),
                    color: const Color(0xFF3A86FF),
                  ),
                  AchievementCard(
                    icon: Icons.workspace_premium,
                    label: LocaleKeys.persistence.tr(context: context),
                    color: AppColors.lavender,
                  ),
                  AchievementCard(
                    icon: Icons.local_fire_department,
                    label: LocaleKeys.consistency.tr(context: context),
                    color: AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              WeeklyProgressCard(profile: profile),
              const SizedBox(height: AppSpacing.lg),
              const ProfileShortcutsGrid(),
            ],
          );
        },
      ),
    );
  }
}
