# 19 — Testing

## Test Pyramid
```
Integration Tests  (few — critical user journeys)
Widget Tests       (moderate — key screen interactions)
Unit Tests         (many — domain, use cases, repositories, mappers)
```

## Directory Structure
Tests mirror lib/ structure exactly.
```
test/
├── core/
│   ├── network/
│   │   └── api_client_test.dart
│   ├── utils/
│   │   └── validators_test.dart
│   └── error/
│       └── failure_test.dart
└── features/
    ├── authentication/
    │   ├── data/
    │   │   ├── dto/          (dto fromJson/toJson tests)
    │   │   ├── mappers/      (mapper tests)
    │   │   └── repositories/ (repo impl tests with mock data source)
    │   ├── domain/
    │   │   └── use_cases/    (use case tests with mock repository)
    │   └── presentation/
    │       ├── providers/    (notifier tests with ProviderContainer)
    │       └── pages/        (widget tests)
    └── student/
        └── ...

integration_test/
└── flows/
    ├── login_flow_test.dart
    └── student_list_flow_test.dart
```

## Unit Tests

### Domain / Use Cases
Mock the repository. Test that the use case delegates correctly.
```dart
test('returns student list on success', () async {
  when(mockRepository.getStudents(any)).thenAnswer((_) async =>
    Right(PagedResult(items: [testStudent], ...)));

  final result = await useCase.call(PagedRequest.initial());

  expect(result.isRight(), true);
});
```

### Repository Implementations
Mock the remote data source. Test error mapping.
```dart
test('maps NetworkException to NetworkFailure', () async {
  when(mockDataSource.getStudents(any)).thenThrow(NetworkException('No internet'));

  final result = await repository.getStudents(PagedRequest.initial());

  expect(result.fold((l) => l, (_) => null), isA<NetworkFailure>());
});
```

### Mappers
Test DTO -> entity conversion with representative data.

## Widget Tests

### Providers in Widget Tests
Use ProviderContainer overrides to inject mock dependencies.
Use ProviderScope with overrides for widget tests.
```dart
testWidgets('shows error view on failure', (tester) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      studentListNotifierProvider.overrideWith((_) => MockStudentListNotifier()),
    ],
    child: const MaterialApp(home: StudentListPage()),
  ));
  expect(find.byType(AppErrorView), findsOneWidget);
});
```

## Integration Tests
Located in integration_test/.
Test complete user flows on a real device or emulator.
Mock the HTTP layer via a local mock server or Dio mock adapter.

## Mocking Strategy
Use mockito with @GenerateMocks or mocktail (no code generation required).
Prefer mocktail for simpler test setup:
```dart
class MockStudentRepository extends Mock implements StudentRepository {}
```

## Test Naming Convention
Group: feature_component (e.g., student_repository, login_use_case)
Test name: describes behaviour, not implementation (e.g., 'returns error when network is unavailable')

## Coverage Target
- Domain (entities, use cases): 90%+
- Repository implementations: 80%+
- Mappers: 100% (simple functions)
- Notifiers: 80%+
- Core utilities: 90%+
- Widgets: critical paths only
