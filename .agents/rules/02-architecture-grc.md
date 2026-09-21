# Clean Architecture for Themis (GRC Domain)

Themis adheres strictly to Robert C. Martin's Clean Architecture. The architecture is organized in concentric layers with dependencies pointing strictly inward.

```
       +--------------------------------------------------+
       |   Presentation (UI, Components, Pages, Stores)   |
       |  +--------------------------------------------+  |
       |  |   Infrastructure (APIs, Storage, Crypto)   |  |
       |  |  +--------------------------------------+  |  |
       |  |  |   Application (Use Cases, DTOs)      |  |  |
       |  |  |  +--------------------------------+  |  |  |
       |  |  |  |  Domain (Entities, Value Obj)  |  |  |  |
       |  |  |  +--------------------------------+  |  |  |
       |  |  +--------------------------------------+  |  |
       |  +--------------------------------------------+  |
       +--------------------------------------------------+
```

---

## 1. Domain Layer (`src/domain/`)

*   **Responsibility:** Represents enterprise business rules and GRC concepts. It is completely independent of frameworks, UI, and external libraries.
*   **Contents:**
    *   **Entities:** Objects with a unique identity and lifecycle (e.g., `Risk`, `Control`, `Evidence`, `AuditAssessment`).
    *   **Value Objects:** Immutable objects characterized only by their attributes (e.g., `RiskScore`, `ControlCode`, `ComplianceStatus`, `EvidenceHash`).
    *   **Domain Events:** Events signaling significant business occurrences (e.g., `RiskExceededThresholdEvent`, `ControlFailedAuditEvent`).
    *   **Repository Interfaces:** Ports defining how domain entities are persisted or retrieved (e.g., `IRiskRepository`, `IControlRepository`).
    *   **Domain Exceptions:** Custom errors capturing invariant violations (e.g., `InvalidControlStateTransitionError`).
*   **Dependencies:** ZERO external dependencies (no React, no Next.js, no Prisma/Drizzle, no Axios). Pure TypeScript only.

---

## 2. Application Layer (`src/application/`)

*   **Responsibility:** Coordinates use cases and business workflows. Orchestrates domain entities to fulfill specific application features.
*   **Contents:**
    *   **Use Cases:** Single-purpose command/query handlers (e.g., `AssessRiskUseCase`, `SubmitControlEvidenceUseCase`, `GenerateComplianceReportUseCase`).
    *   **DTOs (Data Transfer Objects):** Plain data structures crossing boundaries between presentation/infrastructure and application.
    *   **Ports & Secondary Interfaces:** Abstractions for notification services, cryptographic signing, or audit streamers (e.g., `IAuditStreamer`, `INotificationService`).
*   **Dependencies:** Depends ONLY on the Domain layer. Never imports Presentation or Infrastructure.

---

## 3. Infrastructure Layer (`src/infrastructure/`)

*   **Responsibility:** Implements ports and secondary interfaces defined in Domain and Application layers. Manages external tools, databases, APIs, and OS features.
*   **Contents:**
    *   **Repository Implementations:** E.g., `IndexedDbRiskRepository`, `RestApiControlRepository`, `SupabaseEvidenceRepository`.
    *   **Cryptographic Services:** E.g., `WebCryptoAuditSigner` (SHA-256 / Ed25519 tamper-evident hashing).
    *   **Adapters & External Clients:** Connectors to external GRC sources (AWS Security Hub, GitHub Audit, Cloudflare).
*   **Dependencies:** Depends on Application and Domain layers, plus external libraries.

---

## 4. Presentation Layer (`src/presentation/`)

*   **Responsibility:** User interface, state management, and user interaction.
*   **Contents:**
    *   **Components:** Modular React 19 components using Shadcn UI / Tailwind CSS.
    *   **State Stores:** Zustand feature slices for transient UI state (e.g., active filters, drawer state, modal visibility).
    *   **Query Hooks:** TanStack Query hooks consuming Application Use Cases / API services for server state.
    *   **View Transitions:** Smooth screen and navigation animations using `@vercel/react-view-transitions`.
*   **Dependencies:** Depends on Application and Domain layers for DTOs and contracts.
