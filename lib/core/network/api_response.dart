/// Standard response envelope matching ASP.NET Core ServiceResponse<T>
class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final int statusCode;
  final List<String> errors;
  final List<ApiValidationError> validationErrors;

  const ApiResponse({
    this.data,
    required this.success,
    this.message,
    required this.statusCode,
    this.errors = const [],
    this.validationErrors = const [],
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData)? fromDataJson,
  ) {
    final rawData = json['data'];
    final data = (rawData != null && fromDataJson != null)
        ? fromDataJson(rawData)
        : (rawData as T?);

    final rawValidationErrors = json['validationErrors'];
    final validationErrors = (rawValidationErrors is List)
        ? rawValidationErrors
            .map((e) => ApiValidationError.fromJson(e as Map<String, dynamic>))
            .toList()
        : <ApiValidationError>[];

    final rawErrors = json['errors'];
    final errors = (rawErrors is List)
        ? rawErrors.map((e) => e.toString()).toList()
        : <String>[];

    return ApiResponse<T>(
      data: data,
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int? ?? 200,
      errors: errors,
      validationErrors: validationErrors,
    );
  }
}

class ApiValidationError {
  final String? field;
  final String message;

  const ApiValidationError({this.field, required this.message});

  factory ApiValidationError.fromJson(Map<String, dynamic> json) {
    return ApiValidationError(
      field: json['field'] as String?,
      message: json['message'] as String? ?? 'Invalid field value',
    );
  }
}
