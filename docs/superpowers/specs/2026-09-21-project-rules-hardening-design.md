# Design Specification: Themis Project Rules Hardening

**Date:** 2026-09-21  
**Status:** Approved  
**Architect:** Antigravity (Lead Systems Architect)  
**Collaborating AIs:** Codex, OpenCode, Cursor, Antigravity  

---

## 1. Executive Summary & Intent

This document establishes the ironclad engineering rules, multi-tier architectural standards, and multi-AI invariants for **Themis** — an enterprise-grade Governance, Risk, and Compliance (GRC) platform.

These standards apply universally across all engineering efforts and are strictly enforced across all 4 collaborating AI agents:
1. **Codex:** Pure Domain Logic, Use Cases & TDD Unit Testing
2. **OpenCode:** Tooling, Environment Automation, Infrastructure Adapters & Monorepo Workspaces
3. **Cursor:** UI/UX Craftsperson, Component Composition & Aesthetic Polish
4. **Antigravity:** Lead Systems Architect, Orchestration & Verification

---

## 2. Monorepo Topology & Greek Pantheon Taxonomy

To reflect the mythological origin of **Themis** (Titaness of Divine Law and Justice), all applications, shared packages, and domain modules must strictly adhere to a unified Greek Pantheon naming convention.

```
themis/
├── apps/
│   ├── iris/                       # Frontend App (TanStack Start + Tailwind v4 + Shadcn)
│   └── olympus/                    # Backend API (NestJS + Native DI + Domain Services)
├── packages/
│   └── nomos/                      # Shared Contracts (Zod Schemas, DTOs & Validation)
├── .agents/                        # Central Multi-AI Hub (Rules, Personas, ADRs, Tasks, Memory)
├── docs/                           # Documentation & Specifications
│   └── superpowers/specs/          # Architectural Design Specifications
├── AGENTS.md                       # Universal Multi-AI Engineering Guide (Single Source of Truth)
├── package.json                    # Monorepo root definition
└── pnpm-workspace.yaml             # Workspace declaration (apps/*, packages/*)
```

### Pantheon Mapping Directory

| Level | Name | Mythological Entity | Responsibility in Themis |
| :--- | :--- | :--- | :--- |
| **App** | **`iris`** | Iris *(Goddess of the rainbow & divine messenger)* | User-facing web application built with TanStack Start, high-density GRC dashboards, and view transitions. |
| **App** | **`olympus`** | Mount Olympus *(Citadel of the gods)* | Authoritative backend API built with NestJS, controllers, business services, and dependency injection. |
| **Package** | **`nomos`** | Nomos *(Spirit of law, statutes & ordinance)* | Shared validation library housing Zod schemas, contract DTOs, and runtime type definitions. |
| **Module** | **`dike`** | Dike *(Goddess of justice and fair judgment)* | Compliance framework engines (ISO 27001, SOC 2, NIST CSF, HIPAA), control mappings, and requirement evaluations. |
| **Module** | **`prometheus`** | Prometheus *(Titan of forethought)* | Risk assessment engine, likelihood/impact matrix calculation, residual risk formulas, and heatmaps. |
| **Module** | **`astraea`** | Astraea *(Goddess of innocence, truth and purity)* | Cryptographic audit ledger, SHA-256 hash chaining, and tamper-detection algorithms. |
| **Module** | **`argus`** | Argus Panoptes *(All-seeing hundred-eyed watcher)* | Continuous automated evidence collection, cloud integrations, and system telemetry. |
| **Module** | **`hermes`** | Hermes *(Herald of the gods)* | Notification dispatch, audit escalation alerting, webhooks, and communication pipelines. |
| **Module** | **`mnemosyne`** | Mnemosyne *(Titaness of memory)* | Evidence document repository, historical audit archives, and retention policy enforcement. |

---

## 3. Universal Clean Code & S.O.L.I.D. Invariants

Every file written in this repository must comply with the following invariants:

### 3.1 S.O.L.I.D. Principles
- **Single Responsibility Principle (SRP):** Every class, module, function, and React component has one and only one reason to change.
- **Open/Closed Principle (OCP):** Open for extension via composition patterns (slots, compound components) and polymorphic strategies; closed for modification.
- **Liskov Substitution Principle (LSP):** Concrete adapters and repository implementations must be completely swappable without altering program correctness.
- **Interface Segregation Principle (ISP):** Depend on narrow, client-focused interfaces rather than bloated god interfaces.
- **Dependency Inversion Principle (DIP):** High-level policy depends on abstractions; details implement abstractions. NestJS handles DI on the backend; constructor injection and interfaces govern domain services.

### 3.2 Code Hygiene Standards
- **Zero Magic Strings:** All status codes, role names, route identifiers, event tokens, and query keys must be declared in strongly typed constants, enums, or `as const` dictionaries.
- **Zero Magic Numbers:** All numerical thresholds (risk weights, retry counts, debounce timings, pagination limits, line caps) must be defined as named constants with descriptive names.
- **Zero God Files & God Components:** No file may accumulate unrelated responsibilities. Functions are kept small ($\le 25$ lines where feasible) with low cyclomatic complexity (indentation depth $\le 2$, early returns).
- **Typed Error Hierarchy:** All domain and application errors must inherit from a structured `ThemisError` base class. Never throw raw strings or swallow exceptions.

---

## 4. Frontend Architecture (`apps/iris`)

### 4.1 Framework & Core Stack
- **Framework:** **TanStack Start** (`@tanstack/react-start`) running on Vite, Nitro, and TanStack Router.
- **Design System:** Shadcn UI primitives powered by Radix / Base UI and Tailwind CSS v4.
- **Animations:** `@vercel/react-view-transitions` for smooth navigation between compliance views.
- **HTTP Client:** `ky` (promise-based fetch wrapper).
- **Server State:** TanStack Query (`@tanstack/react-query`).
- **Client State:** Zustand (`zustand`).
- **Validation:** Zod (`zod` via `@themis/nomos`).

### 4.2 "Pages Are Dumb, Components Are Smart"
- **Dumb Routes:** Files located in `app/routes/` are purely structural route anchors and shells:
  - Parse and validate search parameters via Zod (`validateSearch: zodValidator(searchSchema)`).
  - Optionally preload critical queries in route `loader` via `queryClient.ensureQueryData`.
  - Render high-level grid layouts and mount smart feature components.
  - **Forbidden in Routes:** Complex local `useState`/`useReducer`, domain calculations, or direct API mutations.
- **Smart Components:** Located in `src/features/<feature>/components/`:
  - Encapsulate their own user interactions, data mutations, and reactive subscriptions.
  - Consume their own dedicated TanStack Query hooks and Zustand stores.
  - Self-contained and reusable in dashboards, side drawers, modals, or drill-down views.

### 4.3 Dedicated `hooks/` Isolation
- **No inline hooks:** Custom hooks must NEVER be defined inside component `.tsx` files or route files.
- **Feature-scoped hooks:** Live exclusively in `src/features/<feature>/hooks/*.ts`.
- **Shared hooks:** Live exclusively in `src/shared/hooks/*.ts`.

### 4.4 150-Line Component Hard Cap & Composition Pattern
- **Strict Limit:** No React component file may exceed **150 lines of formatted code**.
- **Enforcement via Composition:** When a component approaches or exceeds 150 lines, it must be decomposed into:
  - **Compound Components:** E.g., `<DikeMatrix>`, `<DikeMatrix.Header>`, `<DikeMatrix.Row>`, `<DikeMatrix.Cell>`.
  - **Slot Pattern (`asChild`):** Delegating DOM rendering to Radix slots.
  - **Subcomponent Extraction:** Splitting complex layout sections into sibling files under the feature's `components/` directory.

### 4.5 Data & State Management Division of Labor
- **`ky` HTTP Client:**
  - Configured singleton in `src/shared/http/client.ts`.
  - Handles `prefixUrl`, bearer auth injection, request timeouts, retries, and normalized API error parsing.
- **TanStack Query (Server State):**
  - Manages all remote data queries, background synchronization, polling, and mutations.
  - Optimistic updates applied for interactive toggles (e.g., control verification status).
  - Centralized query key factories in `src/features/<feature>/api/query-keys.ts`.
- **Zustand (Client State & State Machines):**
  - Dedicated to transient UI state, multi-step assessment state machines, and active filter panels.
  - **Strict Invariant:** Never mirror or duplicate server query responses inside Zustand stores. Use Zustand selectors to prevent unnecessary re-renders.

---

## 5. Backend Architecture (`apps/olympus`)

### 5.1 Framework & Core Stack
- **Framework:** **NestJS** standard modular application structure.
- **Dependency Injection:** Strict adherence to Nest's native IoC container using `@Injectable()` and constructor injection.
- **Validation:** Enforced via a global or module-level `ZodValidationPipe` consuming schemas from `@themis/nomos`.

### 5.2 Clean Architecture Mapping in NestJS
- **Modules:** Organized around Greek Pantheon domains:
  - `DikeModule` (Compliance evaluation, control requirements)
  - `PrometheusModule` (Risk scoring engine, residual risk calculation)
  - `AstraeaModule` (Cryptographic audit ledger, SHA-256 chain signing)
  - `ArgusModule` (Evidence telemetry ingestion)
  - `HermesModule` (Notifications and webhooks)
  - `MnemosyneModule` (Evidence document management)
- **Controllers:** Handle HTTP routes, parameter extraction, and status mapping. Thin transport layer only.
- **Services / Handlers:** Act as Use Cases containing application workflows; injected into controllers via DI.
- **Domain Layer:** Pure TypeScript entities and calculation functions with zero NestJS or external library dependencies.

---

## 6. Shared Contracts (`packages/nomos`)

- Serves as the single source of truth for all data contracts across `iris` (frontend) and `olympus` (backend).
- Contains:
  - Zod schemas for request payloads, query parameters, and response DTOs.
  - TypeScript types inferred directly from Zod schemas (`export type ControlDto = z.infer<typeof ControlSchema>;`).
  - Domain constants, enum definitions, and validation regex rules.

---

## 7. Multi-AI Documentation & Rule Hardening Plan

To institutionalize these decisions, the following files will be updated or created:

1. **`AGENTS.md`:** Comprehensive update reflecting the monorepo structure, Greek Pantheon taxonomy, TanStack Start, NestJS DI, `ky`, Zod, Zustand, 150-line component cap, and hook isolation rules.
2. **`.agents/rules/00-clean-code-solid.md`:** Enhanced with no-magic-strings, no-magic-numbers, 150-line limit, composition patterns, and no-god-files invariants.
3. **`.agents/rules/02-architecture-grc.md`:** Updated to document the clean separation between `iris`, `olympus`, `nomos`, and pure domain logic.
4. **`.agents/rules/03-frontend-quality.md`:** Enhanced with TanStack Start guidelines, dumb routes vs. smart components, dedicated `hooks/` isolation, and the `ky` + TanStack Query + Zustand division.
5. **`.agents/rules/06-backend-nestjs.md` (New):** Dedicated standard for NestJS modular architecture, native DI, controller-service separation, and Zod validation pipes.
6. **`.agents/decisions/ADR-0004-greek-pantheon-monorepo.md` (New):** Architectural Decision Record establishing the workspace topology and Greek Pantheon naming convention.
7. **`.agents/decisions/ADR-0005-frontend-tanstack-start-ky-zod.md` (New):** Architectural Decision Record detailing the selection of TanStack Start, `ky`, Zod, TanStack Query, and Zustand.

---

## 8. Verification & Compliance Checklist

- [ ] All 4 AI bridge files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`) reflect the new architecture.
- [ ] No rule contradictions between Clean Architecture and NestJS DI or TanStack Start routing.
- [ ] All Greek Pantheon names documented with clear functional mappings.
- [ ] 150-line rule and composition patterns explicitly codified.
- [ ] Hook isolation rules codified (zero hooks in routes or components).
- [ ] Zod `@themis/nomos` established as the single validation source of truth.
