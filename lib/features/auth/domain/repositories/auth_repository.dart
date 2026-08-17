import 'package:etzan_life_coaching/features/auth/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;
  Future<AuthUser> signUp(
      {required String fullName,
      required String email,
      required String password});
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> signInAsGuest();
  Future<void> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
