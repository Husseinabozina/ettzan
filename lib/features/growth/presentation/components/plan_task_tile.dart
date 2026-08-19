import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class PlanTaskTile extends StatelessWidget {
  const PlanTaskTile({
    required this.index,
    required this.title,
    required this.checked,
    required this.onTap,
    this.editMode = false,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final int index;
  final String title;
  final bool checked;
  final VoidCallback onTap;
  final bool editMode;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: EtzanCard(
        onTap: onTap,
        child: Row(
          children: [
            if (editMode) ...[
              const Icon(Icons.drag_handle, color: AppColors.inkSubtle),
              const SizedBox(width: AppSpacing.sm),
            ],
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
            if (editMode) ...[
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.primary,
                tooltip: LocaleKeys.editHabit.tr(context: context),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.danger,
                tooltip: LocaleKeys.deleteHabit.tr(context: context),
              ),
            ] else
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
