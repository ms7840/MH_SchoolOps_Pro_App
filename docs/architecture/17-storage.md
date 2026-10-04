# 17 — Storage

## Storage Types
| Type | Package | Used For |
|---|---|---|
| Secure storage | flutter_secure_storage | Tokens, sensitive credentials |
| Local cache | Hive | API response caching, user preferences |
| Preferences | shared_preferences | Non-sensitive app settings (theme mode, last selected tab) |

## Secure Storage (core/storage/secure_storage_service.dart)
Wrapper around flutter_secure_storage.
Uses AES encryption on Android, Keychain on iOS.
Never use for non-sensitive data (slower than Hive).

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();
}
```

Keys defined in core/constants/storage_constants.dart:
```dart
class StorageConstants {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
  static const String userId = 'user_id';
  static const String schoolCode = 'school_code';
}
```

## Local Cache (core/storage/local_cache_service.dart)
Wrapper around Hive.
Used for: caching API responses (student list, staff list, timetable) for offline-tolerable display.
Not for offline-first — initial architecture is online-required.
Cache is secondary; always fetch fresh from API on load; show cached while loading.

Hive box names defined in StorageConstants.
```dart
class StorageConstants {
  static const String studentCacheBox = 'student_cache';
  static const String timetableCacheBox = 'timetable_cache';
}
```

## SharedPreferences
For non-sensitive user preferences:
- Theme mode (light/dark/system)
- Language preference (future)
- Last viewed tab
- Tutorial shown flag

Wrap in a PreferencesService to avoid scattered SharedPreferences calls.

## What Goes Where
```
Access token        -> SecureStorageService
Refresh token       -> SecureStorageService
User ID             -> SecureStorageService
API response cache  -> Hive (LocalCacheService)
Theme preference    -> SharedPreferences
```

## Security
See 18-security.md.
NEVER write tokens to Hive or SharedPreferences.
NEVER log token values.
On logout: call secureStorageService.deleteAll() to clear all sensitive data.

## Cache Invalidation
Hive cache is invalidated when:
- User logs out (clear all boxes)
- Pull-to-refresh is triggered
- After mutating operations (create/update/delete)

Do not implement complex cache invalidation in v1.0.
Prefer: load from network, write to cache, read from cache on network failure.
