import 'dart:async';

import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:etzan_life_coaching/features/auth/domain/entities/auth_user.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);
  static const _authTimeout = Duration(seconds: 25);

  final AuthRemoteDataSource _remote;

  AuthUser _map(User user) => AuthUser(
        id: user.id,
        email: user.email,
        fullName: user.userMetadata?['full_name'] as String?,
        isGuest: user.isAnonymous,
      );

  @override
  AuthUser? get currentUser {
    final user = _remote.currentUser;
    return user == null ? null : _map(user);
  }

  @override
  Stream<AuthUser?> get authStateChanges =>
      _remote.authStateChanges.map((user) => user == null ? null : _map(user));

  @override
  Future<AuthUser> signIn(
      {required String email, required String password}) async {
    try {
      return _map(await _remote
          .signIn(email: email, password: password)
          .timeout(_authTimeout));
    } on AuthException catch (e) {
      throw AppFailure(e.message, code: 'auth');
    } on TimeoutException {
      throw const AppFailure('auth_timeout', code: 'auth_timeout');
    }
  }

  @override
  Future<AuthUser> signInAsGuest() async {
    try {
      return _map(await _remote.signInAnonymously().timeout(_authTimeout));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('anonymous')) {
        // e.g. "Anonymous sign-ins are disabled" -> localized guest error.
        throw const AppFailure('guest_sign_in_failed', code: 'auth');
      }
      throw AppFailure(e.message, code: 'auth');
    } on TimeoutException {
      throw const AppFailure('guest_sign_in_failed', code: 'auth_timeout');
    }
  }

  @override
  Future<AuthUser> signUp(
      {required String fullName,
      required String email,
      required String password}) async {
    try {
      return _map(await _remote
          .signUp(fullName: fullName, email: email, password: password)
          .timeout(_authTimeout));
    } on AuthException catch (e) {
      throw AppFailure(e.message, code: 'auth');
    } on TimeoutException {
      throw const AppFailure('signup_timeout', code: 'auth_timeout');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _remote.signInWithGoogle().timeout(_authTimeout);
    } on AuthException catch (e) {
      throw AppFailure(e.message, code: 'auth');
    } on TimeoutException {
      throw const AppFailure('google_timeout', code: 'auth_timeout');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _remote.sendPasswordReset(email);
    } on AuthException catch (e) {
      throw AppFailure(e.message, code: 'auth');
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      await _remote.changePassword(newPassword).timeout(_authTimeout);
    } on AuthException catch (e) {
      throw AppFailure(e.message, code: 'auth');
    } on TimeoutException {
      throw const AppFailure('auth_timeout', code: 'auth_timeout');
    }
  }

  @override
  Future<void> signOut() => _remote.signOut();
}
