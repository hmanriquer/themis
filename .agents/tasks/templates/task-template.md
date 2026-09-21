# Task Template: [TASK-ID]: [Task Title]

*   **Status:** Backlog | Ready | In Progress | Review | Done
*   **Assigned AI:** Codex | OpenCode | Cursor | Antigravity
*   **Priority:** Critical | High | Medium | Low
*   **Related ADR:** [ADR-XXXX](file:///home/grillo/development/themis/.agents/decisions/ADR-0001-multi-ai-shared-architecture.md)

---

## 1. Description & Context
Briefly explain the problem, user story, or architectural goal.

## 2. Scope & Target Files
- `src/...`
- Tests to add/modify: `tests/...`

## 3. Pre-Conditions & Locks
- Run `sh .agents/hooks/pre-task.sh TASK-ID <AI_NAME>` before editing.

## 4. TDD / Implementation Checklist
- [ ] Write failing unit test for specification
- [ ] Implement minimum code to satisfy test
- [ ] Refactor adhering to Clean Architecture and S.O.L.I.D.
- [ ] Verify no linter or type errors (`tsc --noEmit`)
- [ ] Run `react-doctor` (if frontend)

## 5. Verification Evidence
Paste command output proving all tests and checks pass.

## 6. Post-Completion
- Run `sh .agents/hooks/post-task.sh TASK-ID <AI_NAME>`.
