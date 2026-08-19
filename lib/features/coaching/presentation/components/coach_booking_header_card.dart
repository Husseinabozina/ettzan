import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class CoachBookingHeaderCard extends StatelessWidget {
  const CoachBookingHeaderCard({required this.coach, super.key});

  final CoachItem coach;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      child: Row(
        children: [
          EtzanAvatar(
            name: coach.name,
            online: true,
            imageUrl: coach.avatarUrl,
          ),
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  coach.specialties.isEmpty
                      ? LocaleKeys.lifeCoach.tr(context: context)
                      : coach.specialties.join(' • '),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
