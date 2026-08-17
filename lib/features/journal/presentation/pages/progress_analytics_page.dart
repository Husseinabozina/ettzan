import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/journal/presentation/components/journal_labels.dart';
import 'package:etzan_life_coaching/features/journal/presentation/components/journal_topic_bar.dart';

class ProgressAnalyticsScreen extends StatelessWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.progress.tr(context: context),
      child: FutureBuilder<List<JournalEntryItem>>(
        future: getIt<EtzanBackendRepository>().getJournalEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              children: const [
                EtzanLoadingCard(height: 160),
                SizedBox(height: AppSpacing.sm),
                EtzanLoadingCard(height: 120),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.journalLoadError.tr(context: context),
                  body: LocaleKeys.tryAgainLater.tr(context: context),
                ),
              ],
            );
          }

          final entries = snapshot.data ?? const <JournalEntryItem>[];
          final averageMood = entries.isEmpty
              ? 0.0
              : entries.map((entry) => entry.mood).reduce((a, b) => a + b) /
                  entries.length;

          final tagCounts = <String, int>{};
          for (final entry in entries) {
            for (final tag in entry.tags) {
              tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
            }
          }

          final sortedTags = tagCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            children: [
              EtzanCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            LocaleKeys.overallMood.tr(context: context),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        EtzanTag(
                          label:
                              LocaleKeys.allJournalEntries.tr(context: context),
                          selected: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      entries.isEmpty
                          ? '--'
                          : '${averageMood.toStringAsFixed(1)}/5',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      LocaleKeys.savedJournalCount.tr(
                        context: context,
                        namedArgs: {'count': '${entries.length}'},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AdaptiveGrid(
                phone: 2,
                tablet: 2,
                desktop: 2,
                children: [
                  EtzanCard(
                    child: EtzanMetric(
                      value: '${entries.length}',
                      label: LocaleKeys.writtenEntries.tr(context: context),
                      icon: Icons.menu_book_outlined,
                    ),
                  ),
                  EtzanCard(
                    child: EtzanMetric(
                      value: '${sortedTags.length}',
                      label: LocaleKeys.usedTags.tr(context: context),
                      icon: Icons.sell_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              EtzanSectionTitle(
                title: LocaleKeys.mostFrequentTopics.tr(context: context),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (sortedTags.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noTagsYet.tr(context: context),
                  body: LocaleKeys.noTagsYetDescription.tr(context: context),
                )
              else
                EtzanCard(
                  child: Column(
                    children: sortedTags
                        .take(5)
                        .map(
                          (entry) => JournalTopicBar(
                            label: journalTagLabel(context, entry.key),
                            value: entry.value / entries.length,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
