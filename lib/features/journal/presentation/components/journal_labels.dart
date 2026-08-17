import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';

class JournalTagOption {
  const JournalTagOption({
    required this.value,
    required this.labelKey,
  });

  final String value;
  final String labelKey;
}

const journalDefaultTagValue = 'امتنان';

const journalTagOptions = <JournalTagOption>[
  JournalTagOption(
    value: 'امتنان',
    labelKey: LocaleKeys.tagGratitude,
  ),
  JournalTagOption(
    value: 'قلق',
    labelKey: LocaleKeys.tagAnxiety,
  ),
  JournalTagOption(
    value: 'تحفيز',
    labelKey: LocaleKeys.tagMotivation,
  ),
  JournalTagOption(
    value: 'توازن',
    labelKey: LocaleKeys.tagBalance,
  ),
];

String journalDateLabel(DateTime value) =>
    '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';

String journalTagLabel(BuildContext context, String value) {
  for (final option in journalTagOptions) {
    if (option.value == value) {
      return option.labelKey.tr(context: context);
    }
  }
  return value;
}

IconData journalMoodIcon(int mood) {
  if (mood <= 1) return Icons.sentiment_very_dissatisfied;
  if (mood == 2) return Icons.sentiment_dissatisfied;
  if (mood == 3) return Icons.sentiment_neutral;
  if (mood == 4) return Icons.sentiment_satisfied;
  return Icons.sentiment_very_satisfied;
}

Color journalMoodColor(int mood) {
  if (mood <= 2) return AppColors.warning;
  if (mood == 3) return AppColors.lavender;
  return AppColors.primary;
}
