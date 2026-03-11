# CLAUDE.md Scoring Criteria

Use this rubric to score a CLAUDE.md file. Apply each dimension check and assign the points shown. Total is 100 points.

## Table of Contents
- [A. Structure (20 pts)](#a-structure-20-pts)
- [B. Content Quality (50 pts)](#b-content-quality-50-pts)
- [C. Size & Safety (30 pts)](#c-size--safety-30-pts)

---

## A. Structure (20 pts)

CLAUDE.md is loaded as persistent context every Claude Code session. Poor structure dilutes every conversation.

### A1. Project overview / architecture section present (8 pts)
- **8 pts**: A section clearly describing what the project does and how it is structured (directory layout, key packages, entry points).
- **4 pts**: Partial overview — what the project does but no structure, or vice versa.
- **0 pts**: No overview; Claude must infer project nature from nothing.

### A2. Development commands section present (8 pts)
- **8 pts**: A section listing runnable commands for build, test, lint, and dev server. Commands must be copy-pasteable (not pseudocode).
- **4 pts**: Some commands present but incomplete (e.g. only build, no test).
- **0 pts**: No commands section.

### A3. Proper heading hierarchy (4 pts)
- **4 pts**: H1 at the top; H2 for major sections; H3 for subsections. No heading levels skipped.
- **2 pts**: Heading hierarchy slightly inconsistent.
- **0 pts**: No headings, or headings used randomly.

---

## B. Content Quality (50 pts)

### B1. Actionable instructions — not vague principles (15 pts)
CLAUDE.md content must be actionable, not aspirational. Claude needs instructions it can follow directly.

- **15 pts**: Every rule is specific and verifiable. Example: "Use `pnpm turbo run test` to run all tests" not "Tests are important."
- **10 pts**: Mostly actionable; a few vague principles mixed in.
- **5 pts**: Half vague, half specific.
- **0 pts**: Primarily aspirational ("Write clean code", "Be careful with security").

**Vague language patterns to flag:**
```
"always follow best practices"
"be careful with X"
"ensure quality"
"write clean, maintainable code"
"consider security implications"
```

### B2. Commands are specific and runnable (12 pts)
Any command shown must work as written. No pseudocode.

- **12 pts**: All commands are complete and correct syntax.
- **8 pts**: Most commands correct; 1–2 are pseudocode or incomplete.
- **4 pts**: Commands are primarily pseudocode templates.
- **0 pts**: No actual commands; only descriptions.

**Examples:**
```
FAIL: "run the tests using your test runner"
FAIL: "npm test (or equivalent)"
PASS: "pnpm vitest run --coverage"
```

### B3. No time-sensitive content (8 pts)
- **8 pts**: No pinned versions presented as canonical, no "as of today" claims.
- **4 pts**: 1–2 version-pinned statements.
- **0 pts**: Filled with specific version numbers, dated statements.

### B4. Commands use correct namespacing (5 pts)
- **5 pts**: Slash commands match plugin name (e.g. `/code-auditor:review`).
- **0 pts**: Commands use wrong namespace or no namespace.
- **N/A (5 pts)**: Project is not a plugin (no `.claude-plugin/` directory) — full marks by default.

### B5. Instruction specificity (10 pts)
Every rule tells Claude exactly what to do, not what to "consider" or "keep in mind".

- **10 pts**: Every rule is a specific action: "Run X", "Use Y format", "If Z, do W".
- **5 pts**: Mix of specific and vague instructions.
- **0 pts**: Instructions are primarily suggestions: "consider using...", "try to...", "keep in mind...".

**Patterns to flag:**
```
VAGUE: "Consider security when writing endpoints"
SPECIFIC: "Validate all request inputs with zod. Reject requests with invalid input and return 400."
```

---

## C. Size & Safety (30 pts)

### C1. File under 10,000 characters (10 pts)
Large CLAUDE.md files consume significant context on every session start.

- **10 pts**: Under 5,000 characters.
- **7 pts**: 5,000–9,999 characters.
- **3 pts**: 10,000–19,999 characters.
- **0 pts**: 20,000+ characters.

### C2. No hardcoded secrets (10 pts)
- **10 pts**: No API keys, passwords, tokens, or credential-like strings found.
- **0 pts**: One or more secrets detected.

### C3. `@import` syntax valid (if imports used) (5 pts)
- **5 pts**: All `@...` references use correct syntax and point to existing files.
- **3 pts**: Imports present but some point to non-existent files.
- **0 pts**: Invalid import syntax used.
- **N/A (5 pts)**: No imports used — full marks by default.

### C4. No vague principle patterns (5 pts)
- **5 pts**: No "follow best practices", "ensure quality", "consider implications" patterns found.
- **3 pts**: 1–2 vague patterns found.
- **0 pts**: 3+ vague patterns found.
