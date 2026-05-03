---
description: "Ensure shields.io badges are present in markdown documentation files. Use when: creating markdown, updating documentation, adding README, writing docs, documentation without badges, missing badges."
---

# Shields.io Badge Requirements

All markdown files must include shields.io badges using the two-tier badge approach. When creating or updating markdown files, automatically add appropriate badges if they are missing.

## Scope

**Automatically add badges to:**
- Root-level markdown files (README.md, AGENTS.md, etc.)
- Documentation in `docs/` directory
- Project documentation files throughout the repository

**Skip badge additions for:**
- Files in `.github/` and its subdirectories (agent customization files)
- Files in `.specify/` and its subdirectories (Specify configuration)
- Template files (e.g., `.github/ISSUE_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE.md`)

## Top-Level Badge Requirements (README.md and root-level docs)

Place immediately after the H1 heading:

1. **License badge** — `[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)`
2. **Social badges** — Stars and forks with `?style=social`:
   - Stars: `[![GitHub stars](https://img.shields.io/github/stars/pkumar26/{REPO}?style=social)](https://github.com/pkumar26/{REPO}/stargazers)`
   - Forks: `[![GitHub forks](https://img.shields.io/github/forks/pkumar26/{REPO}?style=social)](https://github.com/pkumar26/{REPO}/network/members)`
3. **Repo stats** (flat style, no `?style=` parameter):
   - Issues: `[![GitHub issues](https://img.shields.io/github/issues/pkumar26/{REPO})](https://github.com/pkumar26/{REPO}/issues)`
   - Last commit: `[![GitHub last commit](https://img.shields.io/github/last-commit/pkumar26/{REPO})](https://github.com/pkumar26/{REPO}/commits/main)`
   - Repo size: `[![Repo size](https://img.shields.io/github/repo-size/pkumar26/{REPO})](https://github.com/pkumar26/{REPO})`

Replace `{REPO}` with the actual repository name (e.g., `codebase_setup`).

## Section-Specific Badge Requirements (docs/ and other documentation)

Add contextual badges that match the document's content:

- **Technology badges** — Use `logo=` parameter for recognizable icons:
  - TypeScript: `![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?logo=typescript&logoColor=white)`
  - Python: `![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)`
  - Docker: `![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)`
  - Kubernetes: `![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)`
  - Node.js: `![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)`
  - Azure: `![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoft-azure&logoColor=white)`
  - React: `![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)`
  - JavaScript: `![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=black)`

- **Status badges** — Documentation status, maintenance level:
  - `![Status](https://img.shields.io/badge/Status-Active-green)`
  - `![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen)`
  - `![Deprecated](https://img.shields.io/badge/Status-Deprecated-red)`

- **Purpose badges** — Guide type, documentation category:
  - `![Guide](https://img.shields.io/badge/Type-Guide-blue)`
  - `![Reference](https://img.shields.io/badge/Type-Reference-orange)`
  - `![Tutorial](https://img.shields.io/badge/Type-Tutorial-purple)`
  - `![API](https://img.shields.io/badge/Type-API-yellow)`

Place these badges near the top of the document (after H1) or at the start of relevant sections.

## Badge Style Rules

1. **Social style** — Only for stars and forks: `?style=social`
2. **Flat style (default)** — All other badges use flat style (no `?style=` parameter)
3. **Linked badges** — Make badges clickable by wrapping in markdown links to relevant GitHub pages
4. **Logo parameter** — Use `logo=<name>` for technology badges to show recognizable icons
5. **Consistency** — Match badge style with existing badges in the same file

## Examples

### Root README.md
```markdown
# Project Name

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/pkumar26/repo?style=social)](https://github.com/pkumar26/repo/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/pkumar26/repo?style=social)](https://github.com/pkumar26/repo/network/members)
[![GitHub issues](https://img.shields.io/github/issues/pkumar26/repo)](https://github.com/pkumar26/repo/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/pkumar26/repo)](https://github.com/pkumar26/repo/commits/main)
[![Repo size](https://img.shields.io/github/repo-size/pkumar26/repo)](https://github.com/pkumar26/repo)

Project description...
```

### docs/setup.md
```markdown
# Setup Guide

![Status](https://img.shields.io/badge/Status-Active-green)
![Guide](https://img.shields.io/badge/Type-Guide-blue)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)

Installation instructions...
```

### docs/api-reference.md
```markdown
# API Reference

![Reference](https://img.shields.io/badge/Type-Reference-orange)
![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?logo=typescript&logoColor=white)

API documentation...
```

## Guidance for Agents

When working with markdown files:

- ✅ **Always add badges automatically** for new or updated documentation files in `docs/`, root-level docs, or project documentation
- ✅ **Add appropriate badges** based on file location (root vs nested) and content (technologies, status, purpose)
- ✅ **Use shields.io** — all badges must use https://img.shields.io/
- ✅ **Make badges clickable** by linking to relevant GitHub pages (issues, stargazers, commits, etc.)
- ✅ **Place badges correctly** — immediately after H1 heading, before any other content
- ✅ **Infer context** — analyze file content to determine which technology/purpose badges apply
- ⚠️ **Skip files** in `.github/` and `.specify/` directories and their subdirectories
- ⚠️ **Preserve existing badges** — if badges are already present, verify they match the standard and update if needed
- 🚫 **Never remove badges** without replacing them with correct ones
- 🚫 **Never add badges** to template files or agent customization files
