# 09 — Dependency Injection

## Decision: Riverpod as DI Container
Riverpod providers serve dual purpose: state management AND dependency injection.
No separate get_it or injectable needed.

## Registration Layers

### Core Infrastructure (core/di/core_providers.dart)
```
// Dio + ApiClient
final dioProvider = Provider<Dio>((ref) => DioClient.create(AppConfig.instance));
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.read(dioProvider)));

// Storage
final secureStorageProvider = Provider<SecureStorageService>((_) => SecureStorageService());
final localCacheProvider = Provider<LocalCacheService>((_) => LocalCacheService());

// Logger
final loggerProvider = Provider<AppLogger>((_) => AppLogger());
```

### Feature Providers (features/x/presentation/providers/x_providers.dart)
```
// Data sources
final studentRemoteDataSourceProvider = Provider<StudentRemoteDataSource>((ref) =>
  StudentRemoteDataSource(ref.read(apiClientProvider)));

// Repository
final studentRepositoryProvider = Provider<StudentRepository>((ref) =>
  StudentRepositoryImpl(ref.read(studentRemoteDataSourceProvider)));

// Use cases
final getStudentListUseCaseProvider = Provider<GetStudentListUseCase>((ref) =>
  GetStudentListUseCase(ref.read(studentRepositoryProvider)));

// Notifier (auto-registered via code generation @riverpod)
```

## Dependency Direction in Providers
Providers reference other providers via ref.read(xProvider).
This mirrors constructor injection in .NET.
There is no service locator anti-pattern because Riverpod validates at compile time.

## Testing
Override providers in tests:
```
final container = ProviderContainer(overrides: [
  studentRepositoryProvider.overrideWithValue(MockStudentRepository()),
]);
```
No need for service locator mocking. Clean and explicit.

## DI Registration Checklist for New Feature
1. Create RemoteDataSource provider in features/x/presentation/providers/x_providers.dart
2. Create Repository provider in same file
3. Create UseCase providers in same file
4. Annotate Notifier with @riverpod (auto-registers)
5. Ensure core providers are not duplicated (read from core/di/core_providers.dart)

## ProviderScope
Single ProviderScope wraps the entire app at the root in app/app.dart.
No nested ProviderScope unless deliberately overriding (e.g., testing or feature isolation).

## What NOT to Do
- Do not call ref.read() during build() for side effects
- Do not create providers inside widgets (use ref.watch())
- Do not create a global singleton service locator alongside Riverpod
- Do not pass repository instances via constructor through multiple widget layers (use ref)
