import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';

class JournalTopicBar extends StatelessWidget {
  const JournalTopicBar({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: normalizedValue,
              minHeight: 9,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('${(normalizedValue * 100).round()}%'),
        ],
      ),
    );
  }
}
