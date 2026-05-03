#!/bin/bash
# Auto-format files with Prettier after agent edits
# Usage: format-file.sh <file_path>

set -e

FILE_PATH="$1"

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if file path was provided
if [ -z "$FILE_PATH" ]; then
    echo -e "${YELLOW}⚠️  No file path provided to Prettier hook${NC}"
    exit 0
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo -e "${YELLOW}⚠️  File not found: $FILE_PATH${NC}"
    exit 0
fi

# Get file extension
FILE_EXT="${FILE_PATH##*.}"

# Skip files that Prettier doesn't typically format
case "$FILE_EXT" in
    jpg|jpeg|png|gif|svg|ico|pdf|zip|tar|gz|exe|bin|so|dylib)
        echo -e "${YELLOW}⏭️  Skipping binary file: $FILE_PATH${NC}"
        exit 0
        ;;
esac

# Check if Prettier is installed
if ! command -v prettier &> /dev/null; then
    echo -e "${YELLOW}⚠️  Prettier not found. Install with: npm install -g prettier${NC}"
    exit 0
fi

# Check if npx is available (prefer npx for local installations)
if command -v npx &> /dev/null; then
    PRETTIER_CMD="npx prettier"
else
    PRETTIER_CMD="prettier"
fi

# Format the file
echo -e "${GREEN}✨ Formatting: $FILE_PATH${NC}"

if $PRETTIER_CMD --write "$FILE_PATH" 2>/dev/null; then
    echo -e "${GREEN}✅ Successfully formatted: $FILE_PATH${NC}"
else
    # If Prettier fails (e.g., parsing error), report but don't fail
    echo -e "${YELLOW}⚠️  Prettier couldn't format $FILE_PATH (may not be a supported file type)${NC}"
    exit 0
fi
