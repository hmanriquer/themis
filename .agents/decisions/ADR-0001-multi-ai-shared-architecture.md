# ADR-0001: Shared Multi-AI Coordination Layer via `.agents/`

## Status
Accepted (amended 2026-09-21)

## Date
2026-09-21

## Context
Themis is developed collaboratively by 4 distinct AI agents: Codex, OpenCode, Cursor, and Antigravity. Without a unified repository structure, each AI tool historically looked in its own proprietary configuration directory (e.g. `.cursor/`, `.gemini/`, `.opencode/`, `.claude/`, `.codex/`), leading to fragmented rules, duplicated skills, uncoordinated concurrent edits, and broken context.

The first draft of this ADR required adapter symlink trees for every product. A Cursor audit on 2026-09-21 found those directories were never created, and current product docs no longer need them: Antigravity, Codex, OpenCode, and Cursor all scan `.agents/skills` natively.

## Decision
1. Establish a single shared root directory: `.agents/`.
2. Consolidate all rules, hooks, skills, personas, architectural decisions, documentation, domain knowledge, tasks, locks, logs, and persistent memory under `.agents/`.
3. Discover skills from `.agents/skills/<name>/SKILL.md`. Do **not** maintain duplicate copies or required symlinks in `.claude/skills`, `.codex/skills`, `.opencode/skills`, `.gemini/skills`, or `.cursor/skills`.
4. Keep thin, product-specific **bridge files** that point at the hub:
   - Antigravity / Gemini: `GEMINI.md` and `.agents/rules/`
   - Codex / OpenCode: root `AGENTS.md`
   - Cursor: `.cursorrules` and `.cursor/rules/themis-agents.mdc`
   - Claude Code: `CLAUDE.md`
5. Enforce concurrency via file-based locks in `.agents/tasks/locks/` managed by `pre-task.sh` and `post-task.sh`.

## Consequences
### Positive
- Single source of truth for rules, guidelines, and skills.
- Zero drift between what Cursor sees and what Antigravity, Codex, or OpenCode sees.
- Native skill discovery works without extra adapter folders.
- Concurrency locks prevent overlapping or conflicting file edits.
- Standardized cross-AI memory history in `.agents/memory/`.

### Negative
- Bridge files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`) must stay accurate when discovery rules change.
- Skills that depend on product-specific MCP tools (for example claude-mem search) are readable by every agent but only executable where those tools exist.
