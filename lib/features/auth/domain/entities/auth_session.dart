import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  final String? email;
  final bool isAuthorized;

  const AuthSession({required this.email, required this.isAuthorized});

  @override
  List<Object?> get props => [email, isAuthorized];
}
