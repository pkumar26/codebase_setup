---
name: 'Secrets Scanner'
description: 'Scans files modified during a Copilot coding agent session for leaked secrets, credentials, and sensitive data'
tags: ['security', 'secrets', 'scanning', 'session-end']
---

# Secrets Scanner Hook

Scans files modified during a GitHub Copilot coding agent session for accidentally leaked secrets, credentials, API keys, and other sensitive data before they are committed.

## Overview

AI coding agents generate and modify code rapidly, which increases the risk of hardcoded secrets slipping into the codebase. This hook acts as a safety net by scanning files immediately after the agent edits them for 25+ categories of secret patterns, including:

- **Cloud credentials**: AWS access keys, GCP service account keys, Azure client secrets
- **Platform tokens**: GitHub PATs, npm tokens, Slack tokens, Stripe keys
- **Private keys**: RSA, EC, OpenSSH, PGP, DSA private key blocks
- **Connection strings**: Database URIs (PostgreSQL, MongoDB, MySQL, Redis, MSSQL)
- **Generic secrets**: API keys, passwords, bearer tokens, JWTs
- **Internal infrastructure**: Private IP addresses with ports

## Features

- **Real-time scanning**: Scans files immediately after agent edits them (PostToolUse event)
- **Two scan modes**: `block` (default, prevents commit) or `warn` (log only)
- **Smart filtering**: Skips binary files, lock files, large files, and placeholder/example values
- **Allowlist support**: Exclude known false positives via `SECRETS_ALLOWLIST`
- **Structured logging**: JSON Lines output for integration with monitoring tools
- **Redacted output**: Findings are truncated in display to avoid re-exposing secrets
- **Zero dependencies**: Uses only standard Unix tools (`grep`, `file`, `stat`)

## Installation

1. Copy the hook folder to your repository:

   ```bash
   cp -r hooks/secrets-scanner .github/hooks/
   ```

2. Ensure the script is executable:

   ```bash
   chmod +x .github/hooks/secrets-scanner/scan-secrets.sh
   ```

3. Create the logs directory and add it to `.gitignore`:

   ```bash
   mkdir -p logs/copilot/secrets
   echo "logs/" >> .gitignore
   ```

4. Commit the hook configuration to your repository's default branch.

## Configuration

The hook is configured in `.github/hooks/secrets-scanner.json` to run on the `PostToolUse` event:

```json
{
  "name": "secrets-scanner",
  "description": "Scan files for leaked secrets, credentials, and sensitive data after agent edits",
  "event": "PostToolUse",
  "enabled": true,
  "condition": {
    "tools": [
      "replace_string_in_file",
      "multi_replace_string_in_file",
      "create_file"
    ]
  },
  "action": {
    "type": "shell",
    "script": ".github/hooks/secrets-scanner/scan-file.sh",
    "args": ["{{filePath}}"],
    "silent": false,
    "continueOnError": false
  },
  "userMessage": "🔒 Scanning for secrets in edited file..."
}
```

### Environment Variables

| Variable | Values | Default | Description |
|----------|--------|---------|-------------|
| `SCAN_MODE` | `warn`, `block` | `block` | `block` exits non-zero to stop workflow; `warn` logs findings only |
| `SECRETS_LOG_DIR` | path | `logs/copilot/secrets` | Directory where scan logs are written |
| `SECRETS_ALLOWLIST` | comma-separated | unset | Patterns to ignore (e.g., `test_key_123,example.com`) |

## How It Works

1. Agent edits a file using `replace_string_in_file`, `multi_replace_string_in_file`, or `create_file`
2. Hook is triggered automatically on the PostToolUse event
3. Receives the file path from the tool execution context
4. Filters out binary files, lock files, and files > 1MB
5. Scans the file line-by-line against 25+ regex patterns for known secret formats
6. Skips matches that look like placeholders (e.g., values containing `example`, `changeme`, `your_`)
7. Checks matches against the allowlist if configured
8. Reports findings with line number, pattern name, severity, and redacted match
9. Writes a structured JSON log entry for audit purposes
10. In `block` mode (default), exits non-zero to stop the workflow; in `warn` mode, continues

## Detected Secret Patterns

| Pattern | Severity | Example Match |
|---------|----------|---------------|
| `AWS_ACCESS_KEY` | critical | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_KEY` | critical | `aws_secret_access_key = wJalr...` |
| `GCP_SERVICE_ACCOUNT` | critical | `"type": "service_account"` |
| `GCP_API_KEY` | high | `AIzaSyC...` |
| `AZURE_CLIENT_SECRET` | critical | `azure_client_secret = ...` |
| `GITHUB_PAT` | critical | `ghp_xxxxxxxxxxxx...` |
| `GITHUB_FINE_GRAINED_PAT` | critical | `github_pat_...` |
| `GITHUB_OAUTH` | critical | `gho_xxxxxxxxxxxx...` |
| `GITHUB_APP_TOKEN` | critical | `ghu_xxxxxxxxxxxx...` |
| `GITHUB_REFRESH_TOKEN` | critical | `ghr_xxxxxxxxxxxx...` |
| `RSA_PRIVATE_KEY` | critical | `-----BEGIN RSA PRIVATE KEY-----` |
| `EC_PRIVATE_KEY` | critical | `-----BEGIN EC PRIVATE KEY-----` |
| `OPENSSH_PRIVATE_KEY` | critical | `-----BEGIN OPENSSH PRIVATE KEY-----` |
| `PYPI_TOKEN` | high | `pypi-AgEI...` |
| `POSTGRES_URI` | high | `postgres://user:pass@host/db` |
| `MYSQL_URI` | high | `mysql://user:pass@host/db` |
| `MONGODB_URI` | high | `mongodb://user:pass@host/db` |
| `REDIS_URI` | high | `redis://:pass@host/db` |
| `JWT_TOKEN` | medium | `eyJhbGci...` |
| `INTERNAL_IP_PORT` | medium | `192.168.1.1:8080` |

See the full list in `scan-file` |
| `STRIPE_SECRET_KEY` | critical | `sk_live_...` |
| `NPM_TOKEN` | high | `npm_...` |
| `JWT_TOKEN` | medium | `eyJhbGci...` |
| `INTERNAL_IP_PORT` | medium | `192.168.1.1:8080` |

See the full list in `scan-secrets.sh`.

✅ No secrets detected in src/config.ts
### Clean scan

```
🔍 Scanning 5 modified file(s) for secrets...
✅ No secrets detected in 5 scanned file(s)
```

### Findings detected (warn mode)

```
� SECRETS DETECTED in src/config.ts

Found 1 potential secret(s):

  Line 12: [critical] GITHUB_PAT - ghp_abc123...***

❌ Please remove secrets before committing. Use environment variables or secret management services.

⚠️  Running in warn mode - continuing despite secrets
```

### Findings detected (block mode)

```
🔍 Scanning 3 modified file(s) for secrets...
� SECRETS DETECTED in lib/auth.py

Found 2 potential secret(s):

  Line 45: [critical] AWS_ACCESS_KEY - AKIAIOSFOD...***
  Line 46: [critical] AWS_SECRET_KEY - aws_secret...***

❌ Please remove secrets before committing. Use environment variables or secret management services.

[Hook exits with code 1, stopping the agent workflow]

## Log Format

Scan events are written to `logs/copilot/secrets/scan.log` in JSON Lines format:

```json
{"timestamp":"2026-05-02T21:30:00Z","event":"secrets_found","file":"src/config.ts","count":1}
```

## Pairing with Other Hooks

This hook pairs well with the **Session Auto-Commit** hook. When both are installed, order them so that `secrets-scanner` runs first:

1. Secrets scanner runs at `sessionEnd`, catches leaked secrets
2. Auto-commit runs at `sessionEnd`, only commits if all previous hooks pass
other PostToolUse hooks like **auto-prettier**. They run in sequence after each file edit. Since `secrets-scanner` has `continueOnError: false`, it will stop the workflow if secrets are found in block mode, preventing formatters from running on files with secretssh` to add project-specific secret formats
- **Adjust sensitivity**: Change severity levels or remove patterns that generate false positives
- **Allowlist known values**: Use `SECRETS_ALLOWLIST` for test fixtures or known safe patterns
- **Change log location**: Set `SECRETS_LOG_DIR` to route logs to your preferred directory

## Disabling

To temporarily disable the scanner:

- Set `SKIP_SECRETS_SCAN=true` in the hook environmentfile.sh` to add project-specific secret formats
- **Adjust sensitivity**: Change severity levels or remove patterns that generate false positives
- **Allowlist known values**: Use `SECRETS_ALLOWLIST` for test fixtures or known safe patterns
- **Change log location**: Set `SECRETS_LOG_DIR` to route logs to your preferred directory

## Disabling

To disable the scanner, edit `.github/hooks/secrets-scanner.json`:

```json
{
  "enabled": false
}
``