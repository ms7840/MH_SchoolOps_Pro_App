# 10 — Navigation

## Decision: go_router
- Declarative route configuration
- URL-based routing (enables deep links)
- Built-in redirect support for auth guards
- ShellRoute for bottom navigation bar
- Strong Riverpod integration via refreshListenable

## Route Constants (core/constants/route_constants.dart)
All route names and paths as constants. Never hardcode in widgets.
```
class RouteConstants {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String students = '/students';
  static const String studentDetail = '/students/:id';
  static const String timetable = '/timetable';
  static const String attendance = '/attendance';
  // etc.
}
```

## Router Definition (core/routing/app_router.dart)
One GoRouter instance. All routes defined here. No routes defined in widgets.
```
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: RouteConstants.login,
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateProvider.stream)),
    redirect: (context, state) => _authGuard(authState, state),
    routes: [
      GoRoute(path: RouteConstants.login, builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: RouteConstants.dashboard, builder: (_, __) => const DashboardPage()),
          GoRoute(path: RouteConstants.students, builder: (_, __) => const StudentListPage()),
          GoRoute(
            path: RouteConstants.studentDetail,
            builder: (_, state) => StudentDetailPage(id: state.pathParameters['id']!)),
          // ... more routes
        ],
      ),
    ],
  );
});
```

## Auth Guard (core/routing/route_guards.dart)
```
String? authGuard(AuthState authState, GoRouterState state) {
  final isOnLoginPage = state.matchedLocation == RouteConstants.login;
  if (authState is Unauthenticated && !isOnLoginPage) return RouteConstants.login;
  if (authState is Authenticated && isOnLoginPage) return RouteConstants.dashboard;
  return null; // allow navigation
}
```

## Role-Based Navigation
Check UserProfile.roles inside the guard or inside route builders.
Redirect to an "access denied" screen or back to dashboard if unauthorized.
Role constants: features/authentication/domain/entities/user_roles.dart

## Navigation in Widgets
Use context.go() or context.push() from go_router.
Never use Navigator.push() directly (bypasses the router).
Never hardcode paths in widgets — use RouteConstants.

## Deep Links
go_router supports deep links natively via URL matching.
Android: intent-filter in AndroidManifest.xml
iOS: Associated Domains / Universal Links in Info.plist
Configure in app/bootstrap.dart when feature is needed.

## Bottom Navigation
Implemented as a ShellRoute with AppShell widget.
Navigation items are driven by user roles (show only accessible tabs).
State is preserved across tabs using go_router's ShellRoute.

## Passing Arguments
Prefer path parameters for IDs: /students/:id
Use extra for complex objects that do not belong in the URL.
Never pass sensitive data in the URL.
