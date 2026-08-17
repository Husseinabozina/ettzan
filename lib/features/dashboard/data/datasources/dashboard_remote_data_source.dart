import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/features/dashboard/data/dto/dashboard_dto.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardDto> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<DashboardDto> getDashboard() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AppFailure(LocaleKeys.loginSessionExpired,
          code: 'auth_required');
    }

    final profile = await _supabase
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .maybeSingle();
    final goals = await _supabase
        .from('goals')
        .select('progress,is_completed')
        .eq('user_id', user.id);
    final completedBookings = await _supabase
        .from('bookings')
        .select('starts_at,ends_at')
        .eq('user_id', user.id)
        .eq('status', 'completed');
    final nextBooking = await _supabase
        .from('bookings')
        .select('id,coach_id,starts_at,ends_at,session_type,meeting_url')
        .eq('user_id', user.id)
        .inFilter('status', ['confirmed', 'pending'])
        .gte('starts_at', DateTime.now().toUtc().toIso8601String())
        .order('starts_at')
        .limit(1)
        .maybeSingle();

    final goalRows = (goals as List<dynamic>).cast<Map<String, dynamic>>();
    final bookingRows =
        (completedBookings as List<dynamic>).cast<Map<String, dynamic>>();
    final progress = goalRows.isEmpty
        ? 0.0
        : goalRows
                .map((g) => (g['progress'] as num?)?.toDouble() ?? 0)
                .reduce((a, b) => a + b) /
            goalRows.length /
            100;
    final supportHours = bookingRows.fold<double>(0, (sum, booking) {
      final start = DateTime.tryParse(booking['starts_at'] as String? ?? '');
      final end = DateTime.tryParse(booking['ends_at'] as String? ?? '');
      if (start == null || end == null) return sum;
      return sum + end.difference(start).inMinutes / 60;
    });

    Map<String, dynamic>? sessionJson;
    if (nextBooking != null) {
      final coach = await _supabase
          .from('coach_profiles')
          .select('user_id')
          .eq('id', nextBooking['coach_id'])
          .maybeSingle();
      final coachUserId = coach?['user_id'] as String?;
      final coachProfile = coachUserId == null
          ? null
          : await _supabase
              .from('profiles')
              .select('full_name')
              .eq('id', coachUserId)
              .maybeSingle();
      final startsAt = DateTime.parse(nextBooking['starts_at'] as String);
      final endsAt = DateTime.parse(nextBooking['ends_at'] as String);
      sessionJson = {
        'id': nextBooking['id'],
        'title': _sessionTitle(nextBooking['session_type'] as String?),
        'coach_name': coachProfile?['full_name'] ?? 'مدرب اتزان',
        'starts_at': startsAt.toIso8601String(),
        'duration_minutes': endsAt.difference(startsAt).inMinutes,
        'is_online': nextBooking['meeting_url'] != null,
      };
    } else {
      sessionJson = null;
    }

    final fullName = ((profile?['full_name'] as String?) ??
            (user.userMetadata?['full_name'] as String?) ??
            user.email)
        ?.trim();
    final firstName = (fullName == null || fullName.isEmpty)
        ? 'صديقنا'
        : fullName.split(RegExp(r'\s+')).first;

    return DashboardDto.fromJson({
      'user': {'first_name': firstName},
      'progress': {
        'monthly_ratio': progress.clamp(0.0, 1.0),
        'completed_sessions': bookingRows.length,
        'support_hours': supportHours,
        'completed_tasks':
            goalRows.where((g) => g['is_completed'] == true).length,
      },
      'next_session': sessionJson,
      'daily_nudge': 'خطوة صغيرة اليوم تصنع فرقًا كبيرًا غدًا.',
    });
  }

  String _sessionTitle(String? type) => switch (type) {
        'intensive' => 'جلسة مكثفة',
        'individual' => 'جلسة فردية',
        _ => 'جلسة كوتشينج',
      };
}
