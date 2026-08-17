import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class CoachProfileSummaryCard extends StatelessWidget {
  const CoachProfileSummaryCard({required this.coach, super.key});

  final CoachItem coach;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      gradient: AppColors.calmGradient,
      child: Column(
        children: [
          EtzanAvatar(name: coach.name, size: 104, online: true),
          const SizedBox(height: AppSpacing.md),
          Text(
            LocaleKeys.coachNameLabel.tr(
              context: context,
              namedArgs: {'name': coach.name},
            ),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            (coach.isVerified
                    ? LocaleKeys.certifiedLifeCoach
                    : LocaleKeys.lifeCoach)
                .tr(context: context),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EtzanMetric(
                value: coach.rating.toStringAsFixed(1),
                label: LocaleKeys.ratingMetric.tr(context: context),
                icon: Icons.star_rounded,
              ),
              EtzanMetric(
                value: '${coach.reviewCount}',
                label: LocaleKeys.reviewsMetric.tr(context: context),
                icon: Icons.rate_review_outlined,
              ),
              EtzanMetric(
                value: '+${coach.yearsExperience}',
                label: LocaleKeys.yearsExperienceMetric.tr(context: context),
                icon: Icons.workspace_premium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
