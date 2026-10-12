import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolops_pro/core/constants/message_constants.dart';
import 'package:schoolops_pro/core/error/failure.dart';
import 'package:schoolops_pro/features/authentication/domain/entities/auth_token.dart';
import 'package:schoolops_pro/features/authentication/domain/entities/user_profile.dart';
import 'package:schoolops_pro/features/authentication/domain/repositories/auth_repository.dart';
import 'package:schoolops_pro/features/authentication/domain/use_cases/login_use_case.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldSucceed = true;

  @override
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  }) async {
    if (shouldSucceed) {
      return Right(AuthToken(
        accessToken: 'fake_jwt_token',
        refreshToken: 'fake_refresh_token',
        expiresIn: 900,
        expiresAt: DateTime.now().add(const Duration(seconds: 900)),
      ));
    }
    return const Left(AuthFailure('Invalid credentials'));
  }

  @override
  Future<Option<UserProfile>> getCurrentUser() async => none();

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async =>
      const Right(UserProfile(userId: '1', userName: 'test', email: 'test@school.com'));

  @override
  Future<bool> isAuthenticated() async => shouldSucceed;

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<Either<Failure, AuthToken>> refreshToken({required String refreshToken}) async =>
      throw UnimplementedError();
}

void main() {
  late MockAuthRepository mockRepo;
  late LoginUseCase useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });

  test('should return ValidationFailure when username is empty', () async {
    final result = await useCase(const LoginParams(username: '', password: 'password123'));

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, MessageConstants.usernameRequired),
      (_) => fail('Should not succeed with empty username'),
    );
  });

  test('should return ValidationFailure when password is empty', () async {
    final result = await useCase(const LoginParams(username: 'admin', password: '   '));

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, MessageConstants.passwordRequired),
      (_) => fail('Should not succeed with empty password'),
    );
  });

  test('should return AuthToken when credentials are valid', () async {
    final result = await useCase(const LoginParams(username: 'admin', password: 'password123'));

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Should not fail with valid credentials'),
      (token) => expect(token.accessToken, 'fake_jwt_token'),
    );
  });
}
