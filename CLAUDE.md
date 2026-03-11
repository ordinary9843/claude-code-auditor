# Claude Code Auditor

## Plugin Commands

```text
/code-auditor:review [path]   →  score (read-only)
/code-auditor:fix    [path]   →  review + apply improvements (confirms before writing)
```

Auto-detects file type. No argument = current directory. Directory path triggers full weighted audit across all markdown artifacts.

The fix command performs structural fixes (frontmatter, voice, code block tags) and semantic fixes (ambiguity rewrite, edge case injection, example scaffolding). Internally applies a devil's advocate perspective (inspired by the `challenger` agent's principles) on each proposed fix before showing the plan. Always confirms before writing.

## Project Architecture

- **`.claude-plugin/`**: `plugin.json` and `marketplace.json` (not evaluated)
- **`skills/review/`**: Evaluation skill; `references/` holds criteria loaded on demand
- **`skills/fix/`**: Auto-improvement skill
- **`agents/`**: `auditor` (deep audit) and `challenger` (devil's advocate)
- **`hooks/`**: `hooks.json` + `scripts/` (not evaluated)

## Key Rules by Artifact Type

### SKILL.md
- `description`: third-person, 3+ specific trigger phrases
- Body: imperative form, under 500 lines; heavy detail in `references/`
- No ambiguous verbs; define edge cases and exit conditions for every flow
- Side-effect skills: add `disable-model-invocation: true`
- No README.md / CHANGELOG.md inside skill directory

### Agent.md
- `name` must match filename; description: 80+ characters, third-person, includes specific invocation phrases in quotes; says when Claude should delegate
- Body: clear role + 3+ expertise areas + behavioural guidelines + anti-hallucination guard
- Agents: `auditor` (directory audits), `challenger` (debating scores)

### CLAUDE.md
- Actionable rules only; no "follow best practices" / "ensure quality" patterns

### .claude/rules/*.md
- One topic per file; descriptive filename; `paths` frontmatter with valid globs
- Actionable imperatives only; no vague patterns
- No contradictions between rules or with CLAUDE.md

### .claude/commands/*.md (Custom Slash Commands)
- `description` required for `/help` discoverability
- `argument-hint` required when `$ARGUMENTS` is used in body
- Imperative voice; explicit fallback for empty `$ARGUMENTS`
- `allowed-tools` should scope tool access for safety

### Context Files (template.md, examples/*.md)
- Clear visual hierarchy (headers, lists, code blocks with syntax highlighting)
- Templates: unmistakable placeholders (`[PLACEHOLDER]`, `{{VAR}}`)
- Examples: explicit input/output separation
- 1-line framing at top explaining the file's role

### MEMORY.md & Topic Files
- `MEMORY.md` must stay under 200 lines (only first 200 loaded into system prompt)
- Index-only: detailed notes belong in topic files (e.g., `debugging.md`)
- Actionable, specific entries only; no vague observations
- No contradictions or duplication with `CLAUDE.md`

### Output Styles (.claude/output-styles/*.md)
- `name` and `description` required in frontmatter
- `keep-coding-instructions` explicitly declared
- Concrete behavioral rules; no vague persona descriptions

## Scoring

A (90–100) / B (80–89) / C (70–79) / D (60–69) / F (<60)

Plugin dir: `(skills × 0.30) + (agents × 0.20) + (commands × 0.10) + (context × 0.10) + (rules × 0.10) + (memory × 0.05) + (output_style × 0.05) + (CLAUDE.md × 0.10)`

If a component is absent, redistribute its weight proportionally.

## Dev Setup

```shell
# Install (run steps in order — marketplace add must complete before install)
claude plugin marketplace add .        # Step 1: register local marketplace
claude plugin install code-auditor@claude-code-auditor  # Step 2: install plugin

# Lint / Validate
claude plugin validate .

# Test (no automated suite — validate quality with self-audit)
claude /code-auditor:review .
claude /code-auditor:fix agents/auditor.md
```
