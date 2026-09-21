# AI Collaboration & Orchestration Protocol

Themis development is driven by a cooperative multi-AI team comprising 4 AI engines:
1. **Codex** (Implementation Specialist & Unit Tests)
2. **OpenCode** (Terminal, CLI, Tooling & Automation)
3. **Cursor** (Inline UI / UX Refactoring & Rapid Pair Programming)
4. **Antigravity** (System Architecture, Deep Reasoning & Scaffolding Lead)

---

## 1. Shared State & Single Source of Truth

*   All coordination artifacts reside exclusively in `.agents/`:
    *   `rules/`: Active engineering and governance standards.
    *   `hooks/`: Lifecycle trigger scripts (`pre-task.sh`, `post-task.sh`).
    *   `skills/`: Shared modular agent skills.
    *   `personas/`: Operating profiles and specialization domains.
    *   `decisions/`: Architectural Decision Records (ADRs).
    *   `docs/`: Specifications, protocols, and workflows.
    *   `knowledge/`: Domain GRC knowledge, regulatory frameworks, control taxonomies.
    *   `tasks/`: Central task board (`board.md`) and concurrency lock files (`locks/`).
    *   `logs/`: Append-only activity log (`activity.jsonl`).
    *   `memory/`: Persistent memory store, observations, and context indices.

---

## 2. Concurrency & Task Locking Protocol

To prevent two AI agents from modifying the same files or executing overlapping tasks simultaneously:

1.  **Inspect Task Board & Locks:**
    *   Before starting any work, check `.agents/tasks/board.md` and `.agents/tasks/locks/`.
    *   Run `sh .agents/hooks/pre-task.sh <TASK_ID> <AI_NAME>` to acquire a lock and check preconditions.
2.  **Claiming a Task:**
    *   Move the task status to `In Progress (<AI_NAME>)` in `.agents/tasks/board.md`.
    *   Create a lock file at `.agents/tasks/locks/<TASK_ID>.lock` containing:
        ```json
        {
          "taskId": "TASK-001",
          "assignedTo": "Codex",
          "startedAt": "2026-09-21T13:30:00Z",
          "filesLocked": ["src/domain/risk/*"]
        }
        ```
3.  **Completing & Releasing:**
    *   Run tests and verification before declaring success.
    *   Run `sh .agents/hooks/post-task.sh <TASK_ID> <AI_NAME>` to remove the lock, append to `.agents/logs/activity.jsonl`, update `.agents/tasks/board.md`, and record observations in `.agents/memory/observations.jsonl`.

---

## 3. Hand-off Protocol

When an AI completes its phase and delegates to another AI:
1.  **Antigravity $\to$ Codex / OpenCode:**
    *   Antigravity defines the architectural contract, types, and writes implementation plans.
    *   Codex / OpenCode implements the domain entities, repositories, and unit tests.
2.  **Codex $\to$ Cursor:**
    *   Codex completes backend/domain logic and custom hooks.
    *   Cursor builds interactive components, accessibility, and UI polish in Shadcn / Tailwind.
3.  **Cursor / Codex $\to$ Antigravity:**
    *   Antigravity conducts adversarial code reviews, architectural audits, and verifies S.O.L.I.D. adherence.

---

## 4. Conflict Resolution & Ground Rules
*   **Respect Existing Decisions:** Never overwrite an approved ADR in `.agents/decisions/` without creating a new superseding ADR.
*   **No Silent Breaking Changes:** If an interface must change, all implementers and mock tests must be updated in the same changeset.
*   **Clean History:** Use conventional commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`).
