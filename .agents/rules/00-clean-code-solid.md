# Universal Clean Code & S.O.L.I.D. Principles

All 4 AIs (Codex, OpenCode, Cursor, Antigravity) working on Themis MUST adhere to the following Clean Code and S.O.L.I.D. standards across all layers (Domain, Application, Infrastructure, Presentation).

---

## 1. S.O.L.I.D. Principles in TypeScript & React

### S — Single Responsibility Principle (SRP)
*   **Rule:** Every class, module, function, and React component must have only one reason to change.
*   **Application:**
    *   **Components:** A UI component only renders UI. Data fetching belongs in custom hooks or query abstractions. Business rules belong in domain/application services.
    *   **Stores & Slices:** Zustand stores must be split into atomic feature slices rather than one monolithic store.
    *   **Services:** A service handles one specific domain concern (e.g., `RiskCalculatorService`, `AuditLogSignerService`).

### O — Open/Closed Principle (OCP)
*   **Rule:** Software entities should be open for extension, but closed for modification.
*   **Application:**
    *   Use polymorphic interfaces or strategy patterns for compliance frameworks (e.g., `ComplianceFrameworkRuleEngine` evaluates rules via registered strategy handlers for NIST, ISO 27001, SOC 2, HIPAA, without modifying the core engine).
    *   Use React composition patterns (Slot pattern, `asChild`, compound components via Radix/Base UI) so components can be extended without altering their internals.

### L — Liskov Substitution Principle (LSP)
*   **Rule:** Subtypes or implementations must be substitutable for their base abstractions without altering program correctness.
*   **Application:**
    *   All repository implementations (e.g., `InMemoryRiskRepository`, `PostgresRiskRepository`, `ApiRiskRepository`) must strictly adhere to the `IRiskRepository` contract, returning identical domain value objects and throwing predictable domain exceptions.
    *   Mock adapters in tests must behave identically to real adapters from the client's perspective.

### I — Interface Segregation Principle (ISP)
*   **Rule:** Clients should not be forced to depend upon interfaces they do not use.
*   **Application:**
    *   Prefer many small, focused interfaces over large, bloated ones (e.g., `IReader<T>`, `IWriter<T>`, `ISigner<T>` rather than a gigantic `IDataManager<T>`).
    *   Component props must only require what the component actually renders. Do not pass an entire `AssessmentEntity` into a badge component that only needs `{ status: AssessmentStatus }`.

### D — Dependency Inversion Principle (DIP)
*   **Rule:** High-level modules should not depend upon low-level modules. Both should depend upon abstractions. Abstractions should not depend on details; details should depend on abstractions.
*   **Application:**
    *   The Domain and Application layers must NEVER import from Infrastructure (database, fetch, localStorage, third-party libraries).
    *   Inject dependencies via constructor injection, factory functions, or React context providers.

---

## 2. Clean Code Standards

### Meaningful Naming
*   Use pronounceable, intention-revealing names:
    *   Variables & properties: nouns (e.g., `residualRiskScore`, `controlMitigationStatus`).
    *   Functions & methods: active verbs (e.g., `calculateRiskIndex()`, `verifyAuditSignature()`, `isEvidenceCompliant()`).
    *   Booleans: prefixes like `is`, `has`, `should`, `can` (e.g., `isAudited`, `hasActiveViolation`).
*   Avoid abbreviations, cryptic acronyms, or Hungarian notation.

### Functions & Methods
*   **Small & Focused:** Ideal length under 25 lines. A function should do one thing and do it well.
*   **Pure Functions First:** Maximize pure functions in domain logic for effortless testability and zero side effects.
*   **Zero Side Effects:** Functions should not mutate input arguments or global state unexpectedly. Use immutable data patterns.
*   **Low Cyclomatic Complexity:** Keep indentation depth $\le 2$. Use early returns (guard clauses) to reduce nesting.

### Error Handling & Exceptions
*   Use custom Domain Error classes extending a base `ThemisError` (e.g., `EntityNotFoundError`, `ComplianceViolationError`, `UnauthorizedAuditMutationError`).
*   Never swallow exceptions with empty `catch` blocks.
*   Log errors with contextual metadata through the shared logging interface.
*   Return typed results (e.g., `Result<T, E>`) for expected domain failures; reserve thrown exceptions for truly exceptional infrastructure failures.

### Comments & Documentation
*   Code should be self-documenting through expressive typing and clear naming.
*   Use JSDoc comments to document domain concepts, invariants, regulatory constraints, and architectural rationales—not to narrate trivial code mechanics.
*   Link Architecture Decision Records (ADRs) when making non-obvious design choices.
