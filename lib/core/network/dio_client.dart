import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'api_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Concrete ApiClient implementation wrapping Dio.
class DioClient implements ApiClient {
  final Dio _dio;

  DioClient({
    required SecureStorageService secureStorage,
    void Function()? onSessionExpired,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    final appConfig = AppConfig.instance;

    _dio.options = BaseOptions(
      baseUrl: appConfig.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        secureStorage: secureStorage,
        authServerUrl: appConfig.authServerUrl,
        clientId: appConfig.clientId,
        scopes: appConfig.scopes,
        onSessionExpired: onSessionExpired,
      ),
      LoggingInterceptor(),
    ]);
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> postForm<T>(
    String path, {
    required Map<String, dynamic> formData,
    Options? options,
  }) async {
    final formOptions = options ?? Options();
    formOptions.contentType = Headers.formUrlEncodedContentType;

    return await _dio.post<T>(
      path,
      data: formData,
      options: formOptions,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
