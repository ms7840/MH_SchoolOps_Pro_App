# 21 — Coding Guidelines

## Overview
This document defines the code style, idioms, design patterns, and engineering standards for the SchoolOpsPro Flutter mobile application. All code written for this repository—whether by human engineers or AI agents—must adhere to these standards.

---

## 1. General Dart & Flutter Standards

### Effective Dart Compliance
Follow the official [Effective Dart](https://dart.dev/effective-dart) style guide across all four dimensions:
- **Style**: Identifier naming, ordering, formatting.
- **Documentation**: Comments, docstrings, markdown formatting.
- **Usage**: Collections, strings, equality, functions.
- **Design**: Types, error handling, interfaces.

### Code Formatting
- Always format code with `dart format` (120-character line limit configured in `analysis_options.yaml`).
- Trailing commas are mandatory for all multi-line argument lists and collection literals. Trailing commas enable clean formatting and readable Git diffs.

```dart
// GOOD: Trailing commas allow clean formatting
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Student Directory'),
      centerTitle: true,
    ),
    body: const StudentListView(),
  );
}

// BAD: Missing trailing commas lead to collapsed lines
Widget build(BuildContext context) {
  return Scaffold(appBar: AppBar(title: const Text('Student Directory')));
}
```

---

## 2. Strong Typing & Null Safety

- **Zero `dynamic`**: Avoid `dynamic` type whenever possible. Explicitly type all generics, collections, and callback signatures. If raw JSON is parsed, type it as `Map<String, dynamic>` and convert it immediately to a typed DTO.
- **No Force Unwrapping (`!`)**: The bang operator (`!`) is strictly forbidden unless guarded by an explicit null check or in unit tests with assertions. Prefer null-aware operators (`?.`, `??`, `??=`) or pattern matching.
- **Prefer `final` and `const`**:
  - Mark every variable, field, and constructor parameter `final` unless mutation is strictly required.
  - Mark constructors `const` whenever possible to enable Flutter's widget tree rebuild optimizations.
- **Dart 3 Features**: Leverage sealed classes, pattern matching, record types, and switch expressions for expressive, type-safe logic:

```dart
// GOOD: Exhaustive pattern matching with sealed classes
String getStatusMessage(SyncStatus status) => switch (status) {
  SyncStatusInitial() => 'Ready to sync',
  SyncStatusLoading(:final progress) => 'Syncing: ${(progress * 100).toInt()}%',
  SyncStatusSuccess(:final itemsCount) => 'Synced $itemsCount records',
  SyncStatusFailure(:final error) => 'Sync failed: ${error.message}',
};
```

---

## 3. Immutability & Model Design

### Freezed for Value Objects & State
Use the `freezed` package for:
1. Domain Entities requiring copy-with and equality.
2. Data Transfer Objects (DTOs) with `json_serializable`.
3. UI State classes and union states.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';

@freezed
class Student with _$Student {
  const factory Student({
    required String id,
    required String admissionNumber,
    required String firstName,
    required String lastName,
    required String classSectionId,
    required String rollNumber,
    required bool isActive,
    String? photoUrl,
    DateTime? dateOfBirth,
  }) = _Student;
}
```

### Freezed Rules
- Never manually edit generated `.freezed.dart` or `.g.dart` files.
- Always run `dart run build_runner build --delete-conflicting-outputs` after editing annotated classes.
- Use `const factory` constructors for all Freezed classes.

---

## 4. Riverpod Usage Guidelines

### Widget Types
Choose the appropriate Riverpod widget base:
1. **`ConsumerWidget`**: Default choice for stateless widgets that read or watch providers.
2. **`HookConsumerWidget`**: When Flutter hooks (`useTextEditingController`, `useAnimationController`, `useFocusNode`) are needed alongside Riverpod.
3. **`ConsumerStatefulWidget`**: When explicit widget lifecycle (`initState`, `dispose`, `didChangeDependencies`) is necessary and hooks are not suitable.
4. **`Consumer` (scoped)**: To minimize rebuild scope within a larger static subtree.

### `ref` Method Conventions
| Method | Where to Use | Purpose |
|---|---|---|
| `ref.watch(provider)` | Inside `build()` method | Subscribes widget to changes; rebuilds on state emission |
| `ref.read(provider)` | Inside event handlers (e.g., `onPressed`, callbacks) | One-time read without subscribing to rebuilds |
| `ref.listen(provider, (prev, next) { ... })` | Inside `build()` method | Triggers side-effects (snackbars, navigation, dialogs) |

```dart
// GOOD: ref.watch for UI, ref.read in callbacks, ref.listen for side effects
class StudentListPage extends ConsumerWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen for one-time side effects
    ref.listen<AsyncValue<void>>(
      studentActionNotifierProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, _) => AppSnackbar.showError(context, error.toString()),
        );
      },
    );

    // 2. Watch state for rendering
    final studentsAsync = ref.watch(studentListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: studentsAsync.when(
        data: (students) => ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) => StudentCard(student: students[index]),
        ),
        loading: () => const AppLoader(),
        error: (error, stack) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.read(studentListNotifierProvider.notifier).load(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // 3. ref.read inside click handler
        onPressed: () => ref.read(studentListNotifierProvider.notifier).refresh(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### NEVER Do in Riverpod
- **NEVER** use `ref.read` inside `build()`: It bypasses reactivity and can lead to stale UI.
- **NEVER** use `ref.watch` inside `onPressed` or asynchronous callbacks: Providers cannot be watched dynamically outside `build()`.
- **NEVER** instantiate state notifiers manually: Always access them via their generated or defined providers.

---

## 5. Widget Architecture & Clean UI

### Single Responsibility Widgets
- Keep widgets small and focused (ideally under 150 lines per widget).
- Break complex layouts into dedicated, descriptive private or public widget classes.

### Do NOT Use Helper Methods for Widgets
```dart
// BAD: Helper methods that return widgets lose element tree caching and context isolation
Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Text('Header'),
  );
}

// GOOD: Extract into a const Stateless / Consumer widget
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Header'),
    );
  }
}
```
**Why?** Standalone widget classes benefit from Flutter’s element-level diffing, `const` constructor caching, and independent rebuild boundaries.

### Design System Compliance
- Never hardcode raw hex colors or fixed pixel dimensions in feature widgets.
- Use `Theme.of(context)`, `AppColors`, `AppTextStyles`, and `AppDimensions`.
- Use pre-built core widgets from `core/widgets/`:
  - Buttons: `AppButton.primary`, `AppButton.secondary`, `AppButton.text`
  - Text fields: `AppTextField`, `AppSearchField`
  - Feedback: `AppLoader`, `AppErrorView`, `AppEmptyView`, `AppDialog`, `AppSnackbar`

---

## 6. Asynchronous Programming & Error Flow

### Functional Error Handling with `fpdart`
All Repository and Use Case calls return an `Either<Failure, T>` from the `fpdart` package:
- `Left(Failure)`: Represents anticipated domain or technical failures.
- `Right(T)`: Represents successful data payload.

```dart
// GOOD: Return Either<Failure, T> from Use Case
class GetStudentDetailsUseCase {
  final StudentRepository _repository;
  const GetStudentDetailsUseCase(this._repository);

  Future<Either<Failure, Student>> call(String studentId) {
    if (studentId.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Student ID cannot be empty.')));
    }
    return _repository.getStudentById(studentId);
  }
}
```

### Async/Await Rules
- Never leave a `Future` unawaited without explicit documentation.
- When working with Flutter controllers (`AnimationController`, `TextEditingController`, `ScrollController`), always dispose them in `dispose()` or use Flutter Hooks (`useTextEditingController`).
- When triggering asynchronous tasks in `StatefulWidget`, check `if (!mounted) return;` after every `await` statement before calling `setState()` or interacting with `BuildContext`.

---

## 7. Comments & Documentation

- **Doc Comments (`///`)**: Provide doc comments for all public classes, abstract interfaces, repository methods, use cases, and complex utilities.
- **Self-Documenting Code**: Choose expressive, intention-revealing names for variables, methods, and types. Comments should explain *why* an unusual decision was made, not *what* clean code already expresses.
- **No Dead Code**: Remove unused imports, commented-out debugging blocks, and obsolete TODOs before merging or committing.
- **No `print()`**: Use `AppLogger.d()`, `AppLogger.i()`, `AppLogger.w()`, or `AppLogger.e()` from `core/utils/logger.dart`.
