import 'package:etzan_life_coaching/features/dashboard/domain/entities/dashboard_summary.dart';

abstract interface class DashboardRepository {
  Future<DashboardSummary> getDashboard();
}
