import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/goal_card.dart';

class CompletedGoalsScreen extends StatefulWidget {
  const CompletedGoalsScreen({super.key});

  @override
  State<CompletedGoalsScreen> createState() => _CompletedGoalsScreenState();
}

class _CompletedGoalsScreenState extends State<CompletedGoalsScreen> {
  late final Future<List<GoalItem>> _future =
      getIt<EtzanBackendRepository>().getGoals();

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.completedGoals.tr(context: context),
      child: FutureBuilder<List<GoalItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              children: const [
                EtzanLoadingCard(),
                SizedBox(height: AppSpacing.sm),
                EtzanLoadingCard(),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.goalsLoadError.tr(context: context),
                  body: LocaleKeys.checkConnectionAndRetry.tr(context: context),
                ),
              ],
            );
          }

          final completed = (snapshot.data ?? const <GoalItem>[])
              .where((goal) => goal.isCompleted)
              .toList(growable: false);

          if (completed.isEmpty) {
            return EtzanEmptyState(
              title: LocaleKeys.noCompletedGoals.tr(context: context),
              body: LocaleKeys.noCompletedGoalsDescription.tr(
                context: context,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              EtzanCard(
                gradient: AppColors.calmGradient,
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.warning,
                      size: 40,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        LocaleKeys.completedGoalsCount.tr(
                          context: context,
                          namedArgs: {'count': '${completed.length}'},
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AdaptiveGrid(
                phone: 1,
                tablet: 2,
                desktop: 3,
                children: completed
                    .map(
                      (goal) => GoalCard(
                        goal: goal,
                        isUpdating: false,
                        readOnly: true,
                        onProgressChanged: (_) {},
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
