import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    this.isGuest = false,
  });

  final String id;
  final String? email;
  final String? fullName;
  final bool isGuest;

  @override
  List<Object?> get props => [id, email, fullName, isGuest];
}
