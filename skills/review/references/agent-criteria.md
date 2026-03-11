# Agent.md Scoring Criteria

Use this rubric to score an agent `.md` file. Apply each dimension check and assign the points shown. Total is 100 points.

## Table of Contents
- [A. Trigger & Identity (30 pts)](#a-trigger--identity-30-pts)
- [B. Effectiveness (45 pts)](#b-effectiveness-45-pts)
- [C. Safety & Consistency (25 pts)](#c-safety--consistency-25-pts)

---

## A. Trigger & Identity (30 pts)

Agent `.md` files use a YAML frontmatter block (`---`) that Claude Code reads to register the agent. The description is injected into Claude's context to determine when to delegate.

### A1. `name` field matches filename (5 pts)
- **5 pts**: `name: security-analyst` matches file `security-analyst.md`.
- **3 pts**: Minor mismatch (e.g. `name: securityAnalyst` vs `security-analyst.md`).
- **0 pts**: Name and filename are entirely different.

### A2. `description` field present and substantive (5 pts)
- **5 pts**: `description` present and 80+ characters.
- **3 pts**: `description` present but fewer than 80 characters.
- **0 pts**: `description` absent.

### A3. Third-person voice in description (5 pts)
- **5 pts**: Third-person throughout. Examples: "Reviews code for security vulnerabilities", "Performs deep analysis of…"
- **3 pts**: Mostly third-person with minor lapses.
- **0 pts**: First-person ("I review…") or second-person ("Use me to…").

### A4. "When to invoke" context included (10 pts)
Claude automatically selects agents based on context. The description must state **exactly when** to delegate.

- **10 pts**: Explicit invocation conditions with specific user phrases. Example: `"Invoked automatically for full plugin directory audits, or when the user asks for a 'deep audit', 'expert review', or 'comprehensive check'"`.
- **5 pts**: Conditions implied but not stated explicitly (e.g. "Helps with code analysis" — but when specifically?).
- **0 pts**: No invocation context; Claude cannot determine when to use this agent.

**Good vs. bad examples:**
```text
BAD:  "A helpful code review agent" — no trigger specificity
OK:   "Reviews code for issues" — vague, when does Claude choose this over its own code review?
GOOD: "Invoked when the user asks for 'security audit', 'vulnerability scan',
       mentions 'OWASP', or when a commit modifies authentication-related files."
```

### A5. Appropriate scope (5 pts)
- **5 pts**: Clearly bounded domain (e.g. "security review" not "all development tasks").
- **3 pts**: Scope is slightly broad or narrow.
- **0 pts**: Scope duplicates the base model or is too narrow (micro-task that should be a skill).

---

## B. Effectiveness (45 pts)

### B1. Clear role definition (10 pts)
The body must establish the agent's role, expertise domain, and primary responsibility immediately.

- **10 pts**: Role, domain, and responsibility are clear within the first 5 lines. Claude knows what this agent is for after reading one paragraph.
- **5 pts**: Role is present but domain or responsibility is vague.
- **0 pts**: No clear role definition; the agent's purpose is ambiguous.

### B2. Specific expertise areas listed (10 pts)
- **10 pts**: 3+ specific areas of expertise are named and described with enough detail that Claude understands the boundaries.
- **5 pts**: 1–2 expertise areas mentioned.
- **0 pts**: Generic claims only ("I am a helpful assistant").

### B3. Concrete behavioural guidelines (10 pts)
The body must include specific instructions about **how** the agent behaves, not just what it knows.

- **10 pts**: Explicit behavioural rules: output format, tone, what to always/never do, how to handle edge cases, how to handle uncertainty.
- **5 pts**: Some guidelines present but incomplete or vague (e.g. "be thorough" without defining what thorough means).
- **0 pts**: No behavioural guidelines; only a capability list.

**Good behavioural guidelines include:**
```
- "Always cite exact file paths and line numbers"
- "Never output more than 3 recommendations at once"
- "If the input file is not a supported type, say so explicitly and list supported types"
- "Use emoji anchors for section headers: 🔍 for findings, ✅ for passes, ❌ for failures"
```

### B4. Anti-hallucination guards (8 pts)
Agents frequently operate on user-provided data. Without explicit grounding instructions, Claude will confidently fabricate information that sounds plausible.

- **8 pts**: Explicit instructions such as:
  - "Only use information from the provided files; do not invent findings"
  - "If a check cannot be evaluated (missing data), mark as N/A rather than guessing"
  - "When uncertain about a score, flag it as 'uncertain' and explain why"
- **4 pts**: Some grounding present but incomplete (e.g. "be accurate" without specifying what to do when data is missing).
- **0 pts**: No anti-hallucination instructions.

### B5. Context transmission defined (7 pts)
When Claude delegates to an agent, the agent must know what context it receives (user request, file contents, previous scores) and what it should return (score, report, recommendation).

- **7 pts**: Clear definition of:
  - What inputs the agent expects (files, previous analysis, user question)
  - What outputs the agent must produce (format, structure, required fields)
  - What to do when expected inputs are missing
- **4 pts**: Partially defined (e.g. output format specified but input expectations missing).
- **0 pts**: No context transmission defined; agent operates as a black box.

---

## C. Safety & Consistency (25 pts)

### C1a. No hardcoded secrets (10 pts)
- **10 pts**: No API keys, passwords, or tokens found.
- **0 pts**: One or more secrets detected.

### C1b. No absolute paths (5 pts)
- **5 pts**: No machine-specific absolute paths (`/Users/...`, `/home/...`, `C:\...`) found.
- **0 pts**: One or more absolute paths detected.

### C2. Consistent terminology (5 pts)
- **5 pts**: Same concept always referred to by the same term (e.g. always "skill", not sometimes "command" or "tool").
- **0 pts**: 3+ names for the same concept; contradictory instructions found.

### C3. No scope creep markers (5 pts)
Agents that claim to handle everything effectively handle nothing. Look for unbounded scope.

- **5 pts**: No "also handles…", "any X", "all types of…" claims without enumeration. The agent's boundaries are clear.
- **3 pts**: Minor scope creep (e.g. "and other related tasks" — what tasks?).
- **0 pts**: Scope is effectively unlimited; agent claims to do anything.
