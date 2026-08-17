import 'package:etzan_life_coaching/features/auth/domain/entities/auth_user.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._repository);
  final AuthRepository _repository;
  Future<AuthUser> call({required String email, required String password}) =>
      _repository.signIn(email: email, password: password);
}
