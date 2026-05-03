#!/bin/bash
# Scan files for leaked secrets and credentials
# Usage: scan-file.sh <file_path>

set -e

FILE_PATH="$1"

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Exit codes
EXIT_CLEAN=0
EXIT_SECRETS_FOUND=1

# Check if file path was provided
if [ -z "$FILE_PATH" ]; then
    echo -e "${YELLOW}⚠️  No file path provided to secrets scanner${NC}"
    exit $EXIT_CLEAN
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo -e "${YELLOW}⚠️  File not found: $FILE_PATH${NC}"
    exit $EXIT_CLEAN
fi

# Get file extension
FILE_NAME=$(basename "$FILE_PATH")
FILE_EXT="${FILE_PATH##*.}"

# Skip binary and media files
case "$FILE_EXT" in
    jpg|jpeg|png|gif|svg|ico|pdf|zip|tar|gz|exe|bin|so|dylib|woff|woff2|ttf|eot)
        exit $EXIT_CLEAN
        ;;
    lock)
        # Skip lock files (package-lock.json, yarn.lock, etc.)
        exit $EXIT_CLEAN
        ;;
esac

# Skip if file is too large (> 1MB)
FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH" 2>/dev/null || echo 0)
if [ "$FILE_SIZE" -gt 1048576 ]; then
    exit $EXIT_CLEAN
fi

# Check if file is binary
if file "$FILE_PATH" | grep -q "executable\|binary"; then
    exit $EXIT_CLEAN
fi

# Secret patterns to detect
# Format: "PATTERN_NAME|REGEX|SEVERITY"
declare -a PATTERNS=(
    # AWS Credentials
    "AWS_ACCESS_KEY|AKIA[0-9A-Z]{16}|critical"
    "AWS_SECRET_KEY|(aws_secret_access_key|AWS_SECRET_ACCESS_KEY)[^a-zA-Z0-9]['\"]?[A-Za-z0-9/+=]{40}|critical"
    
    # GCP Credentials
    "GCP_API_KEY|AIza[0-9A-Za-z_-]{35}|high"
    "GCP_SERVICE_ACCOUNT|\"type\"[[:space:]]*:[[:space:]]*\"service_account\"|critical"
    
    # Azure Credentials
    "AZURE_CLIENT_SECRET|(client_secret|AZURE_CLIENT_SECRET)[^a-zA-Z0-9]['\"]?[A-Za-z0-9~._-]{34,40}|critical"
    
    # GitHub Tokens
    "GITHUB_PAT|ghp_[a-zA-Z0-9]{36}|critical"
    "GITHUB_OAUTH|gho_[a-zA-Z0-9]{36}|critical"
    "GITHUB_APP_TOKEN|ghu_[a-zA-Z0-9]{36}|critical"
    "GITHUB_REFRESH_TOKEN|ghr_[a-zA-Z0-9]{36}|critical"
    "GITHUB_FINE_GRAINED_PAT|github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}|critical"
    
    # Private Keys
    "RSA_PRIVATE_KEY|BEGIN RSA PRIVATE KEY|critical"
    "EC_PRIVATE_KEY|BEGIN EC PRIVATE KEY|critical"
    "OPENSSH_PRIVATE_KEY|BEGIN OPENSSH PRIVATE KEY|critical"
    "PGP_PRIVATE_KEY|BEGIN PGP PRIVATE KEY BLOCK|critical"
    
    # API Keys and Tokens
    "STRIPE_SECRET_KEY|sk_live_[0-9a-zA-Z]{24,}|critical"
    "SLACK_TOKEN|xox[baprs]-[0-9a-zA-Z]{10,}|high"
    "SLACK_WEBHOOK|https://hooks\.slack\.com/services/T[a-zA-Z0-9_]+/B[a-zA-Z0-9_]+/[a-zA-Z0-9_]+|high"
    "NPM_TOKEN|npm_[a-zA-Z0-9]{36}|high"
    "PYPI_TOKEN|pypi-AgEIcHlwaS5vcmc[A-Za-z0-9_-]{50,}|high"
    
    # Database Connection Strings
    "POSTGRES_URI|postgres(ql)?://[^:]+:[^@]+@[^/[:space:]]+|high"
    "MYSQL_URI|mysql://[^:]+:[^@]+@[^/[:space:]]+|high"
    "MONGODB_URI|mongodb(\+srv)?://[^:]+:[^@]+@[^/[:space:]]+|high"
    "REDIS_URI|redis://[^:]*:[^@]+@[^/[:space:]]+|high"
    
    # Generic Secrets
    "GENERIC_API_KEY|(api_key|apikey|api-key|API_KEY|APIKEY)[^a-zA-Z0-9]['\"]?[A-Za-z0-9_-]{32,}|high"
    "GENERIC_SECRET|(secret|SECRET|password|PASSWORD)[^a-zA-Z0-9]['\"]?[A-Za-z0-9!@#\$%^&*()_+-=]{16,}|medium"
    "BEARER_TOKEN|Bearer[[:space:]]+[A-Za-z0-9_-]{20,}|high"
    "JWT_TOKEN|eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+|medium"
    
    # Private IPs with ports (internal infrastructure)
    "INTERNAL_IP_PORT|(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)[0-9.]+:[0-9]{2,5}|medium"
)

# Placeholder patterns to skip (case-insensitive)
PLACEHOLDERS="example|changeme|your_|<YOUR|<SECRET|TODO|FIXME|dummy|test_key|sample|xxx|yyy|zzz|placeholder"

# Read allowlist from environment
IFS=',' read -ra ALLOWLIST <<< "${SECRETS_ALLOWLIST:-}"

FOUND_SECRETS=0
FINDINGS=()

# Scan the file
while IFS= read -r line || [ -n "$line" ]; do
    LINE_NUM=$((LINE_NUM + 1))
    
    # Skip empty lines and comments
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^[[:space:]]*/[/*] ]]; then
        continue
    fi
    
    # Check each pattern
    for pattern_def in "${PATTERNS[@]}"; do
        IFS='|' read -r pattern_name pattern_regex severity <<< "$pattern_def"
        
        # Try to match the pattern (suppress errors for invalid patterns)
        if echo "$line" | grep -qiE "$pattern_regex" 2>/dev/null; then
            MATCH=$(echo "$line" | grep -oiE "$pattern_regex" 2>/dev/null | head -1)
            
            # Skip if it looks like a placeholder
            if echo "$MATCH" | grep -qiE "$PLACEHOLDERS"; then
                continue
            fi
            
            # Skip if in allowlist
            SKIP=false
            for allowed in "${ALLOWLIST[@]}"; do
                if [[ -n "$allowed" ]] && echo "$MATCH" | grep -qF "$allowed"; then
                    SKIP=true
                    break
                fi
            done
            
            if [ "$SKIP" = true ]; then
                continue
            fi
            
            # Redact the match for display (show first 10 chars + ...)
            REDACTED=$(echo "$MATCH" | cut -c1-10)
            if [ ${#MATCH} -gt 10 ]; then
                REDACTED="${REDACTED}...***"
            fi
            
            FOUND_SECRETS=$((FOUND_SECRETS + 1))
            FINDINGS+=("  Line $LINE_NUM: [$severity] $pattern_name - $REDACTED")
        fi
    done
done < <(cat "$FILE_PATH"; echo)

# Report findings
if [ $FOUND_SECRETS -gt 0 ]; then
    echo -e "${RED}${BOLD}🚨 SECRETS DETECTED in $FILE_PATH${NC}"
    echo ""
    echo -e "${YELLOW}Found $FOUND_SECRETS potential secret(s):${NC}"
    echo ""
    for finding in "${FINDINGS[@]}"; do
        echo -e "$finding"
    done
    echo ""
    echo -e "${RED}❌ Please remove secrets before committing. Use environment variables or secret management services.${NC}"
    echo ""
    
    # Log to file if directory exists
    LOG_DIR="${SECRETS_LOG_DIR:-logs/copilot/secrets}"
    if [ -d "$LOG_DIR" ] || mkdir -p "$LOG_DIR" 2>/dev/null; then
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"secrets_found\",\"file\":\"$FILE_PATH\",\"count\":$FOUND_SECRETS}" >> "$LOG_DIR/scan.log"
    fi
    
    # Check scan mode
    SCAN_MODE="${SCAN_MODE:-block}"
    if [ "$SCAN_MODE" = "block" ]; then
        exit $EXIT_SECRETS_FOUND
    else
        echo -e "${YELLOW}⚠️  Running in warn mode - continuing despite secrets${NC}"
        exit $EXIT_CLEAN
    fi
else
    echo -e "${GREEN}✅ No secrets detected in $FILE_PATH${NC}"
    exit $EXIT_CLEAN
fi
