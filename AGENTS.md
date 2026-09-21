# AGENTS.md: Universal Multi-AI Engineering & Collaboration Guide

Welcome to **Themis** — an enterprise-grade Governance, Risk, and Compliance (GRC) platform engineered for portfolio demonstration.

Themis is developed collaboratively by a 4-AI engineering team:
1. **Codex** — Pure Domain Logic, Use Cases & TDD Unit Testing Specialist
2. **OpenCode** — Tooling, Environment Automation, Infrastructure Adapters & Git Worktrees
3. **Cursor** — UI/UX Craftsperson, Component Composition & Aesthetic Polish
4. **Antigravity** — Lead Systems Architect, Orchestration & Verification

All 4 AI agents operate under a shared, centralized repository structure located at `[.agents/](file:///home/grillo/development/themis/.agents/)`.

Canonical architecture spec: `[docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md](file:///home/grillo/development/themis/docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md)`.

Operational process-risk (v1): `[ADR-0006](file:///home/grillo/development/themis/.agents/decisions/ADR-0006-operational-process-risk-postgres.md)`, `[ADR-0007](file:///home/grillo/development/themis/.agents/decisions/ADR-0007-authorization-membership-not-oso.md)`, spec `[2026-09-21-database-schema-grc-core-design.md](file:///home/grillo/development/themis/docs/superpowers/specs/2026-09-21-database-schema-grc-core-design.md)`, workflow `[operational-process-workflow.md](file:///home/grillo/development/themis/.agents/knowledge/operational-process-workflow.md)`.

---

## 1. Universal Single Source of Truth (`.agents/`)

Every rule, skill, decision, task, log, and memory observation is stored in `.agents/`. Antigravity, Codex, OpenCode, and Cursor all scan `.agents/skills` natively. Thin bridge files point each product at the hub; do not maintain duplicate skill trees.

```
themis/
├── apps/
│   ├── iris/                      <-- TanStack Start frontend host
│   └── olympus/                   <-- NestJS API
├── packages/
│   └── nomos/                     <-- @themis/nomos Zod contracts
├── AGENTS.md                      <-- Universal AI onboarding guide (You are here)
├── DESIGN.md                      <-- System architecture & product design
├── CLAUDE.md                      <-- Claude Code bridge
├── GEMINI.md                      <-- Antigravity / Gemini bridge
├── .cursorrules                   <-- Cursor bridge
├── .cursor/rules/themis-agents.mdc
├── docs/superpowers/specs/        <-- Architectural design specs
└── .agents/                       <-- SHARED MULTI-AI ROOT
    ├── rules/
    │   ├── 00-clean-code-solid.md
    │   ├── 01-ai-collaboration.md
    │   ├── 02-architecture-grc.md
    │   ├── 03-frontend-quality.md
    │   ├── 04-testing-tdd.md
    │   ├── 05-security-compliance.md
    │   └── 06-backend-nestjs.md
    ├── hooks/
    ├── personas/
    ├── decisions/                 <-- ADR-0001 … ADR-0007
    ├── docs/
    ├── knowledge/
    ├── tasks/
    ├── logs/
    ├── memory/
    └── skills/
```

---

## 2. Core Architectural & Code Mandates

### Workspaces
- **`apps/iris`:** TanStack Start. Routing and SSR only. No `createServerFn` for GRC business logic.
- **`apps/olympus`:** NestJS with native DI. Domain, services, controllers. PostgreSQL + Prisma in `infrastructure/` (ADR-0006). See `.agents/rules/06-backend-nestjs.md`.
- **`packages/nomos`:** Zod schemas, inferred DTOs, path/error constants. No React, Nest, or formulas.

### Clean Architecture Mapping
Dependencies point **strictly inward**:
1. **Domain (`olympus` `domain/`):** Pure TypeScript. Entities (`Risk`, `Control`, `Evidence`), value objects (`RiskScore`, `ControlCode`), repository ports. English GRC names.
2. **Application (`olympus` `*.service.ts`):** Injectable use cases. Depends only on domain ports.
3. **Infrastructure (`olympus` `infrastructure/`):** Repository adapters, crypto, external clients. Nest providers.
4. **Presentation (API):** Nest controllers, `/v1`, `ZodValidationPipe` from `nomos`.
5. **Presentation (UI):** `iris` feature folders. Routes dumb, feature components smart, `shared/ui` primitives dumb. `iris` consumes `nomos` DTOs only and calls `olympus` through `ky` inside `api/`.

### Authorization (ADR-0007)
- Built-in RBAC + resource grants in `olympus` use cases. **Not Oso / OpenFGA / SpiceDB.**
- `User` is identity only. `CompanyMembership` is the company role. `ProcessAssignment` is liable / sub-liable / viewer. Sub-liables cannot approve.

### S.O.L.I.D. & Hygiene
- Follow `.agents/rules/00-clean-code-solid.md`.
- Zero magic strings / magic numbers (allowed literals: `0`, `1`, `-1`).
- React files ≤ 150 Prettier lines; compose instead of growing god components.
- Custom hooks are **defined** only in `hooks/` folders. Components may **use** hooks.
- Tests colocate with units; feature `tests/` is integration-only. See `.agents/rules/04-testing-tdd.md`.

### Frontend Stack (`iris`)
- TanStack Query for **all** server interactions (`useQuery` / `useMutation`). Optimistic updates live here.
- `ky` singleton for HTTP. Components never call `ky`. Query owns retries; `ky` retry is `0`.
- Zustand for complex UI state and explicit state machines. Never a server cache. Never optimistic API writes (overrides the LobeHub Zustand skill).
- TanStack Form + `nomos` Zod for forms. TanStack Table for grids.
- View transitions via TanStack Router + `@vercel/react-view-transitions` — not Next.js.

### Naming
- **Greek:** apps, packages, Nest modules, `iris` feature folders (`dike`, `prometheus`, `astraea`, `argus`, `hermes`, `mnemosyne`).
- **English GRC:** entities, copy, URLs (`/compliance`, `/risks`).

---

## 3. The 4-AI Task Coordination Protocol

To avoid collisions or duplicate work across Codex, OpenCode, Cursor, and Antigravity:

1. **Check Task Board:** Consult `[.agents/tasks/board.md](file:///home/grillo/development/themis/.agents/tasks/board.md)`.
2. **Acquire Lock:** Run `sh .agents/hooks/pre-task.sh <TASK_ID> <AI_NAME> [TARGET_DIR]`.
3. **Execute:** Follow the Superpowers workflow (Brainstorm → Plan → TDD → Verify).
4. **Verify Quality:**
   - Run unit/integration tests (`pnpm test`)
   - Check types (`tsc --noEmit`)
   - Audit frontend health (`npx react-doctor`)
5. **Release & Record:** Run `sh .agents/hooks/post-task.sh <TASK_ID> <AI_NAME> "<SUMMARY>"`.

---

## 4. Superpowers Development Methodology

All agents must follow the engineering discipline provided by `obra/superpowers`:
- **`brainstorming`:** Invoke before designing new features, models, or UI flows.
- **`writing-plans`:** Decompose requirements into verifiable, step-by-step tasks.
- **`test-driven-development`:** Write failing tests first before implementing code.
- **`systematic-debugging`:** When tests fail or bugs arise, isolate root cause with evidence rather than guessing.
- **`verification-before-completion`:** Never claim a task is complete without running verification commands and confirming green output.

---

## 5. Persistent Memory System (Cross-AI Compatible)

The persistent memory system bridges sessions across all 4 AI engines:
- **Index:** `[.agents/memory/index.md](file:///home/grillo/development/themis/.agents/memory/index.md)` provides the current architectural mental model.
- **Search Memory:** Run `sh .agents/memory/memory-helper.sh search "<query>"` or invoke the `mem-search` skill.
- **Record Insight:** Run `sh .agents/memory/memory-helper.sh add "<AI_NAME>" "<type>" "<insight>" [TASK_ID]`.

---

## 6. Installed Skills Directory & Usage Map

| Skill Set | Source | Description & Primary Use | Primary Agent |
| :--- | :--- | :--- | :--- |
| **Superpowers** | `obra/superpowers` | Engineering habits (TDD, plans, debugging, code review) | All AIs |
| **Claude Mem** | `thedotmack/claude-mem` | Long-term memory, code navigation, AST search | All AIs |
| **React Doctor** | `millionco/react-doctor` | React health auditing, performance triage, deslop, similar-function search | All AIs |
| **Shadcn UI** | `shadcn/ui` | Adding & customizing accessible UI components | Cursor |
| **Impeccable** | `pbakaus/impeccable` | Design critique, anti-AI-slop aesthetics, typography, polish | Cursor |
| **TanStack Query / Start / Form / Table / Router** | `tanstack-skills` | Server state, Start host, forms, grids, routing | Codex, Cursor |
| **Zustand** | `lobehub/lobehub` | Client/UI slices and machines. **Themis override:** no optimistic API writes in stores | Cursor, Codex |
| **React Best Practices** | `vercel-labs/agent-skills` | React 19 performance, composition, memoization rules | Cursor, Codex |
| **Web Design Guidelines** | `vercel-labs/agent-skills` | Vercel Web Interface Guidelines & WCAG 2.1 AA audits | Cursor |
| **View Transitions** | `vercel-labs/agent-skills` | Adapt recipes to TanStack Router — do not copy Next.js APIs | Cursor |
| **Composition Patterns** | `vercel-labs/agent-skills` | Compound components, slots, render props | Cursor, Codex |
