# 06 — API Architecture

## Overview
```
Widget
  --> Riverpod Provider/Notifier
    --> Use Case
      --> Repository Interface (domain)
        --> Repository Implementation (data)
          --> Remote Data Source
            --> ApiClient (core/network)
              --> Dio + Interceptors
                --> Backend REST API
```

The widget NEVER skips layers.

## ApiClient (core/network/api_client.dart)
Typed wrapper around Dio. All features call this, never Dio directly.
Methods match HTTP verbs:
```
Future<ApiResponse<T>> get<T>(String path, {Map<String,dynamic>? queryParams, ...})
Future<ApiResponse<T>> post<T>(String path, {dynamic body, ...})
Future<ApiResponse<T>> put<T>(String path, {dynamic body, ...})
Future<ApiResponse<T>> delete<T>(String path)
```

## Dio Setup (core/network/dio_client.dart)
Dio is configured once at app startup with:
- BaseUrl: AppConfig.instance.apiBaseUrl
- ConnectTimeout: AppConstants.connectTimeout (10s)
- ReceiveTimeout: AppConstants.receiveTimeout (30s)
- Interceptors (in order): AuthInterceptor, LoggingInterceptor, RetryInterceptor

## ApiResponse<T> (core/network/api_response.dart)
Maps the backend ServiceResponse<T> structure:
```
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<ValidationError>? validationErrors;
  final int statusCode;
}
```
T is deserialized by the remote data source using the DTO fromJson factory.

## Interceptors

### AuthInterceptor
- Reads access token from SecureStorageService on every request
- Adds Authorization: Bearer <token> header
- On 401 response: attempts token refresh via AuthRepository
- If refresh succeeds: retries original request with new token
- If refresh fails: clears tokens, fires auth expiry event (authExpiredProvider)

### LoggingInterceptor
- In debug mode: logs method, URL, status, duration
- In production: logs only errors (no request body, no tokens)
- Uses AppLogger abstraction (see 21-coding-guidelines.md)

### RetryInterceptor
- Retries on network errors (DioException.connectionError) up to 2 times
- Exponential backoff: 500ms, 1000ms
- Does NOT retry on 4xx or 5xx (only network-level failures)

## Error Mapping
Remote data sources catch DioException and map to AppException:
```
DioException.connectionError  -> NetworkException
DioException.receiveTimeout   -> TimeoutException
statusCode 401                -> UnauthorizedException
statusCode 403                -> ForbiddenException
statusCode 404                -> NotFoundException
statusCode 422                -> ValidationException(validationErrors)
statusCode 500+               -> ServerException
other                         -> UnknownException
```

Repository implementations catch AppException -> Failure (domain type).
See 14-error-handling.md.

## Endpoint Constants (core/constants/api_constants.dart)
All API paths are constants. Never hardcode in remote data sources.
```
class ApiConstants {
  // Auth
  static const String login = '/api/Auth/login';
  static const String refreshToken = '/api/Auth/refresh-token';

  // Students
  static const String students = '/api/Student';
  static const String studentById = '/api/Student/{id}';

  // Timetable
  static const String timetableSave = '/api/TimetableEntry/save-timetable';
  static const String timetableGet = '/api/TimetableEntry/timetable';
  static const String substitutions = '/api/TimetableSubstitution';
  static const String availableTeachers = '/api/TimetableSubstitution/available-teachers';
}
```
Path parameters ({id}) are replaced using string interpolation in the remote data source.

## Authentication Headers
Set by AuthInterceptor automatically.
Features never set Authorization header manually.

## Pagination
Backend uses server-side pagination. See 22-pagination section in app_constants.dart.
Standard query params: pageNumber, pageSize, sortColumn, sortDirection, searchTerm.
Use PagedRequest and PagedResult domain types defined in core/domain/.

## Request Serialization
Request bodies: DTO.toJson() via json_serializable.
Response deserialization: DTO.fromJson() via json_serializable.
DTOs are generated. Never write fromJson manually.
