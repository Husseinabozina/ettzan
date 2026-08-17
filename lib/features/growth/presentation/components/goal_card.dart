import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/growth_labels.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.goal,
    required this.isUpdating,
    required this.onProgressChanged,
    super.key,
  });

  final GoalItem goal;
  final bool isUpdating;
  final ValueChanged<double> onProgressChanged;

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.clamp(0.0, 1.0).toDouble();
    return EtzanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.category,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(goal.progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(goal.title, style: Theme.of(context).textTheme.bodyLarge),
          if ((goal.description ?? '').isNotEmpty) Text(goal.description!),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            backgroundColor: AppColors.divider,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            remainingGoalLabel(context, goal.targetDate),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              IconButton.outlined(
                tooltip: LocaleKeys.decreaseProgress.tr(context: context),
                onPressed: isUpdating || progress <= 0
                    ? null
                    : () => onProgressChanged(progress - .1),
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton.filledTonal(
                tooltip: LocaleKeys.increaseProgress.tr(context: context),
                onPressed: isUpdating || progress >= 1
                    ? null
                    : () => onProgressChanged(progress + .1),
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: isUpdating || progress >= 1
                    ? null
                    : () => onProgressChanged(1),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(LocaleKeys.markCompleted.tr(context: context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
