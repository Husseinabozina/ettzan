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
    final response = await _client.auth
        .signInWithPassword(email: email.trim(), password: password);
    final user = response.user;
    if (user == null) throw const AuthException('auth_sign_in_failed');
    return user;
  }

  @override
  Future<User> signInAnonymously() async {
    final response = await _client.auth.signInAnonymously();
    final user = response.user;
    if (user == null) throw const AuthException('guest_sign_in_failed');
    return user;
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
  Future<void> signOut() => _client.auth.signOut();
}
