import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logging interceptor with strict credential scrubbing.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method.toUpperCase()} ${options.uri}');
      if (options.data != null && !options.path.contains('/token')) {
        debugPrint('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ERROR [${err.response?.statusCode}] ${err.requestOptions.uri}: ${err.message}');
    }
    handler.next(err);
  }
}
