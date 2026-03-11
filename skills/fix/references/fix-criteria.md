# Fix Rules by Artifact Type

This file defines structural and semantic improvement rules for each artifact type. Load it during the Improvement Rules step of the `fix` skill to determine which changes are safe to auto-apply and which require user confirmation.

## SKILL.md

**Structural fixes (safe to auto-apply):**
- Rewrite `description` to third-person with trigger phrases if voice or trigger checks fail
- Change second-person / passive body sentences to imperative form
- Add language tags to fenced code blocks missing them
- Add `disable-model-invocation: true` if the skill has side effects (writes, deploys, sends)

**Semantic fixes (higher impact):**
- **Ambiguity rewrite**: Detect vague verbs ("handle", "process", "manage") and rewrite to specific actions
  - Before:
    ```text
    Handle the error appropriately
    ```
  - After:
    ```text
    If the API returns 4xx, log the error and return an empty result. If 5xx, retry once after 2s, then fail with the error message.
    ```
- **Edge case injection**: Add explicit handling for missing paths
  - Detect: flow steps that lack "if X doesn't exist" / "if Y is invalid" guidance
  - Add:
    ```text
    If <X> is missing or invalid, <specific recovery action or error message>.
    ```
- **Exit condition addition**: Add explicit success/failure end states to flows that lack them
  - Add:
    ```text
    If all checks pass, output <result>. If any check fails, report the failing check and stop.
    ```
- **Example scaffolding**: Generate example templates the user can fill in
  ```markdown
  ### Example (fill with your real data)
  **Input**: <describe a realistic input for this skill>
  **Expected behavior**: <what should happen step by step>
  **Expected output**: <what the user sees>
  ```

**Do NOT auto-fix:**
- Do not fill in domain-specific examples — they require user knowledge
- Do not restructure headings beyond fixing obvious hierarchy errors
- Do not change the skill's fundamental approach or scope

**Supported frontmatter keys** (do not add others):
`argument-hint`, `compatibility`, `description`, `disable-model-invocation`, `license`, `metadata`, `name`, `user-invokable`

Keys NOT valid for SKILL.md (cause validation errors): `agent`, `allowed-tools`, `context` — these apply to custom slash commands only.

## Agent .md

**Structural fixes:**
- Add frontmatter `name` and `description` if missing
- Rewrite description to third-person if needed; collapse multi-line YAML block scalars (`description: >`) to single-line inline values
- Add "when to invoke" context if missing

**Semantic fixes:**
- Add anti-hallucination guards if absent: `"Only use information from the provided files; do not invent findings"`
- Add context transmission if undefined: `"You receive: <inputs>. You must produce: <outputs>."`
- Flag scope creep: mark unbounded claims with `<!-- SCOPE: consider narrowing -->`



## CLAUDE.md
- Flag vague language with inline comments: `<!-- VAGUE: replace with specific, verifiable rule -->`
- Add a stub "Development Commands" section if absent
- Flag aspirational patterns: `"follow best practices"` → `<!-- VAGUE: what specific practices? list them -->`
- Do not rewrite substantive content — only add structure and flag problems

## .claude/rules/*.md

**Structural fixes:**
- Fix invalid YAML frontmatter syntax in `paths` field
- Rename vague filenames: suggest better names via `<TODO: rename to descriptive-name.md>`

**Content fixes:**
- Flag vague patterns with inline comments: `<!-- VAGUE: replace with specific rule -->`
- Rewrite suggestions ("You might want to") to imperatives ("Use X", "Always Y")
- Flag files covering multiple unrelated topics with `<!-- SCOPE: split into separate files -->`

**Do NOT auto-fix:**
- Do not change glob patterns in `paths` — they are project-specific
- Do not rewrite domain-specific rules
- Do not merge or split files without user confirmation

## .claude/commands/*.md (Custom Slash Commands)

**Structural fixes:**
- Add missing `description` field with a concise summary
- Add `argument-hint` field if `$ARGUMENTS` is present in the prompt body
- Add `allowed-tools` if the command instructs executing shell commands but lacks scoping

**Semantic fixes:**
- Convert passive suggestions ("You might want to review") to imperative ("Review this")
- Inject conditional fallback if `$ARGUMENTS` is used but empty case is unhandled:
  - Add: `If $ARGUMENTS is empty, <ask the user or use current directory>.`
- Convert hardcoded static targets into dynamic `$ARGUMENTS` usage where logical

## Context Files (template.md, examples/*.md)

**Structural fixes:**
- Add syntax highlighting language to code blocks missing them
- Break walls of text into bulleted lists or add H2/H3 headers

**Semantic fixes:**
- Replace ambiguous plain-text placeholders with unmistakable syntax like `[ERROR_LOG]` or `{{VARIABLE}}`
- For example files, add clear `**Input:**` and `**Output:**` headers if they bleed together
- Add a 1-line framing sentence at the top if the file starts abruptly (e.g., "The following is the expected structure for X:")

## MEMORY.md & Topic Files

**Structural fixes:**
- If `MEMORY.md` exceeds 200 lines, extract detailed entries into topic files and replace with summary references
- Add header groupings (e.g., `## Build & Test`, `## Architecture`) if entries are ungrouped
- Flag topic files with generic names (`notes.md`, `misc.md`) with `<!-- RENAME: use a descriptive name like debugging.md -->`

**Semantic fixes:**
- Flag vague memory entries with `<!-- VAGUE: replace with specific, verifiable fact -->`
- Flag entries that duplicate `CLAUDE.md` content with `<!-- DUPLICATE: already in CLAUDE.md -->`
- Flag contradictions with `CLAUDE.md` with `<!-- CONFLICT: contradicts CLAUDE.md rule: "..." -->`

## Output Styles (.claude/output-styles/*.md)

**Structural fixes:**
- Add missing `name` or `description` frontmatter fields
- Add `keep-coding-instructions: true` if undeclared and the style body references coding tasks

**Semantic fixes:**
- Flag vague persona descriptions with `<!-- VAGUE: define specific communication rules -->`
- Flag aspirational phrases ("be helpful", "respond well") → rewrite to concrete rules
