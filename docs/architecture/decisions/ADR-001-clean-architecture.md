# ADR-001: Adoption of Clean Architecture

## Status
Accepted

## Date
2026-10-04

## Context & Problem Statement
SchoolOpsPro Mobile is a multi-tenant, white-label school management application for Android and iOS that communicates with existing .NET Core microservices. The app will support complex domains: attendance, timetables, subject allocations, fees, student records, and exams. Over time, multiple schools will require different configurations, branding, and feature toggles.

Without strict architectural separation, Flutter codebases tend to mix widget rendering, state logic, direct HTTP requests, and serialization in widget trees, resulting in:
- High coupling and low testability.
- Severe friction when modifying API contracts or UI layouts.
- Inability to share core business logic or test domain rules without the Flutter test harness.

## Considered Options
1. **Clean Architecture (Domain, Data, Presentation layers)**
2. **MVC / MVVM without layered boundaries**
3. **Feature-first / Pragmatic Bloc without strict Domain separation**

## Decision Outcome
Chosen option: **Clean Architecture** (Option 1).

### Architectural Breakdown
- **Presentation Layer**: Widgets, Pages, StateNotifiers, UI States. Depends inward on Domain.
- **Domain Layer**: Pure Dart Entities, Repository Interfaces, Use Cases. Zero dependencies on Flutter UI or Data transport.
- **Data Layer**: DTOs, Mappers, Data Sources (Remote/Local), Repository Implementations. Depends inward on Domain interfaces.

### Positive Consequences
- **Independent Domain Logic**: Domain rules and entities are pure Dart with zero Flutter dependencies, testable with fast pure Dart unit tests.
- **Flexible UI**: UI widgets can be redesigned or replaced without touching business logic or data transport.
- **Interchangeable Backend**: API changes only affect DTOs and DataSources, leaving Domain and Presentation intact.
- **Team Scalability**: Multiple engineers and AI agents can work on distinct layers concurrently with minimal merge conflicts.

### Negative Consequences & Trade-offs
- **Boilerplate**: Requires separate classes for DTOs, Entities, Mappers, Repositories, and Use Cases.
- **Mitigation**: Standardized code generation via `freezed` and `json_serializable`, and feature generation templates outlined in `docs/architecture/23-feature-development-process.md`.

## Compliance & Enforcement
- Enforced by `docs/architecture/03-dependency-rules.md` and `docs/architecture/22-ai-development-rules.md`.
- No `package:flutter` imports allowed in `lib/features/*/domain/`.
- DTOs forbidden from being returned by Use Cases or imported in Presentation.
