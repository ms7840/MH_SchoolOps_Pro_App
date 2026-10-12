/// Immutable state representing login form inputs and validations.
class LoginFormState {
  final String username;
  final String password;
  final bool isPasswordVisible;
  final bool isSubmitting;
  final String? usernameError;
  final String? passwordError;
  final String? generalError;

  const LoginFormState({
    this.username = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isSubmitting = false,
    this.usernameError,
    this.passwordError,
    this.generalError,
  });

  bool get isValid =>
      username.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      usernameError == null &&
      passwordError == null;

  LoginFormState copyWith({
    String? username,
    String? password,
    bool? isPasswordVisible,
    bool? isSubmitting,
    String? usernameError,
    String? passwordError,
    String? generalError,
    bool clearErrors = false,
  }) {
    return LoginFormState(
      username: username ?? this.username,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      usernameError: clearErrors ? null : (usernameError ?? this.usernameError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
      generalError: clearErrors ? null : (generalError ?? this.generalError),
    );
  }
}
