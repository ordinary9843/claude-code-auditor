# Claude Code Auditor

[![Claude Code Auditor](https://img.shields.io/badge/Claude_Code_Auditor-Grade_A-success?style=flat-square&logo=anthropic&logoColor=white)](https://github.com/ordinary9843/claude-code-auditor)

Tells you why your Claude Code setup isn't working as well as it should. Scores any Claude Code markdown file — `CLAUDE.md`, `.claude/rules/*.md`, `SKILL.md`, `agents/*.md`, `.claude/commands/*.md`, `MEMORY.md`, `.claude/output-styles/*.md`, and context files — against Anthropic best practices. Gives you an A–F grade, exact fixes, and a standard `shields.io` Score Badge for your README.

Most plugin quality improvements are based on intuition ("I feel this is better"). This plugin makes quality measurable with a consistent 100-point scoring rubric derived from Anthropic's official documentation and established community standards.

## Installation

You can install this plugin either directly within Claude Code or via your standard terminal.

### 1. Inside Claude Code (Recommended)
```shell
/plugin marketplace add https://github.com/ordinary9843/claude-code-auditor.git
/plugin install code-auditor@claude-code-auditor
```

### 2. Via Standard Terminal
```shell
claude plugin marketplace add https://github.com/ordinary9843/claude-code-auditor.git
claude plugin install code-auditor@claude-code-auditor
```

*Note: Please restart Claude Code after installation to ensure the plugin loads correctly.*

## How It Works

The plugin provides two primary commands that auto-detect the target file type. There is no need to manually specify what kind of file you are evaluating:

```text
/code-auditor:review [path]   →  score a file or directory (read-only)
/code-auditor:fix    [path]   →  review + apply improvements (confirms before writing)
```

If no path argument is provided, it defaults to the current working directory.

**Two precision tiers are available:**
- **Fast Review** (default): Scores using the criteria files in `skills/review/references/`. Best for quick feedback on a single file.
- **Deep Audit**: Activated automatically for directory-level audits, or when you ask for a "deep audit" or "detailed review". Handled by the `auditor` agent for full reference criteria with cross-file consistency checks.

### Supported File Types & Components

| Target | Description |
|--------|-------------|
| Directory | Performs a full weighted audit |
| `CLAUDE.md` | Assesses context file quality (actionability, commands, architecture layout, size limit). |
| `.claude/rules/*.md` | Evaluates rule actionability, scope focus, path targeting, and cross-rule consistency. |
| `.claude/commands/*.md` | Evaluates custom slash command quality (frontmatter, `$ARGUMENTS` usage, prompt clarity). |
| `SKILL.md` | Evaluates skill rubrics (frontmatter, content, progressive disclosure, structure). |
| `agents/*.md` | Evaluates agent rubrics (frontmatter, role definition, behavioral guidelines). |
| `MEMORY.md` & topic files | Evaluates auto-memory quality (200-line limit, actionability, topic file structure). |
| Output styles (`.claude/output-styles/*.md`) | Evaluates custom output style quality (frontmatter, persona, behavioral rules). |
| Context files (`template.md`, `examples/*.md`) | Evaluates supporting prompt files (formatting, placeholders, input/output clarity). |

> Commands, rules, skills, and output styles must be under `.claude/` (project-level) or `~/.claude/` (global). CLAUDE.md can be placed at the project root or any subdirectory.

### Background Hooks

The plugin also includes background hooks that fire automatically to assist your development flow:

*   **PostToolUse:** When you write or edit any Claude Code artifact, this hook suggests running the relevant review/fix command.
*   **SessionStart:** When a Claude Code session begins in a plugin project, it displays available commands.

*Both hooks are advisory only (exit 0) and will never block your operations.*

## Usage Examples

### 1. Run a Full Plugin Audit

```shell
/code-auditor:review .
```

**Example Output:**
```text
## Plugin Audit: Project   Overall: 64/100 — Grade D

Badge: `[![Claude Code Auditor](https://img.shields.io/badge/Claude_Code_Auditor-Grade_D-orange?style=flat-square&logo=anthropic&logoColor=white)](https://github.com/ordinary9843/claude-code-auditor)`

| Component         | Score      | Grade | Top issue                                                                                         |
|-------------------|------------|-------|---------------------------------------------------------------------------------------------------|
| Skills (6)        | 49/100     | F     | Missing frontmatter entirely; No XML bounding for input parsing (-15 security penalty)            |
| Agents (1)        | 68/100     | D     | reviewer.md has no frontmatter; Claude cannot register or route to the agent                      |
| Commands (0)      | —          | —     | No custom commands found                                                                          |
| Rules (2)         | 75/100     | C     | security.md has overlapping globs and vague principles                                            |
| Memory (0)        | —          | —     | No MEMORY.md found                                                                                |
| Output Styles (0) | —          | —     | No custom output styles found                                                                     |
| CLAUDE.md         | 86/100     | B     | No dedicated "Development Commands" section; commands scattered; 1–2 vague principle patterns     |
| **OVERALL**       | **64/100** | **D** |                                                                                                   |

### Top 5 actions (highest point impact across the directory)
1. [+19.6 pts overall] All 6 SKILL.md files — Add YAML frontmatter with name, description, argument-hint. Example for review/SKILL.md:
---
name: review
description: >
  Scores any Claude Code artifact against Anthropic best practices.
  Invoked when user asks to "review", "score", or "audit".
argument-hint: "[file path or leave empty for current dir]"
---
2. [+4.8 pts overall] All 6 SKILL.md files — Add concrete input→output examples
3. [+3.2 pts overall] reviewer.md + write-capable skills — Add frontmatter + disable-model-invocation
4. [+2.5 pts overall] security.md — Rewrite vague principles to specific imperatives
5. [+2.0 pts overall] CLAUDE.md — Group floating commands into a "Development Commands" section
```

### 2. Challenge a Score or Fix
The plugin includes a Devil's Advocate agent (`challenger`) to debate review scores or analyze architectural trade-offs of proposed fixes. Just ask Claude to "challenge the score" or "debate this fix".

### 3. Auto-Improve a File
This command reviews the file, displays a before/after plan, generates an improved version, and requests your confirmation before writing any changes.
```shell
/code-auditor:fix skills/review/SKILL.md
```

## Understanding Scoring & Grades

All components are scored from 0 to 100 and assigned an A–F grade based on the following scale:

| Grade | Score Range | Meaning                                                    |
|-------|-------------|------------------------------------------------------------|
| A     | 90–100      | Production-ready. Excellent formatting and best practices. |
| B     | 80–89       | Good. Only minor improvements needed.                      |
| C     | 70–79       | Adequate. Several issues should be addressed.              |
| D     | 60–69       | Below standard. Needs significant revision.                |
| F     | < 60        | Major restructuring required.                              |

**Full Directory Audit Weighting:**

The plugin auto-detects `plugin-dir` mode (evaluating the current directory of markdown files):

```text
Overall Score = (Skills Avg × 30%) + (Agents Avg × 20%) + (Commands Avg × 10%)
             + (Context Avg × 10%) + (Rules Avg × 10%) + (Memory Avg × 5%)
             + (Output Styles Avg × 5%) + (CLAUDE.md × 10%)
```

If a component is absent, redistribute its weight proportionally.

## CI/CD GitHub Actions Integration

You can integrate Claude Code Auditor into your CI/CD pipeline to automatically score your plugin pull requests or commits.

1. Ensure your repository contains a script like the included `scripts/ci-audit.py`.
2. Ensure you have `.github/workflows/audit.yml` configured.
3. Add `ANTHROPIC_API_KEY` to your repository's GitHub Secrets.
4. On every pull request touching a Claude artifact, the action will trigger an Anthropic API call to the `auditor` agent, post the score in the logs, and fail the build if the plugin grades as an **F**.

*Note: The CI script requires an Anthropic API key to invoke the Claude 3.7 Sonnet model for grading.*

## Plugin Architecture

```text
claude-code-auditor/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest (name: code-auditor)
│   └── marketplace.json         # Marketplace definition
├── skills/
│   ├── review/
│   │   ├── SKILL.md             # Unified review skill (auto-detects file type)
│   │   └── references/          # Per-component scoring rubrics
│   │       ├── skill-criteria.md
│   │       ├── agent-criteria.md
│   │       ├── claude-md-criteria.md
│   │       ├── rules-criteria.md
│   │       ├── command-criteria.md
│   │       ├── memory-criteria.md
│   │       ├── output-style-criteria.md
│   │       ├── context-criteria.md
│   │       ├── security-criteria.md
│   │       └── prompt-effectiveness-criteria.md
│   └── fix/
│       ├── SKILL.md             # Review + apply improvements
│       └── references/
│           └── fix-criteria.md  # Per-type fix rules
├── agents/
│   ├── auditor.md               # Deep audit specialist agent
│   └── challenger.md            # Devil's advocate / debate agent
├── hooks/
│   ├── hooks.json               # PostToolUse + SessionStart hooks
│   └── scripts/
│       ├── suggest-review.sh    # Advisory: suggest review after write/edit
│       └── welcome.sh           # Session start: show available commands
├── CLAUDE.md                    # Plugin context loaded at session start
├── LICENSE                      # MIT License
└── README.md
```

## Requirements & Troubleshooting

### Prerequisites
*   [Claude Code CLI](https://code.claude.com) must be installed.
*   `jq` must be installed (required by our shell hooks). You can install it via Homebrew:
    ```shell
    brew install jq
    ```

### Common Issues

**1. The Plugin is not loading**
Run the built-in validate command to check for errors:
```shell
claude plugin validate .
claude plugin list
```

**2. The Hooks are not firing**
Ensure the hook scripts have execute permissions and that `jq` is installed:
```shell
chmod +x hooks/scripts/*.sh
jq --version
```

**3. The Skills are not available**
If you don't see `/code-auditor:review` when typing `/help`:
*   Make sure you have restarted Claude Code after installation.

## Contributing

We welcome community improvements! To contribute:

1. Clone this repository to your local machine.
2. Add the marketplace locally: `claude plugin marketplace add .`
3. Install the local plugin: `claude plugin install code-auditor@claude-code-auditor`
4. Run the plugin against itself to establish a baseline: `/code-auditor:review .`
5. Submit a PR and kindly include the review score generated by the tool in your pull request description.
