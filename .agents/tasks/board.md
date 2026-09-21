# Themis Master Task Board

This board coordinates active, backlog, and completed development tasks across all 4 AI agents.

---

## Active & Sprint Status

| Status | Count |
| :--- | :--- |
| **Backlog** | 5 |
| **Ready for Work** | 1 |
| **In Progress** | 0 |
| **In Review / Verification** | 0 |
| **Completed** | 5 |

---

## 1. In Progress

*(None currently active)*

---

## 2. Ready for Work

- [ ] `TASK-003`: **GRC Domain Model Implementation (Entities & Value Objects)**
  - **Owner:** Codex
  - **Priority:** High
  - **Scope:** Pure domain models for **operational** Process, Risk, Control, TaxonomyNode, Meeting, CompanyMembership, ProcessAssignment in `olympus` `prometheus` `domain/` (English GRC names). Obey ADR-0006 / ADR-0007. Framework, Evidence, and residual 1..25 scoring stay out of this task (later Dike/Mnemosyne). DTOs belong in `@themis/nomos` once that package exists.
  - **Dependencies:** `TASK-002` (Completed), `TASK-008` (Completed), `TASK-010` (Completed). Prefer landing after or with `TASK-009` workspace scaffolding.

---

## 3. Backlog

- [ ] `TASK-009`: **pnpm Workspace Scaffolding (`iris` / `olympus` / `nomos`)**
  - **Owner:** OpenCode
  - **Scope:** Create `pnpm-workspace.yaml`, `apps/iris` (TanStack Start), `apps/olympus` (NestJS), `packages/nomos`, ESLint (`max-lines` 150, `no-magic-numbers`, restricted `ky`/`fetch`/`axios` imports). Obey `docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md`. Do not put GRC logic in Start server functions.

- [ ] `TASK-004`: **Cryptographic Audit Ledger Engine**
  - **Owner:** Codex / OpenCode
  - **Scope:** WebCrypto SHA-256 hash chaining, append-only repository, and tamper-detection validator in `olympus` `astraea` module.

- [ ] `TASK-005`: **Design System Setup & Shadcn Component Primitives**
  - **Owner:** Cursor
  - **Scope:** Configure Tailwind CSS v4, base tokens, typography scale, Shadcn UI primitives under `iris` `src/shared/ui/` (dumb), view transition wrappers via TanStack Router.

- [ ] `TASK-006`: **Compliance Framework Explorer & Risk Heatmap Views**
  - **Owner:** Cursor / Codex
  - **Scope:** `dike` / `prometheus` feature modules. Smart components + colocated tests. TanStack Table + Query. Shareable filters in URL params. Zustand only for ephemeral UI/machines.

---

## 4. Completed

- [x] `TASK-010`: **Record Operational Process-Risk & Authorization Decisions**
  - **Owner:** Cursor
  - **Date Completed:** 2026-09-21
  - **Outcome:** Accepted ADR-0006 (PostgreSQL + Prisma, process lifecycle, heatmap, migration) and ADR-0007 (CompanyMembership + ProcessAssignment; not Oso). Cascaded into `DESIGN.md`, `AGENTS.md`, rules 05/06, knowledge workflow, spec mermaid, memory, and task board.

- [x] `TASK-008`: **Project Rules Hardening**
  - **Owner:** Cursor (amendment) / Antigravity (original spec)
  - **Date Completed:** 2026-09-21
  - **Outcome:** Accepted spec with feature-based `iris` layout, Nest module template, Query-only interactions, hook isolation, 150-line cap, test colocation, Greek/English naming split. Cascaded into rules `00`–`06`, ADR-0002–0005, `AGENTS.md`, `DESIGN.md`, bridges, and memory.

- [x] `TASK-007`: **Skill Discoverability Bridges & Catalog Sync**
  - **Owner:** Cursor
  - **Date Completed:** 2026-09-21
  - **Outcome:** Confirmed all four AIs natively read `.agents/skills`. Added `GEMINI.md`, amended ADR-0001 to drop required adapter symlinks, synced the skills catalog to every installed skill, corrected `CLAUDE.md` / `AGENTS.md`, and installed `find-similar-functions`.

- [x] `TASK-002`: **Core Clean Architecture TypeScript Scaffolding**
  - **Owner:** Antigravity
  - **Date Completed:** 2026-09-21
  - **Outcome:** Initialized `package.json`, Vite 6, React 19, TypeScript strict mode, Tailwind CSS v4, Vitest with TDD setup. Implemented first pure domain value object (`RiskScore`), domain error hierarchy (`ThemisError`), and presentation demo with 100% green tests and 0 build/type errors. *Superseded as the long-term app shape by TASK-008 / TASK-009.*

- [x] `TASK-001`: **Multi-AI Framework & Skills Integration Scaffolding**
  - **Owner:** Antigravity
  - **Date Completed:** 2026-09-21
  - **Outcome:** Setup `.agents/` repository with rules, personas, ADRs, docs, knowledge, tasks, locks, logs, universal memory system. Installed 11 required skill sets. Clean single-hub configuration with zero redundant AI folders. Created `AGENTS.md` and `DESIGN.md`.
