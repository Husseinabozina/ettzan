-- ============================================================================
-- guest_quotes table for the guest-home quote carousel
-- ----------------------------------------------------------------------------
-- The carousel fetches these quotes from Supabase and falls back to bundled
-- translations if this table is empty or unreachable.
--
-- Run this file in Supabase Dashboard > SQL Editor. It is idempotent.
-- After running it, hot-restart the app and re-enter guest mode.
-- ============================================================================

create table if not exists public.guest_quotes (
  id bigint generated always as identity primary key,
  text_ar text not null,
  text_en text not null,
  sort_order int not null default 0 unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.guest_quotes enable row level security;

drop policy if exists "anyone can read guest quotes" on public.guest_quotes;
create policy "anyone can read guest quotes" on public.guest_quotes
  for select to anon, authenticated
  using (true);

-- Expose the table to the Data (REST) API for both roles.
grant select on public.guest_quotes to anon, authenticated;

-- Seed the initial quotes (safe to re-run; unique sort_order prevents dupes).
insert into public.guest_quotes (text_ar, text_en, sort_order) values
(
  'التوازن ليس وجهة نصل إليها، بل طريق نمشي فيه كل يوم.',
  'Balance isn''t a place you arrive at — it''s a path you walk every day.',
  1
),
(
  'الهدوء لا يعني التوقف، بل أن تتحرك دون أن تهتز.',
  'Calm doesn''t mean standing still — it means moving without shaking.',
  2
),
(
  'حين تُرتَّب خطواتك الصغيرة، تصنع حياةً أكبر من أحلامك.',
  'When your small steps fall into place, you build a life bigger than your dreams.',
  3
)
on conflict (sort_order) do nothing;

-- ---------------------------------------------------------------------------
-- Editing quotes later:
--   update public.guest_quotes set text_ar = '...', text_en = '...' where sort_order = 1;
--   insert into public.guest_quotes (text_ar, text_en, sort_order) values (...);  -- next number
--   update public.guest_quotes set is_active = false where sort_order = 1;        -- hide without delete
-- ============================================================================
