# 15 — Validation

## Philosophy
Backend (.NET Core) is the source of truth for business validation.
Flutter client-side validation improves UX only — prevents obviously bad requests.
Do not duplicate complex backend business rules on the client.

## Validator Functions (core/utils/validators.dart)
Pure Dart functions. Return String? (null = valid, string = error message).
Used directly in TextFormField validator parameter.
```dart
class Validators {
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // use required() separately
    if (!RegExp(ValidationConstants.emailRegex).hasMatch(value)) return MessageConstants.invalidEmail;
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'Field'}) {
    if (value == null || value.length < min) return '$fieldName must be at least $min characters';
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'Field'}) {
    if (value != null && value.length > max) return '$fieldName cannot exceed $max characters';
    return null;
  }

  static String? numeric(String? value, {String fieldName = 'Field'}) {
    if (value != null && value.isNotEmpty && double.tryParse(value) == null)
      return '$fieldName must be a number';
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final v in validators) {
      final error = v(value);
      if (error != null) return error;
    }
    return null;
  }
}
```

## Validation Constants (core/constants/validation_constants.dart)
```dart
class ValidationConstants {
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const int passwordMinLength = 8;
  static const int nameMinLength = 2;
  static const int nameMaxLength = 100;
  static const int maxDescriptionLength = 500;
}
```

## Form Validation Pattern
Use GlobalKey<FormState> and Form widget.
Call form.validate() before submitting.
Display backend ValidationFailure errors inline via a form error state variable.

## Backend Validation Errors
When backend returns ValidationFailure with field errors:
- Display in a SnackBar or inline summary
- Map backend field names to form field context where feasible
- Never silently discard validation errors

## Rules
- Client validates: required, email format, length limits, numeric format
- Backend validates: uniqueness, business rules, referential integrity
- Do NOT replicate backend business rules (e.g., "teacher cannot be assigned to two classes at same time") on the client
- Complex rules should only be enforced server-side
