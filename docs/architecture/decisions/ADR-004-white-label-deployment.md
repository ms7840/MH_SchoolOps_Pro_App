# ADR-004: Multi-School White-Label Architecture via Flutter Flavors and Dart Defines

## Status
Accepted

## Date
2026-10-04

## Context & Problem Statement
SchoolOpsPro is sold to multiple independent educational institutions. Each institution requires:
1. Distinct app identity on Google Play Store and Apple App Store (unique Bundle ID / Application ID, App Name, App Icon, and Splash Screen).
2. Custom visual branding (primary brand colors, institution crest/logo, typography adjustments).
3. School-specific backend URLs and tenant IDs.
4. Selective feature availability (e.g., School A has Bus/Transport Tracking enabled, School B only has Attendance and Grades).
5. A single unified codebase: we must avoid maintaining separate Git forks or branches for each school.

## Considered Options
1. **Flutter Flavors + Compile-Time Dart Defines (`--dart-define`)**
2. **Runtime Dynamic Theming only (single app in App Store, user picks school at login)**
3. **Separate Git branches/forks per institution**

## Decision Outcome
Chosen option: **Flutter Flavors + Compile-Time Dart Defines** (Option 1).

### Architectural Breakdown
- **Native Android Flavors**: Configured in `android/app/build.gradle` with unique `applicationId`, `resValue "string", "app_name"`, and flavor-specific resource directories (`src/flavor_school_a/res`).
- **iOS Schemes & Configurations**: Configured in Xcode via custom schemes and `.xcconfig` files (`Configurations/SchoolA-Release.xcconfig`) defining unique `BUNDLE_IDENTIFIER` and `APP_DISPLAY_NAME`.
- **Flavor Config Injection**:
  - Distinct entry points (`lib/main_school_a.dart`, `lib/main_school_b.dart`) initialize the app with a strongly-typed `FlavorConfig`.
  - Compile-time `--dart-define` allows switching between `development`, `staging`, and `production` environments per flavor.
- **Theme Extensions**: `ThemeExtension<AppBrandTheme>` applies school-specific primary and secondary color palettes injected at app startup.
- **Feature Flags**: `AppConfig.features` provides boolean flags (`isTransportEnabled`, `isFeePaymentOnlineEnabled`) to conditionally show/hide UI sections.

### Positive Consequences
- **Zero Business Logic Duplication**: 100% of domain, data, and core presentation code is shared across all school builds.
- **Zero Forking**: Eliminates the catastrophic maintenance overhead of Git branching strategies for multi-client apps.
- **Store Compliance**: Fully complies with Apple App Store Review Guidelines regarding institutional branding and dedicated apps.

### Negative Consequences & Trade-offs
- CI/CD build matrix scales with the number of supported schools.
- Native build configurations (`build.gradle` and Xcode schemes) must be updated whenever a new school flavor is onboarded.

## Compliance & Enforcement
- Enforced by `docs/architecture/12-white-label.md` and `docs/architecture/22-ai-development-rules.md`.
- No hardcoded school names, colors, or URLs allowed in any feature or core file.
