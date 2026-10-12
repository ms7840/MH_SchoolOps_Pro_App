import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../storage/local_cache_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/authentication/data/remote/auth_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/use_cases/get_current_user_use_case.dart';
import '../../features/authentication/domain/use_cases/login_use_case.dart';
import '../../features/authentication/domain/use_cases/logout_use_case.dart';
import '../../features/authentication/domain/use_cases/refresh_token_use_case.dart';
import '../../features/authentication/presentation/providers/auth_notifier.dart';

// Storage Providers
final Provider<SecureStorageService> secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final Provider<LocalCacheService> localCacheProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});

// Network / ApiClient Provider
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(
    secureStorage: secureStorage,
    onSessionExpired: () {
      ref.read(authStateProvider.notifier).handleSessionExpired();
    },
  );
});

// Authentication Infrastructure Providers
final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final secure = ref.watch(secureStorageProvider);
  final cache = ref.watch(localCacheProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remote,
    secureStorage: secure,
    localCache: cache,
  );
});

// Authentication Use Case Providers
final Provider<LoginUseCase> loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
});

final Provider<RefreshTokenUseCase> refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(repo);
});

final Provider<LogoutUseCase> logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repo);
});

final Provider<GetCurrentUserUseCase> getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repo);
});
