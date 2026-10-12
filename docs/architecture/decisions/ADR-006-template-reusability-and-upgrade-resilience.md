# ADR-006: Reusable Enterprise App Template & Technology Upgrade Resilience

## Status
Accepted

## Date
2026-10-10

## Context & Problem Statement
The application must serve not only as the implementation for SchoolOpsPro, but also as a reusable enterprise-grade mobile application template and foundation for future mobile applications. Furthermore, mobile platforms, Flutter SDK versions, and open-source packages evolve quickly. The architecture must guarantee:
1. **High Reusability as a Template**: Core infrastructure, authentication orchestration, design system tokens, storage contracts, and network clients can be lifted or cloned to build new mobile apps with custom branding with minimal overhead.
2. **Effortless Technology Upgrades**: Upgrading Flutter SDK (e.g., Flutter 3.x to 4.x), switching or updating external libraries (e.g., HTTP clients, state management versions, caching engines) must not break business logic (Use Cases, Domain Entities) or presentation layouts.
3. **Strict Abstraction Barriers**: Third-party libraries must never leak into Domain or Presentation layers. All external services are wrapped behind adapter interfaces in `core/`.

## Considered Options
1. **Coupled Framework Code**: Directly invoking third-party packages (Dio, Hive, SecureStorage, GoRouter) across widgets and repositories. (Fast to write initially, but catastrophic during framework/package upgrades and cannot be reused cleanly across projects).
2. **Adapter & Interface Isolation Pattern (Chosen)**: All third-party libraries are wrapped in domain/core interfaces (`ApiClient`, `SecureStorageService`, `LocalCacheService`, `NavigationService`, `ThemeConfig`). Features depend strictly on abstractions, enabling drop-in upgrades or replacements without modifying business rules or UI screens.

## Decision Outcome
Chosen option: **Adapter & Interface Isolation Pattern** (Option 2).

### Architectural Breakdown
- **Core Abstraction Layer (`lib/core/`)**:
  - `ApiClient`: Isolates Dio so HTTP client internals, interceptors, or versions can be updated or swapped without touching Data Sources.
  - `SecureStorageService`: Encapsulates OS keychain/keystore APIs.
  - `LocalCacheService`: Encapsulates Hive/KV caching. If cache engine is upgraded or swapped, only one adapter file is modified.
  - `Design System & Theme Tokens (`AppColors`, `AppTypography`, `AppSpacing`, `AppTheme`)`: Fully decoupled from raw platform widgets. Brand styling is defined through swappable brand configuration palettes.
- **Pure Dart Domain Core**:
  - Zero framework dependencies. Upgrading Flutter versions has zero impact on domain models, business logic, validation, or use cases.
- **Pluggable Brand Template Configuration**:
  - App identity, branding assets (logo, icons, splash), theme palettes, and API endpoints are injected via `FlavorConfig` and `AppConfig`, allowing this repository to serve as a starter template for other apps.

### Positive Consequences
- **Future-Proof Upgradability**: Major Flutter SDK or package breaking changes are isolated to small adapter classes in `core/`.
- **Reusable Foundation**: Serves as a standard, modular starter boilerplate for future company mobile applications.
- **Technology Migration Ease**: Easy to adopt newer libraries in the future with zero impact on Domain or Presentation logic.

### Negative Consequences / Trade-offs
- Requires creating and maintaining wrapper/adapter interfaces in `core/`.
- Requires disciplined adherence by developers to never bypass `core/` interfaces.

## Compliance & Enforcement
- Enforced by `docs/architecture/03-dependency-rules.md`, `docs/architecture/22-ai-development-rules.md`, and `docs/architecture/25-template-and-upgradability.md`.
