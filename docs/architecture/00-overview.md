# 00 — System Overview

**Project**: SchoolOpsPro Mobile
**Platform**: Flutter (Android + iOS)
**Backend**: .NET Core microservices, PostgreSQL, REST APIs

## System Context

```
Schools (multiple) --> SchoolOpsPro Mobile App
                            |
                            v
                   SchoolOpsPro Backend APIs
                   (.NET Core microservices)
                            |
                            v
                        PostgreSQL
```

The mobile app is a consumer of existing REST APIs.
It does NOT modify the backend. All business logic lives on the server.
Client-side logic is limited to: UI state, form validation, caching, and navigation.

## Architecture in One Sentence
Feature-oriented Clean Architecture with Riverpod state management,
Dio HTTP client, go_router navigation, and Flutter flavors for multi-school deployment.

## Key Technical Decisions at a Glance
| Concern | Decision | ADR |
|---|---|---|
| Architecture | Clean Architecture (feature-oriented) | ADR-001 |
| State management | Riverpod | ADR-002 |
| HTTP client | Dio | ADR-003 |
| Multi-school / white-label | Flutter flavors + Dart defines | ADR-004 |
| Secure storage | flutter_secure_storage | ADR-005 |
| Local cache | Hive | ADR-005 |
| Navigation | go_router | — |
| Serialization | json_serializable + freezed | — |
| Code generation | build_runner | — |

## SchoolOpsPro Feature Domains
The following features will be developed. Each is an independent feature module.

| Feature | Domain |
|---|---|
| authentication | Login, tokens, session |
| dashboard | Home screen, summaries |
| student | Student profile, lists |
| staff | Staff profile, lists |
| academic | Classes, subjects, timetable |
| attendance | Attendance marking, reports |
| fees | Fee structure, payments |
| communication | Messaging, notifications |
| administration | School setup |
| timetable | Timetable view, substitutions |

## .NET Conceptual Mapping
For developers coming from .NET:

| .NET Project | Flutter Equivalent |
|---|---|
| MyApp.Domain | features/x/domain/ |
| MyApp.Application | features/x/domain/use_cases/ |
| MyApp.Infrastructure | features/x/data/ |
| MyApp.API | Backend — already exists |
| Common.Contract | core/ shared models/types |

See 01-clean-architecture.md for full explanation.

## Multi-School Model
Same Flutter source code. Different build per school.
School-specific values (name, icon, API URL, theme, package name) are injected at build time via Flutter flavors.
See 12-white-label.md.

## Dependency Direction (never violate)
Presentation -> Domain <- Data
All layers -> Core
Domain must NOT import Flutter or Data packages.
See 03-dependency-rules.md.
