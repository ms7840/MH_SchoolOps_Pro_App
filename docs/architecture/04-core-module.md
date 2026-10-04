# 04 — Core Module

The core module is shared infrastructure. It is NOT a feature.
It provides cross-cutting services consumed by all features.

## core/config/
**app_config.dart** — Runtime singleton holding flavor-injected values.
```
AppConfig {
  String apiBaseUrl
  String schoolCode
  String schoolName
  Flavor flavor  // dev | staging | production
}
```
Populated once at app startup from the flavor-specific main.dart.
Access via: AppConfig.instance (singleton, not a Riverpod provider to allow use before ProviderScope).

**flavor_config.dart** — Flavor enum + per-flavor constants.
See 12-white-label.md and 13-environment-configuration.md.

## core/constants/
See 05-feature-module.md for scope rules. Core constants cover:
- **api_constants.dart**: endpoint path strings (no base URL — that is in AppConfig)
- **app_constants.dart**: timeouts, page sizes, date formats, regex patterns
- **route_constants.dart**: all go_router named route strings
- **storage_constants.dart**: Hive box names, secure storage key names
- **validation_constants.dart**: min/max lengths, regex references
- **message_constants.dart**: user-facing error and success message templates

## core/di/
**core_providers.dart** — Riverpod providers for core infrastructure:
- apiClientProvider (Dio-based)
- secureStorageProvider
- localCacheProvider
- loggerProvider

Feature providers are defined inside each feature's di/ or presentation/providers/.

## core/error/
**failure.dart** — Sealed class hierarchy for typed failures:
```
Failure (abstract)
  NetworkFailure      -- connection issues
  ServerFailure       -- 5xx errors
  AuthFailure         -- 401/403
  ValidationFailure   -- 422 or client-side
  NotFoundFailure     -- 404
  TimeoutFailure      -- connection/read timeout
  UnknownFailure      -- catch-all
```
Use dartz Either<Failure, T> as return type from repositories and use cases.

**exception.dart** — Internal data-layer exceptions that are caught and mapped to Failure.

## core/network/
See 06-api-architecture.md for full detail.
- **api_client.dart** — Typed wrapper around Dio; all features use this, not Dio directly.
- **dio_client.dart** — Dio instance factory with interceptors attached.
- **api_response.dart** — Generic wrapper matching backend ServiceResponse<T>.
- **interceptors/** — auth_interceptor, logging_interceptor, retry_interceptor.

## core/routing/
See 10-navigation.md for full detail.
- **app_router.dart** — All GoRouter route definitions.
- **route_guards.dart** — Auth guard, role guard logic.

## core/storage/
See 17-storage.md for full detail.
- **secure_storage_service.dart** — Wrapper around flutter_secure_storage.
- **local_cache_service.dart** — Wrapper around Hive.

## core/theme/
- **app_theme.dart** — ThemeData factory; reads school primary/secondary from AppConfig.
- **app_colors.dart** — All color constants (semantic names, not raw hex).
- **app_text_styles.dart** — Named text styles.
- **app_dimensions.dart** — Standard spacing, border radius, icon sizes.

School-specific primary and secondary colors are injected via AppConfig.
The theme is rebuilt on app start using those values.

## core/utils/
Pure Dart utilities. No Flutter imports.
- **date_utils.dart** — Format, parse, compare dates.
- **string_utils.dart** — Truncate, capitalize, sanitize strings.
- **logger.dart** — Centralized logging abstraction (see 19-logging in 21-coding-guidelines.md).
- **validators.dart** — Pure functions returning bool; used by presentation forms.

## core/widgets/
Flutter widgets shared across 2 or more features.
If a widget is used in only one feature, keep it in that feature.

Standard widgets:
- **app_button.dart** — Primary, secondary, danger variants.
- **app_text_field.dart** — Standard input with validation display.
- **app_loader.dart** — Centered loading indicator.
- **app_error_view.dart** — Full-screen or inline error with retry button.
- **app_empty_view.dart** — Empty state with icon and message.
- **app_dialog.dart** — Confirm, info, and error dialog factory.
- **app_dropdown.dart** — Consistent dropdown/select widget.
- **app_pagination.dart** — Load-more and page indicator widget.

## What Does NOT Belong in core/
- Business logic of any feature
- Feature-specific API calls
- Feature-specific state
- API DTOs of specific features
