import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  Future<Option<UserProfile>> call() async {
    return await _repository.getCurrentUser();
  }
}
