import 'package:equatable/equatable.dart';

class AppFailure extends Equatable implements Exception {
  const AppFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'AppFailure(code: $code, message: $message)';
}
