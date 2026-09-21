# Themis Agent Skills Catalog

This catalog lists every skill installed in `.agents/skills/` and when each AI should use it. All four agents — Antigravity, Codex, OpenCode, and Cursor — discover these files natively from `.agents/skills/<name>/SKILL.md`. No product-specific skill copies are required.

---

## 1. Development Methodology & Superpowers (`obra/superpowers`)

| Skill | Trigger / When to Use | Primary Agent |
| :--- | :--- | :--- |
| `using-superpowers` | Start of a conversation. Find and invoke the right skill before acting. | All AIs |
| `brainstorming` | Before any creative work: designing features, components, or altering behavior. | Antigravity, Cursor |
| `writing-plans` | When breaking down a multi-step specification into structured implementation tasks. | Antigravity |
| `writing-skills` | When creating, editing, or verifying agent skills. | Antigravity, Cursor |
| `test-driven-development` | Whenever writing or modifying features/bugfixes. Write failing tests first. | Codex |
| `executing-plans` | When executing step-by-step implementation tasks. | Codex, OpenCode |
| `subagent-driven-development` | When running parallel subagents for independent modular tasks. | Antigravity |
| `dispatching-parallel-agents` | When 2+ independent tasks can run without shared state. | Antigravity |
| `systematic-debugging` | Whenever a test fails, bug appears, or unexpected behavior occurs. Never guess. | Codex, OpenCode |
| `diagnosing-superpowers` | When a skills session went wrong and the failure needs a root-cause report. | All AIs |
| `verification-before-completion` | Before committing or declaring a task complete. Verify evidence and tests. | All AIs |
| `requesting-code-review` | Before submitting a pull request or finishing a major milestone. | Codex, Cursor |
| `receiving-code-review` | When addressing review comments with technical rigor. | Codex, Cursor |
| `using-git-worktrees` | When starting isolated feature development without clashing with the main working directory. | OpenCode |
| `finishing-a-development-branch` | When all tests pass and work is ready to integrate/merge. | OpenCode |

---

## 2. Persistent Memory & Context (`thedotmack/claude-mem` & Universal Memory)

These skills are **readable** by every agent. Search/MCP execution still depends on claude-mem being available; otherwise use `.agents/memory/memory-helper.sh`.

| Skill | Trigger / When to Use | Primary Agent |
| :--- | :--- | :--- |
| `mem-search` | Search cross-session memory database for prior solutions, decisions, and patterns. | All AIs |
| `smart-explore` | Token-optimized AST exploration of codebase structure before reading full files. | All AIs |
| `learn-codebase` | Prime agent memory with full codebase understanding. | All AIs |
| `knowledge-agent` | Query and build specialized knowledge bases from observation logs. | Antigravity |
| `pathfinder` | Map features into unified flowcharts and identify duplication. | Antigravity |
| `timeline-report` | Generate chronological project history from memory observations. | Antigravity |
| `how-it-works` | Understand memory ingestion lifecycle and storage mechanics. | All AIs |

---

## 3. UI, Design & Frontend Craftsmanship

| Skill | Source | Trigger / When to Use | Primary Agent |
| :--- | :--- | :--- | :--- |
| `impeccable` | `pbakaus/impeccable` | UI critique, styling polish, color tuning, typography, visual hierarchy, eliminating AI slop. | Cursor |
| `web-design-guidelines` | `vercel-labs/agent-skills` | Auditing layouts against Vercel's Web Interface Guidelines and WCAG 2.1 accessibility. | Cursor |
| `shadcn` | `shadcn/ui` | Adding, configuring, and styling Shadcn components and Base/Radix primitives. | Cursor |
| `migrate-radix-to-base` | `shadcn/ui` | Migrating components to Base UI primitives when needed. | Cursor |
| `vercel-react-view-transitions` | `vercel-labs/agent-skills` | Adding smooth animated transitions between dashboard views and detail routes. | Cursor |
| `vercel-composition-patterns` | `vercel-labs/agent-skills` | Structuring components using slots, compound patterns, and render props. | Cursor, Codex |
| `vercel-react-best-practices` | `vercel-labs/agent-skills` | React 19 standards, server/client component boundaries, memoization, pure rendering. | Cursor, Codex |

---

## 4. State Management & Data Fetching

| Skill | Source | Trigger / When to Use | Primary Agent |
| :--- | :--- | :--- | :--- |
| `zustand` | `lobehub/lobehub` | Building Zustand stores, slices, selectors, and atomic state updates. | Cursor, Codex |
| `store-data-structures` | `lobehub/lobehub` | Guidance on normalized data shapes and store organization. Companion to `zustand`. | Cursor, Codex |
| `heterogeneous-agent` | `lobehub/lobehub` | External-agent adapters, IPC, event mapping, sessions, and tool-call chains. | OpenCode, Antigravity |
| `tanstack-query` | `tanstack-skills` | Server state management, caching, background polling, and mutations. | Codex, Cursor |
| `tanstack-query-best-practices` | `deckardger` | Query keys factory, optimistic updates, and cache invalidation patterns. | Codex, Cursor |
| `tanstack-table` | `tanstack-skills` | High-performance data grids for compliance controls and audit logs. | Cursor, Codex |
| `tanstack-form` | `tanstack-skills` | Type-safe form state for risk, evidence, and control editors. | Cursor, Codex |
| `tanstack-router` | `tanstack-skills` | Type-safe routing, search params, and data loading. | Cursor |
| `tanstack-start` | `tanstack-skills` | Full-stack TanStack Start routing and SSR patterns. | Cursor |
| `tanstack-store` | `tanstack-skills` | Framework-agnostic reactive store primitives. | Codex, Cursor |
| `tanstack-db` | `tanstack-skills` | Client-side collections and reactive local data. | Codex |
| `tanstack-virtual` | `tanstack-skills` | Virtualized lists for large control and audit tables. | Cursor |
| `tanstack-pacer` | `tanstack-skills` | Debounce, throttle, and rate-limit async UI work. | Cursor, Codex |
| `tanstack-ranger` | `tanstack-skills` | Headless range sliders (risk scores, residual ranges). | Cursor |
| `tanstack-devtools` | `tanstack-skills` | Installing and composing TanStack Devtools. | OpenCode, Cursor |
| `tanstack-cli` | `tanstack-skills` | TanStack CLI scaffolding and codegen. | OpenCode |
| `tanstack-config` | `tanstack-skills` | Shared TanStack project configuration. | OpenCode |
| `tanstack-ai` | `tanstack-skills` | Type-safe AI SDK: streaming, tools, structured output. | Antigravity, Codex |

---

## 5. Code Health & Diagnostic Auditing

| Skill | Source | Trigger / When to Use | Primary Agent |
| :--- | :--- | :--- | :--- |
| `react-doctor` | `millionco/react-doctor` | Automated health checks (0–100 score), performance audits, and linting. | All AIs |
| `improve-react` | `millionco/react-doctor` | Architectural audit and optimization plan generation. Read-only. | Antigravity |
| `performance` | `millionco/react-doctor` | Diagnosing render bottlenecks, interaction lag, and Long Animation Frames. Slash-invoked. | Cursor, Codex |
| `deslop` | `millionco/react-doctor` | Cleaning up redundant, noisy, or verbose code while preserving logic. | OpenCode, Cursor |
| `find-similar-functions` | `millionco/react-doctor` | Fuzzy symbol search with `truffler` before adding helpers, to avoid duplicates. | OpenCode, Cursor |
