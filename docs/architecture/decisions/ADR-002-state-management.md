# ADR-002: Riverpod for State Management and Dependency Injection

## Status
Accepted

## Date
2026-10-04

## Context & Problem Statement
A scalable school management mobile app requires predictable state management and dependency injection across dozens of features. The state management solution must:
1. Guarantee compile-time safety and eliminate runtime `ProviderNotFoundException` issues common with InheritedWidget/Provider.
2. Natively handle asynchronous states (`AsyncValue` with data, loading, error).
3. Enable easy testing of business logic without spinning up the Flutter widget tree or mocking `BuildContext`.
4. Serve as a clean, unified Dependency Injection (DI) mechanism to eliminate the cognitive overhead and fragility of maintaining separate service locators (like `get_it`).

## Considered Options
1. **Riverpod 2.x (StateNotifier / Notifier + Providers)**
2. **BLoC (flutter_bloc) + get_it / injectable**
3. **Provider + get_it**
4. **GetX**

## Decision Outcome
Chosen option: **Riverpod** (Option 1).

### Key Reasons
- **Compile-Time Safety**: Providers are global constants. Compiler detects missing or misconfigured providers at build time.
- **Unified DI + State**: Riverpod acts as both the state management solution and the dependency injection container. A single `ref.watch(repositoryProvider)` resolves dependencies cleanly without needing `get_it`.
- **AsyncValue Support**: Standardized handling of asynchronous data loading, refreshing, error catching, and cached values.
- **Scoping and Auto-Dispose**: Automatic cleanup of state when screens are popped (`autoDispose`), preventing memory leaks in large forms.
- **Pure Unit Testability**: Business logic inside Notifiers and Providers can be tested by instantiating a `ProviderContainer` without any Flutter rendering pipeline.

### Positive Consequences
- Unified mental model across the codebase.
- No `BuildContext` required to read or pass dependencies.
- Zero runtime crashes due to provider scoping or order of tree insertion.

### Negative Consequences & Trade-offs
- Learning curve for developers accustomed to classic BLoC or GetX.
- Code generation (`riverpod_generator`) adds build steps; however, manual provider declarations are also fully supported where preferred.

## Compliance & Enforcement
- Enforced by `docs/architecture/08-state-management.md` and `docs/architecture/09-dependency-injection.md`.
- No importing `get_it`, `provider`, or `bloc` in `pubspec.yaml`.
- All state updates must be immutable via `state = state.copyWith(...)`.
