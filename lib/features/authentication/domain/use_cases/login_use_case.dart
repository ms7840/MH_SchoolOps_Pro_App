import 'package:dartz/dartz.dart';
import '../../../../core/constants/message_constants.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});
}

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, AuthToken>> call(LoginParams params) async {
    final trimmedUsername = params.username.trim();
    final trimmedPassword = params.password.trim();

    if (trimmedUsername.isEmpty) {
      return const Left(ValidationFailure(MessageConstants.usernameRequired));
    }
    if (trimmedPassword.isEmpty) {
      return const Left(ValidationFailure(MessageConstants.passwordRequired));
    }

    return await _repository.login(
      username: trimmedUsername,
      password: trimmedPassword,
    );
  }
}
