import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';

import 'package:etzan_life_coaching/features/account/presentation/pages/profile_page.dart';
import 'package:etzan_life_coaching/features/account/presentation/pages/resource_web_view_page.dart';
import 'package:etzan_life_coaching/features/account/presentation/pages/resources_page.dart';
import 'package:etzan_life_coaching/features/account/presentation/pages/settings_page.dart';
import 'package:etzan_life_coaching/features/account/presentation/pages/subscription_page.dart';

import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';
import 'package:etzan_life_coaching/features/auth/presentation/auth_screens.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:etzan_life_coaching/features/auth/presentation/pages/sign_in_required_page.dart';

import 'package:etzan_life_coaching/features/coaching/presentation/pages/book_session_page.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/pages/coach_chat_page.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/pages/coach_profile_page.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/pages/discover_coaches_page.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/pages/session_details_page.dart';
import 'package:etzan_life_coaching/features/coaching/presentation/pages/upcoming_sessions_page.dart';

import 'package:etzan_life_coaching/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:etzan_life_coaching/features/dashboard/presentation/pages/guest_home_page.dart';
import 'package:etzan_life_coaching/features/dashboard/presentation/pages/home_dashboard_page.dart';

import 'package:etzan_life_coaching/features/growth/presentation/pages/calendar_page.dart';
import 'package:etzan_life_coaching/features/growth/presentation/pages/create_goal_page.dart';
import 'package:etzan_life_coaching/features/growth/presentation/pages/daily_plan_page.dart';
import 'package:etzan_life_coaching/features/growth/presentation/pages/goals_overview_page.dart';
import 'package:etzan_life_coaching/features/growth/presentation/pages/habits_page.dart';

import 'package:etzan_life_coaching/features/journal/presentation/pages/journal_entry_page.dart';
import 'package:etzan_life_coaching/features/journal/presentation/pages/journal_home_page.dart';
import 'package:etzan_life_coaching/features/journal/presentation/pages/progress_analytics_page.dart';

import 'package:etzan_life_coaching/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:etzan_life_coaching/features/notifications/presentation/pages/notifications_page.dart';

abstract final class AppRouter {
  static const _protectedRoutes = <String>{
    AppRoutes.upcomingSessions,
    AppRoutes.bookSession,
    AppRoutes.goalsOverview,
    AppRoutes.createGoal,
    AppRoutes.habits,
    AppRoutes.dailyPlan,
    AppRoutes.calendar,
    AppRoutes.journalHome,
    AppRoutes.journalEntry,
    AppRoutes.progress,
    AppRoutes.sessionDetails,
    AppRoutes.coachChat,
    AppRoutes.notifications,
    AppRoutes.subscription,
    AppRoutes.profile,
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final user = getIt<AuthRepository>().currentUser;
    final isGuest = user?.isGuest ?? false;
    final useGuestHome = user == null || isGuest;

    final needsAccount =
        useGuestHome && _protectedRoutes.contains(settings.name);

    final page = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),

      AppRoutes.onboardingGoals => const OnboardingGoalsScreen(),

      AppRoutes.onboardingCoach => const OnboardingCoachScreen(),

      AppRoutes.signUp => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const SignUpScreen(),
        ),

      AppRoutes.login => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const LoginScreen(),
        ),

      AppRoutes.home => useGuestHome
          ? const GuestHomePage()
          : BlocProvider(
              create: (_) => getIt<DashboardCubit>()..load(),
              child: const HomeDashboardScreen(),
            ),

      // Coaching
      AppRoutes.discoverCoaches => const DiscoverCoachesScreen(),

      AppRoutes.coachProfile => const CoachProfileScreen(),

      AppRoutes.bookSession => const BookSessionScreen(),

      AppRoutes.upcomingSessions => const UpcomingSessionsScreen(),

      AppRoutes.sessionDetails => const SessionDetailsScreen(),

      AppRoutes.coachChat => const CoachChatScreen(),

      // Growth
      AppRoutes.goalsOverview => const GoalsOverviewScreen(),

      AppRoutes.createGoal => const CreateGoalScreen(),

      AppRoutes.habits => const HabitsScreen(),

      AppRoutes.dailyPlan => const DailyPlanScreen(),

      AppRoutes.calendar => const CalendarScreen(),

      // Journal
      AppRoutes.journalHome => const JournalHomeScreen(),

      AppRoutes.journalEntry => const JournalEntryScreen(),

      AppRoutes.progress => const ProgressAnalyticsScreen(),

      // Notifications
      AppRoutes.notifications => BlocProvider(
          create: (_) => getIt<NotificationsCubit>()..load(),
          child: const NotificationsScreen(),
        ),

      // Account
      AppRoutes.resources => const ResourcesScreen(),

      AppRoutes.resourceViewer => const ResourceWebViewScreen(),

      AppRoutes.subscription => const SubscriptionScreen(),

      AppRoutes.profile => const ProfileScreen(),

      AppRoutes.settings => const SettingsScreen(),

      _ => useGuestHome
          ? const GuestHomePage()
          : BlocProvider(
              create: (_) => getIt<DashboardCubit>()..load(),
              child: const HomeDashboardScreen(),
            ),
    };

    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) =>
          needsAccount ? const SignInRequiredPage() : page,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.025, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}