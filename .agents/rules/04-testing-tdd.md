# Testing, TDD & Verification Protocol

High-reliability GRC platforms require rigorous verification. All code contributions must be accompanied by comprehensive tests written prior to or alongside implementation.

---

## 1. Test-Driven Development (TDD) Workflow

Follow the red-green-refactor cycle guided by the `test-driven-development` superpower skill:

1.  **Red:** Write an automated test expressing a single unit of behavior or specification. Run it and verify it fails for the expected reason.
2.  **Green:** Write the minimal implementation code necessary to make the test pass.
3.  **Refactor:** Clean up code, remove duplication, enforce S.O.L.I.D. principles, and ensure tests remain green.

---

## 2. Testing Pyramid & Categories

*   **Unit Tests (Domain & Application Logic):**
    *   Test all domain entities, value objects, domain services, and use cases in isolation.
    *   Execute in sub-second time without IO or database dependencies.
    *   Aim for $100\%$ branch coverage on critical GRC calculation engines (Risk Scoring, Residual Risk formula, Framework Mapping).
*   **Integration Tests (Infrastructure & Adapters):**
    *   Verify repository contracts, cryptographic hashing, external API adapters, and database migrations.
*   **Component Tests (Presentation Layer):**
    *   Verify user interactions, accessibility, error states, and slot behaviors using React Testing Library / Vitest.
*   **End-to-End & Audit Trace Scenarios:**
    *   Verify complete workflows: e.g., Onboard Framework $\to$ Map Controls $\to$ Collect Evidence $\to$ Verify Hash $\to$ Generate Audit Report.

---

## 3. Systematic Debugging Protocol

When encountering any bug or test failure, execute the `systematic-debugging` skill:
1.  **Isolate & Reproduce:** Create a minimal reproducible test case replicating the defect.
2.  **Root Cause Analysis:** Inspect execution logs and state traces; do not patch symptoms blindly.
3.  **Fix with Verification:** Apply the targeted fix, verify the failing test passes, and ensure no regressions occur.

---

## 4. Verification Before Completion

Before claiming any task is complete or submitting changes:
1.  Run the full test suite (`pnpm test` or `npm test`).
2.  Run static type checking (`tsc --noEmit`).
3.  Run code quality and linting checks.
4.  Run `react-doctor` to ensure no component regressions or performance bottlenecks.
5.  Document test evidence and run output in the task completion log.
