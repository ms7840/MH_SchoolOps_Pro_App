import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/message_constants.dart';
import '../../../../core/di/core_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../state/login_form_state.dart';
import 'auth_notifier.dart';

class LoginNotifier extends StateNotifier<LoginFormState> {
  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;
  final AuthNotifier _authNotifier;

  LoginNotifier({
    required LoginUseCase loginUseCase,
    required AuthRepository authRepository,
    required AuthNotifier authNotifier,
  })  : _loginUseCase = loginUseCase,
        _authRepository = authRepository,
        _authNotifier = authNotifier,
        super(const LoginFormState());

  void setUsername(String value) {
    state = state.copyWith(
      username: value,
      usernameError: value.trim().isEmpty ? MessageConstants.usernameRequired : null,
      generalError: null,
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      passwordError: value.trim().isEmpty ? MessageConstants.passwordRequired : null,
      generalError: null,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<bool> submit() async {
    final username = state.username.trim();
    final password = state.password.trim();

    String? usernameError;
    String? passwordError;

    if (username.isEmpty) {
      usernameError = MessageConstants.usernameRequired;
    }
    if (password.isEmpty) {
      passwordError = MessageConstants.passwordRequired;
    }

    if (usernameError != null || passwordError != null) {
      state = state.copyWith(
        usernameError: usernameError,
        passwordError: passwordError,
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrors: true);

    final loginResult = await _loginUseCase(LoginParams(
      username: username,
      password: password,
    ));

    return loginResult.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          generalError: failure.message,
        );
        return false;
      },
      (token) async {
        // Retrieve resolved user profile and update auth state
        final profileEither = await _authRepository.getUserProfile();

        profileEither.fold(
          (failure) {
            state = state.copyWith(
              isSubmitting: false,
              generalError: failure.message,
            );
          },
          (profile) {
            _authNotifier.setAuthenticated(profile);
            state = state.copyWith(isSubmitting: false);
          },
        );

        return profileEither.isRight();
      },
    );
  }
}

final loginNotifierProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginFormState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final authNotifier = ref.watch(authStateProvider.notifier);

  return LoginNotifier(
    loginUseCase: loginUseCase,
    authRepository: authRepository,
    authNotifier: authNotifier,
  );
});
