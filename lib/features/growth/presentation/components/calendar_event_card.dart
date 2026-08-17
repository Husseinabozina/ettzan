import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';

class CalendarEventCard extends StatelessWidget {
  const CalendarEventCard({
    required this.icon,
    required this.title,
    required this.time,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String title;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(time),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
