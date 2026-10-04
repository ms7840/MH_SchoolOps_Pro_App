# SchoolOpsPro Mobile — Architecture & System Flow Blueprint

> **Enterprise Multi-Tenant Flutter Mobile Application for Android & iOS**  
> Powered by Clean Architecture, Riverpod 2.x, Dio, and .NET Core Microservices.

---

## 1. System Overview & Context Flow

SchoolOpsPro Mobile is designed as a single Flutter codebase that compiles to institution-specific branded releases (Android & iOS). Each application flavor communicates with .NET Core microservices backed by PostgreSQL.

### Diagram 1: High-Level System Architecture & Context Flow

```mermaid
flowchart TB
    subgraph Clients["Mobile Client Deployments"]
        SA["School A App (iOS / Android)<br/>• Brand A Theme & Logo<br/>• Custom Bundle ID"]
        SB["School B App (iOS / Android)<br/>• Brand B Theme & Logo<br/>• Custom Bundle ID"]
        SC["Default / Tenant N<br/>• Configurable Branding"]
    end

    subgraph MobileCore["Flutter Unified Core Codebase (schoolops_mobile)"]
        direction TB
        FLV["Flavor Injection (FlavorConfig)"]
        UI["Presentation Layer (Riverpod + GoRouter)"]
        DOM["Domain Layer (Pure Dart Entities + Use Cases)"]
        DAT["Data Layer (DTOs + Dio ApiClient)"]
        SEC["Secure Storage & Offline Hive Cache"]
        FLV --> UI
        UI --> DOM
        DOM --> DAT
        DAT --> SEC
    end

    subgraph Gateway["Edge & Security Layer"]
        GW["Reverse Proxy / API Gateway<br/>(TLS Termination, Rate Limiting)"]
    end

    subgraph BackendServices[".NET Core Microservices Platform"]
        AUTH["Auth Service<br/>/api/Authentication"]
        ACAD["Academic & Timetable<br/>/api/Timetable, /api/SubjectAllocation"]
        STUD["Student SIS<br/>/api/Student, /api/Guardian"]
        HR["Staff & HR<br/>/api/Staff"]
        FEE["Fee Management<br/>/api/Fee"]
    end

    subgraph DataStore["Persistence & Storage"]
        PG[("PostgreSQL Database")]
        S3["Cloud Document & Photo Storage"]
    end

    SA --> GW
    SB --> GW
    SC --> GW
    GW --> AUTH
    GW --> ACAD
    GW --> STUD
    GW --> HR
    GW --> FEE

    AUTH --> PG
    ACAD --> PG
    STUD --> PG
    HR --> PG
    FEE --> PG
    STUD --> S3
    HR --> S3
```

---

## 2. Clean Architecture Layer & Dependency Flow

The application strictly obeys Robert C. Martin's Clean Architecture. Outer layers depend inward; the Domain layer contains zero references to Flutter UI or external transport mechanisms.

### Diagram 2: Layer Boundaries & Data Transformation Flow

```mermaid
flowchart LR
    subgraph PresentationLayer["Presentation Layer (Flutter)"]
        direction TB
        Page["Page / Screen<br/>(ConsumerWidget)"]
        Widget["Reusable UI Components<br/>(Core / Feature Widgets)"]
        Notifier["StateNotifier / Notifier<br/>(Riverpod)"]
        UIState["UI State<br/>(AsyncValue / Freezed)"]
        Page --> Widget
        Page --> Notifier
        Notifier --> UIState
    end

    subgraph DomainLayer["Domain Layer (Pure Dart)"]
        direction TB
        UseCase["Use Case<br/>(Single Responsibility call)"]
        RepoContract["Repository Interface<br/>(abstract interface)"]
        Entity["Domain Entity<br/>(Immutable Business Object)"]
        UseCase --> RepoContract
        RepoContract -.returns.-> Entity
    end

    subgraph DataLayer["Data Layer (Infrastructure & Networking)"]
        direction TB
        RepoImpl["Repository Implementation<br/>(Either<Failure, T>)"]
        Mapper["DTO Mapper<br/>(toDomain / toDto)"]
        RemoteDS["Remote Data Source<br/>(HTTP / Dio)"]
        LocalDS["Local Data Source<br/>(Hive Cache)"]
        DTO["Data Transfer Object<br/>(JSON Serializable)"]
        
        RepoImpl --> RemoteDS
        RepoImpl --> LocalDS
        RemoteDS --> DTO
        DTO --> Mapper
        Mapper --> Entity
    end

    subgraph External["External System"]
        API["Backend REST API (.NET Core)"]
        Storage["Keychain / SharedPreferences"]
    end

    Notifier -->|"executes"| UseCase
    RepoImpl --implements--> RepoContract
    RemoteDS -->|"HTTP JSON"| API
    LocalDS -->|"Cached Records"| Storage
```

---

## 3. End-to-End Request, Auth & Silent Token Refresh Flow

Authentication uses JWT access tokens and long-lived refresh tokens. Token injection and 401 recovery occur transparently within Dio interceptors without exposing credentials or logic to the presentation layer.

### Diagram 3: API Request & Silent 401 Token Refresh Sequence

```mermaid
sequenceDiagram
    autonumber
    actor User as User / Screen
    participant Notifier as Riverpod Notifier
    participant UseCase as Use Case
    participant Repo as Repository Impl
    participant RemoteDS as Remote Data Source
    participant Dio as Dio Client & Interceptor
    participant SecureStorage as Secure Storage (Keychain)
    participant API as .NET Core Backend

    User->>Notifier: Trigger Action (e.g. Load Timetable)
    Notifier->>UseCase: call(classSectionId)
    UseCase->>Repo: getWeeklySchedule(...)
    Repo->>RemoteDS: getWeeklySchedule(...)
    RemoteDS->>Dio: GET /api/Timetable/weekly
    Dio->>SecureStorage: Read Access Token
    SecureStorage-->>Dio: "Bearer eyJhbGciOi..."
    Dio->>API: GET /api/Timetable/weekly (Authorization: Bearer)

    alt Scenario A: Token Valid (HTTP 200 OK)
        API-->>Dio: 200 OK + JSON Payload
        Dio-->>RemoteDS: Response Data
        RemoteDS-->>Repo: List<TimetableSlotDto>
        Repo->>Repo: Map DTOs to Domain Entities
        Repo-->>UseCase: Right(List<TimetableSlot>)
        UseCase-->>Notifier: Right(List<TimetableSlot>)
        Notifier-->>User: Emit AsyncValue.data(slots)
    else Scenario B: Token Expired (HTTP 401 Unauthorized)
        API-->>Dio: 401 Unauthorized
        Note over Dio: AuthInterceptor queues outgoing requests
        Dio->>SecureStorage: Read Refresh Token
        SecureStorage-->>Dio: "refresh_token_xyz"
        Dio->>API: POST /api/Authentication/refresh-token
        
        alt Refresh Successful (HTTP 200)
            API-->>Dio: 200 OK + { newAccessToken, newRefreshToken }
            Dio->>SecureStorage: Store New Tokens
            Note over Dio: Replay original failed request
            Dio->>API: GET /api/Timetable/weekly (New Bearer)
            API-->>Dio: 200 OK + JSON Payload
            Dio-->>RemoteDS: Response Data
            RemoteDS-->>Repo: List<TimetableSlotDto>
            Repo-->>Notifier: Right(List<TimetableSlot>)
            Notifier-->>User: Render updated UI
        else Refresh Expired (HTTP 401 / 403)
            API-->>Dio: 401 Unauthorized
            Dio->>SecureStorage: Clear Tokens & Cache
            Dio-->>Notifier: Left(UnauthorizedFailure)
            Notifier-->>User: Navigate to Login (Session Expired)
        end
    end
```

---

## 4. Multi-School White-Label Build Architecture

SchoolOpsPro leverages Flutter Flavors combined with compile-time Dart Defines to compile custom-branded binaries from a single code repository.

### Diagram 4: White-Label Build Pipeline & Configuration Injection

```mermaid
flowchart TD
    subgraph BuildTrigger["Build Invocation (CLI / CI-CD)"]
        CMD["flutter build apk/ipa --flavor school_a \<br/>--target lib/main_school_a.dart \<br/>--dart-define=ENVIRONMENT=production"]
    end

    subgraph NativeFlavoring["Native Platform Packaging"]
        subgraph Android["Android Configuration"]
            AG["android/app/build.gradle<br/>• applicationId: com.schoola.ops<br/>• app_name: School A Ops<br/>• res/drawable: app_icon"]
        end
        subgraph iOS["iOS Configuration"]
            XC["Configurations/SchoolA.xcconfig<br/>• PRODUCT_BUNDLE_IDENTIFIER<br/>• APP_DISPLAY_NAME<br/>• Assets.xcassets"]
        end
    end

    subgraph DartRuntime["Dart Runtime Injection"]
        ENTRY["lib/main_school_a.dart"]
        BOOT["bootstrap()"]
        CONF["FlavorConfig & AppConfig<br/>• tenantId: 'SCH_001'<br/>• baseUrl: 'https://schoola.api...'<br/>• features: { isFees: true, isBus: false }"]
        THEME["ThemeExtension<AppBrandTheme><br/>• primaryColor: #1E88E5<br/>• accentColor: #FFC107"]
    end

    subgraph AppArtifact["Target Release Artifact"]
        OUT1["Google Play Store: School A Mobile.apk / .aab"]
        OUT2["Apple App Store: School A Mobile.ipa"]
    end

    CMD --> Android
    CMD --> iOS
    CMD --> ENTRY
    ENTRY --> BOOT
    BOOT --> CONF
    CONF --> THEME
    Android --> OUT1
    iOS --> OUT2
    THEME --> OUT1
    THEME --> OUT2
```

---

## 5. Feature Development Lifecycle Flow

When developing a new feature (e.g., Timetable, Student Attendance, or Fees), follow the strict 7-phase Inside-Out pattern.

### Diagram 5: Inside-Out Feature Implementation Flow

```mermaid
flowchart TB
    P1["Phase 1: API Inspection<br/>• Inspect .NET Core Swagger / Response Contract<br/>• Register endpoint in ApiConstants"]
    
    P2["Phase 2: Domain Layer (Pure Dart)<br/>• Define Entity in features/x/domain/entities/<br/>• Define Repository interface in domain/repositories/<br/>• Implement Use Case(s) in domain/use_cases/"]

    P3["Phase 3: Data Layer<br/>• Create DTO with @freezed + JsonSerializable<br/>• Write Mapper extension (toDomain, toDto)<br/>• Implement RemoteDataSource (invokes ApiClient)<br/>• Implement RepositoryImpl (returns Either<Failure, T>)"]

    P4["Phase 4: Dependency Injection (Riverpod)<br/>• Register RemoteDataSourceProvider<br/>• Register RepositoryProvider<br/>• Register UseCaseProvider"]

    P5["Phase 5: Presentation Layer<br/>• Define immutable UI State (AsyncValue / Freezed)<br/>• Build StateNotifier with UI event methods<br/>• Implement Page widget & sub-widgets using core design tokens"]

    P6["Phase 6: Navigation & Routing<br/>• Add route name/path to RouteConstants<br/>• Register GoRoute with route guards in AppRouter"]

    P7["Phase 7: Testing & Verification<br/>• Unit test Use Cases and RepositoryImpl<br/>• Widget test Page state transitions<br/>• Run build_runner, flutter analyze, flutter test"]

    P1 --> P2
    P2 --> P3
    P3 --> P4
    P4 --> P5
    P5 --> P6
    P6 --> P7
```

---

## 6. Architecture Documentation Index

The complete architectural context is documented across dedicated Markdown files in `docs/architecture/`:

| Doc | Topic | Highlights |
|---|---|---|
| [GEMINI.md](file:///d:/MH_SchoolOps_Pro_Mobile/GEMINI.md) | AI Agent Master Entry Point | Critical instructions, mandatory read list, hard rules |
| [00-overview.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/00-overview.md) | System Overview | High-level system context, tech stack, constraints |
| [01-clean-architecture.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/01-clean-architecture.md) | Clean Architecture | 3-layer architecture, concentric dependency model |
| [02-project-structure.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/02-project-structure.md) | Project Structure | Complete directory tree and file placement rules |
| [03-dependency-rules.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/03-dependency-rules.md) | Dependency Rules | Strict layer import restrictions and boundaries |
| [04-core-module.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/04-core-module.md) | Core Module | Shared infrastructure, networking, design system |
| [05-feature-module.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/05-feature-module.md) | Feature Module | Feature blueprint and standard component directory |
| [06-api-architecture.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/06-api-architecture.md) | API & HTTP Client | Dio configuration, interceptor pipeline, error unwrapping |
| [07-authentication.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/07-authentication.md) | Authentication | JWT lifecycle, silent 401 refresh, secure token storage |
| [08-state-management.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/08-state-management.md) | State Management | Riverpod patterns, AsyncValue, reactivity rules |
| [09-dependency-injection.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/09-dependency-injection.md) | Dependency Injection | Riverpod as sole DI container; provider hierarchy |
| [10-navigation.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/10-navigation.md) | Navigation | GoRouter routing, route constants, and auth guards |
| [11-assets-and-icons.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/11-assets-and-icons.md) | Assets & Icons | Flavor asset overrides, resolution density, SVGs |
| [12-white-label.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/12-white-label.md) | White-Label Multi-School | Flavor build pipeline, runtime configs, dynamic theming |
| [13-environment-configuration.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/13-environment-configuration.md) | Environments | Development, Staging, Production configuration |
| [14-error-handling.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/14-error-handling.md) | Error Handling | Sealed Failure hierarchy, functional Either<L, R> flow |
| [15-validation.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/15-validation.md) | Validation | Client-side UX validation vs backend authority |
| [16-models-and-mapping.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/16-models-and-mapping.md) | Models & Mapping | DTO vs Domain Entity vs UI State separation |
| [17-storage.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/17-storage.md) | Storage | Secure Storage (tokens) + Hive (offline cache) |
| [18-security.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/18-security.md) | Security | Cryptography, logging hygiene, OWASP MASVS compliance |
| [19-testing.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/19-testing.md) | Testing | Unit test pyramid, mocks, widget tests, integration tests |
| [20-naming-conventions.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/20-naming-conventions.md) | Naming Conventions | File, class, method, provider, and variable naming laws |
| [21-coding-guidelines.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/21-coding-guidelines.md) | Coding Guidelines | Effective Dart, immutability, clean UI, hooks, linting |
| [22-ai-development-rules.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/22-ai-development-rules.md) | AI Agent Rules | Inviolable laws, forbidden patterns, pre-task checklist |
| [23-feature-development-process.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/23-feature-development-process.md) | Feature Process | Step-by-step feature development SOP |
| [24-decisions.md](file:///d:/MH_SchoolOps_Pro_Mobile/docs/architecture/24-decisions.md) | Architecture Decisions | Master ADR index and ADR template |

---

## 7. Developer Quickstart & Build Commands

### Code Generation
Whenever Freezed models or Riverpod providers are added or modified:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Static Analysis & Verification
```bash
flutter analyze
flutter test
```

### Running School Flavors (Development)
```bash
# Run School A in Development mode
flutter run --flavor school_a -t lib/main_school_a.dart --dart-define=ENVIRONMENT=development

# Run School B in Development mode
flutter run --flavor school_b -t lib/main_school_b.dart --dart-define=ENVIRONMENT=development
```

### Building Release Artifacts (Production)
```bash
# Build Android App Bundle (AAB) for School A
flutter build appbundle --flavor school_a -t lib/main_school_a.dart --dart-define=ENVIRONMENT=production

# Build iOS Archive (IPA) for School A
flutter build ipa --flavor school_a -t lib/main_school_a.dart --dart-define=ENVIRONMENT=production
```
