# ADR-003: Dio as Core HTTP Client

## Status
Accepted

## Date
2026-10-04

## Context & Problem Statement
SchoolOpsPro Mobile consumes a suite of .NET Core microservices over REST APIs. The mobile client requires:
1. Automatic injection of JWT access tokens in the `Authorization` header.
2. Transparent token refresh: when an API returns HTTP 401 Unauthorized, the client must pause outgoing requests, fetch a new access token using the refresh token, and replay the original request seamlessly.
3. Configurable timeouts, SSL certificate handling, and base URL resolution per environment.
4. Robust request/response interceptors for logging, retry on network drops, and error normalization.
5. Standard `http` package in Dart requires significant custom plumbing for interceptors, streaming, and cancellation.

## Considered Options
1. **Dio with Interceptors**
2. **Dart `http` package with custom client wrappers**
3. **Chopper / Retrofit on top of `http`**

## Decision Outcome
Chosen option: **Dio** (Option 1).

### Key Architectural Components
- **`ApiClient`**: A thin abstraction over Dio wrapped in Riverpod (`apiClientProvider`), providing standardized GET, POST, PUT, DELETE methods returning typed responses.
- **`AuthInterceptor`**:
  - Automatically attaches `Authorization: Bearer <accessToken>` to every outgoing request.
  - Intercepts HTTP 401 errors, acquires a lock via Dio QueuedInterceptor, requests a token refresh from `POST /api/Authentication/refresh-token`, updates secure storage, and retries queued failed requests.
- **`LoggingInterceptor`**: Logs method, endpoint, status, and duration in development builds while redacting sensitive headers and passwords.
- **`RetryInterceptor`**: Automatically retries idempotent GET requests on transient network timeouts (up to 3 attempts with exponential backoff).

### Positive Consequences
- Centralized token lifecycle management with zero boilerplate in individual data sources.
- First-class support for request cancellation tokens, timeouts, and multi-part file uploads (for student documents and profile pictures).
- Clear separation between raw HTTP details and domain repositories.

### Negative Consequences & Trade-offs
- Third-party dependency dependency risk (Dio is one of the most mature and widely supported Dart packages).
- Interceptor queues must be carefully handled during 401 refresh to avoid infinite loops if the refresh token itself expires.

## Compliance & Enforcement
- Enforced by `docs/architecture/06-api-architecture.md` and `docs/architecture/07-authentication.md`.
- No direct usage of `dart:io` `HttpClient` or `package:http`.
- All network calls must pass through `ApiClient` and reference `ApiConstants`.
