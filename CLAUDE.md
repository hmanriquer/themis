# Claude Code Bridge for Themis

Welcome! In this repository, all engineering guidelines, multi-AI coordination protocols, personas, ADRs, tasks, logs, and skills are centralized in:

👉 **[AGENTS.md](file:///home/grillo/development/themis/AGENTS.md)**
👉 **[.agents/](file:///home/grillo/development/themis/.agents/)**

## Quick Protocol
1. **Clean Code & S.O.L.I.D.:** Follow `.agents/rules/00-clean-code-solid.md`.
2. **Clean Architecture:** Follow `.agents/rules/02-architecture-grc.md`.
3. **Skills:** Discovered natively from `.agents/skills/`. Do not look for a project `.claude/skills` copy.
4. **Task Locking:** Run `.agents/hooks/pre-task.sh <TASK_ID> <AGENT_NAME>` before editing files.
5. **Memory:** Read `.agents/memory/index.md` and check `.agents/memory/observations.jsonl`.
