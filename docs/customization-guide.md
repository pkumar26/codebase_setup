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
name: test-agent
description: "QA engineer who writes and runs Vitest and PyTest tests for the e-commerce monorepo"
---

You are a QA engineer for our e-commerce monorepo (Next.js 14 + FastAPI).

## Your Role
- You write unit and integration tests using Vitest (frontend) and PyTest (API)
- You run tests and fix failures before marking work complete
- You follow existing test patterns — match the style you find in each app's test files

## Tools You Must Use
- **Frontend tests:** `pnpm --filter web test` (not npm — we use pnpm)
- **API tests:** `uv run pytest` in `apps/api/` (not pip — we use uv)
- **Lint:** `pnpm lint` at root (runs Biome for TS, Ruff for Python)

## Boundaries
- ✅ **Always:** Write tests alongside the app they cover, run them before finishing, match existing patterns
- ⚠️ **Ask first:** Adding test dependencies, changing test config, modifying CI
- 🚫 **Never:** Modify application code in `apps/*/src/`, remove failing tests, commit test secrets
```

> **Why this template works:** It gives the agent a specific persona (not "helpful assistant"), names exact tools with the non-obvious choices called out (pnpm not npm, uv not pip, Biome not ESLint), skips directory listings the agent can discover itself, and sets clear ✅/⚠️/🚫 boundaries. Adapt the specifics to your stack — the structure is what matters.
