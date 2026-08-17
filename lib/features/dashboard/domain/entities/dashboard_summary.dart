import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.firstName,
    required this.monthlyProgress,
    required this.completedSessions,
    required this.supportHours,
    required this.completedTasks,
    this.upcomingSession,
    required this.dailyNudge,
  });

  final String firstName;
  final double monthlyProgress;
  final int completedSessions;
  final double supportHours;
  final int completedTasks;
  final CoachingSession? upcomingSession;
  final String dailyNudge;

  @override
  List<Object?> get props => [
        firstName,
        monthlyProgress,
        completedSessions,
        supportHours,
        completedTasks,
        upcomingSession,
        dailyNudge,
      ];
}

class CoachingSession extends Equatable {
  const CoachingSession({
    required this.id,
    required this.title,
    required this.coachName,
    required this.startsAt,
    required this.durationMinutes,
    required this.isOnline,
  });

  final String id;
  final String title;
  final String coachName;
  final DateTime startsAt;
  final int durationMinutes;
  final bool isOnline;

  @override
  List<Object?> get props =>
      [id, title, coachName, startsAt, durationMinutes, isOnline];
}
