import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../constants/storage_constants.dart';
import '../../storage/secure_storage_service.dart';

/// Centralized AuthInterceptor managing automatic Bearer token injection
/// and silent transparent 401 token refresh loop with OpenIddict.
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _secureStorage;
  final Dio _refreshDio;
  final String _authServerUrl;
  final String _clientId;
  final String _scopes;
  final void Function()? onSessionExpired;

  bool _isRefreshing = false;

  AuthInterceptor({
    required SecureStorageService secureStorage,
    required String authServerUrl,
    required String clientId,
    required String scopes,
    this.onSessionExpired,
    Dio? refreshDio,
  })  : _secureStorage = secureStorage,
        _authServerUrl = authServerUrl,
        _clientId = clientId,
        _scopes = scopes,
        _refreshDio = refreshDio ?? Dio();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for token issuance or discovery endpoints
    if (options.path.contains(ApiConstants.token) ||
        options.path.contains(ApiConstants.openIdConfig)) {
      return handler.next(options);
    }

    final accessToken = await _secureStorage.read(key: StorageConstants.accessToken);
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    // Check if error is 401 Unauthorized and not on token endpoint itself
    if (response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiConstants.token)) {
      final refreshToken = await _secureStorage.read(key: StorageConstants.refreshToken);

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final newAccessToken = await _performRefreshToken(refreshToken);

          if (newAccessToken != null) {
            // Replay original request with updated access token
            final originalOptions = err.requestOptions;
            originalOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _refreshDio.fetch(originalOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Token refresh failed - session has truly expired
          await _handleSessionExpired();
          return handler.next(err);
        }
      } else {
        await _handleSessionExpired();
      }
    }

    return handler.next(err);
  }

  Future<String?> _performRefreshToken(String refreshToken) async {
    if (_isRefreshing) return null;
    _isRefreshing = true;

    try {
      final tokenUrl = '$_authServerUrl${ApiConstants.token}';
      final response = await _refreshDio.post(
        tokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _clientId,
          'scope': _scopes,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String?;
        final expiresIn = data['expires_in'] as int? ?? 900;

        await _secureStorage.write(
          key: StorageConstants.accessToken,
          value: newAccessToken,
        );

        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _secureStorage.write(
            key: StorageConstants.refreshToken,
            value: newRefreshToken,
          );
        }

        final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
        await _secureStorage.write(
          key: StorageConstants.tokenExpiry,
          value: expiryDate.toIso8601String(),
        );

        return newAccessToken;
      }
    } finally {
      _isRefreshing = false;
    }

    return null;
  }

  Future<void> _handleSessionExpired() async {
    await _secureStorage.delete(key: StorageConstants.accessToken);
    await _secureStorage.delete(key: StorageConstants.refreshToken);
    await _secureStorage.delete(key: StorageConstants.tokenExpiry);
    onSessionExpired?.call();
  }
}
