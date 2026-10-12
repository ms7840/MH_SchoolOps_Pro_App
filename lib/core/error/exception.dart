/// Data layer exceptions caught by repositories and translated to Failures.
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode});
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.statusCode});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode});
}

class ValidationException extends AppException {
  final List<String> fieldErrors;
  const ValidationException(super.message, {this.fieldErrors = const [], super.statusCode});
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}
