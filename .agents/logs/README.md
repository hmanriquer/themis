# AI Team Activity Log

This directory contains append-only logs tracking actions, task hand-offs, commits, and milestones performed by Codex, OpenCode, Cursor, and Antigravity.

## Structure of `activity.jsonl`
Each line is a valid JSON object:
```json
{
  "timestamp": "2026-09-21T13:30:00Z",
  "agent": "Antigravity",
  "action": "TASK_COMPLETE",
  "taskId": "TASK-001",
  "summary": "Scaffolded multi-AI integrations, shared .agents/ structure, installed 11 skills.",
  "gitCommit": null
}
```
