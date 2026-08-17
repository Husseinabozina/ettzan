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
    return EtzanCard(
      child: Column(
        children: [
          Row(
            children: [
              EtzanAvatar(name: coach.name, size: 58, online: true),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.coachNameLabel.tr(
                        context: context,
                        namedArgs: {'name': coach.name},
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      coach.specialties.isEmpty
                          ? LocaleKeys.lifeCoach.tr(context: context)
                          : coach.specialties.join(' • '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        Text(
                          '${coach.rating.toStringAsFixed(1)} '
                          '(${coach.reviewCount})',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: onViewProfile,
            child: Text(LocaleKeys.viewProfile.tr(context: context)),
          ),
        ],
      ),
    );
  }
}
