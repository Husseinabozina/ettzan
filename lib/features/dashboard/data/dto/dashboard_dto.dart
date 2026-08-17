class DashboardDto {
  const DashboardDto({
    required this.firstName,
    required this.monthlyRatio,
    required this.completedSessions,
    required this.supportHours,
    required this.completedTasks,
    required this.session,
    required this.dailyNudge,
  });

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final progress = json['progress'] as Map<String, dynamic>;
    final session = json['next_session'] as Map<String, dynamic>?;
    return DashboardDto(
      firstName: user['first_name'] as String,
      monthlyRatio: (progress['monthly_ratio'] as num).toDouble(),
      completedSessions: progress['completed_sessions'] as int,
      supportHours: (progress['support_hours'] as num).toDouble(),
      completedTasks: progress['completed_tasks'] as int,
      session: session == null ? null : CoachingSessionDto.fromJson(session),
      dailyNudge: json['daily_nudge'] as String,
    );
  }

  final String firstName;
  final double monthlyRatio;
  final int completedSessions;
  final double supportHours;
  final int completedTasks;
  final CoachingSessionDto? session;
  final String dailyNudge;
}

class CoachingSessionDto {
  const CoachingSessionDto({
    required this.id,
    required this.title,
    required this.coachName,
    required this.startsAt,
    required this.durationMinutes,
    required this.isOnline,
  });

  factory CoachingSessionDto.fromJson(Map<String, dynamic> json) =>
      CoachingSessionDto(
        id: json['id'] as String,
        title: json['title'] as String,
        coachName: json['coach_name'] as String,
        startsAt: json['starts_at'] as String,
        durationMinutes: json['duration_minutes'] as int,
        isOnline: json['is_online'] as bool,
      );

  final String id;
  final String title;
  final String coachName;
  final String startsAt;
  final int durationMinutes;
  final bool isOnline;
}
