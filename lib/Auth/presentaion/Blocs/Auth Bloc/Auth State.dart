
import '../../../data/user model.dart';

abstract class AuthenticationState {}

class AuthInitial extends AuthenticationState {}

class AuthLoading extends AuthenticationState {}

class AuthAuthenticated extends AuthenticationState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthenticationState {}

class AuthError extends AuthenticationState {
  final String message;
  AuthError(this.message);
}