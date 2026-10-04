# 14 — Error Handling

## Failure Hierarchy (core/error/failure.dart)
```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class ServerFailure extends Failure { const ServerFailure(super.message); }
class AuthFailure extends Failure { const AuthFailure(super.message); }
class ValidationFailure extends Failure {
  final List<String> errors;
  const ValidationFailure(super.message, {this.errors = const []});
}
class NotFoundFailure extends Failure { const NotFoundFailure(super.message); }
class TimeoutFailure extends Failure { const TimeoutFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure(super.message); }
```

## Exception Hierarchy (core/error/exception.dart)
Used only in the data layer. Caught in repositories and converted to Failure.
```dart
sealed class AppException implements Exception { final String message; }
class NetworkException extends AppException { ... }
class UnauthorizedException extends AppException { ... }
class ForbiddenException extends AppException { ... }
class NotFoundException extends AppException { ... }
class ValidationException extends AppException {
  final List<String> errors;
}
class ServerException extends AppException { ... }
class TimeoutException extends AppException { ... }
class UnknownException extends AppException { ... }
```

## Mapping Chain
```
DioException
  -> AppException (mapped in remote data source / interceptor)
    -> Failure (mapped in repository implementation)
      -> State update in notifier
        -> UI: AppErrorView or inline error message
```

## Repository Error Mapping Pattern
```dart
@override
Future<Either<Failure, Student>> getStudentById(String id) async {
  try {
    final dto = await _remoteDataSource.getStudentById(id);
    return Right(dto.toDomain());
  } on NotFoundException catch (e) {
    return Left(NotFoundFailure(e.message));
  } on UnauthorizedException {
    return Left(AuthFailure(MessageConstants.sessionExpired));
  } on NetworkException {
    return Left(NetworkFailure(MessageConstants.noInternet));
  } catch (e) {
    return Left(UnknownFailure(MessageConstants.unexpectedError));
  }
}
```

## Notifier Error Handling
```dart
final result = await _getStudentUseCase.call(id);
state = result.fold(
  (failure) => StudentDetailState.error(failure),
  (student) => StudentDetailState.loaded(student),
);
```

## UI Error Display
```dart
state.when(
  error: (failure) => AppErrorView(
    message: _mapFailureToMessage(failure),
    onRetry: _load,
  ),
  ...
)
```

## User-Facing Message Mapping
```dart
String _mapFailureToMessage(Failure failure) => switch (failure) {
  NetworkFailure() => MessageConstants.noInternetConnection,
  AuthFailure() => MessageConstants.sessionExpired,
  NotFoundFailure() => MessageConstants.resourceNotFound,
  TimeoutFailure() => MessageConstants.requestTimeout,
  ValidationFailure(errors: final e) => e.join('\n'),
  _ => MessageConstants.unexpectedError,
};
```

## Validation Error Display
ValidationFailure carries a list of field-level messages from the backend.
Display inline next to the relevant form field where possible.
Fall back to a summary snackbar if field context is unknown.

## Auth Errors
401 in AuthInterceptor triggers token refresh.
If refresh fails: fires authExpiredProvider -> router redirects to login.
No feature needs to handle 401 directly.
