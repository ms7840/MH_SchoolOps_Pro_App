import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import 'route_guards.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/providers/auth_notifier.dart';
import '../../features/dashboard/presentation/pages/staff_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/student_dashboard_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStateProvider.notifier);

  return GoRouter(
    initialLocation: RouteConstants.login,
    refreshListenable: _RiverpodRefreshListenable(authNotifier),
    redirect: (context, state) {
      final currentAuthState = ref.read(authStateProvider);
      return RouteGuards.authGuard(currentAuthState, state);
    },
    routes: [
      GoRoute(
        path: RouteConstants.login,
        name: RouteConstants.loginName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.studentDashboard,
        name: RouteConstants.studentDashboardName,
        builder: (context, state) => const StudentDashboardPage(),
      ),
      GoRoute(
        path: RouteConstants.staffDashboard,
        name: RouteConstants.staffDashboardName,
        builder: (context, state) => const StaffDashboardPage(),
      ),
    ],
  );
});

class _RiverpodRefreshListenable extends ChangeNotifier {
  _RiverpodRefreshListenable(StateNotifier notifier) {
    notifier.addListener((_) {
      notifyListeners();
    });
  }
}
