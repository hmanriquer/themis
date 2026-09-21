# Testing, TDD & Verification Protocol

High-reliability GRC platforms require rigorous verification. All code contributions must be accompanied by comprehensive tests written prior to or alongside implementation.

Canonical design: `docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md`.

---

## 1. Test-Driven Development (TDD) Workflow

Follow the red-green-refactor cycle guided by the `test-driven-development` superpower skill:

1.  **Red:** Write an automated test expressing a single unit of behavior or specification. Run it and verify it fails for the expected reason.
2.  **Green:** Write the minimal implementation code necessary to make the test pass.
3.  **Refactor:** Clean up code, remove duplication, enforce S.O.L.I.D. principles, and ensure tests remain green.

---

## 2. Where Tests Live

**If a test proves one unit, colocate it. If a test proves the feature as a whole, put it in `tests/`.**

Do not collect all tests in a repository-root `__tests__` dump.

### `iris` feature layout

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
  tests/
    dike-matrix.integration.test.tsx
    fixtures.ts
    msw-handlers.ts
```

*   `tests/` is for integration flows, fixtures, and MSW handlers only — not a second home for unit tests.
*   No `types.d.ts` beside components. No per-folder `index.ts` inside `components/`.
*   Playwright / E2E lives at `apps/iris/e2e/`.
*   Test files are exempt from `REACT_COMPONENT_MAX_LINES` (150).

### `olympus` layout

Colocate `*.spec.ts` / `*.test.ts` with the unit (`dike.service.spec.ts` beside `dike.service.ts`, `control.test.ts` beside `domain/control.ts`). Use Nest testing utilities for controllers and services.

---

## 3. Testing Pyramid & Categories

*   **Unit Tests (Domain & Application Logic):**
    *   Test all domain entities, value objects, domain services, and use cases in isolation (`olympus` `domain/` and `*.service.ts`).
    *   Execute in sub-second time without IO or database dependencies.
    *   Aim for $100\%$ branch coverage on critical GRC calculation engines (Risk Scoring, Residual Risk formula, Framework Mapping).
*   **Integration Tests (Infrastructure, Adapters, Feature Flows):**
    *   Verify repository contracts, cryptographic hashing, external API adapters, and database migrations in `olympus`.
    *   Verify feature-level UI flows in `iris` `features/<name>/tests/`.
*   **Component Tests (Presentation):**
    *   Colocated beside the component. Verify user interactions, accessibility, error states, and slot behaviors using React Testing Library / Vitest.
*   **End-to-End & Audit Trace Scenarios:**
    *   `apps/iris/e2e/` (and backend e2e beside `olympus` if added). Example: Onboard Framework → Map Controls → Collect Evidence → Verify Hash → Generate Audit Report.

---

## 4. Systematic Debugging Protocol

When encountering any bug or test failure, execute the `systematic-debugging` skill:
1.  **Isolate & Reproduce:** Create a minimal reproducible test case replicating the defect.
2.  **Root Cause Analysis:** Inspect execution logs and state traces; do not patch symptoms blindly.
3.  **Fix with Verification:** Apply the targeted fix, verify the failing test passes, and ensure no regressions occur.

---

## 5. Verification Before Completion

Before claiming any task is complete or submitting changes:
1.  Run the workspace test suite (`pnpm test`).
2.  Run static type checking (`tsc --noEmit`).
3.  Run code quality and linting checks (including `max-lines` and `no-magic-numbers` once configured).
4.  Run `react-doctor` on `iris` changes to ensure no component regressions or performance bottlenecks.
5.  Document test evidence and run output in the task completion log.
