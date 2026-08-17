-- ============================================================================
-- Guest (anonymous) access policies for Etzan
-- ----------------------------------------------------------------------------
-- Based on Supabase docs "Anonymous Sign-Ins":
--   * Anonymous users use the `authenticated` Postgres role.
--   * Distinguish them via the JWT claim `is_anonymous`.
--   * Permissive policies are OR-combined, so blocks must be `restrictive`.
--   * A single restrictive policy alone fails; it only ever ADDS constraints
--     on top of your existing permissive policies.
--
-- Personal tables  -> anonymous users are blocked from SELECT/INSERT/UPDATE/DELETE
-- Public tables    -> anonymous users can read (coaches, resources, plans)
--
-- Run this file in Supabase Dashboard > SQL Editor.
-- It is idempotent: safe to re-run after policy changes.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Block anonymous users on personal tables
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  t text;
  tables text[] := ARRAY[
    'profiles',
    'goals',
    'goal_milestones',
    'habits',
    'habit_logs',
    'journal_entries',
    'bookings',
    'user_subscriptions',
    'user_preferences',
    'notifications',
    'messages',
    'conversations'
  ];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format(
      'drop policy if exists "block anonymous select on %s" on public.%s', t, t);
    EXECUTE format(
      'drop policy if exists "block anonymous insert on %s" on public.%s', t, t);
    EXECUTE format(
      'drop policy if exists "block anonymous update on %s" on public.%s', t, t);
    EXECUTE format(
      'drop policy if exists "block anonymous delete on %s" on public.%s', t, t);

    EXECUTE format(
      'create policy "block anonymous select on %s" on public.%s as restrictive
         for select to authenticated
         using ((select (auth.jwt()->>''is_anonymous'')::boolean) is false)', t, t);
    EXECUTE format(
      'create policy "block anonymous insert on %s" on public.%s as restrictive
         for insert to authenticated
         with check ((select (auth.jwt()->>''is_anonymous'')::boolean) is false)', t, t);
    EXECUTE format(
      'create policy "block anonymous update on %s" on public.%s as restrictive
         for update to authenticated
         using ((select (auth.jwt()->>''is_anonymous'')::boolean) is false)
         with check ((select (auth.jwt()->>''is_anonymous'')::boolean) is false)', t, t);
    EXECUTE format(
      'create policy "block anonymous delete on %s" on public.%s as restrictive
         for delete to authenticated
         using ((select (auth.jwt()->>''is_anonymous'')::boolean) is false)', t, t);
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- 2. Let anonymous users read public data
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  t text;
  tables text[] := ARRAY[
    'coach_profiles',
    'coach_specialties',
    'coach_availability',
    'subscription_plans',
    'resources'
  ];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format(
      'drop policy if exists "guests can read %s" on public.%s', t, t);
    EXECUTE format(
      'create policy "guests can read %s" on public.%s
         for select to authenticated using (true)', t, t);
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- 3. Optional housekeeping: delete anonymous users older than 30 days
--    (Supabase does not clean them up automatically). Schedule this with
--    pg_cron or run it manually once in a while.
-- ---------------------------------------------------------------------------
-- delete from auth.users
-- where is_anonymous is true and created_at < now() - interval '30 days';

-- ---------------------------------------------------------------------------
-- Notes (not SQL):
--   * Abuse: an IP-based rate limit of 30 anonymous sign-ins/hour applies;
--     Supabase recommends enabling Invisible CAPTCHA for anonymous logins.
--   * Conversion: linking an anonymous user to email/password (updateUser)
--     requires "Manual Linking" to be enabled in Authentication > Identity Linking.
-- ============================================================================
