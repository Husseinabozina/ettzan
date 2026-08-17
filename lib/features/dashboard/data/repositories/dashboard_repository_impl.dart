import 'package:etzan_life_coaching/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:etzan_life_coaching/features/dashboard/data/mappers/dashboard_mapper.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardSummary> getDashboard() async {
    final dto = await _remoteDataSource.getDashboard();
    return dto.toDomain();
  }
}
