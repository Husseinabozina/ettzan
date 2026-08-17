import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etzan_life_coaching/core/error/app_failure.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/features/auth/domain/entities/auth_user.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/send_password_reset.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/sign_in.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/sign_in_as_guest.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:etzan_life_coaching/features/auth/domain/usecases/sign_up.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._signIn, this._signUp, this._signInAsGuest,
      this._signInWithGoogle, this._reset)
      : super(const AuthInitial()) {
    _authSubscription = _repository.authStateChanges.listen(
      (user) {
        if (user != null && !isClosed) emit(AuthAuthenticated(user));
      },
      onError: (_, __) {
        if (!isClosed) {
          emit(const AuthFailure(LocaleKeys.authSessionRefreshError));
        }
      },
    );
  }

  final AuthRepository _repository;
  final SignIn _signIn;
  final SignUp _signUp;
  final SignInAsGuest _signInAsGuest;
  final SignInWithGoogle _signInWithGoogle;
  final SendPasswordReset _reset;
  late final StreamSubscription<AuthUser?> _authSubscription;

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      emit(AuthAuthenticated(await _signIn(email: email, password: password)));
    } on AppFailure catch (e) {
      emit(AuthFailure(_messageKeyForFailure(e)));
    } catch (_) {
      emit(const AuthFailure(LocaleKeys.unexpectedAuthError));
    }
  }

  Future<void> signUp(
      {required String fullName,
      required String email,
      required String password}) async {
    emit(const AuthLoading());
    try {
      emit(AuthAuthenticated(
          await _signUp(fullName: fullName, email: email, password: password)));
    } on AppFailure catch (e) {
      emit(AuthFailure(_messageKeyForFailure(e)));
    } catch (_) {
      emit(const AuthFailure(LocaleKeys.unexpectedAuthError));
    }
  }

  Future<void> signInAsGuest() async {
    emit(const AuthLoading());
    try {
      emit(AuthAuthenticated(await _signInAsGuest()));
    } on AppFailure catch (e) {
      emit(AuthFailure(_messageKeyForFailure(e)));
    } catch (_) {
      emit(const AuthFailure(LocaleKeys.guestSignInError));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      await _signInWithGoogle();
      emit(const AuthExternalSignInStarted(LocaleKeys.completeGoogleSignIn));
    } on AppFailure catch (e) {
      emit(AuthFailure(_messageKeyForFailure(e)));
    } catch (_) {
      emit(const AuthFailure(LocaleKeys.googleSignInStartError));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthLoading());
    try {
      await _reset(email);
      emit(const AuthPasswordResetSent());
    } on AppFailure catch (e) {
      emit(AuthFailure(_messageKeyForFailure(e)));
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }

  String _messageKeyForFailure(AppFailure failure) {
    return switch (failure.message) {
      'auth_sign_up_failed' => LocaleKeys.authSignUpFailed,
      'auth_sign_up_login_failed' => LocaleKeys.authSignUpLoginFailed,
      'auth_sign_in_failed' => LocaleKeys.authSignInFailed,
      'google_open_failed' => LocaleKeys.googleOpenError,
      'auth_timeout' => LocaleKeys.authTimeout,
      'signup_timeout' => LocaleKeys.signupTimeout,
      'google_timeout' => LocaleKeys.googleTimeout,
      'guest_sign_in_failed' => LocaleKeys.guestSignInError,
      _ => failure.message,
    };
  }
}
