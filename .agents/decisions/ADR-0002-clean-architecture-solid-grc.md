# ADR-0002: Clean Architecture and S.O.L.I.D. for GRC Core

## Status
Accepted

## Date
2026-09-21

## Context
Governance, Risk, and Compliance (GRC) software involves strict regulatory models (ISO 27001, SOC 2, NIST CSF, HIPAA), complex risk assessment calculations, tamper-evident audit ledgers, and multi-tenant evidence gathering. Tightly coupling domain logic to a UI framework or specific database library makes testing difficult, leads to high maintenance costs, and makes regulatory audits risky.

## Decision
Adopt Robert C. Martin's Clean Architecture and S.O.L.I.D. object-oriented/functional design principles:
1. **Domain Layer:** Pure TypeScript, zero external dependencies. Contains entities (`Risk`, `Control`, `Evidence`), value objects (`RiskScore`, `ControlCode`), and repository interfaces (`IRiskRepository`).
2. **Application Layer:** Use cases/interactors (`AssessRiskUseCase`, `SubmitEvidenceUseCase`) orchestrating domain rules.
3. **Infrastructure Layer:** Concrete implementations of repositories (IndexedDB/Postgres), WebCrypto SHA-256 audit log signers, and cloud connectors.
4. **Presentation Layer:** React components, custom hooks, Zustand stores, and TanStack Query handlers.
5. Inward dependency rule: Outer layers may depend on inner layers; inner layers never know about outer layers.

## Consequences
### Positive
- Enterprise-grade testability with $100\%$ pure unit tests on domain calculation engines.
- Framework-agnostic core logic: UI or database can be replaced without touching business rules.
- High credibility for portfolio presentation showcasing senior-level engineering discipline.

### Negative
- Slightly higher initial boilerplate (DTOs, interfaces, use cases).
- Requires all 4 AIs to resist shortcutting domain boundaries.
