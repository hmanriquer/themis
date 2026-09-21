# Clean Architecture for Themis (GRC Domain)

Themis adheres strictly to Robert C. Martin's Clean Architecture. Dependencies point strictly inward. The monorepo maps those layers onto two apps and one contract package — it does not keep a single `src/domain` tree at the repository root.

Canonical design: `docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md`.

```
       +--------------------------------------------------+
       |  iris (TanStack Start) — Presentation            |
       |  routes + feature components + Query + Zustand   |
       |  +--------------------------------------------+  |
       |  |  nomos — Zod DTOs, paths, error envelope   |  |
       |  +--------------------------------------------+  |
       +--------------------------------------------------+
                          |
                          | HTTPS /v1  (ky from iris api/)
                          v
       +--------------------------------------------------+
       |  olympus (NestJS)                                |
       |  Controllers → Services → Domain                 |
       |  Infrastructure implements domain ports          |
       +--------------------------------------------------+
```

---

## 1. Workspace Mapping

| Workspace | Role | Clean Architecture |
| :--- | :--- | :--- |
| `apps/iris` | Frontend host | Presentation + frontend application (hooks) + HTTP adapters |
| `apps/olympus` | NestJS API | Presentation (controllers), Application (services), Domain, Infrastructure |
| `packages/nomos` | Shared contracts | Zod schemas, inferred types, path/error constants. Not domain logic. |

`iris` must never import `olympus` source. `nomos` must never import React, Nest, or `ky`. Domain formulas (residual risk, hash chaining) live only in `olympus`.

YAGNI: do not add `@themis/ui` or `@themis/domain` until a second consumer exists.

---

## 2. Domain Layer (`olympus` module `domain/` folders)

*   **Responsibility:** Enterprise business rules and GRC concepts. Completely independent of frameworks, UI, and external libraries.
*   **Contents:**
    *   **Entities:** Objects with identity and lifecycle (`Risk`, `Control`, `Evidence`, `AuditAssessment`). English GRC **identifiers**, not pantheon names. User-facing labels are Spanish (ADR-0009).
    *   **Value Objects:** Immutable (`RiskScore`, `ControlCode`, `ComplianceStatus`, `EvidenceHash`).
    *   **Domain Events:** `RiskExceededThresholdEvent`, `ControlFailedAuditEvent`.
    *   **Repository Interfaces:** Ports (`IRiskRepository`, `IControlRepository`).
    *   **Domain Exceptions:** `InvalidControlStateTransitionError` extending `ThemisError`.
*   **Dependencies:** ZERO external dependencies (no React, no Nest, no Prisma/Drizzle, no Axios, no `ky`). Pure TypeScript only.

---

## 3. Application Layer (`olympus` `*.service.ts`)

*   **Responsibility:** Coordinates use cases and business workflows. Orchestrates domain entities to fulfill application features.
*   **Contents:** Nest injectable services acting as use cases (`AssessRisk`, `SubmitControlEvidence`, `GenerateComplianceReport`).
*   **Dependencies:** Domain folders only. Never imports controllers or React. Persistence enters through injected ports.

---

## 4. Infrastructure Layer (`olympus` module `infrastructure/`)

*   **Responsibility:** Implements ports defined in Domain and Application. Manages databases, crypto, and external APIs.
*   **Contents:**
    *   Repository implementations (`PostgresRiskRepository`, `RestEvidenceAdapter`).
    *   Cryptographic services (`WebCryptoAuditSigner` — SHA-256 / Ed25519).
    *   Adapters to external GRC sources (AWS Security Hub, GitHub Audit, Cloudflare).
*   **Dependencies:** Domain/application ports plus external libraries. Registered as Nest providers.

---

## 5. Presentation — Backend (`olympus` controllers)

*   Thin HTTP: route params, Zod validation via `ZodValidationPipe`, status mapping.
*   API versioned under `/v1`. Path tokens come from `nomos`.
*   No domain formulas in controllers.

---

## 6. Presentation — Frontend (`apps/iris`)

Feature-based folders mapped to Clean Architecture:

```
apps/iris/
  app/routes/                    # dumb route shells
  src/features/<pantheon-name>/
    api/                         # infrastructure: ky + queryOptions
    hooks/                       # application: Query/Mutation/UI hooks
    stores/                      # client state machines (Zustand)
    components/                  # smart feature UI
    constants/
    tests/                       # feature integration only
  src/shared/
    http/                        # ky singleton
    ui/                          # dumb Shadcn primitives
    hooks/
```

| Layer | `iris` location |
| :--- | :--- |
| Presentation | `app/routes/`, `features/*/components/`, `shared/ui/` |
| Application | `features/*/hooks/` |
| Infrastructure | `features/*/api/`, `shared/http/` |
| Domain | Not in `iris`. Use `@themis/nomos` DTOs. |

### Three-layer UI
*   **Routes are dumb.** Layout, `validateSearch`, optional `ensureQueryData`. No `ky`, no inline mutations, no domain state.
*   **Feature components are smart.** They consume feature hooks and stores.
*   **Shared primitives are dumb.** Props in, events out.

### State
*   **TanStack Query:** All server reads and writes (interactions). Optimistic updates live here.
*   **Zustand:** Transient UI and explicit state machines. Never a copy of Query data. Never optimistic API writes.
*   **URL:** Filters, pagination, search, and view mode.

View transitions use TanStack Router plus `@vercel/react-view-transitions`. Do not copy Next.js `Link` / `loading.tsx` patterns.

---

## 7. NestJS Compatibility

Follow Nest's own architecture so the framework does not break:

*   One Nest module per pantheon name (`DikeModule`, `PrometheusModule`, …).
*   Native `@Injectable()` constructor injection. No second IoC container.
*   Template: `*.module.ts`, `*.controller.ts`, `*.service.ts`, `domain/`, `infrastructure/`.
*   Full Nest rules: `.agents/rules/06-backend-nestjs.md`.
