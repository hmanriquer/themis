# Multi-AI Coordination Protocol

This document defines the operational protocol for the 4 autonomous AI agents collaborating on Themis: **Codex**, **OpenCode**, **Cursor**, and **Antigravity**.

---

## 1. Lifecycle of a Feature or Task

```
       +-------------------------------------------------------------+
       | 1. Architecture & Plan (Antigravity)                        |
       |    - Superpower: brainstorming, writing-plans               |
       |    - ADR in .agents/decisions/, task in .agents/tasks/      |
       +------------------------------+------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | 2. Domain & Application TDD (Codex)                         |
       |    - Hook: pre-task.sh acquires lock                        |
       |    - Superpower: test-driven-development, executing-plans   |
       |    - Implements Pure Domain & Use Cases                     |
       +------------------------------+------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | 3. Environment, CLI & Infrastructure (OpenCode)             |
       |    - Infrastructure adapters, DB/Storage, Git worktrees     |
       |    - Runs tests & linters                                   |
       +------------------------------+------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | 4. UI/UX Implementation & Polish (Cursor)                   |
       |    - Skills: impeccable, shadcn, zustand, tanstack-query    |
       |    - Compound components, responsive styling, transitions   |
       +------------------------------+------------------------------+
                                      |
                                      v
       +-------------------------------------------------------------+
       | 5. Review & Verification (Antigravity + All)                |
       |    - react-doctor scan, systematic-debugging check          |
       |    - Hook: post-task.sh releases lock, updates log & memory |
       +-------------------------------------------------------------+
```

---

## 2. Shared File Structure Reference

All configuration, instructions, and coordination files are centralized:

| Path | Purpose | Primary Consumers |
| :--- | :--- | :--- |
| `.agents/rules/` | Engineering and design standards | All 4 AIs |
| `.agents/hooks/` | Pre-task & post-task scripts | OpenCode, Codex, Antigravity |
| `.agents/skills/` | Modular skills library (Superpowers, Impeccable, etc.) | All 4 AIs |
| `.agents/personas/` | Agent identity, roles, and strengths | All 4 AIs |
| `.agents/decisions/` | ADR records | All 4 AIs |
| `.agents/docs/` | System documentation and protocols | All 4 AIs |
| `.agents/knowledge/` | GRC domain facts, standards, and control sets | All 4 AIs |
| `.agents/tasks/` | Task board (`board.md`) and locks (`locks/`) | All 4 AIs |
| `.agents/logs/` | Append-only execution history (`activity.jsonl`) | All 4 AIs |
| `.agents/memory/` | Cross-AI persistent observations & sessions | All 4 AIs |

---

## 3. Concurrency Protection Rules

1.  **Never edit without a lock:** An agent must never write to code files without checking `.agents/tasks/locks/` or invoking `pre-task.sh`.
2.  **Granular file locks:** Locks should specify the targeted directory or files (e.g. `src/domain/risk/*`).
3.  **Automatic timeout:** If a lock is older than 2 hours without commit activity, it is considered stale and may be reclaimed after confirmation.
4.  **Handoff Logging:** Whenever an agent finishes work, it must write a summary entry in `.agents/logs/activity.jsonl` and update `.agents/memory/observations.jsonl`.
