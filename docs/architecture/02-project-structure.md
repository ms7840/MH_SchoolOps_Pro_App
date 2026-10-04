# 02 — Project Structure

## Full Directory Tree

```
d:\MH_SchoolOps_Pro_Mobile\
├── GEMINI.md                          # AI agent entry point (always read first)
├── CLAUDE.md                          # Alias — same content as GEMINI.md
├── docs/
│   └── architecture/
│       ├── 00-overview.md
│       ├── 01-clean-architecture.md
│       ├── 02-project-structure.md    # This file
│       ├── 03-dependency-rules.md
│       ├── 04-core-module.md
│       ├── 05-feature-module.md
│       ├── 06-api-architecture.md
│       ├── 07-authentication.md
│       ├── 08-state-management.md
│       ├── 09-dependency-injection.md
│       ├── 10-navigation.md
│       ├── 11-assets-and-icons.md
│       ├── 12-white-label.md
│       ├── 13-environment-configuration.md
│       ├── 14-error-handling.md
│       ├── 15-validation.md
│       ├── 16-models-and-mapping.md
│       ├── 17-storage.md
│       ├── 18-security.md
│       ├── 19-testing.md
│       ├── 20-naming-conventions.md
│       ├── 21-coding-guidelines.md
│       ├── 22-ai-development-rules.md
│       ├── 23-feature-development-process.md
│       ├── 24-decisions.md
│       └── decisions/
│           ├── ADR-001-clean-architecture.md
│           ├── ADR-002-state-management.md
│           ├── ADR-003-network-client.md
│           ├── ADR-004-white-label-deployment.md
│           └── ADR-005-storage.md
│
└── schoolops_mobile/                  # Flutter project root
    ├── android/
    │   └── app/
    │       ├── src/
    │       │   ├── main/              # Shared Android source
    │       │   ├── flavor_school_a/   # School A overrides
    │       │   └── flavor_school_b/   # School B overrides
    │       └── build.gradle           # Flavor definitions
    ├── ios/
    │   ├── Runner/
    │   │   └── Info.plist
    │   ├── Flutter/
    │   │   ├── Debug.xcconfig
    │   │   ├── Release.xcconfig
    │   │   └── Generated.xcconfig
    │   └── Configurations/
    │       ├── SchoolA-Debug.xcconfig
    │       └── SchoolA-Release.xcconfig
    ├── assets/
    │   ├── branding/                  # Flavor-specific; replaced per school
    │   │   ├── app_icon.png
    │   │   ├── app_logo.png
    │   │   └── splash_logo.png
    │   ├── icons/                     # App feature icons (SVG preferred)
    │   ├── images/                    # Static app images
    │   ├── fonts/                     # Custom fonts
    │   └── lottie/                    # Lottie animation files
    ├── lib/
    │   ├── main.dart                  # Entry point — minimal; calls bootstrap
    │   ├── main_school_a.dart         # Flavor-specific main (School A)
    │   ├── main_school_b.dart         # Flavor-specific main (School B)
    │   ├── app/
    │   │   ├── app.dart               # MaterialApp + ProviderScope
    │   │   └── bootstrap.dart         # DI initialization, flavor config load
    │   ├── core/
    │   │   ├── config/
    │   │   │   ├── app_config.dart    # Flavor-injected runtime config
    │   │   │   └── flavor_config.dart # Flavor enum and model
    │   │   ├── constants/
    │   │   │   ├── api_constants.dart
    │   │   │   ├── app_constants.dart
    │   │   │   ├── route_constants.dart
    │   │   │   ├── storage_constants.dart
    │   │   │   ├── validation_constants.dart
    │   │   │   └── message_constants.dart
    │   │   ├── di/
    │   │   │   └── core_providers.dart
    │   │   ├── error/
    │   │   │   ├── failure.dart
    │   │   │   └── exception.dart
    │   │   ├── network/
    │   │   │   ├── api_client.dart
    │   │   │   ├── dio_client.dart
    │   │   │   ├── interceptors/
    │   │   │   │   ├── auth_interceptor.dart
    │   │   │   │   ├── logging_interceptor.dart
    │   │   │   │   └── retry_interceptor.dart
    │   │   │   └── api_response.dart
    │   │   ├── routing/
    │   │   │   ├── app_router.dart
    │   │   │   └── route_guards.dart
    │   │   ├── security/
    │   │   │   └── secure_storage_service.dart
    │   │   ├── storage/
    │   │   │   ├── secure_storage_service.dart
    │   │   │   └── local_cache_service.dart
    │   │   ├── theme/
    │   │   │   ├── app_theme.dart
    │   │   │   ├── app_colors.dart
    │   │   │   ├── app_text_styles.dart
    │   │   │   └── app_dimensions.dart
    │   │   ├── utils/
    │   │   │   ├── date_utils.dart
    │   │   │   ├── string_utils.dart
    │   │   │   ├── logger.dart
    │   │   │   └── validators.dart
    │   │   └── widgets/
    │   │       ├── app_button.dart
    │   │       ├── app_text_field.dart
    │   │       ├── app_loader.dart
    │   │       ├── app_error_view.dart
    │   │       ├── app_empty_view.dart
    │   │       ├── app_dialog.dart
    │   │       ├── app_dropdown.dart
    │   │       └── app_pagination.dart
    │   └── features/
    │       ├── authentication/
    │       │   ├── data/
    │       │   │   ├── dto/
    │       │   │   │   ├── login_request_dto.dart
    │       │   │   │   └── token_response_dto.dart
    │       │   │   ├── mappers/
    │       │   │   │   └── auth_mapper.dart
    │       │   │   ├── remote/
    │       │   │   │   └── auth_remote_data_source.dart
    │       │   │   └── repositories/
    │       │   │       └── auth_repository_impl.dart
    │       │   ├── domain/
    │       │   │   ├── entities/
    │       │   │   │   └── auth_token.dart
    │       │   │   ├── repositories/
    │       │   │   │   └── auth_repository.dart
    │       │   │   └── use_cases/
    │       │   │       ├── login_use_case.dart
    │       │   │       └── logout_use_case.dart
    │       │   └── presentation/
    │       │       ├── pages/
    │       │       │   └── login_page.dart
    │       │       ├── providers/
    │       │       │   └── auth_provider.dart
    │       │       ├── state/
    │       │       │   └── auth_state.dart
    │       │       └── widgets/
    │       │           └── login_form.dart
    │       ├── student/
    │       │   ├── data/ ...
    │       │   ├── domain/ ...
    │       │   └── presentation/ ...
    │       ├── staff/ ...
    │       ├── academic/ ...
    │       ├── attendance/ ...
    │       ├── fees/ ...
    │       ├── communication/ ...
    │       └── timetable/ ...
    ├── test/
    │   ├── core/ ...
    │   └── features/
    │       ├── authentication/
    │       │   ├── data/
    │       │   ├── domain/
    │       │   └── presentation/
    │       └── student/ ...
    ├── integration_test/ ...
    ├── pubspec.yaml
    └── analysis_options.yaml
```

## Rules for This Structure
1. Every feature follows the identical data/domain/presentation layout.
2. core/ is shared infrastructure — not a feature.
3. No cross-feature imports. Features communicate via core/ or navigation.
4. Feature-specific widgets stay inside features/x/presentation/widgets/.
5. Shared widgets (used in 2+ features) go in core/widgets/.
6. Test files mirror the lib/ structure exactly.
