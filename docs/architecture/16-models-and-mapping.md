# 16 — Models and Mapping

## Three Model Types
```
API JSON --> DTO --> Domain Entity --> UI State
```
Each type has a distinct role. They must NOT be mixed.

## DTOs (Data Transfer Objects)
Location: features/x/data/dto/
Purpose: Exact mirror of the backend JSON response/request.
Generated with: json_serializable + freezed.
Never passed into use cases or widgets.

Naming: XDto, XRequestDto, XResponseDto, XListResponseDto
```dart
@freezed
class StudentDto with _StudentDto {
  const factory StudentDto({
    required String id,
    required String firstName,
    String? lastName,
    String? photoUrl,
    @JsonKey(name: 'classSection') String? classSection,
  }) = _StudentDto;

  factory StudentDto.fromJson(Map<String, dynamic> json) => _StudentDto.fromJson(json);
}
```

## Domain Entities
Location: features/x/domain/entities/
Purpose: Business objects. Pure Dart. No serialization.
Use freezed for immutability and equality, or equatable for simpler cases.

Naming: X (not XEntity, not XModel)
```dart
@freezed
class Student with _Student {
  const factory Student({
    required String id,
    required String fullName,
    String? photoUrl,
    required String classSection,
  }) = _Student;
}
```

## Mappers
Location: features/x/data/mappers/
Convert DTO -> Domain Entity. One extension per aggregate.
```dart
extension StudentDtoMapper on StudentDto {
  Student toDomain() => Student(
    id: id,
    fullName: [firstName, lastName].whereType<String>().join(' '),
    photoUrl: photoUrl,
    classSection: classSection ?? '',
  );
}
```

## UI State Models
If a screen needs a computed/display-only model (not the domain entity itself),
create a separate UI model in presentation/state/ or presentation/models/.
Use when: the screen needs combined/flattened fields not present in the entity.
Avoid premature UI models — use entity directly where sufficient.

## PagedResult (core/domain/paged_result.dart)
Shared across all features:
```dart
@freezed
class PagedResult<T> with _PagedResult<T> {
  const factory PagedResult({
    required List<T> items,
    required int totalCount,
    required int pageNumber,
    required int pageSize,
    required int totalPages,
  }) = _PagedResult<T>;

  bool get hasNextPage => pageNumber < totalPages;
}
```

## PagedRequest (core/domain/paged_request.dart)
```dart
class PagedRequest {
  final int pageNumber;
  final int pageSize;
  final String? sortColumn;
  final String? sortDirection; // asc | desc
  final String? searchTerm;

  Map<String, dynamic> toQueryParams() => {...}
}
```

## Code Generation
Run after modifying any DTO:
  flutter pub run build_runner build --delete-conflicting-outputs
Generated files: x.freezed.dart, x.g.dart (committed to source control).

## Anti-Patterns (NEVER do this)
- Passing DTO directly to a use case
- Passing DTO directly to a widget
- Adding json_serializable to domain entities
- Adding Flutter imports to domain entities
- Sharing a single "model" class across all three concerns
