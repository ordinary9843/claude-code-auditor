# Prompt Effectiveness Guide — How Claude Interprets Your Instructions

This reference explains how Claude Code actually processes skill instructions, agent definitions, and hooks. Use it to understand why certain prompt patterns work better than others and to diagnose issues where Claude behaves unexpectedly.

---

## 1. Common Ambiguity Patterns

These verbs/phrases sound clear to humans but are semantically empty for Claude. Claude will substitute its training priors, which may not match your intent.

| Ambiguous pattern                     | What Claude does                          | Better alternative                                                            |
|---------------------------------------|-------------------------------------------|-------------------------------------------------------------------------------|
| "Handle the error"                    | Logs it and continues (most common prior) | "If 4xx, return empty result. If 5xx, retry once, then fail with error."      |
| "Process the data"                    | Reads it and produces a summary           | "Parse each row as JSON, validate against schema, collect failures in array"  |
| "Manage the state"                    | Creates a variable and updates it         | "Store in `Map<string, State>`, update on event X, clear on event Y"          |
| "Ensure quality"                      | Does nothing measurable                   | "Run `pnpm lint && pnpm test` and fail if either exits non-zero"              |
| "Check if valid"                      | Returns boolean with no definition        | "Validate: field X is non-empty string, field Y matches regex `/^\d{3}$/`"    |
| "Clean up"                            | Deletes temporary files                   | "Remove files matching `*.tmp` in `./out/`, but preserve `./out/index.html`"  |
| "Optimize"                            | Adds caching                              | "Reduce response time by batching DB queries: max 1 query per entity type"    |

---

## 2. Claude's Interpretation Heuristics

When instructions are ambiguous, Claude falls back to these defaults:

### 2a. Missing error handling → Claude skips errors silently
If your skill doesn't say what to do when something fails, Claude will typically try/catch and continue. This is almost never what you want.

**Fix**: Always specify failure behaviour explicitly:
```markdown
If the file cannot be read, report the error message and stop. Do not attempt to continue with partial data.
```

### 2b. Missing output format → Claude invents one each time
Without a specified format, Claude generates a different structure every invocation — sometimes markdown, sometimes JSON, sometimes prose.

**Fix**: Include an output template:
```markdown
Output in this exact format:
## Result: `<filename>`
| Field | Value |
|-------|-------|
| Status | PASS / FAIL |
| Issues | <count> |
```

### 2c. Conflicting instructions → Claude picks the later/more specific one
If rule A says "always include full details" and rule B says "keep output under 10 lines", Claude will usually follow rule B (the constraint). This can cause truncation of important information.

**Fix**: Use explicit priority:
```markdown
Include all critical issues. If output exceeds 20 lines, summarize non-critical items
but always list critical items in full.
```

### 2d. "Use best judgment" → Claude defaults to safe/generic
Phrases like "use your judgment", "as appropriate", "when needed" cause Claude to take the most conservative path, which usually means doing less.

**Fix**: Replace with decision trees:
```markdown
If the file is under 100 lines, review inline.
If 100–500 lines, summarize and highlight key sections.
If over 500 lines, list sections by heading and ask the user which to review.
```

---

## 3. Token Budget Awareness

Every skill's SKILL.md body is loaded into context when triggered. Here's the real cost:

| Content type                          | Typical tokens per line | Impact                       |
|---------------------------------------|-------------------------|------------------------------|
| Prose instructions                    | ~15 tokens/line         | Moderate                     |
| Code blocks                           | ~10 tokens/line         | Low                          |
| Tables                                | ~20 tokens/line         | Higher (many special chars)  |
| Filler phrases ("Please note that…")  | Wasted                  | Remove entirely              |
| Repeated information                  | Double cost             | Deduplicate to `references/` |

**Rule of thumb**: A 200-line SKILL.md costs ~3,000 tokens. You have ~200K tokens total. This means a single skill consumes ~1.5% of context. This sounds small, but with 10+ skills loaded, overhead compounds quickly.

**Progressive disclosure saves real money**:
- Keep SKILL.md under 150 lines (core instructions only)
- Move scoring rubrics, examples, and reference tables to `references/`
- Claude loads `references/` only when explicitly instructed

---

## 4. Anti-Pattern Catalog

### 4a. The "Swiss Army Knife" skill
A skill that tries to do 5 different things based on input type. Claude gets confused about which path to take.

**Symptom**: Claude mixes behaviours from different paths, producing hybrid output.
**Fix**: Split into focused skills, or use a clear routing table at the top:
```markdown
| Input | Action |
|-------|--------|
| Directory path | Full audit (delegate to auditor agent) |
| Single .md file | Inline rubric review |
| JSON file | Schema validation |
```

### 4b. The "Just Figure It Out" instruction
Instructions that say "detect the appropriate action" without enumeration.

**Symptom**: Claude picks an action based on training data, which may not be your intent.
**Fix**: Enumerate all possible actions explicitly.

### 4c. The "Kitchen Sink" description
A description that lists every possible use case, diluting trigger precision.

**Symptom**: Skill triggers for unrelated queries because the description is too broad.
**Fix**: Focus description on the 3 most common triggers. Put edge cases in the body.

### 4d. The "Nested Conditionals" flow
Instructions with 3+ levels of if/else nesting.

**Symptom**: Claude loses track of which branch it's on beyond 2 levels of nesting.
**Fix**: Flatten to a decision table or sequential checks.

### 4e. The "Self-Referential Loop"
Instructions that say "apply this skill's own criteria to evaluate X" without bounds.

**Symptom**: Claude enters infinite reasoning loops or produces meta-analysis instead of results.
**Fix**: Set explicit depth: "Apply criteria once. Do not re-evaluate the evaluation."

---

## 5. Effective Frontmatter Patterns

> **Scope note**: `context` and `allowed-tools` are valid keys for `.claude/commands/*.md` (custom slash commands) only. They are NOT valid SKILL.md frontmatter keys and will cause validation errors if added to a SKILL.md file. See `memory/skill-frontmatter-constraints.md` for the authoritative SKILL.md key list.

### Choosing `disable-model-invocation` (SKILL.md only)
```yaml
# Allow Claude to auto-trigger this skill when it sees a matching prompt
# Good for: read-only analysis, formatting, information lookup
disable-model-invocation: false  # (or omit — this is the default)

# Only trigger via user slash command
# REQUIRED for: deploy, write, delete, send, publish — anything with side effects
disable-model-invocation: true
```

### Using `context` for slash commands (.claude/commands/*.md only)
```yaml
# Default: runs in main conversation context
# Good for: quick lookups, formatting, small transformations
context: default  # (or omit entirely)

# Fork: runs in isolated subagent context
# Good for: large file analysis, multi-step research, anything that
# would pollute main conversation with intermediate thinking
context: fork
```

### Using `allowed-tools` for slash commands (.claude/commands/*.md only)
```yaml
# Restrict to read-only tools
allowed-tools: Read, Grep, Glob

# Allow only specific bash commands
allowed-tools: Bash(git:*), Bash(gh:*), Read
```
