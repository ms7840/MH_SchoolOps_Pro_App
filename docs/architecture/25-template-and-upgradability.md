# 25 — Reusable App Template & Technology Upgradability

## Overview
This document specifies how SchoolOpsPro Mobile is architected to function both as a production school management app and as a **reusable, future-proof mobile application template** that can be cloned and adapted for other mobile products, while ensuring that future technology upgrades (Flutter SDK, Dart releases, third-party libraries) remain effortless and isolated.

---

## 1. Core Principles of Upgradability & Reusability

### 1.1 Strict Adapter Isolation Pattern
No external library or third-party dependency is ever consumed directly across feature layers. Every external dependency is quarantined behind an adapter in `lib/core/`:

| External Technology | Core Abstraction / Adapter | Impact of Upgrading / Swapping |
|---|---|---|
| **Dio** (HTTP Client) | `ApiClient` (`core/network/api_client.dart`) | Zero change to Data Sources or Repositories |
| **flutter_secure_storage** | `SecureStorageService` (`core/storage/`) | Zero change to Auth/Session logic |
| **Hive** (Key-Value Cache) | `LocalCacheService` (`core/storage/`) | Zero change to Cache Repositories |
| **go_router** (Navigation) | `RouteConstants` + `AppRouter` | Zero change to Feature pages/widgets |
| **Material/Cupertino** | `core/widgets/` (`AppButton`, `AppTextField`, etc.) | Design tokens update centrally |

### 1.2 Pure Dart Domain Layer
The Domain layer (`features/<feature>/domain/`) contains **zero** imports of:
- `package:flutter/...`
- Any third-party state, networking, or persistence packages

Because the domain consists of pure Dart contracts (Entities, Use Cases, Repository interfaces, Failures), breaking changes in Flutter UI or external packages can **never** break core business logic.

---

## 2. Using the Project as a Reusable Template

To repurpose this codebase as a template for a new mobile product:

### 2.1 Pluggable Branding & Theming
All brand-specific visual assets and styling are externalized from widgets:
1. **Brand Palette**: Defined in `lib/core/theme/app_colors.dart` and `lib/core/theme/app_theme.dart`.
2. **Brand Assets**: Sourced dynamically via `assets/branding/app_logo.png`, `splash_logo.png`, `app_icon.png`.
3. **Typography**: Decoupled in `lib/core/theme/app_text_styles.dart`. Switching from one Google Font (e.g. Inter) to another requires updating one font definition file.

### 2.2 Reusable Template Blueprint Checklist
When generating a new app from this template:
1. **Update `AppConfig` / `FlavorConfig`**:
   - Change `appName`, `appCode`, `apiBaseUrl`.
2. **Replace Branding Assets**:
   - Place new logo, splash, and icon in `assets/branding/`.
3. **Configure Color Scheme**:
   - Update primary/secondary accent colors in `FlavorConfig` or `AppColors`.
4. **Plug Feature Modules**:
   - Keep common infrastructure (`authentication`, `core`, `settings`).
   - Add new domain features following the inside-out pattern in `docs/architecture/23-feature-development-process.md`.

---

## 3. Technology Upgrade Strategy (Step-by-Step)

When upgrading major dependencies or Flutter SDK versions:

### 3.1 Flutter SDK Upgrade
1. Update SDK constraint in `pubspec.yaml` (e.g., `sdk: ^3.5.0` or higher).
2. Run `dart format .` and `flutter analyze` to inspect any newly deprecated Dart language features.
3. Because UI components use `core/widgets/`, platform deprecations are fixed once in `core/widgets/` rather than across dozens of screens.

### 3.2 State Management (Riverpod) Upgrade
1. Business logic lives in pure Dart Use Cases, completely independent of Riverpod.
2. StateNotifiers / Notifiers merely call Use Cases and update immutable UI state classes.
3. If Riverpod introduces new syntax or generator APIs, only the `providers/` files in presentation layers are updated.

### 3.3 HTTP & Network Library Upgrade
1. Data sources interact strictly with `ApiClient.get()`, `ApiClient.post()`, etc.
2. If Dio undergoes a breaking major version bump or is replaced, only `lib/core/network/dio_client.dart` and `lib/core/network/api_client.dart` require changes.

### 3.4 Local Storage Upgrade
1. Repositories read/write to `LocalCacheService` and `SecureStorageService`.
2. If Hive is upgraded (e.g., Hive 2 to Hive Next / Isar / SQLite), only `local_cache_service.dart` is refactored. The rest of the app remains 100% untouched.

---

## 4. Production Hygiene Rules for Template Longevity
- **Zero hardcoded strings or raw hex colors**: Always route through `MessageConstants`, `ApiConstants`, `RouteConstants`, and `AppColors`.
- **Zero dynamic types**: Enforce strict compile-time types so compiler flags upgrade errors immediately.
- **Explicit interfaces**: Every service, repository, and data source must be backed by an abstract interface.
