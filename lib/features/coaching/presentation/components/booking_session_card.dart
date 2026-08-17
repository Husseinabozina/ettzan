import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coaching_labels.dart';

class BookingSessionCard extends StatelessWidget {
  const BookingSessionCard({
    required this.session,
    required this.onOpenDetails,
    super.key,
  });

  final BookingItem session;
  final Future<void> Function() onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  coachingDateLabel(session.startsAt),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  coachingStatusLabel(context, session.status),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${coachingTimeLabel(context, session.startsAt)} - '
            '${coachingTimeLabel(context, session.endsAt)}',
          ),
          const Divider(height: 28),
          Text(
            coachingSessionTypeLabel(context, session.sessionType),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(session.coachName),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onOpenDetails,
            child: Text(LocaleKeys.viewDetails.tr(context: context)),
          ),
        ],
      ),
    );
  }
}
