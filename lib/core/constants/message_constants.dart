/// User-facing string templates and feedback messages.
class MessageConstants {
  const MessageConstants._();

  static const String appTitle = 'MH SchoolOps Pro';
  static const String welcomeBack = 'Welcome Back';
  static const String signInSubtitle = 'Sign in to access your school dashboard';
  static const String usernameOrEmail = 'Username or Email';
  static const String password = 'Password';
  static const String signInButton = 'Sign In';
  static const String signingIn = 'Signing in...';

  // Validation
  static const String usernameRequired = 'Please enter your username or email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort = 'Password must be at least 6 characters';

  // Errors
  static const String invalidCredentials = 'The username or password you entered is incorrect.';
  static const String sessionExpired = 'Your session has expired. Please sign in again.';
  static const String noInternetConnection = 'No internet connection. Please check your network and try again.';
  static const String serverError = 'Server temporarily unavailable. Please try again later.';
  static const String unexpectedError = 'An unexpected error occurred. Please try again.';
  static const String timeoutError = 'Connection timed out. Please try again.';

  // Sibling Switcher
  static const String switchChild = 'Switch Student Profile';
  static const String selectChildPrompt = 'Select a child to view academic records:';
  static const String currentActiveChild = 'Active Profile';
}
