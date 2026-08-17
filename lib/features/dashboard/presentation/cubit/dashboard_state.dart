part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState._({required this.status, this.summary, this.message});

  const DashboardState.initial() : this._(status: DashboardStatus.initial);
  const DashboardState.loading() : this._(status: DashboardStatus.loading);
  const DashboardState.success(DashboardSummary summary)
      : this._(status: DashboardStatus.success, summary: summary);
  const DashboardState.failure(String message)
      : this._(status: DashboardStatus.failure, message: message);

  final DashboardStatus status;
  final DashboardSummary? summary;
  final String? message;

  @override
  List<Object?> get props => [status, summary, message];
}
