# AGENTS.md: Universal Multi-AI Engineering & Collaboration Guide

Welcome to **Themis** — an enterprise-grade Governance, Risk, and Compliance (GRC) platform engineered for portfolio demonstration.

Themis is developed collaboratively by a 4-AI engineering team:
1. **Codex** — Pure Domain Logic, Use Cases & TDD Unit Testing Specialist
2. **OpenCode** — Tooling, Environment Automation, Infrastructure Adapters & Git Worktrees
3. **Cursor** — UI/UX Craftsperson, Component Composition & Aesthetic Polish
4. **Antigravity** — Lead Systems Architect, Orchestration & Verification

All 4 AI agents operate under a shared, centralized repository structure located at `[.agents/](file:///home/grillo/development/themis/.agents/)`.

---

## 1. Universal Single Source of Truth (`.agents/`)

Every rule, skill, decision, task, log, and memory observation is stored in `.agents/`. Antigravity, Codex, OpenCode, and Cursor all scan `.agents/skills` natively. Thin bridge files point each product at the hub; do not maintain duplicate skill trees.

```
themis/
├── AGENTS.md                      <-- Universal AI onboarding guide (You are here)
├── DESIGN.md                      <-- System architecture & product design scaffold
├── CLAUDE.md                      <-- Claude Code bridge (points to AGENTS.md & .agents/)
├── GEMINI.md                      <-- Antigravity / Gemini bridge (points to AGENTS.md & .agents/)
├── .cursorrules                   <-- Cursor bridge (points to .agents/)
├── .cursor/                       <-- Cursor configuration
│   └── rules/themis-agents.mdc    <-- Modern Cursor rule directing to .agents/
└── .agents/                       <-- SHARED MULTI-AI ROOT (Single Source of Truth)
    ├── rules/                     <-- Clean Code, S.O.L.I.D. & Engineering standards
    │   ├── 00-clean-code-solid.md
    │   ├── 01-ai-collaboration.md
    │   ├── 02-architecture-grc.md
    │   ├── 03-frontend-quality.md
    │   ├── 04-testing-tdd.md
    │   └── 05-security-compliance.md
    ├── hooks/                     <-- Lifecycle automation hooks
    │   ├── pre-task.sh            <-- Acquires concurrency lock and logs task start
    │   ├── post-task.sh           <-- Releases lock, logs completion, appends memory
    │   └── agent-hook.json        <-- Hook schema specification
    ├── personas/                  <-- AI identity profiles and role matrix
    │   ├── antigravity.md
    │   ├── codex.md
    │   ├── opencode.md
    │   ├── cursor.md
    │   └── roles.md
    ├── decisions/                 <-- Architectural Decision Records (ADRs)
    │   ├── ADR-0001-multi-ai-shared-architecture.md
    │   ├── ADR-0002-clean-architecture-solid-grc.md
    │   └── ADR-0003-frontend-state-data-stack.md
    ├── docs/                      <-- Collaboration protocols and architecture specs
    │   ├── ai-coordination-protocol.md
    │   ├── architecture-overview.md
    │   └── skills-catalog.md
    ├── knowledge/                 <-- GRC domain expertise & regulatory frameworks
    │   ├── grc-domain-overview.md
    │   ├── compliance-frameworks.md
    │   └── audit-trail-design.md
    ├── tasks/                     <-- Task coordination & concurrency management
    │   ├── board.md               <-- Master task board (Backlog -> Done)
    │   ├── locks/                 <-- Active file/feature concurrency locks
    │   └── templates/             <-- Task definition templates
    ├── logs/                      <-- Append-only execution history
    │   └── activity.jsonl         <-- Structured team activity log
    ├── memory/                    <-- Universal cross-AI persistent memory
    │   ├── index.md               <-- Working memory index of project context
    │   ├── observations.jsonl     <-- Append-only episodic memory stream
    │   └── memory-helper.sh       <-- CLI memory search and append utility
    └── skills/                    <-- 52 installed modular agent skills
```

---

## 2. Core Architectural & Code Mandates

### Clean Architecture Layers
Dependencies must point **strictly inward**:
1. **Domain Layer (`src/domain/`):** Pure TypeScript. Zero dependencies. Entities (`Risk`, `Control`, `Evidence`), value objects (`RiskScore`, `ControlCode`), and repository interfaces (`IRiskRepository`).
2. **Application Layer (`src/application/`):** Use cases orchestrating domain rules (`AssessRiskUseCase`, `SubmitEvidenceUseCase`). Depends only on Domain.
3. **Infrastructure Layer (`src/infrastructure/`):** Concrete repository adapters, WebCrypto audit signers, external storage. Depends on Domain and Application interfaces.
4. **Presentation Layer (`src/presentation/`):** React 19 components, Shadcn UI primitives, Zustand client state, TanStack Query server caches, and View Transitions.

### S.O.L.I.D. Principles
- **S:** Every function, component, or class has one reason to change.
- **O:** Open for extension (compound components, strategy patterns for compliance frameworks), closed for modification.
- **L:** Implementations must be fully substitutable for their interfaces without side effects.
- **I:** Narrow, client-specific interfaces rather than broad "god" interfaces.
- **D:** High-level policy depends on abstractions; details implement abstractions.

---

## 3. The 4-AI Task Coordination Protocol

To avoid collisions or duplicate work across Codex, OpenCode, Cursor, and Antigravity:

1. **Check Task Board:** Consult `[.agents/tasks/board.md](file:///home/grillo/development/themis/.agents/tasks/board.md)`.
2. **Acquire Lock:** Run `sh .agents/hooks/pre-task.sh <TASK_ID> <AI_NAME> [TARGET_DIR]`.
3. **Execute:** Follow the Superpowers workflow (Brainstorm $\to$ Plan $\to$ TDD $\to$ Verify).
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
| **TanStack Query** | `tanstack-skills` & `deckardger` | Server state management, query keys, optimistic updates | Codex, Cursor |
| **Zustand** | `lobehub/lobehub` | Client/UI state slices, selectors, state structures | Cursor, Codex |
| **React Best Practices** | `vercel-labs/agent-skills` | React 19 performance, composition, memoization rules | Cursor, Codex |
| **Web Design Guidelines** | `vercel-labs/agent-skills` | Vercel Web Interface Guidelines & WCAG 2.1 AA audits | Cursor |
| **View Transitions** | `vercel-labs/agent-skills` | Smooth page & view animations | Cursor |
| **Composition Patterns** | `vercel-labs/agent-skills` | Compound components, slots, render props | Cursor, Codex |
