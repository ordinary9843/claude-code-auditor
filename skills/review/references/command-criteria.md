# Custom Command Evaluation Criteria

Scores `.claude/commands/*.md` (or `~/.claude/commands/*.md` for global) custom slash commands against official Anthropic custom command best practices.

Total: 100 points across 3 dimensions.

## A. Command Configuration & Validation (40 pts)

Slash commands power shortcuts. Proper configuration ensures they are predictable, discoverable, and safe.

| Check                  | Points | Pass condition                                                                                                          |
|------------------------|--------|-------------------------------------------------------------------------------------------------------------------------|
| Frontmatter present    | 10     | The file starts with a valid YAML `---` block.                                                                          |
| Description provided   | 15     | `description` field exists and clearly explains the command's purpose for `/help`.                                      |
| Argument hint provided | 10     | If `$ARGUMENTS` is used in the prompt body, `argument-hint` must be defined.                                            |
| Safe tool scoping      | 5      | If the command requires read/write tools, `allowed-tools` minimizes access (e.g., `Bash(git *)` instead of `Bash(*)`). |

### Scoring tiers
- 35–40: Well-documented and scoped command.
- 20–34: Missing argument hints or descriptive text.
- 0–19: Completely missing frontmatter or unsafe scoping.

## B. Prompt Actionability & Clarity (40 pts)

The prompt (body of the file) should be a highly explicit template for Claude to execute.

| Check                    | Points | Pass condition                                                                                                                                                    |
|--------------------------|--------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Zero-shot clarity        | 15     | The instructions use imperative active voice (e.g., "Review this code", not "You might want to review").                                                          |
| Handling empty arguments | 15     | If the command expects `$ARGUMENTS`, it explicitly instructs Claude what to do if `$ARGUMENTS` is empty (e.g., "If `$ARGUMENTS` is empty, target the current directory"). |
| No vague instructions    | 10     | Avoids undefined phrases like "do a good job", "be smart", or "as appropriate".                                                                                   |

### Scoring tiers
- 35–40: Clear, imperative prompt that handles edge cases safely.
- 20–34: Broad instructions, assumes arguments will always be present.
- 0–19: Vague rambling file that leaves execution up to interpretation.

## C. Variable & Context Optimization (20 pts)

Custom commands often rely on context injection.

| Check                   | Points | Pass condition                                                                                                                            |
|-------------------------|--------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `$ARGUMENTS` injection  | 10     | Uses `$ARGUMENTS` instead of hardcoding target paths or values the user might want to change.                                             |
| Shell command injection | 10     | Uses `!` for dynamic context where appropriate (e.g., `!git diff` instead of asking Claude to run git diff itself) to save token roundtrips. |

---

## Example of a Perfect Custom Command

```markdown
---
description: Automatically generates a commit and pushes to the current branch.
argument-hint: "[commit message or leave blank for auto-generation]"
allowed-tools: Bash
---

You are a senior engineer finishing a piece of work.

1. First, check the current `git status`.
2. Review the diff of all staged files.
3. If `$ARGUMENTS` is provided, use it exactly as the commit message.
4. If `$ARGUMENTS` is empty, generate an extremely concise, professional Conventional Commit message based on the diff.
5. Create the commit using the message from step 3 or 4.
6. Push the changes to the current remote branch. Do not ask for permission if the branch already has an upstream.
```
