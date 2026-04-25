# Agent Instructions

## What This Is

A starter template for setting up AI coding agent customization files (agents, instructions, prompts, skills, hooks) in any project. All customization files live under `.github/`. Documentation lives in `docs/`.

**License:** MIT · **Owner:** pkumar26

## How to Validate

No build or test commands — documentation-only template. To verify customization files:

1. Check YAML frontmatter parses correctly (no tabs, colons are quoted)
2. Confirm `description` fields contain relevant trigger keywords
3. Confirm files are in the expected `.github/` subdirectory

## Key Docs

- [docs/customization-guide.md](docs/customization-guide.md) — which primitive to use, where files go, writing guidelines, and common pitfalls

---

## Writing Guide — WHAT, WHY, HOW

When adapting this template for your project, replace the sections above with your own content following the patterns below. Every line goes into every agent session — make each one count.

### The WHAT — Tech stack, structure, components

> Tell the agent what it's working with. Critical for monorepos — name the apps, shared packages, and services.

```markdown
## What This Is

A Next.js 14 + FastAPI monorepo for an e-commerce platform.

- `apps/web/` — Next.js storefront (App Router, TypeScript, Tailwind)
- `apps/api/` — FastAPI backend (Python 3.12, SQLAlchemy, Postgres)
- `packages/shared/` — Shared TypeScript types and validation schemas
- `infra/` — Terraform modules for AWS (ECS, RDS, CloudFront)
```

### The WHY — Purpose and intent behind key decisions

> Help the agent understand *why* things are the way they are, not just *what* they are.

```markdown
## Key Decisions

- We use server components by default; client components only when interactivity is required
- API uses repository pattern — all DB access goes through `app/repositories/`, never direct queries in routes
- Feature flags live in `packages/shared/flags.ts` — check there before adding conditional logic
- We chose SQLAlchemy over Django ORM because the API is standalone, not a Django project
```

### The HOW — Build, test, verify

> Include non-obvious tooling. Tools mentioned here get used **160× more often** than unmentioned ones.

```markdown
## Build & Test

- **Package manager:** `pnpm` (not npm/yarn) — `pnpm install` at root
- **Python env:** `uv` (not pip) — `uv sync` in `apps/api/`
- **Run frontend:** `pnpm --filter web dev`
- **Run API:** `uv run fastapi dev` in `apps/api/`
- **Tests:** `pnpm --filter web test` and `uv run pytest` in `apps/api/`
- **Lint:** `pnpm lint` at root (runs Biome for TS, Ruff for Python)
- **Before committing:** run `pnpm lint && pnpm --filter web test && cd apps/api && uv run pytest`
```

### Boundaries — What the agent can and cannot do

> Set explicit guardrails using the ✅/⚠️/🚫 pattern. Agents respect boundaries — that's precisely why vague ones cause problems.

```markdown
## Boundaries

- ✅ **Always:** Write to `src/` and `tests/`, run tests before commits, follow naming conventions
- ⚠️ **Ask first:** Database schema changes, adding dependencies, modifying CI/CD config
- 🚫 **Never:** Commit secrets or API keys, edit `node_modules/` or `vendor/`, remove failing tests
```

### Iteration — Start simple, refine over time

> Don't try to write the perfect AGENTS.md upfront. The best agent files grow through iteration, not planning.

1. Start with just WHAT + HOW + Boundaries
2. Run the agent on real tasks
3. When it makes a mistake, add a line to prevent it
4. Review quarterly — remove lines that no longer apply