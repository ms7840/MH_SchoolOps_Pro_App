# 24 — Architecture Decision Records (ADRs)

## Overview
This document logs the foundational architectural decisions governing the SchoolOpsPro Flutter mobile application. An Architecture Decision Record (ADR) captures an important architectural decision made along with its context and consequences.

---

## Decision Log

| ID | Title | Status | Date | Decision Summary | Full Document |
|---|---|---|---|---|---|
| **ADR-001** | Adoption of Clean Architecture | Accepted | 2026-10-04 | 3-layer architecture (Presentation, Domain, Data) with strict inward dependency rule | [ADR-001](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/decisions/ADR-001-clean-architecture.md) |
| **ADR-002** | Riverpod for State & Dependency Injection | Accepted | 2026-10-04 | Compile-time safe state management and unified DI container without `get_it` | [ADR-002](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/decisions/ADR-002-state-management.md) |
| **ADR-003** | Dio as Core HTTP Client | Accepted | 2026-10-04 | Interceptor-driven HTTP client with automatic JWT refresh and logging | [ADR-003](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/decisions/ADR-003-network-client.md) |
| **ADR-004** | White-Label Architecture via Flavors | Accepted | 2026-10-04 | Flutter Flavors + compile-time `--dart-define` for multi-school deployments | [ADR-004](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/decisions/ADR-004-white-label-deployment.md) |
| **ADR-005** | Dual Storage Strategy (Keychain + Hive) | Accepted | 2026-10-04 | `flutter_secure_storage` for credentials + `Hive` for offline caching | [ADR-005](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/decisions/ADR-005-storage.md) |
| **ADR-006** | Template Reusability & Upgrade Resilience | Accepted | 2026-10-10 | Strict adapter isolation in `core/` and pure Dart domain for effortless tech upgrades and multi-app template reuse | [ADR-006](file:///d:/MH_SchoolPro_APP/docs/architecture/decisions/ADR-006-template-reusability-and-upgrade-resilience.md) |

---

## ADR Status Lifecycle

```
[Proposed]  -->  [Accepted]  -->  [Deprecated]
                     |
                     +--------->  [Superseded by ADR-xxx]
```

- **Proposed**: Under review by the engineering team; not yet binding.
- **Accepted**: Approved and actively enforced in the codebase.
- **Deprecated**: No longer recommended; legacy code may still use it.
- **Superseded**: Replaced by a newer ADR (must link to the successor).

---

## How to Propose a New ADR

1. Create a new markdown file in `docs/architecture/decisions/` named `ADR-XXX-<short-title>.md`.
2. Follow the standard template below.
3. Update this index table with ID, Title, Status, and link.
4. Submit for team architectural review.

---

## ADR Template

```markdown
# ADR-XXX: [Short Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-YYY]

## Date
YYYY-MM-DD

## Context & Problem Statement
What is the problem or architectural challenge we are addressing?
What constraints or requirements must be balanced?

## Considered Options
1. Option 1: Description, pros, cons
2. Option 2: Description, pros, cons
3. Option 3: Description, pros, cons

## Decision Outcome
Chosen option: [Option X] because [rationale].

### Positive Consequences
- Benefit 1
- Benefit 2

### Negative Consequences / Trade-offs
- Trade-off 1
- Mitigation strategy

## Compliance & Enforcement
How will this decision be enforced? (e.g., linter rules, code review checklist, architecture tests).
```
