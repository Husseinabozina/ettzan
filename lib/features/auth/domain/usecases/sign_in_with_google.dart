import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signInWithGoogle();
}
