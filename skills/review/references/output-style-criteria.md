# Output Style Evaluation Criteria

Scores custom output style files in `.claude/output-styles/*.md` (or `~/.claude/output-styles/*.md` for global) against Anthropic official output style documentation.

Total: 100 points across 3 dimensions.

> **Context**: Output styles modify Claude's system prompt to change response personality. They are activated via `/output-style [name]`. The same criteria apply regardless of whether the file is project-level or user-level.

## A. Frontmatter Completeness (40 pts)

| Check                               | Points | Pass condition                                                                                                                                  |
|-------------------------------------|--------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| `name` present                      | 15     | Required. Used as the `/output-style` command argument                                                                                          |
| `description` present               | 15     | Required. Shown in the `/output-style` selection menu                                                                                           |
| `keep-coding-instructions` declared | 10     | Boolean field is explicitly set. `true` = retain coding behaviors (code verification, testing). `false` = fully replace with custom instructions |

### Scoring tiers
- 35–40: All three fields present and correctly typed
- 20–34: Missing description or undeclared keep-coding-instructions
- 0–19: Missing name (style cannot be invoked)

## B. Instruction Quality (40 pts)

| Check                        | Points | Pass condition                                                                                                                             |
|------------------------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------|
| Clear persona definition     | 15     | The body defines a specific role or communication style (e.g., "You are a concise technical writer"), not vague ("Be helpful")             |
| Behavioral specificity       | 15     | Includes concrete behavioral rules (e.g., "Always use bullet points", "Never use filler phrases"), not aspirational goals                  |
| No conflict with core safety | 10     | Does not instruct Claude to skip safety checks, ignore permissions, or bypass tool restrictions                                            |

### Scoring tiers
- 35–40: Precise, actionable persona with clear behavioral rules
- 20–34: Vague style description or missing specific behaviors
- 0–19: No meaningful style instructions beyond the frontmatter

## C. Structure & Formatting (20 pts)

| Check              | Points | Pass condition                                                                                                    |
|--------------------|--------|-------------------------------------------------------------------------------------------------------------------|
| Markdown structure | 10     | Uses headers (H1/H2) to separate persona definition from behavioral rules                                         |
| Conciseness        | 10     | Style file is focused and under 100 lines (output styles are injected into every system prompt — bloat is costly) |

---

## Example of a Well-Structured Output Style

```markdown
---
name: concise-reviewer
description: Terse code review style — bullet points only, no filler
keep-coding-instructions: true
---

# Concise Reviewer

You are a senior staff engineer performing code review.

## Communication Rules
- Use bullet points exclusively; never write paragraphs
- Lead each point with a severity tag: `[critical]`, `[suggestion]`, `[nit]`
- Never use filler phrases ("I think", "Perhaps", "You might want to")
- If the code is correct, say "LGTM" and nothing else

## Code Review Focus
- Security vulnerabilities first
- Performance implications second
- Style and naming last
```
