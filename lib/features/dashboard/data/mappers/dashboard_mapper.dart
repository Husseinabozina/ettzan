import 'package:etzan_life_coaching/features/dashboard/data/dto/dashboard_dto.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/entities/dashboard_summary.dart';

extension DashboardDtoMapper on DashboardDto {
  DashboardSummary toDomain() => DashboardSummary(
        firstName: firstName,
        monthlyProgress: monthlyRatio.clamp(0.0, 1.0).toDouble(),
        completedSessions: completedSessions,
        supportHours: supportHours,
        completedTasks: completedTasks,
        upcomingSession: session?.toDomain(),
        dailyNudge: dailyNudge,
      );
}

extension CoachingSessionDtoMapper on CoachingSessionDto {
  CoachingSession toDomain() => CoachingSession(
        id: id,
        title: title,
        coachName: coachName,
        startsAt: DateTime.parse(startsAt),
        durationMinutes: durationMinutes,
        isOnline: isOnline,
      );
}
