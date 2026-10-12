import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/message_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/auth_mapper.dart';
import '../remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final LocalCacheService _localCache;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
    required LocalCacheService localCache,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage,
        _localCache = localCache;

  @override
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  }) async {
    try {
      final tokenDto = await _remoteDataSource.loginWithPassword(
        username: username,
        password: password,
      );

      // 1. Persist tokens in hardware-backed secure storage
      await _secureStorage.write(
        key: StorageConstants.accessToken,
        value: tokenDto.accessToken,
      );

      if (tokenDto.refreshToken != null) {
        await _secureStorage.write(
          key: StorageConstants.refreshToken,
          value: tokenDto.refreshToken!,
        );
      }

      final expiresAt = DateTime.now().add(Duration(seconds: tokenDto.expiresIn));
      await _secureStorage.write(
        key: StorageConstants.tokenExpiry,
        value: expiresAt.toIso8601String(),
      );

      // 2. Fetch and cache user profile
      try {
        final profileEither = await getUserProfile();
        profileEither.forEach((profile) async {
          await _cacheUserProfile(profile);
        });
      } catch (_) {
        // Fallback claims decoding happens in getUserProfile()
      }

      return Right(tokenDto.toDomain());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(MessageConstants.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final tokenDto = await _remoteDataSource.refreshToken(refreshToken: refreshToken);

      await _secureStorage.write(
        key: StorageConstants.accessToken,
        value: tokenDto.accessToken,
      );

      if (tokenDto.refreshToken != null) {
        await _secureStorage.write(
          key: StorageConstants.refreshToken,
          value: tokenDto.refreshToken!,
        );
      }

      final expiresAt = DateTime.now().add(Duration(seconds: tokenDto.expiresIn));
      await _secureStorage.write(
        key: StorageConstants.tokenExpiry,
        value: expiresAt.toIso8601String(),
      );

      return Right(tokenDto.toDomain());
    } on UnauthorizedException catch (e) {
      await logout();
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final userDto = await _remoteDataSource.getUserInfo();
      final profile = userDto.toDomain();
      await _cacheUserProfile(profile);
      return Right(profile);
    } catch (_) {
      // If /connect/userinfo fails, decode claims from stored access token
      final token = await _secureStorage.read(key: StorageConstants.accessToken);
      if (token != null && token.isNotEmpty) {
        final profile = JwtClaimsMapper.fromToken(token);
        if (profile.userId.isNotEmpty) {
          await _cacheUserProfile(profile);
          return Right(profile);
        }
      }
      return const Left(ServerFailure('Could not resolve user profile'));
    }
  }

  @override
  Future<Option<UserProfile>> getCurrentUser() async {
    // 1. Try reading from cached JSON
    final cached = _localCache.get<String>(
      boxName: StorageConstants.userContextBox,
      key: StorageConstants.userPayload,
    );

    if (cached != null) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        return some(UserProfile(
          userId: map['userId'] as String,
          userName: map['userName'] as String,
          email: map['email'] as String,
          roles: (map['roles'] as List<dynamic>).map((e) => e.toString()).toList(),
          permissions: (map['permissions'] as List<dynamic>).map((e) => e.toString()).toList(),
          academicSessionId: map['academicSessionId'] as String?,
        ));
      } catch (_) {
        // Corrupted cache - fallback to decoding token
      }
    }

    // 2. Decode from access token
    final token = await _secureStorage.read(key: StorageConstants.accessToken);
    if (token != null && token.isNotEmpty) {
      final profile = JwtClaimsMapper.fromToken(token);
      if (profile.userId.isNotEmpty) {
        await _cacheUserProfile(profile);
        return some(profile);
      }
    }

    return none();
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Continue client wipe
    }

    await _secureStorage.deleteAll();
    await _localCache.clearAllUserCaches();
    return const Right(unit);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: StorageConstants.accessToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> _cacheUserProfile(UserProfile profile) async {
    final payload = jsonEncode({
      'userId': profile.userId,
      'userName': profile.userName,
      'email': profile.email,
      'roles': profile.roles,
      'permissions': profile.permissions,
      'academicSessionId': profile.academicSessionId,
    });

    await _localCache.put(
      boxName: StorageConstants.userContextBox,
      key: StorageConstants.userPayload,
      value: payload,
    );
  }
}
