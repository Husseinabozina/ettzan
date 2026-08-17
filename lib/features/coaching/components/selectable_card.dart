import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.secondary.withValues(alpha: .35)
          : Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.divider,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.primary),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (subtitle != null)
                Text(subtitle!, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
