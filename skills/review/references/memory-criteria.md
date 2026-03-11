# Memory File Evaluation Criteria

Scores `MEMORY.md` (auto-memory index) and its topic files (e.g., `debugging.md`, `api-conventions.md`) against Anthropic official memory best practices.

Total: 100 points across 3 dimensions.

> **Context**: `MEMORY.md` is located at `~/.claude/projects/<project>/memory/MEMORY.md`. The first 200 lines are loaded into Claude's system prompt at every session start. Topic files in the same directory are read on demand.

## A. Size & Structure (40 pts)

The 200-line hard limit makes every line count. Bloated memories waste system prompt budget.

| Check                | Points | Pass condition                                                                                                                               |
|----------------------|--------|----------------------------------------------------------------------------------------------------------------------------------------------|
| Under 200 lines      | 15     | `MEMORY.md` is ≤ 200 lines (content beyond 200 is silently dropped)                                                                         |
| Index-only structure | 15     | `MEMORY.md` acts as a concise index/summary, not a detailed knowledge dump. Detailed notes belong in topic files like `debugging.md`        |
| Logical grouping     | 10     | Entries are grouped by theme (e.g., "Build & Test", "Architecture", "Preferences") using headers or bullet groups                           |

### Scoring tiers
- 35–40: Lean, well-organized index under 200 lines
- 20–34: Over 200 lines OR mixing detailed notes into the index
- 0–19: Massive unstructured dump that wastes system prompt budget

## B. Content Quality (35 pts)

Memories should be actionable and specific, not vague observations.

| Check                      | Points | Pass condition                                                                                                                                 |
|----------------------------|--------|------------------------------------------------------------------------------------------------------------------------------------------------|
| Actionable entries         | 15     | Each memory is a concrete, verifiable fact or instruction (e.g., "Run `npm test -- --watch` for TDD"), not vague ("tests are important")      |
| No stale/duplicate entries | 10     | No entries that contradict each other or repeat the same information                                                                           |
| Topic file delegation      | 10     | Detailed findings (multi-paragraph debugging notes, architecture deep-dives) are in separate topic files, not crammed into `MEMORY.md`        |

### Scoring tiers
- 30–35: Every entry is specific, actionable, and properly delegated
- 15–29: Some vague entries or minor duplication
- 0–14: Mostly vague observations or severely duplicated content

## C. Topic File Quality (25 pts)

Topic files (`debugging.md`, `api-conventions.md`, etc.) extend the memory system.

| Check                  | Points | Pass condition                                                                            |
|------------------------|--------|-------------------------------------------------------------------------------------------|
| Descriptive filenames  | 10     | Filenames clearly indicate the topic (e.g., `debugging.md`, not `notes.md` or `misc.md`) |
| Focused scope          | 10     | Each file covers one coherent topic; no "catch-all" files                                 |
| Formatted for scanning | 5      | Uses headers, code blocks, and lists so Claude can quickly locate relevant info            |

### Scoring tiers
- 20–25: Well-named, focused, scannable topic files
- 10–19: Generic names or multi-topic files
- 0–9: No topic files (everything crammed into MEMORY.md) or chaotic structure

---

## Cross-file Checks

| Check                        | Deduction | Condition                                                      |
|------------------------------|-----------|----------------------------------------------------------------|
| Memory contradicts CLAUDE.md | −5        | A memory entry gives different guidance than a CLAUDE.md rule  |
| Memory duplicates CLAUDE.md  | −3        | A memory entry repeats what's already in CLAUDE.md verbatim   |
| Topic file unreferenced      | −2        | A topic file exists but MEMORY.md has no mention or link to it |
