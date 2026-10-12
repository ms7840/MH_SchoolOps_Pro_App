import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../../features/authentication/presentation/state/auth_state.dart';

/// Navigation redirect guard evaluating authentication and audience roles.
class RouteGuards {
  const RouteGuards._();

  static String? authGuard(AuthState authState, GoRouterState routerState) {
    final isOnLogin = routerState.matchedLocation == RouteConstants.login;

    // 1. User is unauthenticated
    if (authState is Unauthenticated || authState is AuthInitial) {
      return isOnLogin ? null : RouteConstants.login;
    }

    // 2. User is authenticated
    if (authState is Authenticated) {
      if (isOnLogin) {
        // Direct to persona dashboard based on role
        if (authState.profile.isStudentOrParent) {
          return RouteConstants.studentDashboard;
        } else {
          return RouteConstants.staffDashboard;
        }
      }
    }

    return null;
  }
}
