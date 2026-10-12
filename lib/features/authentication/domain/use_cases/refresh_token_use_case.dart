import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository _repository;

  const RefreshTokenUseCase(this._repository);

  Future<Either<Failure, AuthToken>> call(String refreshToken) async {
    if (refreshToken.trim().isEmpty) {
      return const Left(AuthFailure('Invalid refresh token'));
    }
    return await _repository.refreshToken(refreshToken: refreshToken);
  }
}
