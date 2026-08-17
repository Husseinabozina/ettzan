import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coach_booking_header_card.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/coaching_labels.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/selectable_card.dart';

class BookSessionScreen extends StatefulWidget {
  const BookSessionScreen({super.key});

  @override
  State<BookSessionScreen> createState() => _BookSessionScreenState();
}

class _BookSessionScreenState extends State<BookSessionScreen> {
  Future<_BookingData?>? _future;
  int _sessionType = 0;
  int _slot = 0;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _loadBookingData();
  }

  Future<_BookingData?> _loadBookingData() async {
    final argument = ModalRoute.of(context)?.settings.arguments;
    CoachItem? coach = argument is CoachItem ? argument : null;

    if (coach == null) {
      final coaches = await getIt<EtzanBackendRepository>().getCoaches();
      if (coaches.isEmpty) return null;
      coach = coaches.first;
    }

    final slots =
        await getIt<EtzanBackendRepository>().getCoachAvailability(coach.id);
    return _BookingData(coach: coach, slots: slots);
  }

  Future<void> _book(AvailabilityItem availability) async {
    setState(() => _saving = true);
    try {
      await getIt<EtzanBackendRepository>().createBooking(
        availability: availability,
        sessionType: _sessionType == 0 ? 'individual' : 'intensive',
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.upcomingSessions);
    } on AppFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message.tr(context: context))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.bookingConfirmError.tr(context: context),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.bookSession.tr(context: context),
      child: FutureBuilder<_BookingData?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(children: const [EtzanLoadingCard()]);
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

          final data = snapshot.data;
          if (data == null) {
            return ListView(
              children: [
                EtzanEmptyState(
                  title: LocaleKeys.noCoaches.tr(context: context),
                  body: LocaleKeys.addCoachesAndAvailability.tr(
                    context: context,
                  ),
                ),
              ],
            );
          }

          final selectedSlot = data.slots.isEmpty
              ? null
              : data.slots[_slot.clamp(0, data.slots.length - 1).toInt()];

          return ListView(
            children: [
              CoachBookingHeaderCard(coach: data.coach),
              const SizedBox(height: AppSpacing.lg),
              EtzanSectionTitle(
                title: LocaleKeys.sessionType.tr(context: context),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: SelectableCard(
                      selected: _sessionType == 0,
                      title: LocaleKeys.individualSession.tr(context: context),
                      subtitle: LocaleKeys.durationMinutes.tr(
                        context: context,
                        namedArgs: {'count': '60'},
                      ),
                      onTap: () => setState(() => _sessionType = 0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SelectableCard(
                      selected: _sessionType == 1,
                      title: LocaleKeys.intensiveSession.tr(context: context),
                      subtitle: LocaleKeys.durationMinutes.tr(
                        context: context,
                        namedArgs: {'count': '90'},
                      ),
                      onTap: () => setState(() => _sessionType = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              EtzanSectionTitle(
                title: LocaleKeys.chooseTime.tr(context: context),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (data.slots.isEmpty)
                EtzanEmptyState(
                  title: LocaleKeys.noAvailability.tr(context: context),
                  body: LocaleKeys.addCoachAvailability.tr(context: context),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    data.slots.length,
                    (index) => SizedBox(
                      width: 150,
                      child: SelectableCard(
                        selected: _slot == index,
                        title: '${coachingDateLabel(data.slots[index].startsAt)}\n'
                            '${coachingTimeLabel(context, data.slots[index].startsAt)}',
                        onTap: () => setState(() => _slot = index),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              EtzanPrimaryButton(
                label: _saving
                    ? LocaleKeys.bookingInProgress.tr(context: context)
                    : LocaleKeys.confirmBooking.tr(context: context),
                onPressed: selectedSlot == null || _saving
                    ? null
                    : () => _book(selectedSlot),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingData {
  const _BookingData({required this.coach, required this.slots});

  final CoachItem coach;
  final List<AvailabilityItem> slots;
}
