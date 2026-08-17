import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/calendar_event_card.dart';
import 'package:etzan_life_coaching/features/growth/presentation/components/growth_labels.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.calendar.tr(context: context),
      child: FutureBuilder<List<BookingItem>>(
        future: getIt<EtzanBackendRepository>().getBookings(past: false),
        builder: (context, snapshot) {
          final bookings = snapshot.data ?? const <BookingItem>[];
          return ListView(
            children: [
              EtzanCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.upcomingBookings.tr(context: context),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      snapshot.connectionState != ConnectionState.done
                          ? LocaleKeys.loading.tr(context: context)
                          : LocaleKeys.upcomingSessionsCount.tr(
                              context: context,
                              namedArgs: {'count': '${bookings.length}'},
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState != ConnectionState.done)
                const EtzanLoadingCard()
              else if (bookings.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noUpcomingEvents.tr(context: context),
                  body: LocaleKeys.upcomingBookingsDescription.tr(
                    context: context,
                  ),
                )
              else
                ...bookings.map(
                  (booking) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: CalendarEventCard(
                      icon: Icons.video_call,
                      title: sessionTypeLabel(context, booking.sessionType),
                      time:
                          '${growthDateLabel(booking.startsAt)} • ${growthTimeLabel(context, booking.startsAt)}',
                      color: AppColors.primary,
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
