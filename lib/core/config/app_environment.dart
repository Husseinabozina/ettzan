abstract final class AppEnvironment {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yuwindiqcahciovexyjk.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_4e8VF5-PIp1rpkeMDQr3MA_xFmHEfn8',
  );

  static const supabaseAuthRedirectUrl = String.fromEnvironment(
    'SUPABASE_AUTH_REDIRECT_URL',
    defaultValue: 'com.etzan.app.etzanflutter://auth-callback',
  );
}
