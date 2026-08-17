import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coach_card.dart';

class DiscoverCoachesScreen extends StatefulWidget {
  const DiscoverCoachesScreen({super.key});

  @override
  State<DiscoverCoachesScreen> createState() => _DiscoverCoachesScreenState();
}

class _DiscoverCoachesScreenState extends State<DiscoverCoachesScreen> {
  final _searchController = TextEditingController();
  late final Future<List<CoachItem>> _future =
      getIt<EtzanBackendRepository>().getCoaches();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.discoverCoach.tr(context: context),
      child: FutureBuilder<List<CoachItem>>(
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
                  title: LocaleKeys.coachesLoadError.tr(context: context),
                  body: LocaleKeys.checkSupabaseConnection.tr(context: context),
                ),
              ],
            );
          }

          final coaches = snapshot.data ?? const <CoachItem>[];
          final query = _searchController.text.trim().toLowerCase();
          final visibleCoaches = query.isEmpty
              ? coaches
              : coaches.where((coach) {
                  final haystack = [
                    coach.name,
                    coach.bio,
                    ...coach.specialties,
                  ].join(' ').toLowerCase();
                  return haystack.contains(query);
                }).toList(growable: false);

          return ListView(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: LocaleKeys.searchCoach.tr(context: context),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              EtzanSectionTitle(
                title: LocaleKeys.recommendedCoaches.tr(context: context),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (coaches.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noActiveCoaches.tr(context: context),
                  body: LocaleKeys.noActiveCoachesDescription.tr(
                    context: context,
                  ),
                )
              else if (visibleCoaches.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noSearchResults.tr(context: context),
                  body: LocaleKeys.tryDifferentCoachSearch.tr(
                    context: context,
                  ),
                )
              else
                AdaptiveGrid(
                  phone: 1,
                  tablet: 2,
                  desktop: 2,
                  children: visibleCoaches
                      .map(
                        (coach) => CoachCard(
                          coach: coach,
                          onViewProfile: () => Navigator.of(context).pushNamed(
                            AppRoutes.coachProfile,
                            arguments: coach,
                          ),
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
