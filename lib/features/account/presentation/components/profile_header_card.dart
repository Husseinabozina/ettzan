import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.profile,
    required this.onEdit,
    this.onChangePhoto,
    this.savingPhoto = false,
    super.key,
  });

  final ProfileOverview profile;
  final VoidCallback onEdit;
  final VoidCallback? onChangePhoto;
  final bool savingPhoto;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      gradient: AppColors.calmGradient,
      child: Column(
        children: [
          GestureDetector(
            onTap: savingPhoto ? null : onChangePhoto,
            child: Stack(
              children: [
                EtzanAvatar(
                  name: profile.fullName,
                  size: 100,
                  online: true,
                  imageUrl: profile.avatarUrl,
                ),
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: savingPhoto
                          ? AppColors.surface
                          : AppColors.primary,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2.5),
                      boxShadow: AppShadows.card,
                    ),
                    child: savingPhoto
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(profile.fullName,
              style: Theme.of(context).textTheme.headlineMedium),
          Text(
            profile.email.isEmpty
                ? LocaleKeys.balanceAndGrowthJourney.tr(context: context)
                : profile.email,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(LocaleKeys.editProfile.tr(context: context)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EtzanMetric(
                value: '${profile.completedSessions}',
                label: LocaleKeys.sessions.tr(context: context),
              ),
              EtzanMetric(
                value: '${profile.goalsCount}',
                label: LocaleKeys.goals.tr(context: context),
              ),
              EtzanMetric(
                value: '${profile.streakDays}',
                label: LocaleKeys.consecutiveDays.tr(context: context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
