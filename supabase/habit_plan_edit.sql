-- ============================================================================
-- Habit plan editing: ordering + per-day scheduling
-- ----------------------------------------------------------------------------
-- Adds to the `habits` table:
--   * sort_order   int  — task order in the daily plan (0 = first)
--   * days_of_week int[] — weekdays the task appears on (1=Monday .. 7=Sunday,
--                          Dart's DateTime.weekday order). NULL or empty = every day.
--
-- Run in Supabase Dashboard > SQL Editor. Idempotent: safe to re-run.
-- ============================================================================

alter table public.habits add column if not exists sort_order int not null default 0;
alter table public.habits add column if not exists days_of_week int[];

-- Seed ordering for existing habits (keep their current creation order).
with ranked as (
  select id, row_number() over (order by created_at, id) - 1 as rn
  from public.habits
  where is_active
)
update public.habits h
set sort_order = ranked.rn
from ranked
where ranked.id = h.id and h.sort_order = 0;

-- Normalize empty day arrays to NULL (= every day).
update public.habits
set days_of_week = null
where days_of_week is not null and array_length(days_of_week, 1) = 0;
