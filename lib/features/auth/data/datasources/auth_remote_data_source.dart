import 'package:etzan_life_coaching/core/config/app_environment.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<User> signUp(
      {required String fullName,
      required String email,
      required String password});
  Future<User> signIn({required String email, required String password});
  Future<User> signInAnonymously();
  Future<void> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> changePassword(String newPassword);
  Future<void> signOut();
}

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const SupabaseAuthRemoteDataSource(this._client);
  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((data) => data.session?.user);

  @override
  Future<User> signUp(
      {required String fullName,
      required String email,
      required String password}) async {
    await _signOutAnonymousSession();
    final normalizedEmail = email.trim();
    final response = await _client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {'full_name': fullName.trim()},
    );
    final user = response.user;
    if (user == null) throw const AuthException('auth_sign_up_failed');
    if (response.session == null) {
      final signInResponse = await _client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      final signedInUser = signInResponse.user;
      if (signedInUser == null) {
        throw const AuthException('auth_sign_up_login_failed');
      }
      return signedInUser;
    }
    return user;
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    await _signOutAnonymousSession();
    final response = await _client.auth
        .signInWithPassword(email: email.trim(), password: password);
    final user = response.user;
    if (user == null) throw const AuthException('auth_sign_in_failed');
    return user;
  }

  @override
  Future<User> signInAnonymously() async {
    final existing = _client.auth.currentUser;
    if (existing != null && existing.isAnonymous) return existing;
    final response = await _client.auth.signInAnonymously();
    final user = response.user;
    if (user == null) throw const AuthException('guest_sign_in_failed');
    return user;
  }

  /// Switches away from an active anonymous session before a permanent
  /// sign-up/sign-in. GoTrue refuses some auth actions while a session is
  /// active; guests hold no data, so a clean sign-out is the safe transition.
  Future<void> _signOutAnonymousSession() async {
    final user = _client.auth.currentUser;
    if (user == null || !user.isAnonymous) return;
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Best effort; continue with the requested auth action either way.
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final didLaunch = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : AppEnvironment.supabaseAuthRedirectUrl,
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );

    if (!didLaunch) {
      throw const AuthException('google_open_failed');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email.trim());

  @override
  Future<void> changePassword(String newPassword) =>
      _client.auth.updateUser(UserAttributes(password: newPassword));

  @override
  Future<void> signOut() => _client.auth.signOut();
}
