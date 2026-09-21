# ADR-0002: Clean Architecture and S.O.L.I.D. for GRC Core

## Status
Accepted (amended 2026-09-21)

## Date
2026-09-21

## Context
Governance, Risk, and Compliance (GRC) software involves strict regulatory models (ISO 27001, SOC 2, NIST CSF, HIPAA), complex risk assessment calculations, tamper-evident audit ledgers, and multi-tenant evidence gathering. Tightly coupling domain logic to a UI framework or specific database library makes testing difficult, leads to high maintenance costs, and makes regulatory audits risky.

The first draft placed Domain / Application / Infrastructure / Presentation under a single `src/` tree. Themis is now a pnpm workspace (`iris`, `olympus`, `nomos`). Layers must map onto those workspaces without a second DI framework on top of NestJS.

## Decision
Adopt Robert C. Martin's Clean Architecture and S.O.L.I.D. principles, mapped as follows:

1. **Domain:** Pure TypeScript inside each `olympus` pantheon module's `domain/` folder. Entities (`Risk`, `Control`, `Evidence`), value objects (`RiskScore`, `ControlCode`), repository ports. English GRC names. Zero Nest/React/HTTP dependencies.
2. **Application:** Nest injectable services (`*.service.ts`) acting as use cases (`AssessRisk`, `SubmitEvidence`).
3. **Infrastructure:** `infrastructure/` providers implementing ports (Postgres, WebCrypto SHA-256 signers, cloud connectors), registered in Nest modules.
4. **Presentation (API):** Nest controllers. Thin HTTP. Zod pipes from `@themis/nomos`. Routes under `/v1`.
5. **Presentation (UI):** `apps/iris` feature-based folders. Routes are dumb; feature components are smart; `shared/ui` primitives are dumb. Domain is **not** copied into `iris`. `iris` consumes `@themis/nomos` DTOs and calls `olympus` through `ky` inside feature `api/` modules.
6. **Inward dependency rule:** Outer layers may depend on inner layers; inner layers never know about outer layers. `iris` never imports `olympus` source. `nomos` never contains domain formulas.

Follow Nest's own IoC on the backend (see `.agents/rules/06-backend-nestjs.md` and ADR-0004).

## Consequences
### Positive
- Enterprise-grade testability with $100\%$ pure unit tests on domain calculation engines.
- Framework-agnostic core logic inside `olympus` `domain/`.
- Frontend can change (Start today) without moving risk formulas.

### Negative
- Slightly higher initial boilerplate (DTOs, interfaces, use cases).
- Requires all 4 AIs to resist putting business rules in `iris` or in Start server functions.
