# Rules File Evaluation Criteria

Scores files in `.claude/rules/*.md` (or `~/.claude/rules/*.md` for global) against Anthropic official modular rules documentation.

Total: 100 points across 5 dimensions.

## A. Structure & Frontmatter (20 pts)

| Check                               | Points | Pass condition                                                             |
|-------------------------------------|--------|----------------------------------------------------------------------------|
| Valid YAML frontmatter (if present) | 5      | `paths` field is a YAML list of strings, parses without error              |
| Glob patterns valid                 | 5      | Each `paths` entry is a valid glob (`src/**/*.ts`, `*.md`, `{src,lib}/**`) |
| No unreachable patterns             | 5      | Patterns don't reference directories that don't exist in the project       |
| File extension is `.md`             | 5      | All rule files end in `.md`                                                |

### Scoring tiers
- 20/20: All structural checks pass
- 10–19: Minor glob issues
- 0–9: Frontmatter YAML parse failure or wrong file extension

## B. Content Actionability (30 pts)

| Check                           | Points | Pass condition                                                                                  |
|---------------------------------|--------|-------------------------------------------------------------------------------------------------|
| No vague patterns               | 10     | No "follow best practices", "ensure quality", "be careful" without specifics                    |
| Imperative or declarative rules | 10     | Rules are stated as commands ("Use X", "Always Y") not suggestions ("You might want to")        |
| Specific and verifiable         | 10     | Each rule can be objectively checked — includes concrete examples, names, or measurable criteria |

### Scoring tiers
- 30/30: Every rule is actionable, specific, and verifiable
- 20–29: Mostly actionable, 1–2 vague statements
- 10–19: Mix of vague and specific
- 0–9: Mostly vague principles

## C. Scope & Focus (20 pts)

| Check                 | Points | Pass condition                                                          |
|-----------------------|--------|-------------------------------------------------------------------------|
| Single topic per file | 8      | File covers one coherent topic (e.g. testing, API design, security)     |
| Descriptive filename  | 6      | Filename describes the content — not `rule1.md`, `misc.md`, `notes.md` |
| Appropriate length    | 6      | File is between 5–200 lines (too short = useless, too long = unfocused) |

### Scoring tiers
- 20/20: One topic, descriptive name, right length
- 12–19: Minor naming or focus issues
- 0–11: Multiple unrelated topics or useless filename

## D. Path Targeting (15 pts)

Only applies if `paths` frontmatter is present. If absent, award 10/15 (path-free rules are valid but less precise).

| Check                                | Points | Pass condition                                                  |
|--------------------------------------|--------|-----------------------------------------------------------------|
| Paths match actual project structure | 5      | Referenced directories/patterns exist in the project           |
| Appropriate granularity              | 5      | Patterns aren't too broad (`**/*`) or too narrow (single file)  |
| No redundant patterns                | 5      | Paths don't overlap with other rule files' patterns             |

### Scoring tiers
- 15/15: Paths exist, well-scoped, no overlap
- 10–14: Minor overlap or slightly broad
- 0–9: Paths reference non-existent directories or extreme over/under-scoping

## E. Cross-file Consistency (15 pts)

Applied during directory audit when multiple rule files are present.

| Check                          | Points | Pass condition                                                              |
|--------------------------------|--------|-----------------------------------------------------------------------------|
| No contradicting rules         | 8      | Two rule files don't give opposite instructions for the same topic          |
| No duplication with CLAUDE.md  | 4      | Rules don't repeat content already in CLAUDE.md verbatim                   |
| Logical directory organization | 3      | If subdirectories are used (`frontend/`, `backend/`), grouping is coherent  |

### Scoring tiers
- 15/15: All rules are consistent and non-duplicative
- 8–14: Minor duplication
- 0–7: Contradicting rules or heavy duplication
