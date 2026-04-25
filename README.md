# Codebase Setup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/pkumar26/codebase_setup?style=social)](https://github.com/pkumar26/codebase_setup/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/pkumar26/codebase_setup?style=social)](https://github.com/pkumar26/codebase_setup/network/members)
[![GitHub issues](https://img.shields.io/github/issues/pkumar26/codebase_setup)](https://github.com/pkumar26/codebase_setup/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/pkumar26/codebase_setup)](https://github.com/pkumar26/codebase_setup/commits/main)
[![Repo size](https://img.shields.io/github/repo-size/pkumar26/codebase_setup)](https://github.com/pkumar26/codebase_setup)

A starter template that provides the directory structure and conventions for setting up **AI coding agent customization files** in any project. Drop this structure into your repo to configure GitHub Copilot agents, instructions, prompts, skills, and hooks.

## Quick Start

1. Clone or copy this repo's `.github/` directory into your project
2. Edit [`AGENTS.md`](AGENTS.md) with your project-specific conventions
3. Add customization files to the appropriate subdirectories

## Structure

| Directory | Purpose | File Type |
|-----------|---------|-----------|
| `.github/agents/` | Custom agent definitions | `.agent.md` |
| `.github/hooks/` | Lifecycle hooks (PreToolUse, PostToolUse) | `.json` |
| `.github/instructions/` | File-scoped instructions | `.instructions.md` |
| `.github/prompts/` | Reusable prompt templates | `.prompt.md` |
| `.github/skills/` | On-demand skills with bundled assets | `SKILL.md` |
| `.github/workflows/` | GitHub Actions CI/CD | `.yml` |

See [`AGENTS.md`](AGENTS.md) for detailed conventions and writing guidelines.

## License

[MIT](LICENSE)