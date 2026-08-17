import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class PlanTaskTile extends StatelessWidget {
  const PlanTaskTile({
    required this.index,
    required this.title,
    required this.checked,
    required this.onTap,
    super.key,
  });

  final int index;
  final String title;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: EtzanCard(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Text(
                '$index',
                style: const TextStyle(color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(
              checked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: checked ? AppColors.success : AppColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}
