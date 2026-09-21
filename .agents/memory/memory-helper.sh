#!/usr/bin/env bash
# .agents/memory/memory-helper.sh
# Universal Memory Helper CLI for all 4 AI agents

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OBS_FILE="$SCRIPT_DIR/observations.jsonl"
INDEX_FILE="$SCRIPT_DIR/index.md"

COMMAND="${1:-help}"

case "$COMMAND" in
  search)
    QUERY="${2:-}"
    if [ -z "$QUERY" ]; then
      echo "Usage: $0 search <search_term>"
      exit 1
    fi
    echo "Searching observations for: $QUERY"
    if [ -f "$OBS_FILE" ]; then
      grep -i "$QUERY" "$OBS_FILE" || echo "No observations found matching '$QUERY'."
    else
      echo "No observations file found."
    fi
    ;;

  add)
    AGENT="${2:-Unknown}"
    TYPE="${3:-note}"
    TEXT="${4:-}"
    TASK_ID="${5:-GENERAL}"

    if [ -z "$TEXT" ]; then
      echo "Usage: $0 add <agent> <type> <text> [taskId]"
      exit 1
    fi

    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    # Escape quotes in text
    ESCAPED_TEXT=$(echo "$TEXT" | sed 's/"/\\"/g')

    echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$AGENT\",\"type\":\"$TYPE\",\"taskId\":\"$TASK_ID\",\"observation\":\"$ESCAPED_TEXT\"}" >> "$OBS_FILE"
    echo "✓ Saved observation from $AGENT."
    ;;

  index)
    if [ -f "$INDEX_FILE" ]; then
      cat "$INDEX_FILE"
    else
      echo "No index file found."
    fi
    ;;

  recent)
    COUNT="${2:-5}"
    if [ -f "$OBS_FILE" ]; then
      tail -n "$COUNT" "$OBS_FILE"
    else
      echo "No observations found."
    fi
    ;;

  *)
    echo "Themis Universal Memory Helper"
    echo "Commands:"
    echo "  $0 search <query>                     Search episodic memory"
    echo "  $0 add <agent> <type> <text> [taskId] Add an observation"
    echo "  $0 index                              Display working memory index"
    echo "  $0 recent [count]                     Show recent observations"
    ;;
esac
