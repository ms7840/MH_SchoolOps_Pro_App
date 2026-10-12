import 'flavor_config.dart';

/// Runtime singleton holding current environment and school flavor configuration.
class AppConfig {
  static AppConfig? _instance;
  final FlavorConfig flavorConfig;

  AppConfig._(this.flavorConfig);

  static void initialize(FlavorConfig config) {
    _instance = AppConfig._(config);
  }

  static AppConfig get instance {
    if (_instance == null) {
      // Fallback default for development
      _instance = AppConfig._(const FlavorConfig(
        flavor: Flavor.development,
        appName: 'MH SchoolOps Pro',
        schoolCode: 'DEFAULT',
        apiBaseUrl: 'https://localhost:7112',
        authServerUrl: 'https://localhost:7112',
      ));
    }
    return _instance!;
  }

  String get appName => flavorConfig.appName;
  String get schoolCode => flavorConfig.schoolCode;
  String get apiBaseUrl => flavorConfig.apiBaseUrl;
  String get authServerUrl => flavorConfig.authServerUrl;
  String get clientId => flavorConfig.clientId;
  String get scopes => flavorConfig.scopes;
  Flavor get flavor => flavorConfig.flavor;
}
