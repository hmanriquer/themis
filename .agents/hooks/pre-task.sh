#!/usr/bin/env bash
# .agents/hooks/pre-task.sh
# Usage: ./pre-task.sh <TASK_ID> <AI_NAME> [TARGET_PATH]

set -euo pipefail

TASK_ID="${1:-}"
AI_NAME="${2:-}"
TARGET_PATH="${3:-src/*}"

if [ -z "$TASK_ID" ] || [ -z "$AI_NAME" ]; then
  echo "Error: Missing arguments."
  echo "Usage: $0 <TASK_ID> <AI_NAME> [TARGET_PATH]"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOCK_DIR="$PROJECT_ROOT/.agents/tasks/locks"
LOCK_FILE="$LOCK_DIR/${TASK_ID}.lock"
LOG_FILE="$PROJECT_ROOT/.agents/logs/activity.jsonl"

mkdir -p "$LOCK_DIR"

if [ -f "$LOCK_FILE" ]; then
  EXISTING_OWNER=$(grep -o '"assignedTo": *"[^"]*"' "$LOCK_FILE" | cut -d'"' -f4 || echo "Unknown")
  echo "WARNING: Task $TASK_ID is already locked by $EXISTING_OWNER."
  echo "Check $LOCK_FILE before proceeding."
  exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat <<EOF > "$LOCK_FILE"
{
  "taskId": "$TASK_ID",
  "assignedTo": "$AI_NAME",
  "startedAt": "$TIMESTAMP",
  "filesLocked": ["$TARGET_PATH"]
}
EOF

echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$AI_NAME\",\"action\":\"TASK_START\",\"taskId\":\"$TASK_ID\",\"summary\":\"Acquired lock for $TASK_ID targeting $TARGET_PATH\"}" >> "$LOG_FILE"

echo "✓ Lock successfully acquired for $TASK_ID by $AI_NAME."
