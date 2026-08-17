import 'package:etzan_life_coaching/features/auth/domain/entities/auth_user.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);
  final AuthRepository _repository;
  Future<AuthUser> call(
          {required String fullName,
          required String email,
          required String password}) =>
      _repository.signUp(fullName: fullName, email: email, password: password);
}
