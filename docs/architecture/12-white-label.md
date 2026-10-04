# 12 — White-Label / Multi-School Architecture

## Approach: Flutter Flavors + Dart Defines
See ADR-004.
Each school is a Flutter flavor. School-specific values are injected at build time.
Zero business logic changes required between schools.

## Flavor Definition

### Android (android/app/build.gradle)
```groovy
android {
  flavorDimensions "school"
  productFlavors {
    school_a {
      dimension "school"
      applicationId "com.schoolopspro.schoola"
      resValue "string", "app_name", "School A"
      buildConfigField "String", "API_BASE_URL", '"https://api.schoola.schoolopspro.com"'
      buildConfigField "String", "SCHOOL_CODE", '"SCHOOL_A"'
    }
    school_b {
      dimension "school"
      applicationId "com.schoolopspro.schoolb"
      resValue "string", "app_name", "School B"
      buildConfigField "String", "API_BASE_URL", '"https://api.schoolb.schoolopspro.com"'
      buildConfigField "String", "SCHOOL_CODE", '"SCHOOL_B"'
    }
  }
}
```

### iOS (separate .xcconfig files per flavor)
ios/Configurations/SchoolA-Debug.xcconfig:
```
APP_NAME = School A
BUNDLE_ID = com.schoolopspro.schoola
API_BASE_URL = https://api.schoola.schoolopspro.com
SCHOOL_CODE = SCHOOL_A
```

## Dart-Side Flavor Config (core/config/flavor_config.dart)
```
enum Flavor { schoolA, schoolB, development }

class FlavorConfig {
  final Flavor flavor;
  final String schoolCode;
  final String schoolName;
  final String apiBaseUrl;
  final Color primaryColor;
  final Color secondaryColor;
}
```

## main_school_a.dart
```dart
void main() {
  AppConfig.initialize(FlavorConfig(
    flavor: Flavor.schoolA,
    schoolCode: 'SCHOOL_A',
    schoolName: 'Springfield Academy',
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
    primaryColor: const Color(0xFF1565C0),
    secondaryColor: const Color(0xFF42A5F5),
  ));
  bootstrap();
}
```

## Build Commands
```
# School A - Debug
flutter run --flavor school_a -t lib/main_school_a.dart

# School A - Release APK
flutter build apk --flavor school_a -t lib/main_school_a.dart --release

# School A - iOS IPA
flutter build ipa --flavor school_a -t lib/main_school_a.dart --release
```

## What Changes Per School
| Item | Mechanism |
|---|---|
| App name | Flavor string resource (Android) / xcconfig (iOS) |
| Package name / Bundle ID | applicationId / BUNDLE_ID in flavor |
| API base URL | Dart define or flavor BuildConfigField |
| School code | Dart define |
| App icon | assets/branding/app_icon.png replaced, then flutter_launcher_icons |
| App logo | assets/branding/app_logo.png replaced |
| Splash logo | assets/branding/splash_logo.png replaced |
| Primary color | FlavorConfig.primaryColor |
| Secondary color | FlavorConfig.secondaryColor |
| School name (in-app) | FlavorConfig.schoolName |

## What Does NOT Change Per School
- All business logic
- All use cases
- All repositories
- All data sources
- All core widgets
- All navigation
- All feature screens

## Adding a New School
1. Add flavor in android/app/build.gradle and iOS .xcconfig
2. Create lib/main_school_x.dart
3. Place branding assets in a school-specific assets/branding/ replacement
4. Run flutter_launcher_icons and flutter_native_splash for the new flavor
5. Build and distribute via Play Store / App Store as separate app listing

## Flavor-Specific Assets Override (Android)
Place school-specific drawables in:
android/app/src/school_a/res/drawable/
These override the main/ versions for school_a flavor only.
