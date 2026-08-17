import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coaching_labels.dart';

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({
    required this.booking,
    super.key,
  });

  final BookingItem booking;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      gradient: AppColors.calmGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EtzanTag(
            label: coachingStatusLabel(context, booking.status),
            selected: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            coachingSessionTypeLabel(context, booking.sessionType),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              EtzanAvatar(
                name: booking.coachName,
                online: true,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coachingDateLabel(booking.startsAt)),
                    Text(
                      '${coachingTimeLabel(context, booking.startsAt)} - '
                      '${coachingTimeLabel(context, booking.endsAt)}',
                    ),
                    Text(
                      LocaleKeys.withCoach.tr(
                        context: context,
                        namedArgs: {'name': booking.coachName},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
