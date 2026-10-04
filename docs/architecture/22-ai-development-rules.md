# 22 — AI Development Rules

> **MANDATORY READING FOR ALL AI AGENTS**  
> These rules are non-negotiable. Every code generation, modification, or refactoring task must strictly obey every rule in this document. Any pull request or code generation violating these rules must be rejected.

---

## Law 1: Clean Architecture Boundaries Are Inviolable

```
[Presentation Layer]  -->  [Domain Layer]  <--  [Data Layer]
```

1. **Inner Layer Ignorance**: The Domain layer (`domain/`) must NEVER import or reference anything from the Presentation layer (`presentation/`) or Data layer (`data/`).
2. **Zero Framework Dependencies in Domain**: Domain entities, use cases, and repository interfaces must NOT import `package:flutter/...` (except `@immutable` from `meta` or pure Dart foundations). Domain code is pure Dart.
3. **No Direct Presentation-to-Data Access**:
   - Widgets and Notifiers must NEVER import or call Data Sources (`*RemoteDataSource`, `*LocalDataSource`) or Repositories directly.
   - Presentation interacts with Domain via **Use Cases** (or through Domain Repository interfaces via Riverpod providers).
4. **No DTO Leaks**: DTOs (`*Dto`) belong strictly to the Data layer. They must NEVER be returned to Use Cases, stored in Domain Entities, or passed to UI widgets. Always map DTOs to Domain Entities using mappers (`*Mapper`).

---

## Law 2: HTTP & Network Rules

1. **No HTTP in UI**: NEVER call `Dio`, `http`, or any network client from inside a Widget, StateNotifier, or UseCase.
2. **Only Data Sources Call Network**: All HTTP requests are initiated exclusively inside `RemoteDataSource` implementations.
3. **Zero Hardcoded URLs**:
   - NEVER hardcode an endpoint URL (e.g., `'https://api.schoolopspro.com/v1/students'`).
   - Base URLs come from `AppConfig.baseUrl`.
   - Endpoint paths come from `ApiConstants` (e.g., `ApiConstants.students`).
4. **Token Interceptor Exclusivity**:
   - NEVER manually attach `Authorization: Bearer <token>` in data source methods.
   - The centralized `AuthInterceptor` automatically injects access tokens and handles 401 token refresh.
5. **No Swallowing HTTP Errors**: Catch `DioException` exclusively in Data Sources or Repositories and convert them into domain `Failure` subclasses (`ServerFailure`, `NetworkFailure`, `UnauthorizedFailure`).

---

## Law 3: White-Label & Multi-School Isolation

SchoolOpsPro is deployed across multiple institutions. The core codebase must remain 100% tenant-agnostic:

1. **Zero Hardcoded School Identifiers**:
   - NEVER hardcode school names, tenant IDs, school codes, or branch numbers in code.
   - Access the current school configuration via `ref.watch(appConfigProvider)` or `FlavorConfig.current`.
2. **Zero Hardcoded Brand Assets**:
   - Do not reference hardcoded color hex values (e.g., `Color(0xFF1E88E5)`).
   - Use theme colors via `Theme.of(context).colorScheme` or `AppColors`.
   - Brand logos and school banners must be loaded from flavor asset paths (`assets/branding/app_logo.png`) or dynamic tenant media URLs.
3. **No School-Specific Forking**:
   - Never write `if (schoolName == 'SchoolA') { ... }` in business logic.
   - Use feature flags (`appConfig.features.isFeesEnabled`) or polymorphic strategy providers.

---

## Law 4: State Management & DI Consistency

1. **Riverpod as the Sole DI Container**:
   - Do NOT introduce `get_it`, `injectable`, `provider`, `bloc`, or `getx`.
   - All services, repositories, use cases, and notifiers are wired via Riverpod providers.
2. **No Mutable Global State**:
   - Never declare global mutable variables (e.g., `static User? currentUser;`).
   - All state must reside within Riverpod Notifiers/Providers.
3. **State Immutability**:
   - UI State classes must be immutable (using `@freezed` or `const` constructors).
   - Update state by emitting new instances via `state = state.copyWith(...)`.
4. **Appropriate Consumer Usage**:
   - Do NOT use `ref.read` in `build()`.
   - Do NOT use `ref.watch` in click handlers or callbacks.
   - Use `ref.listen` for one-time events (snackbars, navigation, alerts).

---

## Law 5: Storage & Credential Security

1. **Sensitive Data in Secure Storage Only**:
   - JWT tokens (access + refresh), passwords, and PINs MUST be stored using `SecureStorageService` (`flutter_secure_storage`).
   - NEVER store auth tokens or personal identification data in `SharedPreferences`, `Hive`, or plain text files.
2. **Zero Credential Logging**:
   - NEVER print or log passwords, tokens, full authorization headers, or private user payload data.
   - Ensure `LoggingInterceptor` scrubs `Authorization` headers.
3. **Secure Cache Invalidation**:
   - When the user logs out, all sensitive cache boxes in Hive and secure storage tokens must be purged via `AuthRepository.logout()`.

---

## Law 6: Reuse Existing Abstractions Before Creating New Ones

Before writing any new widget, utility, or helper, the AI agent MUST check `core/`:

1. **Core Widgets**:
   - Check `core/widgets/` before building buttons, text inputs, loaders, empty states, or dialogs.
   - Use `AppButton`, `AppTextField`, `AppLoader`, `AppErrorView`, `AppEmptyView`, `AppDialog`.
2. **Core Utilities**:
   - Check `core/utils/` for date formatting (`DateUtils`), string manipulation (`StringUtils`), and logging (`AppLogger`).
3. **Shared Contracts**:
   - Check `core/error/failure.dart` for standard failures.
   - Check `core/network/api_response.dart` for standard API wrappers.

---

## Law 7: Code Generation & Build Runner Etiquette

1. **Never Hand-Edit Generated Files**:
   - NEVER edit files ending in `.g.dart` or `.freezed.dart`.
   - Modify the source definition and document that `build_runner` must be executed:
     ```bash
     dart run build_runner build --delete-conflicting-outputs
     ```
2. **Proper Part Directives**:
   - When creating Freezed or JsonSerializable files, always include the matching part directives:
     ```dart
     part 'student_dto.freezed.dart';
     part 'student_dto.g.dart';
     ```

---

## Law 8: Strict Naming & File Placement

1. **Strict Folder Structure**: Follow `docs/architecture/02-project-structure.md` to the letter.
2. **Strict Naming Patterns**: Follow `docs/architecture/20-naming-conventions.md`:
   - DTOs: `features/<feature>/data/dto/<entity>_dto.dart` (`*Dto`)
   - Mappers: `features/<feature>/data/mappers/<entity>_mapper.dart` (`*Mapper`)
   - Repositories: Interface in `domain/repositories/`, Impl in `data/repositories/`
   - Use Cases: `features/<feature>/domain/use_cases/<verb>_<noun>_use_case.dart`
   - Notifiers: `features/<feature>/presentation/providers/<feature>_notifier.dart`
   - Pages: `features/<feature>/presentation/pages/<feature>_page.dart`

---

## Law 9: Error Handling Protocol

1. **No Throwing to UI**: Repositories and Use Cases must never throw unhandled exceptions to the presentation layer.
2. **Return `Either<Failure, T>`**:
   - All Repository methods and Use Cases return `Future<Either<Failure, T>>` or `Either<Failure, T>`.
3. **Failures Are Sealed**:
   - Subclass `Failure` from `core/error/failure.dart` (`ServerFailure`, `CacheFailure`, `ValidationFailure`, `UnauthorizedFailure`, `NotFoundFailure`).

---

## AI Agent Pre-Completion Checklist

Before finishing any task, the AI agent must verify:
- [ ] Are all layer boundaries intact? (Domain has no data/presentation imports)
- [ ] Are DTOs mapped to Domain Entities before reaching Domain/UI?
- [ ] Are all endpoint URLs extracted into `ApiConstants`?
- [ ] Are all colors/dimensions referencing theme/constants?
- [ ] Is there zero usage of `print()`? (Used `AppLogger`)
- [ ] Are there zero force-unwraps (`!`) without prior null validation?
- [ ] Are all constructors `const` where possible?
- [ ] Has no hardcoded school branding or logic been introduced?
