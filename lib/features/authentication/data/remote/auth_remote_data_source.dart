import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/network/api_client.dart';
import '../dto/token_response_dto.dart';
import '../dto/user_info_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<TokenResponseDto> loginWithPassword({
    required String username,
    required String password,
  });

  Future<TokenResponseDto> refreshToken({
    required String refreshToken,
  });

  Future<UserInfoDto> getUserInfo();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;
  final AppConfig _config;

  AuthRemoteDataSourceImpl(this._client, {AppConfig? config})
      : _config = config ?? AppConfig.instance;

  @override
  Future<TokenResponseDto> loginWithPassword({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.postForm<Map<String, dynamic>>(
        ApiConstants.token,
        formData: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'client_id': _config.clientId,
          'scope': _config.scopes,
        },
      );

      if (response.data != null) {
        return TokenResponseDto.fromJson(response.data!);
      }
      throw const ServerException('Empty response received from auth server');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        final errorDesc = e.response?.data?['error_description'] as String?;
        throw UnauthorizedException(
          errorDesc ?? 'Invalid username or password',
          statusCode: e.response?.statusCode,
        );
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException('Unable to reach the authentication server.');
      }
      throw ServerException(
        e.message ?? 'Authentication server error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TokenResponseDto> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _client.postForm<Map<String, dynamic>>(
        ApiConstants.token,
        formData: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _config.clientId,
          'scope': _config.scopes,
        },
      );

      if (response.data != null) {
        return TokenResponseDto.fromJson(response.data!);
      }
      throw const ServerException('Empty token response from server');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Session expired. Please sign in again.',
          statusCode: e.response?.statusCode,
        );
      }
      throw ServerException(
        e.message ?? 'Failed to refresh authentication token',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserInfoDto> getUserInfo() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(ApiConstants.userInfo);
      if (response.data != null) {
        return UserInfoDto.fromJson(response.data!);
      }
      throw const ServerException('Empty userinfo response');
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to fetch user context',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {
      // Ignored for graceful client-side purge
    }
  }
}
