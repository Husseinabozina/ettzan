import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class CoachCard extends StatelessWidget {
  const CoachCard({
    required this.coach,
    required this.onViewProfile,
    super.key,
  });

  final CoachItem coach;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final verifiedLabel = (coach.isVerified
            ? LocaleKeys.certifiedLifeCoach
            : LocaleKeys.lifeCoach)
        .tr(context: context);

    return EtzanCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EtzanAvatar(name: coach.name, size: 64, online: true),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryDeep,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          coach.rating.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '(${coach.reviewCount})',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              EtzanTag(label: verifiedLabel),
              ...coach.specialties.take(2).map(
                    (specialty) => EtzanTag(label: specialty),
                  ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: EtzanPrimaryButton(
              label: LocaleKeys.viewProfile.tr(context: context),
              icon: Icons.person_outline_rounded,
              onPressed: onViewProfile,
            ),
          ),
        ],
      ),
    );
  }
}
