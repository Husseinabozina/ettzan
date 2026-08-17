import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/usecases/get_dashboard.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getDashboard) : super(const DashboardState.initial());

  final GetDashboard _getDashboard;

  Future<void> load() async {
    emit(const DashboardState.loading());
    try {
      final summary = await _getDashboard();
      emit(DashboardState.success(summary));
    } on AppFailure catch (e) {
      emit(DashboardState.failure(e.message));
    } catch (_) {
      emit(const DashboardState.failure(LocaleKeys.dashboardLoadRetry));
    }
  }
}
