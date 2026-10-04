# 13 — Environment Configuration

## Three Environments
| Environment | Purpose |
|---|---|
| development | Local development, debug features, verbose logging |
| staging | Pre-production testing; production-like data |
| production | Live school deployment |

## Environment + Flavor Combination
Each school has all three environments.
Build matrix: school_a x (dev, staging, prod).

Flavors encode the school identity.
Environment encodes the deployment tier.

main_school_a.dart uses Dart defines to select the environment:
```dart
const environment = String.fromEnvironment('ENV', defaultValue: 'development');
```

## Dart Defines (passing at build time)
```bash
# Development
flutter run --flavor school_a -t lib/main_school_a.dart --dart-define=ENV=development

# Staging
flutter build apk --flavor school_a -t lib/main_school_a.dart --dart-define=ENV=staging

# Production
flutter build apk --flavor school_a -t lib/main_school_a.dart --dart-define=ENV=production
```

## AppConfig Design
```dart
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance!;

  final String apiBaseUrl;
  final String schoolCode;
  final String schoolName;
  final Environment environment;
  final bool enableLogging;
  final bool enableCrashReporting;

  bool get isProduction => environment == Environment.production;
  bool get isDevelopment => environment == Environment.development;
}
```

## API URL Selection per Environment
The API base URL is passed as a Dart define or Flutter flavor build config field.
Never hardcoded in Dart source:
```
WRONG: static const apiBaseUrl = 'https://api.schoolopspro.com';
RIGHT: const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://dev.api.schoola.com')
```

## analysis_options.yaml
Enable strict linting. Add avoid_print lint rule for production readiness.

## CI/CD Considerations
Each pipeline job specifies:
- --flavor <school>
- -t lib/main_<school>.dart
- --dart-define=ENV=<environment>
This matrix ensures correct builds without source code changes.

## No .env Files
Do NOT use .env files or dotenv packages for the mobile app.
All runtime configuration is injected via Dart defines (compile-time) or AppConfig (runtime singleton).
.env files are fragile, easily leaked, and not standard Flutter practice.
