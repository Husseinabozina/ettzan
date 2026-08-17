import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/availability_slot_tile.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/components/session_summary_card.dart';

class SessionDetailsScreen extends StatefulWidget {
  const SessionDetailsScreen({super.key});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  Future<BookingItem?>? _future;
  BookingItem? _currentBooking;
  bool _working = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _resolveBooking();
  }

  Future<BookingItem?> _resolveBooking() async {
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (_currentBooking == null && argument is BookingItem) {
      _currentBooking = argument;
    }

    if (_currentBooking != null) return _currentBooking;

    final bookings =
        await getIt<EtzanBackendRepository>().getBookings(past: false);
    return bookings.isEmpty ? null : bookings.first;
  }

  void _showMessage(String messageKey) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageKey.tr(context: context))),
    );
  }

  Future<void> _copyMeetingLink(BookingItem booking) async {
    final url = booking.meetingUrl;
    if (url == null || url.trim().isEmpty) return;

    await Clipboard.setData(ClipboardData(text: url));
    _showMessage(LocaleKeys.meetingLinkCopied);
  }

  Future<void> _cancelBooking(BookingItem booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          LocaleKeys.cancelSessionTitle.tr(context: dialogContext),
        ),
        content: Text(
          LocaleKeys.cancelSessionBody.tr(context: dialogContext),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              LocaleKeys.back.tr(context: dialogContext),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              LocaleKeys.cancelBooking.tr(context: dialogContext),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _working = true);
    try {
      await getIt<EtzanBackendRepository>().cancelBooking(booking.id);
      if (!mounted) return;
      _showMessage(LocaleKeys.bookingCancelled);
      Navigator.of(context).pop(true);
    } on AppFailure catch (failure) {
      _showMessage(failure.message);
    } catch (_) {
      _showMessage(LocaleKeys.bookingCancelError);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _rescheduleBooking(BookingItem booking) async {
    setState(() => _working = true);

    List<AvailabilityItem> slots;
    try {
      slots = await getIt<EtzanBackendRepository>()
          .getCoachAvailability(booking.coachId);
    } catch (_) {
      _showMessage(LocaleKeys.availabilityLoadError);
      if (mounted) setState(() => _working = false);
      return;
    }

    if (mounted) setState(() => _working = false);
    if (!mounted) return;

    if (slots.isEmpty) {
      _showMessage(LocaleKeys.noAlternativeSlots);
      return;
    }

    final selected = await showModalBottomSheet<AvailabilityItem>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          shrinkWrap: true,
          children: [
            Text(
              LocaleKeys.chooseNewTime.tr(context: sheetContext),
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ...slots.map(
              (slot) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AvailabilitySlotTile(
                  slot: slot,
                  onTap: () => Navigator.of(sheetContext).pop(slot),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null) return;

    setState(() => _working = true);
    try {
      await getIt<EtzanBackendRepository>().rescheduleBooking(
        bookingId: booking.id,
        availabilityId: selected.id,
      );

      final updatedBookings =
          await getIt<EtzanBackendRepository>().getBookings(past: false);

      BookingItem? updatedBooking;
      for (final item in updatedBookings) {
        if (item.id == booking.id) {
          updatedBooking = item;
          break;
        }
      }

      final resolvedBooking = updatedBooking ?? booking;
      if (!mounted) return;

      setState(() {
        _currentBooking = resolvedBooking;
        _future = Future.value(resolvedBooking);
      });

      _showMessage(LocaleKeys.bookingRescheduled);
    } on AppFailure catch (failure) {
      _showMessage(failure.message);
    } catch (_) {
      _showMessage(LocaleKeys.bookingRescheduleError);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtzanPage(
      title: LocaleKeys.sessionDetails.tr(context: context),
      child: FutureBuilder<BookingItem?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              children: const [
                EtzanLoadingCard(height: 220),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title:
                      LocaleKeys.sessionDetailsLoadError.tr(context: context),
                  body: LocaleKeys.tryAgainLater.tr(context: context),
                ),
              ],
            );
          }

          final booking = snapshot.data;
          if (booking == null) {
            return ListView(
              children: [
                const SizedBox(height: 90),
                EtzanEmptyState(
                  title: LocaleKeys.noUpcomingSession.tr(context: context),
                  body:
                      LocaleKeys.bookSessionToSeeDetails.tr(context: context),
                ),
              ],
            );
          }

          return ListView(
            children: [
              SessionSummaryCard(booking: booking),
              const SizedBox(height: AppSpacing.xl),
              EtzanPrimaryButton(
                label: LocaleKeys.joinSession.tr(context: context),
                icon: Icons.video_call,
                onPressed: booking.meetingUrl == null || _working
                    ? null
                    : () => _copyMeetingLink(booking),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.tonalIcon(
                onPressed: _working
                    ? null
                    : () =>
                        Navigator.of(context).pushNamed(AppRoutes.coachChat),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(
                  LocaleKeys.coachChat.tr(context: context),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _working
                    ? null
                    : () => _rescheduleBooking(booking),
                icon: const Icon(Icons.event_repeat),
                label: Text(
                  LocaleKeys.reschedule.tr(context: context),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed:
                    _working ? null : () => _cancelBooking(booking),
                icon: const Icon(Icons.close),
                label: Text(
                  LocaleKeys.cancelBooking.tr(context: context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
