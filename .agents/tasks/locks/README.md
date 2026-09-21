# Task Concurrency Locks

This directory holds transient lock files created by the 4 AI agents before editing code files.

## Lock File Format (`TASK-ID.lock`)
```json
{
  "taskId": "TASK-002",
  "assignedTo": "Codex",
  "startedAt": "2026-09-21T13:40:00Z",
  "filesLocked": ["src/domain/*"]
}
```

## Management
- Created via `.agents/hooks/pre-task.sh`.
- Removed via `.agents/hooks/post-task.sh`.
- If a lock is orphaned (> 2 hours old without commit activity), an agent can clean it up after logging the action.
