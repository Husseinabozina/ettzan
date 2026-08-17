import 'package:equatable/equatable.dart';
import 'package:etzan_life_coaching/features/auth/domain/entities/auth_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
  @override
  List<Object?> get props => [user];
}

class AuthExternalSignInStarted extends AuthState {
  const AuthExternalSignInStarted(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
