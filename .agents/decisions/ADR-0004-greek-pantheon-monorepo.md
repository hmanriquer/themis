# ADR-0004: Greek Pantheon Monorepo Topology

## Status
Accepted (amended 2026-09-21: Spanish product surface, ADR-0009)

## Date
2026-09-21

## Context
Themis is named for the Titaness of divine law. A single Vite app with `src/domain` at the repository root cannot host both a TanStack Start UI and a NestJS API without collisions. Module names also need a stable taxonomy so four AIs do not invent parallel folder names (`compliance` vs `dike` vs `frameworks`).

## Decision
1. **pnpm workspaces:** `apps/*` and `packages/*`.
2. **Apps:** `apps/iris` (TanStack Start frontend host), `apps/olympus` (NestJS API).
3. **Shared package:** `packages/nomos` (`@themis/nomos`) — Zod contracts, inferred DTOs, path/error constants only. No React, Nest, `ky`, or domain formulas.
4. **Pantheon modules** (Nest modules and matching `iris` features): `dike` (compliance), `prometheus` (risk), `astraea` (audit ledger), `argus` (evidence telemetry), `hermes` (notifications), `mnemosyne` (evidence repository).
5. **Naming split:**
   - Greek: app, package, Nest module, and `iris` feature folder names.
   - English GRC: domain entities, use cases, and TypeScript/Prisma identifiers (`Process`, `Risk`, `Control`).
   - Spanish (`es-MX`): all user-facing copy and `iris` URL paths (`/procesos`, `/riesgos`, `/cumplimiento`). See ADR-0009. This amends the earlier English-copy rule.
6. **YAGNI:** No `@themis/ui`, `@themis/domain`, Turborepo, or OpenAPI generation until a second consumer exists.

Workspace scaffolding is a follow-on implementation task. This ADR locks the names and boundaries.

## Consequences
### Positive
- Stable vocabulary across AIs.
- Clear backend/frontend/contract split.
- Portfolio theming without polluting domain language or auditor-facing URLs.

### Negative
- Contributors must learn the pantheon map (documented in the hardening spec).
- Two processes (`iris` + `olympus`) instead of a single full-stack Start app.
