# 05 — Feature Module

Every SchoolOpsPro feature follows this identical structure.

## Template Structure
```
features/<feature_name>/
├── data/
│   ├── dto/                     # API response/request shapes (freezed + json_serializable)
│   ├── mappers/                 # DTO -> Domain entity conversion
│   ├── remote/                  # Remote data source (Dio calls)
│   ├── local/                   # Local data source (Hive cache, optional)
│   └── repositories/            # Repository implementations
├── domain/
│   ├── entities/                # Business objects (freezed or equatable)
│   ├── repositories/            # Abstract repository contracts
│   └── use_cases/               # One class per operation
└── presentation/
    ├── pages/                   # Full-screen route destinations
    ├── widgets/                 # Feature-specific UI components
    ├── providers/               # Riverpod providers and notifiers
    └── state/                   # Immutable UI state classes
```

## data/dto/
DTOs exactly mirror the backend JSON structure.
Use json_serializable + freezed for immutable, generated DTOs.
DTOs are NEVER passed into domain or presentation — only mappers touch them.

Example naming: StudentDto, StudentListResponseDto, CreateStudentRequestDto

## data/mappers/
Static extension methods or standalone classes.
One mapper per aggregate.
```
// student_mapper.dart
extension StudentDtoMapper on StudentDto {
  Student toDomain() => Student(id: id, name: '$firstName $lastName', ...);
}
```

## data/remote/
One remote data source per feature.
Calls ApiClient (from core/network/), receives ApiResponse<T>.
Returns DTOs or throws AppException.
Does NOT perform business logic.
Does NOT return domain entities.

## data/repositories/
Implements the domain repository interface.
Catches AppException from remote data source -> maps to Failure.
Calls mapper to convert DTO -> domain entity.
Returns Either<Failure, Entity>.

## domain/entities/
Pure Dart classes. No Flutter. No json_serializable.
Use freezed for immutability or equatable for equality.
These represent business concepts, not API shapes.

## domain/repositories/
Abstract class (Dart interface) defining what data operations this feature needs.
```
abstract class StudentRepository {
  Future<Either<Failure, PagedResult<Student>>> getStudents(PagedRequest params);
  Future<Either<Failure, Student>> getStudentById(String id);
}
```

## domain/use_cases/
Each use case is one class with a call() method.
Naming: VerbNounUseCase (GetStudentListUseCase, CreateAttendanceUseCase).
```
class GetStudentListUseCase {
  final StudentRepository _repository;
  GetStudentListUseCase(this._repository);
  Future<Either<Failure, PagedResult<Student>>> call(PagedRequest params) =>
      _repository.getStudents(params);
}
```

## presentation/state/
Immutable state class for each screen or logical section.
Use freezed.
```
@freezed
class StudentListState with _StudentListState {
  const factory StudentListState.initial() = _Initial;
  const factory StudentListState.loading() = _Loading;
  const factory StudentListState.loaded(PagedResult<Student> result) = _Loaded;
  const factory StudentListState.error(Failure failure) = _Error;
}
```

## presentation/providers/
Riverpod StateNotifier or AsyncNotifier.
Injects use case via ref.read or constructor injection.
Calls use case, maps result to state.
See 08-state-management.md.

## presentation/pages/
One file per route destination.
Filename ends in _page.dart.
Consumes Riverpod providers.
Delegates to widgets for decomposed UI.
Contains NO business logic.

## presentation/widgets/
Feature-specific UI components.
If a widget becomes useful in another feature, move it to core/widgets/.
