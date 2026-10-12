/// Storage key constants for SecureStorage and Hive boxes.
class StorageConstants {
  const StorageConstants._();

  // Secure Storage Keys (Encrypted)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
  static const String userPayload = 'user_payload';

  // Hive Boxes (Local Cache)
  static const String userContextBox = 'user_context_box';
  static const String siblingsBox = 'siblings_box';
  static const String appPreferencesBox = 'app_preferences_box';

  // Preference Keys
  static const String activeSiblingId = 'active_sibling_id';
  static const String activeAcademicSession = 'active_academic_session';
  static const String isDarkMode = 'is_dark_mode';
}
