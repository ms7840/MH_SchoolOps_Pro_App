# 08 — State Management

## Decision: Riverpod
See ADR-002 for full reasoning. Summary:
- Compile-time safety (no context.read<T>() runtime failures)
- Built-in support for async state (AsyncValue)
- Testable without widget tree
- No BuildContext dependency for reading state
- Strong support for dependency injection
- Active community, excellent Flutter team alignment

## Core Patterns

### AsyncNotifierProvider (preferred for screen-level state)
Used for: list screens, detail screens, form submission.
```
@riverpod
class StudentListNotifier extends _StudentListNotifier {
  @override
  Future<PagedResult<Student>> build() async {
    return await ref.read(getStudentListUseCaseProvider).call(PagedRequest.initial());
  }

  Future<void> loadPage(int page) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
      ref.read(getStudentListUseCaseProvider).call(PagedRequest(page: page)));
  }
}
```

### StateNotifierProvider (for complex mutable UI state)
Used for: forms, multi-step wizards, filter state.
```
@riverpod
class LoginNotifier extends _LoginNotifier {
  @override
  LoginState build() => LoginState.initial();

  void setEmail(String email) => state = state.copyWith(email: email);
  void setPassword(String password) => state = state.copyWith(password: password);

  Future<void> login() async {
    state = state.copyWith(isLoading: true, failure: null);
    final result = await ref.read(loginUseCaseProvider).call(
      LoginParams(email: state.email, password: state.password));
    state = result.fold(
      (failure) => state.copyWith(isLoading: false, failure: failure),
      (_) => state.copyWith(isLoading: false));
  }
}
```

### Provider (for computed/derived state)
Used for: simple computed values, read-only lookups.

## State Classes
Always immutable. Use freezed.
Each state class encodes all possible UI states:
- initial / idle
- loading
- loaded (with data)
- error (with Failure)
- empty (when loaded but no data)

## AsyncValue
Riverpod's built-in for async state. Use it for simple async operations.
Three states: loading, data, error.
Use .when(data:, loading:, error:) in widgets.

## Provider Scoping Rules
- **Global providers** (auth, config, core services): defined in core/di/core_providers.dart
- **Feature providers** (use cases, repositories, notifiers): defined inside features/x/presentation/providers/
- **Local widget state** (tab selection, expansion state): use StateProvider or local widget state — not a full notifier
- NEVER use global providers for feature-specific transient state

## Code Generation
Use riverpod_generator with @riverpod annotation.
Run: flutter pub run build_runner build --delete-conflicting-outputs
Generated file: x.g.dart alongside x.dart.

## Pagination Pattern
```
@freezed
class PagedState<T> with _PagedState<T> {
  const factory PagedState({
    required List<T> items,
    required int currentPage,
    required int totalPages,
    required bool isLoadingMore,
    Failure? failure,
  }) = _PagedState<T>;
}
```
The notifier holds PagedState and appends items on loadMore().

## Error Display Rules
- Failures surface to the UI through state
- Widgets read state and render AppErrorView or inline error
- Never show raw exception messages; map to user-friendly strings via message_constants.dart
