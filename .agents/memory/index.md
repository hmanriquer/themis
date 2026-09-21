# Themis Long-Term Memory Index

*Last Updated: 2026-09-21*

## 1. Project Context & Goals
- **Project Name:** Themis (Governance, Risk, and Compliance Portfolio Platform)
- **Status:** Greenfield Scaffolding Complete
- **Core Purpose:** Enterprise-grade portfolio showcase demonstrating Clean Architecture, S.O.L.I.D. principles, multi-standard compliance management (ISO 27001, SOC 2, NIST CSF, HIPAA), and cryptographic audit trail immutability.

## 2. Multi-AI Team State
- **Antigravity (Google DeepMind):** Lead architect, systems orchestration, verification.
- **Codex (OpenAI):** Pure domain logic, use cases, TDD unit testing.
- **OpenCode:** Tooling, worktree automation, CI/CD, infrastructure adapters.
- **Cursor:** UI/UX craftsmanship, Shadcn components, Tailwind v4 styling, transitions.

## 3. Key Technical Decisions
- **Shared Coordination:** All 4 AIs share `.agents/` as the single source of truth.
- **Clean Architecture:** Domain (zero dependencies) $\to$ Application $\to$ Infrastructure $\to$ Presentation.
- **Frontend Stack:** React 19, Shadcn UI, Zustand (UI/client state), TanStack Query (server state), `@vercel/react-view-transitions`.
- **Quality Gates:** TDD with 100% domain coverage, `react-doctor` score $\ge 90/100$, WCAG 2.1 AA accessibility.

## 4. Installed Skills Summary
- Methodology: `obra/superpowers` (15 skills)
- Context & Memory: `thedotmack/claude-mem` (7 skills) + Universal Memory layer
- Code Quality: `millionco/react-doctor` (5 skills, including `find-similar-functions`)
- Discovery: All 4 AIs read `.agents/skills` natively. Bridges: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`.
- Design & UI: `pbakaus/impeccable`, `shadcn/ui`, `web-design-guidelines`, `vercel-composition-patterns`, `vercel-react-view-transitions`
- State & Data: `tanstack-skills` (Query, Table, Form, Router), `lobehub/lobehub` (Zustand, Store structures, Heterogeneous agents)
