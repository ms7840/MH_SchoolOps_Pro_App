import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_token.dart';
import '../entities/user_profile.dart';

/// Authentication repository contract.
abstract interface class AuthRepository {
  /// Signs in with credentials via OpenIddict password grant.
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  });

  /// Refreshes access token via OpenIddict refresh_token grant.
  Future<Either<Failure, AuthToken>> refreshToken({
    required String refreshToken,
  });

  /// Fetches user profile either via /connect/userinfo or decoded JWT claims.
  Future<Either<Failure, UserProfile>> getUserProfile();

  /// Reads stored active user profile from cache/secure storage.
  Future<Option<UserProfile>> getCurrentUser();

  /// Logs out user, revokes tokens, and clears local secure storage and cache.
  Future<Either<Failure, Unit>> logout();

  /// Checks if valid access token exists.
  Future<bool> isAuthenticated();
}
