# 18 — Security

## Token Security
- Tokens stored in flutter_secure_storage (AES Android / Keychain iOS)
- Tokens NEVER stored in SharedPreferences or Hive
- Tokens NEVER logged (enforced by LoggingInterceptor config)
- Tokens NEVER appear in URLs (passed in Authorization header only)
- Tokens cleared on logout and on session expiry

## HTTPS
All API calls must use HTTPS.
AppConfig.apiBaseUrl must always be an https:// URL in staging and production.
Development may use http:// for local testing only.
Add a network security config to enforce HTTPS in Android release builds.

## Android Network Security Config
android/app/src/main/res/xml/network_security_config.xml:
```xml
<network-security-config>
  <base-config cleartextTrafficPermitted="false">
    <trust-anchors>
      <certificates src="system"/>
    </trust-anchors>
  </base-config>
</network-security-config>
```
For development, allow cleartext for localhost only:
```xml
<domain-config cleartextTrafficPermitted="true">
  <domain includeSubdomains="false">localhost</domain>
  <domain includeSubdomains="false">10.0.2.2</domain>
</network-security-config>
```

## Logging Security Rules
- LoggingInterceptor: NEVER log Authorization header value
- LoggingInterceptor: NEVER log request body in production
- AppLogger: NEVER log passwords, PINs, or token strings
- Log at INFO level: request URL, response status, duration
- Log at ERROR level: status code + sanitized error message

## Sensitive Data Rules
- Student personal data (PII): display only, never cache unencrypted
- Staff personal data: same policy
- Passwords: never stored; submitted once, never read back
- After logout: clear all Hive boxes and SecureStorage

## Code Obfuscation
Flutter release builds should use obfuscation:
```
flutter build apk --obfuscate --split-debug-info=build/debug-info
```
Upload split-debug-info to crash reporting (e.g., Firebase Crashlytics) for deobfuscated stack traces.

## API Key / Client Secrets
Mobile apps cannot securely store secrets.
SchoolOpsPro backend uses JWT. No API key is embedded in the app.
If any third-party keys are needed, proxy them through the backend.
Never embed secrets in Dart source or assets.

## Certificate Pinning (Optional, v2.0)
Not required in v1.0. Can be added via dio_http2_adapter or ssl_pinning_plugin in a future iteration.
Document decision to defer in ADR-003.

## Jailbreak/Root Detection (Optional)
Consider flutter_jailbreak_detection for highly sensitive deployments.
Not required in v1.0 — defer to school-specific security requirements.

## Biometric Authentication (Optional, v2.0)
Use local_auth package for fingerprint/face unlock on the login screen.
Store a short-lived local session token (not the API refresh token) behind biometric.
