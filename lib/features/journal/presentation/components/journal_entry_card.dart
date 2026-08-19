import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/journal/presentation/components/journal_labels.dart';

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    required this.entry,
    this.onTap,
    super.key,
  });

  final JournalEntryItem entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final moodColor = journalMoodColor(entry.mood);

    return EtzanCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              journalMoodIcon(entry.mood),
              color: moodColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.title.trim().isNotEmpty)
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                Text(
                  entry.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  journalDateLabel(entry.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
