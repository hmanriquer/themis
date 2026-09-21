# Claude Code Bridge for Themis

Welcome! In this repository, all engineering guidelines, multi-AI coordination protocols, personas, ADRs, tasks, logs, and skills are centralized in:

👉 **[AGENTS.md](file:///home/grillo/development/themis/AGENTS.md)**
👉 **[.agents/](file:///home/grillo/development/themis/.agents/)**

## Quick Protocol
1. **Clean Code & S.O.L.I.D.:** Follow `.agents/rules/00-clean-code-solid.md`.
2. **Architecture:** Follow `.agents/rules/02-architecture-grc.md` (`iris` / `olympus` / `nomos`).
3. **Frontend:** `.agents/rules/03-frontend-quality.md`. Backend Nest: `.agents/rules/06-backend-nestjs.md`.
4. **Skills:** Discovered natively from `.agents/skills/`. Do not look for a project `.claude/skills` copy.
5. **Task Locking:** Run `.agents/hooks/pre-task.sh <TASK_ID> <AGENT_NAME>` before editing files.
6. **Memory:** Read `.agents/memory/index.md` and check `.agents/memory/observations.jsonl`.
7. **Spec:** `docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md`.
