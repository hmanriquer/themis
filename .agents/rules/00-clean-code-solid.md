# Universal Clean Code & S.O.L.I.D. Principles

All 4 AIs (Codex, OpenCode, Cursor, Antigravity) working on Themis MUST adhere to the following Clean Code and S.O.L.I.D. standards across `apps/iris`, `apps/olympus`, and `packages/nomos`.

Canonical design: `docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md`.

---

## 1. S.O.L.I.D. Principles in TypeScript & React

### S — Single Responsibility Principle (SRP)
*   **Rule:** Every class, module, function, and React component must have only one reason to change.
*   **Application:**
    *   **Routes:** Structural shells only. Data fetching belongs in feature hooks. Business rules belong in `olympus` domain/services.
    *   **Feature components:** Wire user interaction to hooks and stores. They do not own HTTP or domain formulas.
    *   **Primitives:** Render from props. No Query, no Zustand, no `ky`.
    *   **Stores:** Zustand stores are atomic feature slices, never a monolithic app store and never a server cache.
    *   **Services:** One domain concern (e.g., `RiskCalculator` in `prometheus`, audit signing in `astraea`).

### O — Open/Closed Principle (OCP)
*   **Rule:** Software entities should be open for extension, but closed for modification.
*   **Application:**
    *   Use polymorphic interfaces or strategy patterns for compliance frameworks (e.g., `ComplianceFrameworkRuleEngine` evaluates NIST, ISO 27001, SOC 2, HIPAA via registered handlers).
    *   Use React composition (Slot pattern, `asChild`, compound components) so components extend without altering internals.

### L — Liskov Substitution Principle (LSP)
*   **Rule:** Subtypes or implementations must be substitutable for their base abstractions without altering program correctness.
*   **Application:**
    *   Repository implementations (`InMemoryRiskRepository`, `PostgresRiskRepository`) must adhere to the same port, return the same domain values, and throw the same domain exceptions.
    *   Test doubles must behave identically to real adapters from the client's perspective.

### I — Interface Segregation Principle (ISP)
*   **Rule:** Clients should not be forced to depend upon interfaces they do not use.
*   **Application:**
    *   Prefer many small interfaces (`IReader<T>`, `IWriter<T>`, `ISigner<T>`) over a gigantic `IDataManager<T>`.
    *   Component props must only require what the component renders. Do not pass an entire `ControlDto` into a badge that only needs `{ status: ControlStatus }`.

### D — Dependency Inversion Principle (DIP)
*   **Rule:** High-level modules should not depend upon low-level modules. Both should depend upon abstractions.
*   **Application:**
    *   `olympus` domain folders NEVER import Nest, Prisma/Drizzle, HTTP, or React.
    *   `iris` NEVER imports `olympus` internals. It depends on `@themis/nomos` contracts and talks to the API through `ky` inside feature `api/` modules.
    *   Nest native constructor injection composes adapters behind ports.

---

## 2. Clean Code Standards

### Meaningful Naming
*   Use pronounceable, intention-revealing names:
    *   Variables & properties: nouns (e.g., `residualRiskScore`, `controlMitigationStatus`).
    *   Functions & methods: active verbs (e.g., `calculateRiskIndex()`, `verifyAuditSignature()`, `isEvidenceCompliant()`).
    *   Booleans: prefixes like `is`, `has`, `should`, `can` (e.g., `isAudited`, `hasActiveViolation`).
*   Avoid abbreviations, cryptic acronyms, or Hungarian notation.
*   **Greek vs English:** Apps, packages, Nest modules, and `iris` feature folders use pantheon names (`dike`, `prometheus`). Domain entities, use cases, UI copy, and URLs use English GRC terms (`Control`, `/risks`). See ADR-0004.

### Functions & Methods
*   **Small & Focused:** Ideal length under 25 lines. A function should do one thing and do it well.
*   **Pure Functions First:** Maximize pure functions in domain logic for effortless testability and zero side effects.
*   **Zero Side Effects:** Functions should not mutate input arguments or global state unexpectedly. Use immutable data patterns.
*   **Low Cyclomatic Complexity:** Keep indentation depth ≤ 2. Use early returns (guard clauses) to reduce nesting.

### React File Size & Composition
*   **Hard cap:** No React component file may exceed `REACT_COMPONENT_MAX_LINES` (**150**) lines of Prettier-formatted code, including imports.
*   **Exempt:** `*.test.tsx`, `*.spec.ts`, generated files (`routeTree.gen.ts`), and Shadcn primitives under `src/shared/ui/`.
*   When a file approaches the cap, split with compound components, `asChild` slots, or sibling files. One component (or one compound root) per file.
*   **No per-component barrels:** Do not add `index.ts` inside each component folder. One optional feature-level `index.ts` is allowed. Prefer direct imports.
*   Component props live in the `.tsx` file or `types.ts`. Never `types.d.ts`.

### Zero Magic Strings & Magic Numbers
*   Status codes, role names, route identifiers, API paths, event tokens, and query keys must be strongly typed constants, enums, or `as const` dictionaries.
*   Shared tokens belong in `@themis/nomos`. Feature-local tokens belong in `features/<name>/constants/`.
*   Numerical thresholds (risk weights, retry counts, debounce timings, pagination limits, heatmap bands, line caps) must be named constants.
*   Allowed numeric literals: `0`, `1`, `-1`.
*   Enforce with ESLint `no-magic-numbers` and `max-lines` once workspaces are scaffolded. Query owns HTTP retries; `ky` retry count is `0`.

### Error Handling & Exceptions
*   Use custom Domain Error classes extending a base `ThemisError` (e.g., `EntityNotFoundError`, `ComplianceViolationError`, `UnauthorizedAuditMutationError`).
*   Never swallow exceptions with empty `catch` blocks.
*   Log errors with contextual metadata through the shared logging interface.
*   Return typed results (e.g., `Result<T, E>`) for expected domain failures; reserve thrown exceptions for truly exceptional infrastructure failures.
*   HTTP errors serialized by `olympus` must match the `nomos` error envelope so `iris` Query error UI can render them.

### Comments & Documentation
*   Code should be self-documenting through expressive typing and clear naming.
*   Use JSDoc comments to document domain concepts, invariants, regulatory constraints, and architectural rationales—not to narrate trivial code mechanics.
*   Link Architecture Decision Records (ADRs) when making non-obvious design choices.
