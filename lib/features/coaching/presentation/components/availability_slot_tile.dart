import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coaching_labels.dart';

class AvailabilitySlotTile extends StatelessWidget {
  const AvailabilitySlotTile({
    required this.slot,
    required this.onTap,
    super.key,
  });

  final AvailabilityItem slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.divider),
      ),
      title: Text(coachingDateLabel(slot.startsAt)),
      subtitle: Text(
        '${coachingTimeLabel(context, slot.startsAt)} - '
        '${coachingTimeLabel(context, slot.endsAt)}',
      ),
      trailing: const Icon(Icons.chevron_left),
    );
  }
}
