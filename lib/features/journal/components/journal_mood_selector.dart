import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';

class JournalMoodSelector extends StatelessWidget {
  const JournalMoodSelector({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _moods = <({IconData icon, String labelKey})>[
    (
      icon: Icons.sentiment_very_dissatisfied,
      labelKey: LocaleKeys.moodSad,
    ),
    (
      icon: Icons.sentiment_dissatisfied,
      labelKey: LocaleKeys.moodAnxious,
    ),
    (
      icon: Icons.sentiment_neutral,
      labelKey: LocaleKeys.moodNeutral,
    ),
    (
      icon: Icons.sentiment_satisfied,
      labelKey: LocaleKeys.moodGood,
    ),
    (
      icon: Icons.sentiment_very_satisfied,
      labelKey: LocaleKeys.moodExcellent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        _moods.length,
        (index) {
          final mood = _moods[index];
          final selected = selectedIndex == index;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.md),
              onTap: () => onChanged(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          selected ? AppColors.primary : AppColors.lavenderSoft,
                      child: Icon(
                        mood.icon,
                        color: selected ? Colors.white : AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      mood.labelKey.tr(context: context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
