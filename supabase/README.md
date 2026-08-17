# Etzan Supabase Backend

Project ref: `yuwindiqcahciovexyjk`
Region: `eu-central-1`

## What is live

- Supabase Auth (email/password)
- `profiles` trigger on new auth users
- Coaches, specialties and availability
- Bookings with atomic booking/reschedule RPC functions
- Goals and milestones
- Habits and habit logs
- Journal entries
- Conversations and realtime messages
- Notifications (realtime enabled)
- Resources
- Subscription plans and user subscriptions
- Storage buckets: `avatars`, `journal-assets`, `resources`
- RLS policies for user/coach/admin boundaries

## Flutter configuration

The app reads configuration from `--dart-define`, with the current project publishable values as defaults.

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://yuwindiqcahciovexyjk.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_4e8VF5-PIp1rpkeMDQr3MA_xFmHEfn8
```

The publishable key is intended for client applications. Never put a service-role/secret key in Flutter.

## Architecture boundary

Flutter presentation/domain code does not depend on JSON column naming. Supabase lives behind data sources and repositories. Auth now uses a complete Data -> Domain -> Use case -> Cubit flow. Dashboard, Notifications, Resources, Growth, Journal, Bookings, and Chat read/write real Supabase data. Paid subscription plans are displayed as a portfolio feature with payment integration marked as pending.
