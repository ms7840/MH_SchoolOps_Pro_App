# 23 — Feature Development Process

## Overview
This document defines the end-to-end standard operating procedure for creating a new feature or extending an existing feature in the SchoolOpsPro Flutter mobile application.

Every feature follows the **Clean Architecture Inside-Out** workflow:

```
Step 1: API Inspection & Constants
   ↓
Step 2: Domain Layer (Entities, Repository Interfaces, Use Cases)
   ↓
Step 3: Data Layer (DTOs, Mappers, Remote Data Source, Repository Impl)
   ↓
Step 4: Dependency Injection (Riverpod Providers)
   ↓
Step 5: Presentation Layer (UI State, Notifier, Page, Widgets)
   ↓
Step 6: Navigation & Routing (RouteConstants, AppRouter)
   ↓
Step 7: Testing & Verification
```

---

## Step 1: API Inspection & Constants

Before writing code, inspect the backend .NET Core endpoint specification (Swagger/OpenAPI):
1. Note the HTTP method (`GET`, `POST`, `PUT`, `DELETE`), endpoint URL, and route/query parameters.
2. Note the request body schema and response body schema (including whether it uses the standard SchoolOpsPro response envelope: `{ "data": ..., "isSuccess": true, "message": "..." }`).
3. Add the endpoint to `lib/core/constants/api_constants.dart`:

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  // Existing endpoints...
  static const String timetable = '/api/Timetable';
  static const String timetableWeekly = '/api/Timetable/weekly';
  static const String timetableSubstitute = '/api/Timetable/substitute';
}
```

---

## Step 2: Domain Layer (Pure Dart)

Create the business logic contracts independent of Flutter UI and backend transport.

### 2.1 Domain Entity
Path: `lib/features/<feature>/domain/entities/<entity>.dart`
- Immutable entity using `freezed` or pure Dart `final` fields with value equality.
- Contains only fields the business domain cares about.

```dart
@freezed
class TimetableSlot with _$TimetableSlot {
  const factory TimetableSlot({
    required String id,
    required String periodName,
    required String subjectName,
    required String teacherName,
    required String roomNumber,
    required String startTime,
    required String endTime,
    required bool isSubstitute,
    String? substituteTeacherName,
  }) = _TimetableSlot;
}
```

### 2.2 Repository Interface
Path: `lib/features/<feature>/domain/repositories/<feature>_repository.dart`
- Abstract contract returning `Future<Either<Failure, T>>`.

```dart
abstract interface class TimetableRepository {
  Future<Either<Failure, List<TimetableSlot>>> getWeeklySchedule({
    required String classSectionId,
    required String academicYearId,
  });

  Future<Either<Failure, Unit>> assignSubstitute({
    required String timetableSlotId,
    required String substituteTeacherId,
    required DateTime date,
  });
}
```

### 2.3 Use Cases
Path: `lib/features/<feature>/domain/use_cases/<action>_use_case.dart`
- Single-responsibility class with a `call()` method.

```dart
class GetWeeklyTimetableUseCase {
  final TimetableRepository _repository;
  const GetWeeklyTimetableUseCase(this._repository);

  Future<Either<Failure, List<TimetableSlot>>> call({
    required String classSectionId,
    required String academicYearId,
  }) {
    if (classSectionId.isEmpty || academicYearId.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Class section and academic year are required.')),
      );
    }
    return _repository.getWeeklySchedule(
      classSectionId: classSectionId,
      academicYearId: academicYearId,
    );
  }
}
```

---

## Step 3: Data Layer

Implement backend serialization, remote API requests, and data mapping.

### 3.1 Data Transfer Objects (DTO)
Path: `lib/features/<feature>/data/dto/<entity>_dto.dart`
- Annotated with `@freezed` and `@JsonSerializable()`. Matches backend JSON exactly.

```dart
part 'timetable_slot_dto.freezed.dart';
part 'timetable_slot_dto.g.dart';

@freezed
class TimetableSlotDto with _$TimetableSlotDto {
  const factory TimetableSlotDto({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'periodName') required String periodName,
    @JsonKey(name: 'subjectName') required String subjectName,
    @JsonKey(name: 'teacherName') required String teacherName,
    @JsonKey(name: 'roomNumber') required String roomNumber,
    @JsonKey(name: 'startTime') required String startTime,
    @JsonKey(name: 'endTime') required String endTime,
    @JsonKey(name: 'isSubstitute') @Default(false) bool isSubstitute,
    @JsonKey(name: 'substituteTeacherName') String? substituteTeacherName,
  }) = _TimetableSlotDto;

  factory TimetableSlotDto.fromJson(Map<String, dynamic> json) =>
      _$TimetableSlotDtoFromJson(json);
}
```

### 3.2 Mapper
Path: `lib/features/<feature>/data/mappers/<entity>_mapper.dart`
- Converts DTO to Domain Entity and vice versa.

```dart
extension TimetableSlotDtoMapper on TimetableSlotDto {
  TimetableSlot toDomain() {
    return TimetableSlot(
      id: id,
      periodName: periodName,
      subjectName: subjectName,
      teacherName: teacherName,
      roomNumber: roomNumber,
      startTime: startTime,
      endTime: endTime,
      isSubstitute: isSubstitute,
      substituteTeacherName: substituteTeacherName,
    );
  }
}
```

### 3.3 Remote Data Source
Path: `lib/features/<feature>/data/remote/<feature>_remote_data_source.dart`
- Contract and implementation invoking `ApiClient`/`Dio`.

```dart
abstract interface class TimetableRemoteDataSource {
  Future<List<TimetableSlotDto>> getWeeklySchedule({
    required String classSectionId,
    required String academicYearId,
  });
}

class TimetableRemoteDataSourceImpl implements TimetableRemoteDataSource {
  final ApiClient _client;
  const TimetableRemoteDataSourceImpl(this._client);

  @override
  Future<List<TimetableSlotDto>> getWeeklySchedule({
    required String classSectionId,
    required String academicYearId,
  }) async {
    final response = await _client.get(
      ApiConstants.timetableWeekly,
      queryParameters: {
        'classSectionId': classSectionId,
        'academicYearId': academicYearId,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => TimetableSlotDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
```

### 3.4 Repository Implementation
Path: `lib/features/<feature>/data/repositories/<feature>_repository_impl.dart`
- Implements domain repository; handles exceptions and maps DTOs to entities.

```dart
class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableRemoteDataSource _remoteDataSource;
  const TimetableRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<TimetableSlot>>> getWeeklySchedule({
    required String classSectionId,
    required String academicYearId,
  }) async {
    try {
      final dtos = await _remoteDataSource.getWeeklySchedule(
        classSectionId: classSectionId,
        academicYearId: academicYearId,
      );
      return Right(dtos.map((dto) => dto.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
```

---

## Step 4: Riverpod Providers & DI

Path: `lib/features/<feature>/presentation/providers/<feature>_providers.dart`

```dart
// Remote Data Source Provider
final timetableRemoteDataSourceProvider = Provider<TimetableRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TimetableRemoteDataSourceImpl(apiClient);
});

// Repository Provider
final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  final remote = ref.watch(timetableRemoteDataSourceProvider);
  return TimetableRepositoryImpl(remote);
});

// Use Case Provider
final getWeeklyTimetableUseCaseProvider = Provider<GetWeeklyTimetableUseCase>((ref) {
  final repo = ref.watch(timetableRepositoryProvider);
  return GetWeeklyTimetableUseCase(repo);
});
```

---

## Step 5: Presentation Layer

### 5.1 State Class
Path: `lib/features/<feature>/presentation/state/<feature>_state.dart`

```dart
@freezed
class TimetableState with _$TimetableState {
  const factory TimetableState({
    @Default(AsyncValue.loading()) AsyncValue<List<TimetableSlot>> slots,
    @Default('') String selectedDay,
    @Default(false) bool isFilterOpen,
  }) = _TimetableState;
}
```

### 5.2 State Notifier
Path: `lib/features/<feature>/presentation/providers/<feature>_notifier.dart`

```dart
class TimetableNotifier extends StateNotifier<TimetableState> {
  final GetWeeklyTimetableUseCase _getWeeklyTimetableUseCase;

  TimetableNotifier(this._getWeeklyTimetableUseCase) : super(const TimetableState());

  Future<void> loadSchedule(String classSectionId, String academicYearId) async {
    state = state.copyWith(slots: const AsyncValue.loading());
    final result = await _getWeeklyTimetableUseCase(
      classSectionId: classSectionId,
      academicYearId: academicYearId,
    );
    result.fold(
      (failure) => state = state.copyWith(
        slots: AsyncValue.error(failure.message, StackTrace.current),
      ),
      (slots) => state = state.copyWith(slots: AsyncValue.data(slots)),
    );
  }
}

final timetableNotifierProvider =
    StateNotifierProvider.autoDispose<TimetableNotifier, TimetableState>((ref) {
  final useCase = ref.watch(getWeeklyTimetableUseCaseProvider);
  return TimetableNotifier(useCase);
});
```

### 5.3 Page Widget
Path: `lib/features/<feature>/presentation/pages/<feature>_page.dart`
- Uses `ConsumerWidget` or `HookConsumerWidget`.
- Uses `core/widgets/` for standard feedback, buttons, and app bars.

---

## Step 6: Navigation & Route Registration

1. Add route path and name in `lib/core/constants/route_constants.dart`:
```dart
class RouteConstants {
  static const String timetable = '/timetable';
  static const String timetableName = 'timetable';
}
```

2. Register route in `lib/core/routing/app_router.dart`:
```dart
GoRoute(
  path: RouteConstants.timetable,
  name: RouteConstants.timetableName,
  builder: (context, state) => const TimetablePage(),
),
```

---

## Step 7: Testing & Verification

1. **Unit Test**: Test the UseCase and RepositoryImpl with mock data sources.
2. **Widget Test**: Test the Page widget verifying loading state, error display, and data rendering.
3. **Run Code Generation**:
```bash
dart run build_runner build --delete-conflicting-outputs
```
4. **Run Static Analysis & Tests**:
```bash
flutter analyze
flutter test
```
