import '../../../../core/error/failure.dart';
import '../../domain/entities/user_profile.dart';

/// Sealed class hierarchy representing application authentication state.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserProfile profile;
  const Authenticated(this.profile);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final Failure failure;
  const AuthError(this.failure);
}
