# 01 — Clean Architecture

## Philosophy
Clean Architecture separates concerns into concentric layers.
The innermost layer (Domain) has zero dependencies on outer layers.
The outermost layer (Presentation/Data) depends inward, never outward.

## The Three Layers

### Domain Layer (innermost — pure Dart)
The heart of each feature. Zero Flutter imports allowed.
Contains:
- **Entities**: Core business objects (e.g., Student, Staff, TimetableEntry)
- **Repository Interfaces**: Abstract contracts defining what data operations are possible
- **Use Cases**: Single-responsibility application operations (e.g., GetStudentListUseCase)
- **Domain Failures**: Typed failure classes specific to business rules
- **Value Objects**: Strongly typed values with built-in validation (optional, use judiciously)

Must NOT contain:
- Flutter widgets or Material imports
- HTTP clients or API models
- Database references
- Platform-specific code

Dart packages allowed: equatable, dartz (or Result type)

### Data Layer (outer)
Implements the domain contracts. Knows about the outside world.
Contains:
- **DTOs** (Data Transfer Objects): Mirror of API JSON response shape
- **Repository Implementations**: Implement domain repository interfaces
- **Remote Data Sources**: Dio HTTP calls; return DTOs
- **Local Data Sources**: Hive read/write; return cached DTOs
- **Mappers**: Convert DTO -> Domain Entity

Must NOT contain:
- Flutter widgets
- Business logic
- Use case orchestration

Dart packages allowed: dio, hive, json_serializable, freezed

### Presentation Layer (outer)
Everything the user sees and interacts with.
Contains:
- **Screens / Pages**: Full-screen Scaffold widgets
- **Widgets**: Reusable UI within a feature
- **Providers / Notifiers**: Riverpod state holders (StateNotifier or Notifier)
- **State Classes**: Immutable UI state (e.g., StudentListState)
- **View Models**: Computed properties for display (optional)

Must NOT contain:
- Direct HTTP calls
- Direct database access
- Business logic (delegate to use cases)
- Repository instantiation (use DI)

## .NET Analogy
```
.NET                         Flutter (per feature)
----                         -------
Domain entities          <-> domain/entities/
Domain services          <-> domain/use_cases/
Repository interfaces    <-> domain/repositories/
Infrastructure           <-> data/
API controllers          <-> (backend — not in Flutter)
```

## Use Case Pattern
Each use case is a class with a single `call()` method.
It receives parameters, calls the repository, and returns Either<Failure, Entity>.

```
class GetStudentListUseCase {
  final StudentRepository _repository;
  GetStudentListUseCase(this._repository);

  Future<Either<Failure, List<Student>>> call(PagedRequest params) =>
      _repository.getStudents(params);
}
```

One use case = one operation. Do not combine unrelated operations.

## Feature Communication
Features must NOT import each other directly.
Cross-feature communication uses:
1. Shared domain entities from core/domain/ (e.g., UserProfile)
2. Navigation events via go_router
3. Riverpod providers read across features (only for truly shared state like auth)

## Core Layer
See 04-core-module.md.
Core is NOT a layer — it is a shared utility module.
It provides services that cut across all features (networking, storage, theme, DI bootstrap).
