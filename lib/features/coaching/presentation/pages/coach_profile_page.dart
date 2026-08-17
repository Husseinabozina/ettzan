import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coach_profile_summary_card.dart';

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    final initialCoach = argument is CoachItem ? argument : null;

    return EtzanPage(
      title: LocaleKeys.coachProfile.tr(context: context),
      child: initialCoach == null
          ? FutureBuilder<List<CoachItem>>(
              future: getIt<EtzanBackendRepository>().getCoaches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return ListView(
                    children: const [EtzanLoadingCard(height: 220)],
                  );
                }

                if (snapshot.hasError) {
                  return ListView(
                    children: [
                      const SizedBox(height: 90),
                      EtzanEmptyState(
                        title: LocaleKeys.coachesLoadError.tr(context: context),
                        body: LocaleKeys.checkSupabaseConnection.tr(
                          context: context,
                        ),
                      ),
                    ],
                  );
                }

                final coaches = snapshot.data ?? const <CoachItem>[];
                if (coaches.isEmpty) {
                  return ListView(
                    children: [
                      EtzanEmptyState(
                        title: LocaleKeys.noCoach.tr(context: context),
                        body: LocaleKeys.chooseCoachFromList.tr(
                          context: context,
                        ),
                      ),
                    ],
                  );
                }

                return _CoachProfileContent(coach: coaches.first);
              },
            )
          : _CoachProfileContent(coach: initialCoach),
    );
  }
}

class _CoachProfileContent extends StatelessWidget {
  const _CoachProfileContent({required this.coach});

  final CoachItem coach;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CoachProfileSummaryCard(coach: coach),
        const SizedBox(height: AppSpacing.lg),
        EtzanSectionTitle(
          title: LocaleKeys.specialties.tr(context: context),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: coach.specialties.isEmpty
              ? [
                  EtzanTag(
                    label: LocaleKeys.coachingSpecialtyFallback.tr(
                      context: context,
                    ),
                    selected: true,
                  ),
                ]
              : coach.specialties
                  .map(
                    (label) => EtzanTag(label: label, selected: true),
                  )
                  .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        EtzanSectionTitle(
          title: LocaleKeys.aboutCoach.tr(context: context),
        ),
        const SizedBox(height: AppSpacing.sm),
        EtzanCard(child: Text(coach.bio)),
        const SizedBox(height: AppSpacing.xl),
        EtzanPrimaryButton(
          label: LocaleKeys.bookNow.tr(context: context),
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.bookSession,
            arguments: coach,
          ),
        ),
      ],
    );
  }
}
