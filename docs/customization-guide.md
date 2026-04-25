# Customization Guide

## Choosing the Right Primitive

| Need | Primitive | Location |
|------|-----------|----------|
| Always-on project rules | `AGENTS.md` | Root |
| File-pattern-specific guidance | `.instructions.md` | `.github/instructions/` |
| Single focused task with inputs | `.prompt.md` | `.github/prompts/` |
| Multi-step workflow with assets | `SKILL.md` | `.github/skills/<name>/` |
| Subagent with tool restrictions | `.agent.md` | `.github/agents/` |
| Deterministic shell at lifecycle events | `.json` | `.github/hooks/` |

## Where Files Go

All customization files live under `.github/`:

| Directory | File Type | Loaded |
|-----------|-----------|--------|
| `.github/agents/` | `.agent.md` | On demand |
| `.github/hooks/` | `.json` | At lifecycle events |
| `.github/instructions/` | `.instructions.md` | When `applyTo` matches or `description` triggers |
| `.github/prompts/` | `.prompt.md` | On user invocation (`/`) |
| `.github/skills/` | `SKILL.md` | When `description` triggers |
| `.github/workflows/` | `.yml` | By GitHub Actions |

## Writing Guidelines

- **`description` is the discovery surface** — if trigger phrases aren't in the `description` frontmatter, agents won't find the file
- **Link, don't embed** — reference existing docs rather than copying content
- **Quote colons in YAML** — `description: "Use when: doing X"` avoids silent parse failures
- **Scope `applyTo` narrowly** — `"**"` means every file interaction loads the instruction; use specific globs like `**/*.py`
- **Keep AGENTS.md lean** — only universal, every-session content; delegate specifics to instructions/skills

## Common Pitfalls

| Pitfall | Why It Hurts |
|---------|-------------|
| Detailed directory listings in AGENTS.md | Agents discover structure on their own; listings waste context tokens |
| Code style rules in AGENTS.md | Linters/formatters are cheaper and deterministic; agents follow existing patterns |
| Auto-generated AGENTS.md | Reduces task success ~3% and increases cost ~20% (ETH Zurich, 2025) |
| Task-specific instructions in AGENTS.md | Dilutes focus — move to separate docs and reference them |
| Duplicating existing docs | Only hurts when the info is already discoverable elsewhere |
| Vague persona ("helpful coding assistant") | Specificity drives quality — "QA engineer who writes Jest tests" outperforms generic helpers |
| Missing boundaries | Without ✅/⚠️/🚫 guardrails, agents make risky changes (schema edits, secret commits) |

## Custom Agents — Specialists, Not Generalists

Place custom agent files in `.github/agents/<name>.agent.md`. Each agent gets a specific persona, scoped tools, and explicit boundaries. Start with one, iterate.

### Six Agents Worth Building

| Agent | Purpose | Key Boundary |
|-------|---------|-------------|
| `@docs-agent` | Reads code, generates/updates documentation | Writes to `docs/` only, never touches `src/` |
| `@test-agent` | Writes and runs tests | Writes to `tests/` only, never removes failing tests |
| `@lint-agent` | Fixes code style and formatting | Auto-fixes style, never changes logic |
| `@api-agent` | Builds API endpoints | Modifies routes, asks before touching DB schemas |
| `@dev-deploy-agent` | Handles builds and dev deployments | Dev environments only, requires explicit approval |
| `@security-agent` | Reviews code for vulnerabilities | Read-only analysis, never modifies source code |

### Starter Agent Template

Save to `.github/agents/<name>.agent.md`:

```markdown
---
name: your-agent-name
description: "[One-sentence description of what this agent does]"
---

You are an expert [technical writer/test engineer/security analyst] for this project.

## Persona
- You specialize in [writing documentation/creating tests/analyzing logs/building APIs]
- Your output: [API documentation/unit tests/security reports]

## Project Knowledge
- Tech Stack: [your technologies with versions]
- File Structure:
  - `src/` — [what's here]
  - `tests/` — [what's here]

## Tools You Can Use
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint --fix`

## Boundaries
- ✅ **Always:** [what to do — write to specific dirs, run tests, follow conventions]
- ⚠️ **Ask first:** [risky changes — schema edits, new dependencies, CI config]
- 🚫 **Never:** [hard limits — commit secrets, edit vendor dirs, remove failing tests]
```
