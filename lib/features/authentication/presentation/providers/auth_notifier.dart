import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/use_cases/get_current_user_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial());

  /// Checks stored session tokens and restores authenticated user state.
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    final userOption = await _getCurrentUserUseCase();

    state = userOption.fold(
      () => const Unauthenticated(),
      (profile) => Authenticated(profile),
    );
  }

  void setAuthenticated(UserProfile profile) {
    state = Authenticated(profile);
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await _logoutUseCase();
    state = const Unauthenticated();
  }

  void handleSessionExpired() {
    state = const Unauthenticated();
  }
}

final StateNotifierProvider<AuthNotifier, AuthState> authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final getCurrentUser = ref.watch(getCurrentUserUseCaseProvider);
  final logout = ref.watch(logoutUseCaseProvider);

  final notifier = AuthNotifier(
    getCurrentUserUseCase: getCurrentUser,
    logoutUseCase: logout,
  );

  // Initialize auth check on launch
  notifier.checkAuthStatus();
  return notifier;
});
