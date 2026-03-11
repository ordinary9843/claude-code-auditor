#!/usr/bin/env bash
# Hook: Display available code-auditor commands at session start.
# Triggers on: SessionStart
# Effect: Advisory only (exit 0) — informational message.

set -euo pipefail

# Only show the message if we're in a directory that looks like a plugin project
HAS_PLUGIN=false
if [ -f ".claude-plugin/plugin.json" ] || [ -f ".claude-plugin/marketplace.json" ]; then
  HAS_PLUGIN=true
fi
if find . -maxdepth 4 -name "SKILL.md" 2>/dev/null | grep -q .; then
  HAS_PLUGIN=true
fi

if [ "$HAS_PLUGIN" = "true" ]; then
  echo "code-auditor ready. Two commands, any file type:"
  echo "  /code-auditor:review [path]  — score a file or full plugin directory (A–F grade)"
  echo "  /code-auditor:fix    [path]  — review then auto-apply improvements (asks before writing)"
fi

exit 0
