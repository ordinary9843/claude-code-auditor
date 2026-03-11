#!/usr/bin/env bash
# Hook: Suggest running the appropriate review skill after writing a Claude Code artifact.
# Triggers on: PostToolUse for Write or Edit tool calls
# Effect: Advisory only (exit 0) — suggests a review command, never blocks.

set -euo pipefail

INPUT=$(cat)

# Extract the file path that was written/edited
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_response.file_path // empty' 2>/dev/null || true)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")

# Detect any Claude Code artifact and suggest the unified review command
IS_ARTIFACT=false

if [ "$BASENAME" = "SKILL.md" ]; then IS_ARTIFACT=true; fi
if [ "$BASENAME" = "CLAUDE.md" ]; then IS_ARTIFACT=true; fi
if [ "$BASENAME" = "CLAUDE.local.md" ]; then IS_ARTIFACT=true; fi
if echo "$DIRNAME" | grep -qE '(^|/)agents(/|$)' && echo "$BASENAME" | grep -qE '\.md$'; then IS_ARTIFACT=true; fi
if echo "$DIRNAME" | grep -qE '(\.claude|~/.claude)/rules(/|$)' && echo "$BASENAME" | grep -qE '\.md$'; then IS_ARTIFACT=true; fi
if echo "$DIRNAME" | grep -qE '(\.claude|~/.claude)/commands(/|$)' && echo "$BASENAME" | grep -qE '\.md$'; then IS_ARTIFACT=true; fi
if [ "$BASENAME" = "MEMORY.md" ]; then IS_ARTIFACT=true; fi
if echo "$DIRNAME" | grep -qE '/memory(/|$)' && echo "$BASENAME" | grep -qE '\.md$'; then IS_ARTIFACT=true; fi
if echo "$DIRNAME" | grep -qE 'output-styles(/|$)' && echo "$BASENAME" | grep -qE '\.md$'; then IS_ARTIFACT=true; fi
if echo "$FILE_PATH" | grep -qE '(skills|agents)/.*\.md$' && [ "$BASENAME" != "SKILL.md" ]; then IS_ARTIFACT=true; fi

# Skip files inside the plugin's own references/ directories to prevent review→fix→review loops
if echo "$FILE_PATH" | grep -qE 'skills/.*/references/'; then IS_ARTIFACT=false; fi

if [ "$IS_ARTIFACT" = true ]; then
  echo "\n💡 Tip: This looks like a Claude Code artifact. Run /code-auditor:review $FILE_PATH to score it, or /code-auditor:fix $FILE_PATH to improve it."
fi

exit 0
