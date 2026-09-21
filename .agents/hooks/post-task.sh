#!/usr/bin/env bash
# .agents/hooks/post-task.sh
# Usage: ./post-task.sh <TASK_ID> <AI_NAME> [SUMMARY]

set -euo pipefail

TASK_ID="${1:-}"
AI_NAME="${2:-}"
SUMMARY="${3:-Completed task successfully}"

if [ -z "$TASK_ID" ] || [ -z "$AI_NAME" ]; then
  echo "Error: Missing arguments."
  echo "Usage: $0 <TASK_ID> <AI_NAME> [SUMMARY]"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOCK_DIR="$PROJECT_ROOT/.agents/tasks/locks"
LOCK_FILE="$LOCK_DIR/${TASK_ID}.lock"
LOG_FILE="$PROJECT_ROOT/.agents/logs/activity.jsonl"
OBS_FILE="$PROJECT_ROOT/.agents/memory/observations.jsonl"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ -f "$LOCK_FILE" ]; then
  rm -f "$LOCK_FILE"
  echo "✓ Released lock for $TASK_ID."
else
  echo "Notice: No lock file found for $TASK_ID."
fi

# Append to activity log
echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$AI_NAME\",\"action\":\"TASK_COMPLETE\",\"taskId\":\"$TASK_ID\",\"summary\":\"$SUMMARY\"}" >> "$LOG_FILE"

# Append to persistent memory observations
mkdir -p "$(dirname "$OBS_FILE")"
echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$AI_NAME\",\"type\":\"milestone\",\"taskId\":\"$TASK_ID\",\"observation\":\"$SUMMARY\"}" >> "$OBS_FILE"

echo "✓ Task $TASK_ID recorded as complete in activity logs and memory observations."
