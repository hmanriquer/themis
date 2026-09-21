# Universal Persistent Memory System (Cross-AI Compatible)

This directory provides cross-session, persistent long-term memory for **Codex**, **OpenCode**, **Cursor**, and **Antigravity**, harmonizing the principles of `claude-mem` into a universal format compatible across all AI agents.

---

## 1. How the Memory System Works

1.  **Episodic Memory (`observations.jsonl`):**
    *   Append-only stream of observations, discoveries, bug fixes, and system insights.
    *   Any AI can query this via `mem-search` skill or `./memory-helper.sh search <term>`.
2.  **Semantic / Working Memory (`index.md`):**
    *   High-level distilled mental model of the project, key architectural decisions, domain invariants, and current state.
    *   Read at the start of any new session or when switching tasks.
3.  **Session Archives (`sessions/`):**
    *   Detailed transcripts and notes for long-running sessions.

---

## 2. Reading Memory at Session Start

Every AI should review the mental model at startup:
1.  Read `.agents/memory/index.md` for current system state and context.
2.  Search relevant past observations using:
    ```bash
    sh .agents/memory/memory-helper.sh search "risk calculation"
    ```
    or the `mem-search` skill.

---

## 3. Writing Memory on Significant Discoveries

When an AI resolves a tricky bug, establishes a pattern, or discovers an invariant:
```bash
sh .agents/memory/memory-helper.sh add "<AI_NAME>" "<observation_type>" "<description>"
```
*Types:* `architecture`, `bugfix`, `security`, `grc-domain`, `pattern`, `decision`.
