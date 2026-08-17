import 'package:flutter_test/flutter_test.dart';
import 'package:etzan_life_coaching/features/dashboard/data/dto/dashboard_dto.dart';
import 'package:etzan_life_coaching/features/dashboard/data/mappers/dashboard_mapper.dart';

void main() {
  test('dashboard mapper exposes business-facing domain names', () {
    const dto = DashboardDto(
      firstName: 'سارة',
      monthlyRatio: 0.78,
      completedSessions: 6,
      supportHours: 8.5,
      completedTasks: 12,
      session: CoachingSessionDto(
        id: 's1',
        title: 'جلسة دعم',
        coachName: 'هبة',
        startsAt: '2026-08-09T19:00:00+03:00',
        durationMinutes: 60,
        isOnline: true,
      ),
      dailyNudge: 'خطوة صغيرة.',
    );

    final domain = dto.toDomain();

    expect(domain.firstName, 'سارة');
    expect(domain.monthlyProgress, 0.78);
    expect(domain.supportHours, 8.5);
    expect(domain.upcomingSession!.coachName, 'هبة');
  });
}
