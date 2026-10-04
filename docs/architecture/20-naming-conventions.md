# 20 — Naming Conventions

## File Naming
All files: snake_case.dart
One public class per file (with minor exceptions for co-located freezed unions).

| Type | Pattern | Example |
|---|---|---|
| Page/Screen | x_page.dart | student_list_page.dart |
| Widget | x_widget.dart or descriptive_name.dart | student_card.dart |
| DTO | x_dto.dart | student_dto.dart |
| Entity | x.dart | student.dart |
| Repository interface | x_repository.dart | student_repository.dart |
| Repository impl | x_repository_impl.dart | student_repository_impl.dart |
| Use case | x_use_case.dart | get_student_list_use_case.dart |
| Remote data source | x_remote_data_source.dart | student_remote_data_source.dart |
| Local data source | x_local_data_source.dart | student_local_data_source.dart |
| Mapper | x_mapper.dart | student_mapper.dart |
| Notifier/Provider | x_notifier.dart or x_provider.dart | student_list_notifier.dart |
| State class | x_state.dart | student_list_state.dart |
| Constants | x_constants.dart | api_constants.dart |

## Class Naming
PascalCase for all class names.

| Type | Pattern | Example |
|---|---|---|
| Page | XPage | StudentListPage |
| Widget | XWidget or descriptive | StudentCard |
| DTO | XDto | StudentDto |
| Domain entity | X | Student |
| Repository interface | XRepository | StudentRepository |
| Repository impl | XRepositoryImpl | StudentRepositoryImpl |
| Use case | VerbNounUseCase | GetStudentListUseCase |
| Remote data source | XRemoteDataSource | StudentRemoteDataSource |
| State notifier | XNotifier | StudentListNotifier |
| State class | XState | StudentListState |
| Failure | XFailure | NetworkFailure |

## Method Naming
camelCase.
- Use cases: the single method is always call()
- Repository methods: verb + noun (getStudents, getStudentById, createStudent, updateStudent, deleteStudent)
- Notifier methods: verb-first (loadStudents, selectStudent, clearFilter, submitForm)
- Boolean getters: is*, has*, can* (isLoading, hasError, canSubmit)

## Variable Naming
camelCase. Descriptive. No abbreviations except well-known ones (id, url, dto).
- Private: _camelCase
- Providers: xProvider (camelCase ending in Provider): studentListNotifierProvider
- Constants: SCREAMING_SNAKE_CASE for compile-time constants

## Constants
```dart
// Top-level constants: SCREAMING_SNAKE_CASE
const String API_VERSION = 'v1';

// Static class constants: camelCase (preferred for namespaced constants)
class ApiConstants {
  static const String students = '/api/Student';
}
```
Prefer class-namespaced constants to avoid pollution of the global namespace.

## Provider Naming (Riverpod code gen)
With @riverpod annotation, class is XNotifier, generated provider is xNotifierProvider.
Manual providers: xProvider (e.g., apiClientProvider, studentRepositoryProvider).

## Test File Naming
x_test.dart mirroring the source file:
student_repository_impl.dart -> student_repository_impl_test.dart

## Folder Naming
All folders: snake_case. No PascalCase or camelCase folders.

## Import Ordering (enforced by analysis_options.yaml)
1. dart: imports
2. package: imports
3. Relative imports (project files)
Separate each group with a blank line.
