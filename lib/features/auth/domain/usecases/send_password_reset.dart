import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordReset {
  const SendPasswordReset(this._repository);
  final AuthRepository _repository;
  Future<void> call(String email) => _repository.sendPasswordReset(email);
}
