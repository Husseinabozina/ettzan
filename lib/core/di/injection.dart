import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etzan_life_coaching/core/data/etzan_backend_repository.dart';
import 'package:etzan_life_coaching/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:etzan_life_coaching/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/send_password_reset.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/sign_in.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/sign_in_as_guest.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/sign_up.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:etzan_life_coaching/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:etzan_life_coaching/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:etzan_life_coaching/features/dashboard/domain/usecases/get_dashboard.dart';
import 'package:etzan_life_coaching/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:etzan_life_coaching/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:etzan_life_coaching/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:etzan_life_coaching/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:etzan_life_coaching/features/notifications/domain/usecases/get_notifications.dart';
import 'package:etzan_life_coaching/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:etzan_life_coaching/features/notifications/domain/usecases/watch_notifications.dart';
import 'package:etzan_life_coaching/features/notifications/presentation/cubit/notifications_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SupabaseClient>()) return;

  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<EtzanBackendRepository>(
    () => EtzanBackendRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthRemoteDataSource(getIt()),
  );
  getIt
      .registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => SignIn(getIt()));
  getIt.registerLazySingleton(() => SignInAsGuest(getIt()));
  getIt.registerLazySingleton(() => SignUp(getIt()));
  getIt.registerLazySingleton(() => SignInWithGoogle(getIt()));
  getIt.registerLazySingleton(() => SendPasswordReset(getIt()));
  getIt.registerFactory(
      () => AuthCubit(getIt(), getIt(), getIt(), getIt(), getIt(), getIt()));

  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetDashboard(getIt()));
  getIt.registerFactory(() => DashboardCubit(getIt()));

  getIt.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetNotifications(getIt()));
  getIt.registerLazySingleton(() => MarkNotificationAsRead(getIt()));
  getIt.registerLazySingleton(() => WatchNotifications(getIt()));
  getIt.registerFactory(() => NotificationsCubit(getIt(), getIt(), getIt()));
}
