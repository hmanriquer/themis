# Design Specification: Themis Project Rules Hardening

**Date:** 2026-09-21  
**Status:** Accepted (amended)  
**Architect:** Antigravity (Lead Systems Architect)  
**Amended by:** Cursor (Frontend & Rules Craftsperson)  
**Collaborating AIs:** Codex, OpenCode, Cursor, Antigravity  

---

## 1. Executive Summary & Intent

This document establishes the engineering rules, architectural standards, and multi-AI invariants for **Themis** — an enterprise-grade Governance, Risk, and Compliance (GRC) platform.

These standards apply across `apps/iris`, `apps/olympus`, and `packages/nomos`, and are enforced across all 4 collaborating AI agents:

1. **Codex:** Pure Domain Logic, Use Cases & TDD Unit Testing
2. **OpenCode:** Tooling, Environment Automation, Infrastructure Adapters & Monorepo Workspaces
3. **Cursor:** UI/UX Craftsperson, Component Composition & Aesthetic Polish
4. **Antigravity:** Lead Systems Architect, Orchestration & Verification

`iris` is a frontend host. `olympus` is the only GRC backend. `@themis/nomos` is the only shared contract package. Domain entities and formulas live in `olympus`. `iris` consumes DTOs from `nomos` only.

---

## 2. Monorepo Topology & Greek Pantheon Taxonomy

To reflect the mythological origin of **Themis** (Titaness of Divine Law and Justice), all applications, shared packages, and domain **modules** must use a unified Greek Pantheon naming convention.

```
themis/
├── apps/
│   ├── iris/                       # Frontend (TanStack Start + Tailwind v4 + Shadcn)
│   └── olympus/                    # Backend API (NestJS + native DI)
├── packages/
│   └── nomos/                      # Shared contracts (Zod schemas, DTOs, constants)
├── .agents/                        # Central Multi-AI Hub
├── docs/
│   └── superpowers/specs/
├── AGENTS.md
├── package.json
└── pnpm-workspace.yaml             # apps/*, packages/*
```

YAGNI: do not add `@themis/ui`, `@themis/domain`, Turborepo, XState, or OpenAPI generation until a second consumer exists.

### Pantheon Mapping Directory

| Level | Name | Mythological Entity | Responsibility in Themis |
| :--- | :--- | :--- | :--- |
| **App** | **`iris`** | Iris *(Goddess of the rainbow & divine messenger)* | User-facing web application. TanStack Start for routing and SSR only. |
| **App** | **`olympus`** | Mount Olympus *(Citadel of the gods)* | Authoritative NestJS API. Controllers, injectable services, domain, persistence. |
| **Package** | **`nomos`** | Nomos *(Spirit of law, statutes & ordinance)* | Zod schemas, inferred DTO types, enums, API/route path constants, error codes. No Nest, no React, no risk formulas. |
| **Module** | **`dike`** | Dike *(Goddess of justice and fair judgment)* | Compliance framework engines (ISO 27001, SOC 2, NIST CSF, HIPAA), control mappings, requirement evaluations. |
| **Module** | **`prometheus`** | Prometheus *(Titan of forethought)* | Risk assessment engine, likelihood/impact matrix, residual risk formulas, heatmaps. |
| **Module** | **`astraea`** | Astraea *(Goddess of innocence, truth and purity)* | Cryptographic audit ledger, SHA-256 hash chaining, tamper detection. |
| **Module** | **`argus`** | Argus Panoptes *(All-seeing hundred-eyed watcher)* | Continuous evidence collection, cloud integrations, telemetry. |
| **Module** | **`hermes`** | Hermes *(Herald of the gods)* | Notification dispatch, audit escalation alerting, webhooks. |
| **Module** | **`mnemosyne`** | Mnemosyne *(Titaness of memory)* | Evidence document repository, historical archives, retention policy. |

### Naming Split (Greek vs English)

| Surface | Language | Examples |
| :--- | :--- | :--- |
| Apps, packages, Nest modules, `iris` feature folders | Greek | `iris`, `olympus`, `nomos`, `dike`, `prometheus` |
| Domain entities, value objects, use case names | English GRC | `Control`, `Risk`, `Evidence`, `AssessRisk` |
| User-facing copy and URL paths | English GRC | `/compliance`, `/risks`, `/evidence`, `/audit` |

Never name a domain entity `Dike` or a public route `/prometheus`.

---

## 3. Universal Clean Code & S.O.L.I.D. Invariants

Every file written in this repository must comply with the following invariants.

### 3.1 S.O.L.I.D. Principles

- **Single Responsibility Principle (SRP):** Every class, module, function, and React component has one reason to change.
- **Open/Closed Principle (OCP):** Open for extension via composition (slots, compound components) and polymorphic strategies; closed for modification.
- **Liskov Substitution Principle (LSP):** Concrete adapters and repository implementations must be swappable without altering program correctness.
- **Interface Segregation Principle (ISP):** Depend on narrow, client-focused interfaces rather than bloated god interfaces.
- **Dependency Inversion Principle (DIP):** High-level policy depends on abstractions; details implement abstractions. NestJS native DI on the backend. `iris` depends on `nomos` contracts, not on `olympus` internals.

### 3.2 Code Hygiene Standards

- **Zero Magic Strings:** Status codes, role names, route identifiers, API paths, event tokens, and query keys must be declared in strongly typed constants, enums, or `as const` dictionaries. Shared tokens live in `@themis/nomos`.
- **Zero Magic Numbers:** Risk weights, retry counts, debounce timings, pagination limits, heatmap bands, and the React line cap must be named constants. Allowed literals: `0`, `1`, `-1`.
- **Zero God Files & God Components:** No file may accumulate unrelated responsibilities. Functions stay small (≤ 25 lines where feasible) with low cyclomatic complexity (indentation depth ≤ 2, early returns).
- **Typed Error Hierarchy:** Domain and application errors inherit from `ThemisError`. Never throw raw strings or swallow exceptions. HTTP errors serialized by `olympus` must match the `nomos` error schema so `iris` Query error UI can render them.
- **No per-component barrel files:** Do not add `index.ts` inside each component folder. One optional feature-level `index.ts` is allowed as a public surface. Prefer direct imports. Component props live in the `.tsx` file or a `types.ts` — never a `types.d.ts`.

### 3.3 Mechanical Enforcement

Documentation is not sufficient. When workspaces are scaffolded, CI and ESLint must encode:

| Rule | Mechanism |
| :--- | :--- |
| React file line cap | ESLint `max-lines` = `REACT_COMPONENT_MAX_LINES` (`150`) on `*.tsx`. Count is Prettier output, including imports. Exempt: `*.test.tsx`, `*.spec.ts`, `routeTree.gen.ts`, generated files, Shadcn primitives under `src/shared/ui/`. |
| Magic numbers | ESLint `no-magic-numbers` with ignore `0`, `1`, `-1`. |
| HTTP isolation | `no-restricted-imports`: `axios` forbidden; raw `fetch` forbidden in `src/features/**`. Routes cannot import `ky` or `src/features/*/api`. |
| Retry policy | TanStack Query owns retries. `ky` retry count is `0`. Do not double-retry. |
| Env | Zod-validated environment objects at startup in both apps. No untyped `process.env` reads in feature code. |

---

## 4. Frontend Architecture (`apps/iris`)

### 4.1 Framework & Core Stack

- **Framework:** **TanStack Start** (`@tanstack/react-start`) on Vite, Nitro, and TanStack Router. Start is a **frontend host** (routing, SSR, loaders). It is not a second backend.
- **Forbidden:** `createServerFn` and Start API routes for GRC business logic. Loaders may call `olympus` through `ky` only.
- **Design System:** Shadcn UI primitives (Radix / Base UI) and Tailwind CSS v4.
- **Animations:** `@vercel/react-view-transitions` driven by **TanStack Router**, not Next.js `Link` / `loading.tsx`.
- **HTTP Client:** `ky` singleton in `src/shared/http/client.ts`.
- **Server State / Interactions:** TanStack Query (`@tanstack/react-query`).
- **Client State / Machines:** Zustand (`zustand`).
- **Forms:** TanStack Form + Zod schemas from `@themis/nomos` + `useMutation`.
- **Tables:** TanStack Table inside feature components, fed by Query.
- **Validation:** Zod via `@themis/nomos`.
- **The LobeHub Zustand skill is overridden for Themis:** optimistic server updates belong in TanStack Query, never in Zustand stores.

### 4.2 Feature-Based Layout Aligned with Clean Architecture

```
apps/iris/
  app/routes/                    # dumb route shells only
  src/
    features/<pantheon-name>/    # dike, prometheus, astraea, …
      api/                       # ky calls + queryOptions / mutationFns (infrastructure)
      hooks/                     # Query, Mutation, and UI hooks (application)
      stores/                    # Zustand slices and state machines
      components/                # smart feature UI, composed at 150 lines
      constants/                 # feature-local named tokens
      tests/                     # feature integration tests + fixtures only
    shared/
      http/                      # ky singleton
      ui/                        # Shadcn primitives (dumb)
      hooks/                     # cross-feature hooks only
      lib/
```

Clean Architecture mapping **on the frontend**:

| Layer | Lives in `iris` as |
| :--- | :--- |
| Presentation | `app/routes/` + `features/*/components/` + `shared/ui/` |
| Application | `features/*/hooks/` |
| Infrastructure | `features/*/api/` + `shared/http/` |
| Domain | **Not in `iris`.** DTOs and shared constants come from `@themis/nomos`. |

Risk formulas, hash chaining, and entity invariants stay in `olympus`. If the UI needs a display threshold (heatmap bands), put the constant in `nomos` — do not reimplement the formula.

### 4.3 Three-Layer UI: Pages Dumb, Components Smart, Primitives Dumb

- **Routes / pages (`app/routes/`):** Structural shells. Parse and validate search params with Zod (`validateSearch: zodValidator(searchSchema)` from `nomos`). Optionally preload with `queryClient.ensureQueryData`. Render layout and mount smart feature components. **Forbidden:** domain `useState`/`useReducer`, domain calculations, `ky`, Query/Mutation hooks defined inline, direct API mutations.
- **Feature components (`src/features/<feature>/components/`):** Smart. They call feature hooks and Zustand stores. They own user interaction wiring.
- **Shared UI primitives (`src/shared/ui/`):** Dumb. Props in, events out. No TanStack Query, no Zustand, no `ky`.

URL query params remain the source of truth for filters, pagination, search, and view mode. Zustand may mirror ephemeral UI (drawer open, wizard step) but must not become a second source of truth for shareable filters.

### 4.4 Dedicated `hooks/` Isolation

- **Do not define custom hooks** inside component `.tsx` files or route files.
- **Using** React hooks (`useState`, `useMemo`, `useEffect`) and imported feature hooks inside components is required and allowed.
- Feature-scoped hooks live in `src/features/<feature>/hooks/*.ts`.
- Shared hooks live in `src/shared/hooks/*.ts`.
- Smart components consume `useXQuery` / `useXMutation` wrappers from `hooks/`. They never call `ky` and never inline `queryFn`.

### 4.5 150-Line Component Hard Cap & Composition

- No React component file may exceed **150 lines of Prettier-formatted code**.
- When a file approaches the cap, decompose with compound components, `asChild` slots, or sibling files under the feature `components/` directory.
- One component (or one compound root) per file. Route files share the same cap so they stay dumb.

### 4.6 Data & State: Query for Interactions, Zustand for Machines

**`ky` HTTP Client**

- Configured singleton in `src/shared/http/client.ts`.
- Handles `prefixUrl`, auth header injection, timeouts, and normalized `nomos` API error parsing.
- Retry count is `0`. Query owns retry.

**TanStack Query (all server interactions)**

- All remote reads use `useQuery` / `queryOptions`.
- All remote writes use `useMutation`.
- Components never call `ky`. Only `queryFn` / `mutationFn` in `api/` call `ky`.
- Optimistic updates apply in Query (e.g. control verification toggles).
- Centralized query key factories in `src/features/<feature>/api/query-keys.ts`, built from `nomos` constants — no magic strings.

**Zustand (client state and state machines)**

- Transient UI, multi-step wizards, and explicit state machines.
- Machine shape: discriminated union + named transition functions in a feature slice. One store per feature. Selectors only.
- **Never** mirror or duplicate server query responses in Zustand.
- **Never** perform optimistic server updates in Zustand.

### 4.7 Tests Live Inside the Feature

If a test proves one unit, colocate it. If a test proves the feature as a whole, put it in `tests/`.

```
features/dike/
  api/
    control-queries.ts
    control-queries.test.ts
  hooks/
    use-controls.ts
    use-controls.test.ts
  stores/
    dike-filters.store.ts
    dike-filters.store.test.ts
  components/
    dike-matrix.tsx
    dike-matrix.test.tsx
    dike-matrix-header.tsx
    dike-matrix-header.test.tsx
  constants/
  tests/
    dike-matrix.integration.test.tsx
    fixtures.ts
    msw-handlers.ts
```

- No `types.d.ts` beside components.
- No per-folder `index.ts` inside `components/`.
- Playwright / E2E lives at `apps/iris/e2e/`, not inside features.
- Test files are exempt from the 150-line cap.

---

## 5. Backend Architecture (`apps/olympus`)

### 5.1 Framework & Core Stack

- **Framework:** NestJS standard modular application. Follow Nest's own DI, modules, pipes, guards, interceptors, and exception filters. Do not introduce a second DI container or a parallel hexagonal runtime.
- **Validation:** Global or module-level `ZodValidationPipe` consuming schemas from `@themis/nomos`.
- **HTTP API:** Versioned under `/v1`. Path tokens come from `nomos` constants.
- **Persistence / auth:** Chosen later (ORM and session strategy are out of this spec). Whatever is chosen must register as Nest providers.

### 5.2 Nest Module Template (Pantheon Module)

```
apps/olympus/src/dike/
  dike.module.ts
  dike.controller.ts          # HTTP only: params, status mapping
  dike.service.ts             # use case / application workflow
  domain/                     # Nest-free entities and functions
    control.ts
    control.test.ts
  infrastructure/             # repositories, adapters
    control.repository.ts
    control.repository.spec.ts
  dike.controller.spec.ts
  dike.service.spec.ts
```

- **Controllers:** Thin transport. No domain formulas.
- **Services:** Injectable use cases. Constructor injection only.
- **Domain folder:** Pure TypeScript. Zero Nest, Prisma, or HTTP imports.
- **Infrastructure:** Implements repository ports used by the service.
- Shared domain that two modules need stays in `olympus` (or a later package). It does **not** go into `nomos`.
- Tests colocate with the unit they prove (`*.spec.ts` / `*.test.ts` beside the file). Nest testing utilities for controllers/services.

### 5.3 Clean Architecture Mapping in NestJS

| Nest construct | Clean Architecture role |
| :--- | :--- |
| `*Controller` | Presentation / transport |
| `*Service` | Application / use case |
| `domain/` | Domain entities, value objects, domain services |
| `infrastructure/` | Repository adapters, crypto, external clients |
| `*Module` + `@Injectable()` | Composition root via Nest IoC |

Modules: `DikeModule`, `PrometheusModule`, `AstraeaModule`, `ArgusModule`, `HermesModule`, `MnemosyneModule`.

---

## 6. Shared Contracts (`packages/nomos`)

Single source of truth for data crossing `iris` and `olympus`.

Contains:

- Zod schemas for request payloads, query/search params, and response DTOs
- TypeScript types inferred from those schemas (`export type ControlDto = z.infer<typeof ControlSchema>`)
- Enums, API path constants, query-key fragments, heatmap band constants, error codes, validation regexes
- The HTTP error envelope that `olympus` serializes and `iris` parses

Does **not** contain: React, Nest, `ky`, risk-formula implementations, hash-chain algorithms, or UI components.

---

## 7. Multi-AI Documentation & Rule Hardening Plan

These files are updated or created as the implementation of this spec:

1. **`AGENTS.md`:** Monorepo, pantheon, TanStack Start, NestJS DI, `ky`, Zod, Zustand machines, 150-line cap, hook isolation, three-layer UI, test colocation.
2. **`DESIGN.md`:** Replace Next.js/Vite presentation-layer paths with `iris` / `olympus` / `nomos`.
3. **`.agents/rules/00-clean-code-solid.md`:** No magic strings/numbers, 150-line cap, composition, no god files, no component barrels.
4. **`.agents/rules/02-architecture-grc.md`:** `iris` / `olympus` / `nomos` split and frontend Clean Architecture mapping.
5. **`.agents/rules/03-frontend-quality.md`:** Start, three-layer UI, hook isolation, Query-only interactions, Zustand override, TanStack Form/Table, URL state, view transitions via Router.
6. **`.agents/rules/04-testing-tdd.md`:** Feature-local colocation and `tests/` integration rule.
7. **`.agents/rules/05-security-compliance.md`:** Zod env at startup; `nomos` error envelope.
8. **`.agents/rules/06-backend-nestjs.md` (New):** Nest module template, native DI, Zod pipes.
9. **`.agents/decisions/ADR-0002` and `ADR-0003`:** Amended for workspace locations and Start/`ky`/Query-only rules.
10. **`.agents/decisions/ADR-0004-greek-pantheon-monorepo.md` (New).**
11. **`.agents/decisions/ADR-0005-frontend-tanstack-start-ky-zod.md` (New).**
12. **`.agents/docs/architecture-overview.md`**, **`.agents/memory/index.md`**, and AI bridges (`CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `.cursor/rules/themis-agents.mdc`).

Workspace scaffolding (`pnpm-workspace.yaml`, `apps/iris`, `apps/olympus`, `packages/nomos`, ESLint) is a follow-on OpenCode task. This spec locks the rules those apps must obey.

---

## 8. Verification & Compliance Checklist

- [x] Spec records feature-based `iris` layout mapped to Clean Architecture layers.
- [x] Domain lives in `olympus`; `iris` consumes `@themis/nomos` DTOs only.
- [x] Three-layer UI: dumb routes, smart feature components, dumb primitives.
- [x] Custom hooks are defined only in `hooks/` folders; components may *use* hooks.
- [x] TanStack Query is the only server-interaction path; `ky` is confined to `api/`.
- [x] Start server functions are forbidden for GRC business logic.
- [x] Zustand is for UI state and explicit machines, never server cache or optimistic API writes.
- [x] NestJS keeps native DI and a Nest-idiomatic module template.
- [x] Greek names for apps/packages/modules; English GRC for entities, copy, and URLs.
- [x] 150-line React cap, composition, and ESLint/CI enforcement are specified.
- [x] Tests colocate with units; feature `tests/` is integration-only; E2E stays at the app.
- [x] `DESIGN.md`, ADR-0002, ADR-0003, testing rules, and bridges are in the hardening set.
- [x] No rule contradiction between Clean Architecture and Nest DI or TanStack Start routing.
