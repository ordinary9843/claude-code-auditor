# Context File Evaluation Criteria

Scores supporting markdown context files (e.g., `template.md`, `examples/*.md`, or logic splits) referenced internally by Skills and Agents.

Total: 100 points across 2 dimensions.

> Note: Context files intentionally do not require YAML frontmatter, as they are not triggered directly by the user interface.

## A. Structural Formatting (40 pts)

Context files exist to provide Claude with highly structured reference points. A disorganized context file confuses the AI.

| Check                  | Points | Pass condition                                                                                                      |
|------------------------|--------|---------------------------------------------------------------------------------------------------------------------|
| Visual hierarchy       | 15     | Uses markdown headers (H2, H3), bolding, and bulleted lists to separate concerns, avoiding massive walls of text.   |
| Code block definitions | 15     | Snippets and output examples are enclosed in triple backticks with syntax highlighting languages specified.         |
| File size optimization | 10     | The file is concise and strictly focused on its specific role (e.g., *only* examples, or *only* a template schema). |

### Scoring tiers
- 35–40: Perfectly structured and visually parsable template.
- 20–34: Unformatted blocks or missing syntax highlights.
- 0–19: Unstructured chaos that will bloat Claude's context window.

## B. Prompt Effectiveness (60 pts)

Whether it is an example output or a fill-in template, the file must be unambiguous to Claude.

| Check                      | Points | Pass condition                                                                                                                                                      |
|----------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Clear placeholders         | 20     | Template files use unmistakable placeholders (e.g., `[PLACEHOLDER]`, `<VARIABLE>`, `{{VALUE}}`) rather than plain text that Claude might output verbatim.           |
| Input vs Output separation | 20     | Example files explicitly label what is the user's "Input" and what is the expected "Output" or "Action".                                                            |
| Instructional framing      | 20     | Even as a supporting file, it provides a 1-line framing at the top explaining what the file is (e.g., "The following is the required JSON schema for the output:"). |

### Scoring tiers
- 50–60: Bulletproof reference material.
- 30–49: Ambiguous placeholders or merged input/output boundaries.
- 0–29: Confusing or unhelpful context that could derail the parent Skill.

---

## Example of a Perfect Template File

```markdown
# Issue Report Template

When the user asks you to generate a bug report, fill out the following template exactly as shown. Do not add conversational filler before or after the report.

### Environment
- **OS:** [DETECTED_OS]
- **Time:** [CURRENT_TIME]

### Description
[1-2 SENTENCE SUMMARY OF THE BUG]

### Reproduction Steps
1. [STEP 1]
2. [STEP 2]

### Proposed Fix
[EXACT FILE PATH AND SUGGESTED CODE CHANGES]
```
