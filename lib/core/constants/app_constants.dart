/// Global application configuration constants.
class AppConstants {
  const AppConstants._();

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Silent Token Refresh Threshold (2 minutes before expiry, matching Angular)
  static const Duration tokenRefreshOffset = Duration(minutes: 2);

  // Pagination Defaults
  static const int defaultPageSize = 20;
  static const int initialPage = 1;
}
