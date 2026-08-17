import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_shell.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/booking_session_card.dart';

class UpcomingSessionsScreen extends StatefulWidget {
  const UpcomingSessionsScreen({super.key});

  @override
  State<UpcomingSessionsScreen> createState() => _UpcomingSessionsScreenState();
}

class _UpcomingSessionsScreenState extends State<UpcomingSessionsScreen> {
  int _tab = 0;
  late Future<List<BookingItem>> _future = _load();

  Future<List<BookingItem>> _load() =>
      getIt<EtzanBackendRepository>().getBookings(past: _tab == 1);

  void _selectTab(int value) {
    if (value == _tab) return;
    setState(() {
      _tab = value;
      _future = _load();
    });
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return EtzanShell(
      currentIndex: 1,
      title: LocaleKeys.upcomingSessions.tr(context: context),
      child: FutureBuilder<List<BookingItem>>(
        future: _future,
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? const <BookingItem>[];

          return ListView(
            children: [
              EtzanSegmentedControl<int>(
                items: {
                  0: LocaleKeys.upcomingTab.tr(context: context),
                  1: LocaleKeys.pastTab.tr(context: context),
                },
                selected: _tab,
                onChanged: _selectTab,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState != ConnectionState.done)
                const EtzanLoadingCard()
              else if (snapshot.hasError)
                EtzanEmptyState(
                  title: LocaleKeys.sessionsLoadError.tr(context: context),
                  body: LocaleKeys.tryAgainLater.tr(context: context),
                  action: EtzanPrimaryButton(
                    label: LocaleKeys.retry.tr(context: context),
                    onPressed: _refresh,
                  ),
                )
              else if (sessions.isEmpty)
                EtzanEmptyState(
                  title: (_tab == 0
                          ? LocaleKeys.noUpcomingSessions
                          : LocaleKeys.noPastSessions)
                      .tr(context: context),
                  body: LocaleKeys.bookingsAppearHere.tr(context: context),
                )
              else
                ...sessions.map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: BookingSessionCard(
                      session: session,
                      onOpenDetails: () async {
                        await Navigator.of(context).pushNamed(
                          AppRoutes.sessionDetails,
                          arguments: session,
                        );
                        if (mounted) _refresh();
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
