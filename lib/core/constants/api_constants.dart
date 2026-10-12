/// Central registry of all backend API endpoint paths.
/// Never hardcode endpoint URLs directly in data sources.
class ApiConstants {
  const ApiConstants._();

  // OpenIddict OAuth2 Endpoints
  static const String openIdConfig = '/.well-known/openid-configuration';
  static const String token = '/connect/token';
  static const String authorize = '/connect/authorize';
  static const String userInfo = '/connect/userinfo';
  static const String logout = '/connect/logout';
  static const String revocation = '/connect/revocation';

  // Core Services
  static const String permissions = '/api/Permission';
  static const String roles = '/api/Role';
  static const String roleClaims = '/api/RoleClaim';
  static const String userClaims = '/api/UserClaim';
  static const String userRoles = '/api/UserRole';

  // School Domain Endpoints
  static const String students = '/api/Student';
  static const String siblings = '/api/Student/siblings';
  static const String academicSessions = '/api/Academic/sessions';
  static const String attendance = '/api/Attendance';
  static const String homework = '/api/Homework';
  static const String examinations = '/api/Examination';
  static const String fees = '/api/Fee';
  static const String classTests = '/api/ClassTest';
  static const String activityPlanner = '/api/ActivityPlanner';
  static const String transport = '/api/Transport';
  static const String messaging = '/api/Messaging';
}
