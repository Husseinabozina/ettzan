import 'package:etzan_life_coaching/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboard {
  const GetDashboard(this._repository);

  final DashboardRepository _repository;

  Future<DashboardSummary> call() => _repository.getDashboard();
}
