# SchoolOpsPro Mobile — AI Agent Entry Point

> **Read this file before ANY development task.**

## What Is This Project?
Flutter mobile application (Android + iOS) for SchoolOpsPro — a school-management platform.
Backend: .NET Core microservices + PostgreSQL. APIs already exist.

## Before You Write Any Code

1. Read `docs/architecture/00-overview.md`
2. Read `docs/architecture/03-dependency-rules.md`
3. Read `docs/architecture/22-ai-development-rules.md`
4. Identify the **feature** being changed — read its feature doc if it exists
5. Check whether an **existing abstraction** already covers the requirement
6. Follow naming conventions — `docs/architecture/20-naming-conventions.md`

## Always-Read Documents (load every session)
| File | Purpose |
|---|---|
| GEMINI.md | This file — entry point |
| 00-overview.md | System overview and key decisions summary |
| 03-dependency-rules.md | Layer dependency laws |
| 22-ai-development-rules.md | Hard rules for AI agents |

## Read-When-Relevant Documents
| Topic | File |
|---|---|
| Project structure | 02-project-structure.md |
| Core module | 04-core-module.md |
| Feature module | 05-feature-module.md |
| API/HTTP | 06-api-architecture.md |
| Auth/tokens | 07-authentication.md |
| State management | 08-state-management.md |
| Dependency injection | 09-dependency-injection.md |
| Navigation/routing | 10-navigation.md |
| Assets and icons | 11-assets-and-icons.md |
| White-label/multi-school | 12-white-label.md |
| Environments | 13-environment-configuration.md |
| Error handling | 14-error-handling.md |
| Models and mapping | 16-models-and-mapping.md |
| Storage | 17-storage.md |
| Security | 18-security.md |
| Testing | 19-testing.md |
| Naming conventions | 20-naming-conventions.md |
| Adding a new feature | 23-feature-development-process.md |
| Why decisions were made | docs/architecture/decisions/ |

## Key Architectural Decisions (summary)
- **State management**: Riverpod (see ADR-002)
- **HTTP client**: Dio with interceptors (see ADR-003)
- **DI**: Riverpod providers — no get_it
- **Navigation**: go_router with route constants
- **White-label**: Flutter flavors + Dart defines (see ADR-004)
- **Models**: DTO -> Domain Entity -> UI State (no DTOs in domain layer)
- **Storage**: flutter_secure_storage for tokens; Hive for local cache
- **Serialization**: json_serializable + freezed for immutable models

## Hard Rules (abbreviated)
Full list in 22-ai-development-rules.md. The most critical:
- NEVER call HTTP directly from a widget
- NEVER hardcode API URLs
- NEVER bypass layer boundaries (Presentation -> Domain -> Data)
- ALWAYS use existing core abstractions before creating new ones
- ALWAYS put school-specific values in flavor config, not business logic
- ALWAYS follow naming conventions without exception
