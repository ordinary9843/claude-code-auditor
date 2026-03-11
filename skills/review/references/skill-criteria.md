# SKILL.md Scoring Criteria

Use this rubric to score a SKILL.md file. Apply each dimension check and assign the points shown. Total is 100 points.

## Table of Contents
- [A. Trigger Precision (15 pts)](#a-trigger-precision-15-pts)
- [B. Instruction Clarity (25 pts)](#b-instruction-clarity-25-pts)
- [C. Examples & Expected Output (20 pts)](#c-examples--expected-output-20-pts)
- [D. Progressive Disclosure (15 pts)](#d-progressive-disclosure-15-pts)
- [E. Advanced Features (10 pts)](#e-advanced-features-10-pts)
- [F. Structure & Safety (15 pts)](#f-structure--safety-15-pts)

---

## A. Trigger Precision (15 pts)

The `description` field in frontmatter is injected into Claude's system prompt. It is the **sole signal** Claude uses to decide whether to invoke this skill. Bad descriptions → wrong skill selection → wasted context.

### A1. `description` field present and substantive (5 pts)
- **5 pts**: `description` exists and is 100+ characters.
- **3 pts**: `description` exists but is 20–99 characters (too brief for reliable trigger matching).
- **0 pts**: `description` absent or fewer than 20 characters.

### A2. Third-person voice (5 pts)
The description is processed as a tool definition. Claude interprets third-person descriptions as capability statements, which improves routing accuracy.

- **5 pts**: Starts with a third-person verb phrase. Examples: "Processes X and generates Y", "Extracts text from...", "Reviews code against..."
- **0 pts**: Uses first-person ("I can help…") or second-person ("You can use this to…") or imperative addressed to the user ("Use this to…").

**Quick check patterns:**
```text
FAIL: "I ", "I can", "You can", "you should", "Use this to"
PASS: Verb-first ("Processes", "Reviews", "Generates", "Extracts")
      or "This skill..." / "Performs..." / "Provides..."
```

### A3. 3+ specific trigger phrases or scenarios named (5 pts)
Specific phrases help Claude distinguish this skill from similar ones when multiple skills are installed.

- **5 pts**: 3 or more specific trigger phrases, file types, or user intents are explicitly named. Example: `"Use when the user asks to 'parse a PDF', 'read a form', 'extract tables from a document'"`
- **3 pts**: 1–2 specific triggers named.
- **0 pts**: No specific triggers; only generic language.

**Example of good trigger specificity:**
```yaml
description: >
  Extracts structured data from PDF files. Use when the user asks to "parse a PDF",
  "read a form", "extract tables from a document", mentions PDF files, or needs
  to convert a scanned document to text.
```

---

## B. Instruction Clarity (25 pts)

Claude executes skills as literal instruction sequences. Ambiguous instructions cause hallucination, inconsistent behaviour, and skipped steps. This section evaluates whether the instructions are precise enough for a machine to follow deterministically.

### B1. No ambiguous verbs (8 pts)
Verbs like "handle", "process", "manage", "deal with" are semantically empty — they don't tell Claude **what specific action to take**. Claude will guess based on training priors, which may not match the author's intent.

- **8 pts**: All action verbs are specific and measurable: "extract", "validate", "compare", "count", "sort", "filter", "reject", "retry", "append".
- **4 pts**: 1–2 vague verbs used without concrete definition of what they mean in context.
- **0 pts**: 3+ vague verbs. Claude will interpret each one differently across invocations.

**Ambiguous verb checklist:**
```text
FLAG: "handle", "process", "manage", "deal with", "take care of",
      "address", "resolve", "work on", "do something about"
OK if followed by explicit definition:
      "Handle by retrying 3 times then returning error object"
      "Process by extracting all tables as JSON arrays"
```

### B2. Edge case coverage (7 pts)
Missing edge case instructions cause Claude to hallucinate behaviour. The more edge cases are covered, the more predictable the skill becomes.

- **7 pts**: Explicit handling for all of: missing/no input, invalid input format, empty results, and boundary conditions specific to the skill's domain.
- **4 pts**: Some edge cases addressed (e.g. "if file not found, stop") but core scenarios like empty results or malformed input are unhandled.
- **0 pts**: No edge case handling. The skill only describes the happy path.

**Common missing edge cases:**
```text
- What happens when $ARGUMENTS is empty?
- What happens when the target file doesn't exist?
- What happens when the file is in an unexpected format?
- What happens when an intermediate step produces zero results?
- What happens when a required external tool isn't available?
```

### B3. Exit conditions defined (5 pts)
Every flow (step, branch, loop) must have an explicit end state. Without this, Claude may loop indefinitely or end at an arbitrary point.

- **5 pts**: Every flow has clear success/failure end states. Example: "If all checks pass, output the score table. If a blocking error is found, report it and stop."
- **3 pts**: Some flows define end states, but others leave the outcome ambiguous.
- **0 pts**: No end states defined anywhere.

### B4. No conflicting instructions (5 pts)
When two rules contradict each other, Claude silently picks one (usually the later one or the more specific one). The author's intent is lost.

- **5 pts**: All rules are internally consistent. No rule contradicts another. No "always do X" followed by "in case Y, don't do X" without explicit priority ordering.
- **0 pts**: 2+ rules directly contradict each other without resolution.

**Common conflict patterns:**
```text
CONFLICT: "Never modify files" + "Fix the formatting errors"
CONFLICT: "Use imperative voice throughout" + "Describe what this tool does"
CONFLICT: "Always include all details" + "Keep output under 50 lines"
RESOLVED: "Always include all details. If output exceeds 50 lines, summarize and offer to show full output."
```

---

## C. Examples & Expected Output (20 pts)

Examples are Claude's strongest learning signal. A skill with 3 concrete examples outperforms a 200-line instruction manual without examples. Claude uses examples to calibrate output format, level of detail, and edge-case handling.

### C1. Concrete examples with expected output (12 pts)
- **12 pts**: 3 or more realistic, non-placeholder examples showing exactly the input→action→expected output chain.
- **8 pts**: 1–2 examples present.
- **4 pts**: Examples referenced but use placeholder text (`foo`, `example@example.com`, `<your-value>`).
- **0 pts**: No examples.

### C2. Example variety (4 pts)
Examples should cover the skill's behavioural range, not just the happy path.

- **4 pts**: Examples cover at least one success case, one failure/error case, and one edge case.
- **2 pts**: Only happy-path examples.
- **0 pts**: N/A (no examples to evaluate).

### C3. Output format specified (4 pts)
If the skill produces structured output, the format must be explicit. Without it, Claude invents a format each time.

- **4 pts**: Expected output format is explicit: a markdown template, JSON schema, table structure, or "output nothing" for silent operations.
- **2 pts**: Partially specified (e.g. "output a table" but no column definitions).
- **0 pts**: No output format guidance; Claude must guess.

---

## D. Progressive Disclosure (15 pts)

### D1. SKILL.md body under 500 lines (7 pts)
The body (excluding frontmatter) is loaded into the context window every time the skill triggers.

- **7 pts**: Under 300 lines.
- **5 pts**: 300–499 lines.
- **2 pts**: 500–799 lines (context pressure).
- **0 pts**: 800+ lines (severe context bloat).

### D2. Detailed content moved to `references/` (5 pts)
When SKILL.md exceeds 150 lines or contains large reference tables, the detail must move to `references/`.

- **5 pts**: Long content is in `references/`; SKILL.md links to them with explicit `Load references/<filename>.md` or inline instruction.
- **3 pts**: Some content in `references/` but SKILL.md is still bloated.
- **0 pts**: All content crammed in body; or `references/` files exist but are never mentioned.

### D3. No duplication between SKILL.md and references (3 pts)
Each piece of information must live in exactly one place.

- **3 pts**: No duplicate content found.
- **0 pts**: Significant content repeated in both locations.

---

## E. Advanced Features (10 pts)

Claude Code provides features that dramatically affect skill safety and execution quality. Failing to use them when needed is a design flaw, not just a missed optimisation.

### E1. Side-effect awareness (4 pts)
Skills that write files, run deployment commands, send messages, or modify state should be user-invoked only.

- **4 pts**: Skills with side effects use `disable-model-invocation: true`; read-only skills correctly omit it.
- **2 pts**: Side effects present but no guard (Claude may auto-trigger destructive operations).
- **0 pts**: Destructive skill explicitly allows model invocation.
- **N/A (4 pts)**: Skill is read-only — full marks by default.

### E2. Tool restriction (3 pts)
Skills that don't need write access, network access, or shell access should restrict their tools.

- **3 pts**: `allowed-tools` explicitly limits tools to what the skill needs (e.g. `Read, Grep, Glob` for analysis skills).
- **0 pts**: `allowed-tools` absent AND the skill performs operations that should be restricted (file writes, shell commands, network requests).
- **N/A (3 pts)**: Skill genuinely needs all tools (document why in SKILL.md), OR the skill is a lightweight utility that doesn't involve restricted operations — full marks by default.

### E3. Subagent consideration (3 pts)
Heavy or long-running skills (researching large codebases, running test suites, multi-step workflows) benefit from `context: fork` to avoid polluting the main conversation.

- **3 pts**: Long-running or context-heavy skills use `context: fork` or `agent` field.
- **0 pts**: Long-running or context-heavy skill omits `context: fork` or `agent` field.
- **N/A (3 pts)**: Lightweight skill that completes quickly — full marks by default.

---

## F. Structure & Safety (15 pts)

### F1. `name` field present and valid (3 pts)
- **3 pts**: `name` exists, uses lowercase letters, numbers, and hyphens only; max 64 characters; does not contain "anthropic" or "claude" as standalone words.
- **0 pts**: `name` absent or invalid.

### F2. Imperative form throughout (4 pts)
The body must use verb-first imperative sentences (instructions, not suggestions).

- **4 pts**: All steps use imperative form: "Run…", "Extract…", "Check whether…"
- **2 pts**: Mostly imperative; a few passive/second-person lapses.
- **0 pts**: Predominantly non-imperative.

**Patterns to flag:**
```text
FAIL: "You should run…", "The user can…", "It is recommended to…", "Feel free to…"
PASS: "Run…", "Extract…", "Check whether…", "If X, do Y"
```

### F3. Heading structure (2 pts)
- **2 pts**: Exactly one H1 as title; two or more H2 sections.
- **0 pts**: No H1 or unstructured.

### F4. Code blocks with language tags (2 pts)
- **2 pts**: All fenced blocks have language tags.
- **0 pts**: Missing tags.

### F5. No absolute paths (2 pts)
- **2 pts**: No `/Users/…`, `/home/…`, `C:\…` paths found.
- **0 pts**: Absolute paths found.

### F6. Security Check (2 pts)
- **2 pts**: Passes basic checks (no hardcoded secrets). Note: A full prompt injection and safety review is handled separately via `security-criteria.md`.
- **0 pts**: Credential patterns detected.
