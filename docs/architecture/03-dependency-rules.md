# 03 — Dependency Rules

> This is a core law document. Never violate these rules.

## The Single Rule
Dependencies always point INWARD.
Outer layers know about inner layers. Inner layers know NOTHING about outer layers.

```
Presentation ----> Domain <---- Data
     |                |              |
     +-----> Core <---+              |
                 ^                  |
                 +------------------+
```

## Allowed Imports Per Layer

### Domain Layer (features/x/domain/)
MAY import:
- dart:core, dart:async
- dartz (for Either type)
- equatable (for entity equality)
- Other domain layer files within the same feature
- core/error/failure.dart

MUST NOT import:
- flutter/* (any Flutter SDK)
- dio, hive, shared_preferences, or any external SDK
- features/x/data/*
- features/x/presentation/*
- Any other feature's layers directly

### Data Layer (features/x/data/)
MAY import:
- features/x/domain/* (implements domain interfaces)
- core/network/*
- core/storage/*
- core/error/*
- core/constants/*
- External packages: dio, hive, json_serializable, freezed

MUST NOT import:
- features/x/presentation/*
- flutter/material.dart (except for platform channels if absolutely required)
- Other features directly

### Presentation Layer (features/x/presentation/)
MAY import:
- features/x/domain/entities/*
- features/x/domain/use_cases/*
- core/widgets/*
- core/routing/*
- core/constants/*
- core/theme/*
- flutter/* (all Flutter SDK)
- riverpod

MUST NOT import:
- features/x/data/* (never — use DI injection)
- core/network/dio_client.dart directly
- Any HTTP client directly

### Core Layer (lib/core/)
MAY import:
- External utility packages
- flutter/* where required (e.g., for widgets, storage)

MUST NOT import:
- features/* (core must never know about features)

## Cross-Feature Rules
Features MUST NOT import each other's data or presentation layers.

Allowed cross-feature patterns:
1. **Shared domain entities** placed in core/domain/ (e.g., UserSession)
2. **Navigation** via go_router route names (strings in route_constants.dart)
3. **Shared Riverpod providers** placed in core/di/ (e.g., authStateProvider)

Never allowed:
- features/student/ importing features/staff/data/
- features/timetable/ importing features/attendance/presentation/

## Enforcement
The analysis_options.yaml should include lint rules to catch import violations.
In CI, run flutter analyze before merging.

## Quick Reference Card
```
Widget calls Use Case? YES — via provider
Widget calls Repository? NO — violation
Widget calls Dio? NO — violation
Use Case calls Repository? YES — via interface
Repository calls Dio? YES — in data layer only
Dio imported in domain? NO — violation
```
