import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EtzanBackendRepository {
  const EtzanBackendRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) {
      throw const AppFailure(
        LocaleKeys.loginSessionExpired,
        code: 'auth_required',
      );
    }
    return id;
  }

  User get _user {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AppFailure(
        LocaleKeys.loginSessionExpired,
        code: 'auth_required',
      );
    }
    return user;
  }

  Future<ProfileOverview> getProfileOverview() async {
    final user = _user;
    final profile = await _supabase
        .from('profiles')
        .select('full_name,avatar_url,role,locale,timezone')
        .eq('id', user.id)
        .maybeSingle();

    final completedBookings = await _supabase
        .from('bookings')
        .select('id')
        .eq('user_id', user.id)
        .eq('status', 'completed');
    final goals =
        await _supabase.from('goals').select('id').eq('user_id', user.id);

    final today = DateTime.now();
    final from = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6))
        .toIso8601String()
        .substring(0, 10);
    final habitLogs = await _supabase
        .from('habit_logs')
        .select('completed_on')
        .eq('user_id', user.id)
        .gte('completed_on', from);

    final name = ((profile?['full_name'] as String?) ??
            (user.userMetadata?['full_name'] as String?) ??
            user.email ??
            'مستخدم اتزان')
        .trim();
    final logDays = (habitLogs as List<dynamic>)
        .map((row) => (row as Map)['completed_on'] as String?)
        .whereType<String>()
        .toSet();

    return ProfileOverview(
      fullName: name.isEmpty ? 'مستخدم اتزان' : name,
      email: user.email ?? '',
      avatarUrl: profile?['avatar_url'] as String?,
      completedSessions: (completedBookings as List<dynamic>).length,
      goalsCount: (goals as List<dynamic>).length,
      streakDays: logDays.length,
    );
  }

  Future<void> updateProfileName(String fullName) async {
    final name = fullName.trim();
    if (name.isEmpty) {
      throw const AppFailure(LocaleKeys.profileNameRequired,
          code: 'invalid_profile');
    }
    await _supabase.from('profiles').update({
      'full_name': name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', _userId);
    await _supabase.auth.updateUser(UserAttributes(data: {'full_name': name}));
  }

  Future<UserPreferences> getUserPreferences() async {
    final userId = _userId;
    final row = await _supabase
        .from('user_preferences')
        .select(
          'user_id,reminders_enabled,motivation_enabled,offers_enabled,updated_at',
        )
        .eq('user_id', userId)
        .maybeSingle();

    if (row != null) {
      return UserPreferences.fromJson(Map<String, dynamic>.from(row));
    }

    final inserted = await _supabase
        .from('user_preferences')
        .insert({'user_id': userId})
        .select(
          'user_id,reminders_enabled,motivation_enabled,offers_enabled,updated_at',
        )
        .single();
    return UserPreferences.fromJson(Map<String, dynamic>.from(inserted));
  }

  Future<UserPreferences> updateUserPreferences(
    UserPreferences preferences,
  ) async {
    final row = await _supabase
        .from('user_preferences')
        .upsert(
          {
            'user_id': _userId,
            'reminders_enabled': preferences.remindersEnabled,
            'motivation_enabled': preferences.motivationEnabled,
            'offers_enabled': preferences.offersEnabled,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'user_id',
        )
        .select(
          'user_id,reminders_enabled,motivation_enabled,offers_enabled,updated_at',
        )
        .single();
    return UserPreferences.fromJson(Map<String, dynamic>.from(row));
  }

  Future<List<ResourceItem>> getResources() async {
    final rows = await _supabase
        .from('resources')
        .select(
          'id,title_ar,title_en,description_ar,description_en,category,resource_type,content_url,thumbnail_url,is_premium,created_at',
        )
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(100);

    return (rows as List<dynamic>)
        .map((row) =>
            ResourceItem.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<List<SubscriptionPlanItem>> getSubscriptionPlans() async {
    final rows = await _supabase
        .from('subscription_plans')
        .select('id,code,name_ar,name_en,price_monthly,price_yearly,features')
        .eq('is_active', true)
        .order('price_monthly');

    return (rows as List<dynamic>)
        .map((row) => SubscriptionPlanItem.fromJson(
            Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<String?> getCurrentSubscriptionPlanId() async {
    final row = await _supabase
        .from('user_subscriptions')
        .select('plan_id,status')
        .eq('user_id', _userId)
        .inFilter('status', ['trialing', 'active'])
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return row?['plan_id'] as String?;
  }

  Future<void> chooseSubscriptionPlan(String planId) async {
    final userId = _userId;
    final existing = await _supabase
        .from('user_subscriptions')
        .select('id')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final payload = {
      'plan_id': planId,
      'status': 'trialing',
      'provider': 'manual-app',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (existing == null) {
      await _supabase.from('user_subscriptions').insert({
        'user_id': userId,
        ...payload,
      });
      return;
    }

    await _supabase
        .from('user_subscriptions')
        .update(payload)
        .eq('id', existing['id'] as String);
  }

  Future<List<CoachItem>> getCoaches() async {
    final rows = await _supabase
        .from('coach_profiles')
        .select(
          'id,user_id,bio,years_experience,hourly_rate,rating,review_count,is_verified,is_active',
        )
        .eq('is_active', true)
        .order('rating', ascending: false);

    final coachRows = (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    if (coachRows.isEmpty) return const [];

    final userIds = coachRows.map((row) => row['user_id'] as String).toList();
    final profiles = await _supabase
        .from('profiles')
        .select('id,full_name,avatar_url')
        .inFilter('id', userIds);
    final profileById = {
      for (final row in (profiles as List<dynamic>))
        (row as Map)['id'] as String: Map<String, dynamic>.from(row),
    };

    final coachIds = coachRows.map((row) => row['id'] as String).toList();
    final specialtyRows = await _supabase
        .from('coach_specialties')
        .select('coach_id,specialties(name_ar,name_en,slug)')
        .inFilter('coach_id', coachIds);
    final specialtiesByCoach = <String, List<String>>{};
    for (final raw in specialtyRows as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final coachId = row['coach_id'] as String;
      final specialty = row['specialties'] as Map?;
      final label = specialty?['name_ar'] as String?;
      if (label == null) continue;
      specialtiesByCoach.putIfAbsent(coachId, () => <String>[]).add(label);
    }

    return coachRows.map((row) {
      final profile = profileById[row['user_id'] as String];
      return CoachItem.fromJson(
        row,
        profile: profile,
        specialties: specialtiesByCoach[row['id'] as String] ?? const [],
      );
    }).toList(growable: false);
  }

  Future<List<GuestQuote>> getGuestQuotes() async {
    final rows = await _supabase
        .from('guest_quotes')
        .select('id,text_ar,text_en,sort_order')
        .eq('is_active', true)
        .order('sort_order')
        .limit(20);

    return (rows as List<dynamic>)
        .map((row) =>
            GuestQuote.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<CoachItem?> getCoach(String id) async {
    final coaches = await getCoaches();
    for (final coach in coaches) {
      if (coach.id == id) return coach;
    }
    return null;
  }

  Future<List<AvailabilityItem>> getCoachAvailability(String coachId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = await _supabase
        .from('coach_availability')
        .select('id,coach_id,starts_at,ends_at,is_booked')
        .eq('coach_id', coachId)
        .eq('is_booked', false)
        .gte('starts_at', now)
        .order('starts_at')
        .limit(50);

    return (rows as List<dynamic>)
        .map((row) =>
            AvailabilityItem.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<void> createBooking({
    required AvailabilityItem availability,
    required String sessionType,
  }) async {
    try {
      await _supabase.rpc(
        'create_booking_from_slot',
        params: {
          'p_availability_id': availability.id,
          'p_session_type': sessionType,
          'p_notes': null,
        },
      );
    } on PostgrestException catch (e) {
      final message = e.message.toUpperCase();
      if (message.contains('SLOT_ALREADY_BOOKED')) {
        throw const AppFailure(
          LocaleKeys.slotAlreadyBooked,
          code: 'slot_already_booked',
        );
      }
      if (message.contains('SLOT_IN_PAST') ||
          message.contains('SLOT_NOT_FOUND')) {
        throw const AppFailure(
          LocaleKeys.slotNoLongerAvailable,
          code: 'slot_unavailable',
        );
      }
      rethrow;
    }
  }

  Future<List<BookingItem>> getBookings({required bool past}) async {
    final userId = _userId;
    final query = _supabase
        .from('bookings')
        .select(
          'id,coach_id,availability_id,starts_at,ends_at,status,session_type,notes,meeting_url',
        )
        .eq('user_id', userId);
    final rows = past
        ? await query.inFilter('status', ['completed', 'cancelled']).order(
            'starts_at',
            ascending: false,
          )
        : await query
            .inFilter('status', ['pending', 'confirmed'])
            .gte('starts_at', DateTime.now().toUtc().toIso8601String())
            .order('starts_at');

    final bookingRows = (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    if (bookingRows.isEmpty) return const [];

    final coachIds =
        bookingRows.map((row) => row['coach_id'] as String).toSet().toList();
    final coachRows = await _supabase
        .from('coach_profiles')
        .select('id,user_id')
        .inFilter('id', coachIds);
    final coachById = {
      for (final row in (coachRows as List<dynamic>))
        (row as Map)['id'] as String: Map<String, dynamic>.from(row),
    };
    final userIds =
        coachById.values.map((row) => row['user_id'] as String).toList();
    final profiles = userIds.isEmpty
        ? <dynamic>[]
        : await _supabase
            .from('profiles')
            .select('id,full_name')
            .inFilter('id', userIds);
    final profileById = {
      for (final row in profiles)
        (row as Map)['id'] as String: Map<String, dynamic>.from(row),
    };

    return bookingRows.map((row) {
      final coach = coachById[row['coach_id'] as String];
      final profile =
          coach == null ? null : profileById[coach['user_id'] as String];
      return BookingItem.fromJson(row,
          coachName: profile?['full_name'] as String?);
    }).toList(growable: false);
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _supabase.rpc(
        'cancel_booking',
        params: {'p_booking_id': bookingId},
      );
    } on PostgrestException catch (e) {
      final message = e.message.toUpperCase();
      if (message.contains('BOOKING_ALREADY_COMPLETED')) {
        throw const AppFailure(
          LocaleKeys.cancelCompletedSessionError,
          code: 'booking_completed',
        );
      }
      if (message.contains('BOOKING_NOT_FOUND') ||
          message.contains('FORBIDDEN')) {
        throw const AppFailure(
          LocaleKeys.bookingModifyError,
          code: 'booking_unavailable',
        );
      }
      rethrow;
    }
  }

  Future<void> rescheduleBooking({
    required String bookingId,
    required String availabilityId,
  }) async {
    try {
      await _supabase.rpc(
        'reschedule_booking',
        params: {
          'p_booking_id': bookingId,
          'p_new_availability_id': availabilityId,
        },
      );
    } on PostgrestException catch (e) {
      final message = e.message.toUpperCase();
      if (message.contains('SLOT_ALREADY_BOOKED')) {
        throw const AppFailure(
          LocaleKeys.slotAlreadyBooked,
          code: 'slot_already_booked',
        );
      }
      if (message.contains('BOOKING_NOT_RESCHEDULABLE')) {
        throw const AppFailure(
          LocaleKeys.bookingRescheduleNotAllowed,
          code: 'booking_not_reschedulable',
        );
      }
      if (message.contains('SLOT_IN_PAST') ||
          message.contains('SLOT_NOT_FOUND') ||
          message.contains('COACH_MISMATCH')) {
        throw const AppFailure(
          LocaleKeys.slotNoLongerAvailable,
          code: 'slot_unavailable',
        );
      }
      rethrow;
    }
  }

  Future<List<GoalItem>> getGoals() async {
    final rows = await _supabase
        .from('goals')
        .select(
            'id,title,description,category,target_date,progress,is_completed,created_at')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => GoalItem.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<void> createGoal({
    required String title,
    required String category,
    DateTime? targetDate,
    String? description,
    List<String> milestones = const [],
  }) async {
    final inserted = await _supabase
        .from('goals')
        .insert({
          'user_id': _userId,
          'title': title,
          'description': description,
          'category': category,
          'target_date': targetDate?.toIso8601String().substring(0, 10),
          'progress': 0,
          'is_completed': false,
        })
        .select('id')
        .single();

    final goalId = inserted['id'] as String;
    final rows = milestones
        .where((item) => item.trim().isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => {
            'goal_id': goalId,
            'title': entry.value.trim(),
            'position': entry.key + 1,
            'is_completed': false,
          },
        )
        .toList();
    if (rows.isNotEmpty) await _supabase.from('goal_milestones').insert(rows);
  }

  Future<void> updateGoalProgress({
    required String goalId,
    required double progress,
  }) async {
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    await _supabase
        .from('goals')
        .update({
          'progress': percent,
          'is_completed': percent >= 100,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', goalId)
        .eq('user_id', _userId);
  }

  Future<void> createHabit({
    required String title,
    String iconKey = 'habit',
    String frequency = 'daily',
    List<int>? days,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw const AppFailure(LocaleKeys.habitNameRequired,
          code: 'invalid_habit');
    }

    final nextOrder = await _nextHabitSortOrder();

    await _supabase.from('habits').insert({
      'user_id': _userId,
      'title': trimmedTitle,
      'icon_key': iconKey,
      'frequency': frequency,
      'days_of_week': days,
      'sort_order': nextOrder,
      'is_active': true,
    });
  }

  Future<int> _nextHabitSortOrder() async {
    final rows = await _supabase
        .from('habits')
        .select('sort_order')
        .eq('user_id', _userId)
        .eq('is_active', true)
        .order('sort_order', ascending: false)
        .limit(1);
    final maxOrder = rows.isEmpty
        ? -1
        : (rows.first as Map)['sort_order'] as num? ?? 0;
    return maxOrder.toInt() + 1;
  }

  Future<void> renameHabit({required String habitId, required String title}) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw const AppFailure(LocaleKeys.habitNameRequired,
          code: 'invalid_habit');
    }
    await _supabase
        .from('habits')
        .update({'title': trimmedTitle, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', habitId);
  }

  Future<void> deleteHabit(String habitId) async {
    await _supabase
        .from('habits')
        .update({'is_active': false, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', habitId);
  }

  Future<void> updateHabitDays({
    required String habitId,
    required List<int>? days,
  }) async {
    await _supabase
        .from('habits')
        .update({
          'days_of_week': days,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', habitId);
  }

  Future<void> reorderHabits(List<String> habitIds) async {
    final userId = _userId;
    final all = await _supabase
        .from('habits')
        .select('id,sort_order')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('sort_order')
        .order('created_at');
    final reordered = habitIds.toSet();
    final others = (all as List<dynamic>)
        .map((row) => (row as Map)['id'] as String)
        .where((id) => !reordered.contains(id))
        .toList();
    final finalOrder = [...habitIds, ...others];
    for (var index = 0; index < finalOrder.length; index++) {
      await _supabase
          .from('habits')
          .update({
            'sort_order': index,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', finalOrder[index]);
    }
  }

  Future<List<HabitStatusItem>> getAllActiveHabits() =>
      _loadHabits(daysFiltered: false);

  Future<List<HabitStatusItem>> getHabitsForToday() =>
      _loadHabits(daysFiltered: true);

  Future<List<HabitStatusItem>> _loadHabits({
    required bool daysFiltered,
  }) async {
    final userId = _userId;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final weekday = DateTime.now().weekday;
    final habits = await _supabase
        .from('habits')
        .select('id,title,icon_key,frequency,is_active,created_at,sort_order,days_of_week')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('sort_order')
        .order('created_at');
    final habitRows = (habits as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .where((row) {
          if (!daysFiltered) return true;
          final days = row['days_of_week'] as List?;
          if (days == null || days.isEmpty) return true;
          return days.any((day) => (day as num).toInt() == weekday);
        })
        .toList();
    if (habitRows.isEmpty) return const [];
    final habitIds = habitRows.map((row) => row['id'] as String).toList();
    final logs = await _supabase
        .from('habit_logs')
        .select('id,habit_id,completed_on')
        .eq('user_id', userId)
        .eq('completed_on', today)
        .inFilter('habit_id', habitIds);
    final completed = {
      for (final row in logs as List<dynamic>)
        (row as Map)['habit_id'] as String,
    };
    return habitRows
        .map((row) => HabitStatusItem.fromJson(row,
            completedToday: completed.contains(row['id'])))
        .toList(growable: false);
  }

  Future<void> setHabitCompleted({
    required String habitId,
    required bool completed,
  }) async {
    final userId = _userId;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (completed) {
      await _supabase.from('habit_logs').upsert(
        {'habit_id': habitId, 'user_id': userId, 'completed_on': today},
        onConflict: 'habit_id,user_id,completed_on',
      );
    } else {
      await _supabase
          .from('habit_logs')
          .delete()
          .eq('habit_id', habitId)
          .eq('user_id', userId)
          .eq('completed_on', today);
    }
  }

  Future<List<JournalEntryItem>> getJournalEntries() async {
    final rows = await _supabase
        .from('journal_entries')
        .select('id,title,body,mood,tags,created_at,updated_at')
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(100);

    return (rows as List<dynamic>)
        .map((row) =>
            JournalEntryItem.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<void> createJournalEntry({
    required String body,
    String? title,
    required int mood,
    List<String> tags = const [],
  }) async {
    await _supabase.from('journal_entries').insert({
      'user_id': _userId,
      'title': title?.trim().isEmpty == true ? null : title?.trim(),
      'body': body.trim(),
      'mood': mood,
      'tags': tags,
    });
  }

  Future<CoachChatThread> getOrCreateCoachChat() async {
    final userId = _userId;
    final coach = await _resolveChatCoach();
    if (coach == null) {
      throw const AppFailure(
        LocaleKeys.noCoachAvailableForChat,
        code: 'no_coach',
      );
    }

    final existing = await _supabase
        .from('conversations')
        .select('id,coach_id')
        .eq('user_id', userId)
        .eq('coach_id', coach.id)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    final conversationId = existing == null
        ? (await _supabase
            .from('conversations')
            .insert({'user_id': userId, 'coach_id': coach.id})
            .select('id')
            .single())['id'] as String
        : existing['id'] as String;

    return CoachChatThread(
      conversationId: conversationId,
      coach: coach,
      messages: await getChatMessages(conversationId),
    );
  }

  Future<List<ChatMessageItem>> getChatMessages(String conversationId) async {
    final rows = await _supabase
        .from('messages')
        .select(
            'id,conversation_id,sender_id,body,message_type,read_at,created_at')
        .eq('conversation_id', conversationId)
        .order('created_at')
        .limit(200);

    return (rows as List<dynamic>)
        .map((row) => ChatMessageItem.fromJson(
              Map<String, dynamic>.from(row as Map),
              currentUserId: _userId,
            ))
        .toList(growable: false);
  }

  Stream<List<ChatMessageItem>> watchChatMessages(String conversationId) {
    final userId = _userId;
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((rows) => rows
            .map((row) => ChatMessageItem.fromJson(
                  Map<String, dynamic>.from(row),
                  currentUserId: userId,
                ))
            .toList(growable: false));
  }

  Future<ChatMessageItem> sendChatMessage({
    required String conversationId,
    required String body,
  }) async {
    final text = body.trim();
    if (text.isEmpty) {
      throw const AppFailure(LocaleKeys.messageRequired, code: 'empty_message');
    }
    final userId = _userId;
    final row = await _supabase
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': userId,
          'body': text,
          'message_type': 'text',
        })
        .select(
            'id,conversation_id,sender_id,body,message_type,read_at,created_at')
        .single();
    try {
      await _supabase
          .from('conversations')
          .update({'updated_at': DateTime.now().toUtc().toIso8601String()}).eq(
              'id', conversationId);
    } catch (_) {
      // The message is already saved; a stale conversation timestamp should not
      // make the composer feel like sending failed.
    }
    return ChatMessageItem.fromJson(
      Map<String, dynamic>.from(row),
      currentUserId: userId,
    );
  }

  Future<CoachItem?> _resolveChatCoach() async {
    final upcoming = await _supabase
        .from('bookings')
        .select('coach_id')
        .eq('user_id', _userId)
        .inFilter('status', ['pending', 'confirmed'])
        .gte('starts_at', DateTime.now().toUtc().toIso8601String())
        .order('starts_at')
        .limit(1)
        .maybeSingle();
    final bookedCoachId = upcoming?['coach_id'] as String?;
    if (bookedCoachId != null) {
      final bookedCoach = await getCoach(bookedCoachId);
      if (bookedCoach != null) return bookedCoach;
    }

    final coaches = await getCoaches();
    return coaches.isEmpty ? null : coaches.first;
  }
}

class ProfileOverview {
  const ProfileOverview({
    required this.fullName,
    required this.email,
    required this.completedSessions,
    required this.goalsCount,
    required this.streakDays,
    this.avatarUrl,
  });

  final String fullName;
  final String email;
  final String? avatarUrl;
  final int completedSessions;
  final int goalsCount;
  final int streakDays;
}

class UserPreferences {
  const UserPreferences({
    required this.remindersEnabled,
    required this.motivationEnabled,
    required this.offersEnabled,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        remindersEnabled: json['reminders_enabled'] != false,
        motivationEnabled: json['motivation_enabled'] != false,
        offersEnabled: json['offers_enabled'] == true,
      );

  final bool remindersEnabled;
  final bool motivationEnabled;
  final bool offersEnabled;

  UserPreferences copyWith({
    bool? remindersEnabled,
    bool? motivationEnabled,
    bool? offersEnabled,
  }) =>
      UserPreferences(
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        motivationEnabled: motivationEnabled ?? this.motivationEnabled,
        offersEnabled: offersEnabled ?? this.offersEnabled,
      );
}

class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.isPremium,
    this.contentUrl,
    this.thumbnailUrl,
  });

  factory ResourceItem.fromJson(Map<String, dynamic> json) => ResourceItem(
        id: json['id'] as String,
        title: (json['title_ar'] as String?) ??
            (json['title_en'] as String? ?? ''),
        description: (json['description_ar'] as String?) ??
            (json['description_en'] as String? ?? ''),
        category: json['category'] as String? ?? 'عام',
        type: json['resource_type'] as String? ?? 'resource',
        isPremium: json['is_premium'] == true,
        contentUrl: json['content_url'] as String?,
        thumbnailUrl: json['thumbnail_url'] as String?,
      );

  final String id;
  final String title;
  final String description;
  final String category;
  final String type;
  final bool isPremium;
  final String? contentUrl;
  final String? thumbnailUrl;
}

class GuestQuote {
  const GuestQuote({
    required this.id,
    required this.textAr,
    required this.textEn,
  });

  factory GuestQuote.fromJson(Map<String, dynamic> json) => GuestQuote(
        id: json['id'].toString(),
        textAr: json['text_ar'] as String? ?? '',
        textEn: json['text_en'] as String? ?? '',
      );

  final String id;
  final String textAr;
  final String textEn;
}

class SubscriptionPlanItem {
  const SubscriptionPlanItem({
    required this.id,
    required this.code,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
  });

  factory SubscriptionPlanItem.fromJson(Map<String, dynamic> json) {
    final features = json['features'];
    return SubscriptionPlanItem(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      name: (json['name_ar'] as String?) ?? (json['name_en'] as String? ?? ''),
      monthlyPrice: (json['price_monthly'] as num?)?.toDouble() ?? 0,
      yearlyPrice: (json['price_yearly'] as num?)?.toDouble() ?? 0,
      features: features is List
          ? features.map((item) => item.toString()).toList(growable: false)
          : features is Map
              ? features.values
                  .map((item) => item.toString())
                  .toList(growable: false)
              : const [],
    );
  }

  final String id;
  final String code;
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
}

class CoachItem {
  const CoachItem({
    required this.id,
    required this.name,
    required this.bio,
    required this.yearsExperience,
    required this.hourlyRate,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.specialties,
    this.avatarUrl,
  });

  factory CoachItem.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? profile,
    List<String> specialties = const [],
  }) =>
      CoachItem(
        id: json['id'] as String,
        name: (profile?['full_name'] as String?) ?? 'مدرب اتزان',
        avatarUrl: profile?['avatar_url'] as String?,
        bio: json['bio'] as String? ?? 'مدرب معتمد من اتزان.',
        yearsExperience: (json['years_experience'] as num?)?.toInt() ?? 0,
        hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
        isVerified: json['is_verified'] == true,
        specialties: specialties,
      );

  final String id;
  final String name;
  final String? avatarUrl;
  final String bio;
  final int yearsExperience;
  final double hourlyRate;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final List<String> specialties;
}

class AvailabilityItem {
  const AvailabilityItem({
    required this.id,
    required this.coachId,
    required this.startsAt,
    required this.endsAt,
  });

  factory AvailabilityItem.fromJson(Map<String, dynamic> json) =>
      AvailabilityItem(
        id: json['id'] as String,
        coachId: json['coach_id'] as String,
        startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
        endsAt: DateTime.parse(json['ends_at'] as String).toLocal(),
      );

  final String id;
  final String coachId;
  final DateTime startsAt;
  final DateTime endsAt;

  int get durationMinutes => endsAt.difference(startsAt).inMinutes;
}

class BookingItem {
  const BookingItem({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.sessionType,
    this.availabilityId,
    this.meetingUrl,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json,
          {String? coachName}) =>
      BookingItem(
        id: json['id'] as String,
        coachId: json['coach_id'] as String,
        coachName: coachName ?? 'مدرب اتزان',
        availabilityId: json['availability_id'] as String?,
        startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
        endsAt: DateTime.parse(json['ends_at'] as String).toLocal(),
        status: json['status'] as String? ?? 'pending',
        sessionType: json['session_type'] as String? ?? 'individual',
        meetingUrl: json['meeting_url'] as String?,
      );

  final String id;
  final String coachId;
  final String coachName;
  final String? availabilityId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final String sessionType;
  final String? meetingUrl;
}

class GoalItem {
  const GoalItem({
    required this.id,
    required this.title,
    required this.category,
    required this.progress,
    required this.isCompleted,
    this.description,
    this.targetDate,
  });

  factory GoalItem.fromJson(Map<String, dynamic> json) => GoalItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        category: json['category'] as String? ?? 'عام',
        targetDate: json['target_date'] == null
            ? null
            : DateTime.tryParse(json['target_date'] as String),
        progress: ((json['progress'] as num?)?.toDouble() ?? 0) / 100,
        isCompleted: json['is_completed'] == true,
      );

  final String id;
  final String title;
  final String? description;
  final String category;
  final DateTime? targetDate;
  final double progress;
  final bool isCompleted;

  GoalItem copyWith({
    double? progress,
    bool? isCompleted,
  }) =>
      GoalItem(
        id: id,
        title: title,
        category: category,
        description: description,
        targetDate: targetDate,
        progress: progress ?? this.progress,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

class HabitStatusItem {
  const HabitStatusItem({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.frequency,
    required this.completedToday,
    this.sortOrder = 0,
    this.days,
  });

  factory HabitStatusItem.fromJson(
    Map<String, dynamic> json, {
    required bool completedToday,
  }) =>
      HabitStatusItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        iconKey: json['icon_key'] as String? ?? 'habit',
        frequency: json['frequency'] as String? ?? 'daily',
        completedToday: completedToday,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        days: (json['days_of_week'] as List?)
            ?.map((item) => (item as num).toInt())
            .toList(growable: false),
      );

  final String id;
  final String title;
  final String iconKey;
  final String frequency;
  final bool completedToday;
  final int sortOrder;
  final List<int>? days;

  /// True when the habit should appear on the given weekday (null/empty = daily).
  bool showsOn(int weekday) => days == null || days!.isEmpty || days!.contains(weekday);

  HabitStatusItem copyWith({
    String? title,
    String? iconKey,
    bool? completedToday,
    int? sortOrder,
    List<int>? days,
  }) =>
      HabitStatusItem(
        id: id,
        title: title ?? this.title,
        iconKey: iconKey ?? this.iconKey,
        frequency: frequency,
        completedToday: completedToday ?? this.completedToday,
        sortOrder: sortOrder ?? this.sortOrder,
        days: days ?? this.days,
      );
}

class JournalEntryItem {
  const JournalEntryItem({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.tags,
    required this.createdAt,
  });

  factory JournalEntryItem.fromJson(Map<String, dynamic> json) =>
      JournalEntryItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'بدون عنوان',
        body: json['body'] as String? ?? '',
        mood: (json['mood'] as num?)?.toInt() ?? 3,
        tags: (json['tags'] as List?)
                ?.map((item) => item.toString())
                .toList(growable: false) ??
            const [],
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );

  final String id;
  final String title;
  final String body;
  final int mood;
  final List<String> tags;
  final DateTime createdAt;
}

class CoachChatThread {
  const CoachChatThread({
    required this.conversationId,
    required this.coach,
    required this.messages,
  });

  final String conversationId;
  final CoachItem coach;
  final List<ChatMessageItem> messages;
}

class ChatMessageItem {
  const ChatMessageItem({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    required this.isMine,
    this.isPending = false,
  });

  factory ChatMessageItem.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) =>
      ChatMessageItem(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String,
        senderId: json['sender_id'] as String,
        body: json['body'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        isMine: json['sender_id'] == currentUserId,
      );

  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime createdAt;
  final bool isMine;
  final bool isPending;
}
