# ADR-005: Dual Storage Strategy (Keychain/Keystore + Hive)

## Status
Accepted

## Date
2026-10-04

## Context & Problem Statement
The SchoolOpsPro mobile client requires persistent client-side storage for two distinct classes of data with conflicting requirements:
1. **High-Security Sensitive Secrets**: JWT Access Tokens, JWT Refresh Tokens, biometric unlock state, and user credentials. These must be stored in hardware-backed encrypted storage resistant to extraction even on jailbroken or rooted devices.
2. **High-Performance Structured Cache**: Offline timetables, student directory listings, app preferences, and unread notification counts. These require ultra-fast reads, low memory overhead, and structured key-value queries, but do not require OS-level cryptographic isolation.

A single storage solution cannot serve both needs:
- `SharedPreferences` is unencrypted and slow for large datasets.
- `flutter_secure_storage` is secure (backed by Android Keystore / iOS Keychain), but reading and writing is asynchronous, IPC-heavy, and throttled on bulk operations.
- SQLite / `sqflite` introduces significant relational schema migration overhead for simple JSON cache structures.

## Considered Options
1. **Dual Storage: `flutter_secure_storage` (Secrets) + `Hive` (Local Cache)**
2. **SQLite (`sqflite` or `drift`) for everything**
3. **`SharedPreferences` for everything with manual AES encryption**

## Decision Outcome
Chosen option: **Dual Storage Strategy** (Option 1).

### Architectural Breakdown
- **`SecureStorageService`** (`lib/core/storage/secure_storage_service.dart`):
  - Backed by `flutter_secure_storage`.
  - Android options: `encryptedSharedPreferences: true` (AES-256 GCM backed by Android Keystore).
  - iOS options: `accessibility: KeychainAccessibility.first_unlock`.
  - Strictly stores: Access Token, Refresh Token, User PIN / Biometric token.
- **`LocalCacheService`** (`lib/core/storage/local_cache_service.dart`):
  - Backed by `Hive`.
  - Stores non-sensitive offline cache boxes: `timetable_box`, `student_profile_box`, `preferences_box`.
  - Fast, synchronous memory-mapped reads with asynchronous disk flushes.
  - Automatically flushed/cleared on user logout.

### Positive Consequences
- **Maximum Security**: Sensitive tokens never touch unencrypted flash memory.
- **High Performance**: UI loads cached screens instantly from Hive without blocking on OS Keychain IPC calls.
- **Clean Separation of Concerns**: Developers have a clear rule on which storage engine to target for any given data point.

### Negative Consequences & Trade-offs
- Two separate storage dependencies to maintain and test.
- Cache invalidation logic must be explicitly managed when logging out or switching accounts.

## Compliance & Enforcement
- Enforced by `docs/architecture/17-storage.md`, `docs/architecture/18-security.md`, and `docs/architecture/22-ai-development-rules.md`.
- Storing JWT tokens or passwords in Hive or SharedPreferences is strictly prohibited and flagged in code review.
- `AuthRepository.logout()` must clear both `SecureStorageService` and all user-scoped `Hive` boxes.
