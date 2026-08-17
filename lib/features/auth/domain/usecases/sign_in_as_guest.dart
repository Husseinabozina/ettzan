import 'package:etzan_life_coaching/features/auth/domain/entities/auth_user.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';

class SignInAsGuest {
  const SignInAsGuest(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call() => _repository.signInAsGuest();
}
