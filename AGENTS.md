# Agent Instructions

## Project Overview

This is a **GitHub Copilot customization template** — a starter repository that provides the directory structure and conventions for setting up AI coding agent customization files (agents, instructions, prompts, skills, hooks) in any project.

**License:** MIT · **Owner:** pkumar26

## Directory Structure

```
.github/
├── agents/        # Custom agent definitions (.agent.md)
├── hooks/         # Lifecycle hooks (PreToolUse, PostToolUse)
├── instructions/  # File-scoped instructions (.instructions.md)
├── prompts/       # Reusable prompt templates (.prompt.md)
├── skills/        # On-demand skills with bundled assets (SKILL.md)
├── workflows/     # GitHub Actions CI/CD workflows
└── copilot-instructions.md  # Redirects to this file
docs/              # Project documentation (linked, not duplicated)
```

## Conventions

### Customization File Selection

| Need | Primitive | Location |
|------|-----------|----------|
| Always-on project rules | AGENTS.md (this file) | Root |
| File-pattern-specific guidance | `.instructions.md` | `.github/instructions/` |
| Single focused task with inputs | `.prompt.md` | `.github/prompts/` |
| Multi-step workflow with assets | `SKILL.md` | `.github/skills/<name>/` |
| Subagent with tool restrictions | `.agent.md` | `.github/agents/` |
| Deterministic shell at lifecycle events | `.json` | `.github/hooks/` |

### Writing Guidelines

- **Description is the discovery surface** — include trigger phrases in the `description` frontmatter field or the agent won't find the file
- **Link, don't embed** — reference docs in `docs/` rather than copying content
- **Quote colons in YAML** — use `description: "Use when: doing X"` to avoid silent parse failures
- **Avoid `applyTo: "**"`** on instructions unless they truly apply to every file
- **Keep AGENTS.md minimal** — only what applies to *every* task; delegate specifics to instructions/skills

## Build & Test

No build or test commands — this is a documentation-only template. Validate customization files by checking:
1. YAML frontmatter parses correctly (no tabs, colons are quoted)
2. `description` fields contain relevant trigger keywords
3. File paths match expected locations per the table above