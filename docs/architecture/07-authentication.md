# 07 — Authentication

## Overview
SchoolOpsPro uses JWT with access + refresh tokens.
The mobile app implements silent token refresh transparently.

## Token Storage
- Access token: flutter_secure_storage key = StorageConstants.accessToken
- Refresh token: flutter_secure_storage key = StorageConstants.refreshToken
- Token expiry: flutter_secure_storage key = StorageConstants.tokenExpiry (ISO 8601 string)
Never store tokens in SharedPreferences or Hive (not encrypted).
See 17-storage.md and 18-security.md.

## Login Flow
1. User submits credentials on LoginPage
2. AuthNotifier calls LoginUseCase
3. LoginUseCase calls AuthRepository.login()
4. AuthRepositoryImpl calls AuthRemoteDataSource
5. AuthRemoteDataSource POSTs to /api/Auth/login
6. On success: TokenResponseDto returned
7. AuthRepositoryImpl maps DTO -> AuthToken entity
8. AuthRepositoryImpl stores access + refresh tokens via SecureStorageService
9. AuthNotifier updates state to AuthState.authenticated(userProfile)
10. Router guard detects authenticated state -> navigates to home/dashboard

## Token Refresh Flow (transparent)
1. AuthInterceptor detects 401 from any API call
2. Interceptor calls AuthRemoteDataSource.refreshToken(refreshToken)
3. If success: stores new tokens, retries original request
4. If failure (refresh token expired):
   - Clears all tokens from secure storage
   - Sets authExpiredProvider to true
   - Router guard redirects to /login

## Logout Flow
1. User taps logout
2. LogoutUseCase called
3. Calls /api/Auth/logout (optional server-side invalidation)
4. Clears all tokens from SecureStorageService
5. AuthNotifier sets state to AuthState.unauthenticated()
6. Router navigates to /login

## Auth State (features/authentication/presentation/state/auth_state.dart)
```
@freezed
class AuthState with _AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserProfile profile) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(Failure failure) = _Error;
}
```

## AuthNotifier (features/authentication/presentation/providers/auth_provider.dart)
Exposed as a global Riverpod provider read by the router guard.
The router listens to authStateProvider and redirects accordingly.

## Session Expiration
The router redirect function checks authStateProvider on every navigation.
If state is unauthenticated, redirect to /login regardless of route.
This prevents accessing protected screens after token expiry.

## Remember Login
Not supported in v1.0. Tokens persist across app restarts via secure storage.
As long as refresh token is valid, user stays logged in.

## Role-Based Access
UserProfile contains a roles or permissions list returned from the login API.
Route guards check required roles before allowing navigation.
Features should not embed role-checking logic in widgets; use route guards.
See 10-navigation.md.

## Security Considerations
See 18-security.md.
- No tokens in logs
- No tokens in URL query parameters
- Use HTTPS only
- Token never exposed to JavaScript (N/A — native app)
