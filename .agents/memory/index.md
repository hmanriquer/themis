# Themis Long-Term Memory Index

*Last Updated: 2026-09-21*

## 1. Project Context & Goals
- **Project Name:** Themis (Governance, Risk, and Compliance Portfolio Platform)
- **Status:** Rules hardened for a pnpm workspace; app scaffolding (`iris` / `olympus` / `nomos`) is a follow-on task. Root `package.json` is still the pre-workspace Vite scaffold.
- **Core Purpose:** Enterprise-grade portfolio showcase demonstrating Clean Architecture, S.O.L.I.D. principles, multi-standard compliance management (ISO 27001, SOC 2, NIST CSF, HIPAA), and cryptographic audit trail immutability.

## 2. Multi-AI Team State
- **Antigravity (Google DeepMind):** Lead architect, systems orchestration, verification.
- **Codex (OpenAI):** Pure domain logic, use cases, TDD unit testing.
- **OpenCode:** Tooling, worktree automation, CI/CD, infrastructure adapters.
- **Cursor:** UI/UX craftsmanship, Shadcn components, Tailwind v4 styling, transitions, frontend rules.

## 3. Key Technical Decisions
- **Shared Coordination:** All 4 AIs share `.agents/` as the single source of truth.
- **Workspaces (ADR-0004):** `apps/iris` (TanStack Start host), `apps/olympus` (NestJS + native DI), `packages/nomos` (Zod contracts only).
- **Clean Architecture (ADR-0002):** Domain lives in `olympus` `domain/` folders. `iris` consumes `@themis/nomos` DTOs only — no frontend domain formulas.
- **Frontend (ADR-0003, ADR-0005):** TanStack Start for routing/SSR only — no `createServerFn` for GRC logic. TanStack Query for all server interactions. `ky` singleton (retry 0; Query owns retries). Zustand for UI machines only (Themis override: no optimistic API writes in stores). TanStack Form + Table. View transitions via TanStack Router, not Next.js.
- **UI structure:** Dumb routes, smart feature components, dumb primitives. Custom hooks only in `hooks/` folders. React files ≤ 150 Prettier lines. Tests colocate with units; feature `tests/` is integration-only.
- **Naming:** Greek for apps/packages/modules/features (`dike`, `prometheus`, `astraea`, `argus`, `hermes`, `mnemosyne`). English GRC for entities, copy, and URLs.
- **Quality Gates:** TDD with 100% domain coverage, `react-doctor` score ≥ 90/100, WCAG 2.1 AA accessibility.
- **Canonical spec:** `docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md`.
- **Operational process-risk (v1):** ADR-0006 (PostgreSQL + Prisma, process lifecycle, heatmap), ADR-0007 (membership + process assignment; not Oso). Spec `docs/superpowers/specs/2026-09-21-database-schema-grc-core-design.md`. Workflow `.agents/knowledge/operational-process-workflow.md`.
- **Bounded context:** `prometheus` operational Process/Risk/Control is not the Dike ISO/SOC 2 control catalog. Do not share one `Control` entity.
- **Heatmap:** Derive grade from (frequency, severity) for new rows. Canonical cell *poco frecuente × bajo* = Insignificante. Store grade; do not overwrite historic outliers on seed.
- **AuthZ:** `User` is identity only. Liable is `ProcessAssignment`. Sub-liables cannot approve.

## 4. Installed Skills Summary
- Methodology: `obra/superpowers` (15 skills)
- Context & Memory: `thedotmack/claude-mem` (7 skills) + Universal Memory layer
- Code Quality: `millionco/react-doctor` (5 skills, including `find-similar-functions`)
- Discovery: All 4 AIs read `.agents/skills` natively. Bridges: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`.
- Design & UI: `pbakaus/impeccable`, `shadcn/ui`, `web-design-guidelines`, `vercel-composition-patterns`, `vercel-react-view-transitions` (adapt to TanStack Router)
- State & Data: `tanstack-skills` (Query, Table, Form, Router, Start), `lobehub/lobehub` (Zustand — optimistic-in-store pattern is invalid for Themis)
