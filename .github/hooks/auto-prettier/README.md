# Auto-Prettier Hook

Automatically runs Prettier on files after the coding agent edits them, ensuring consistent code formatting across the entire project.

## What It Does

This PostToolUse hook triggers after the agent uses file editing tools and automatically formats the modified files with Prettier.

**Triggers after:**
- `replace_string_in_file`
- `multi_replace_string_in_file`
- `create_file`
- `edit_notebook_file`

## How It Works

1. Agent edits a file using one of the supported tools
2. Hook detects the file modification
3. Runs Prettier on the edited file
4. Reports success or skips gracefully if Prettier isn't available

## Features

- ✅ **Smart skipping**: Automatically skips binary files and unsupported file types
- ✅ **Graceful degradation**: Continues even if Prettier isn't installed
- ✅ **User-friendly output**: Clear colored messages about what's being formatted
- ✅ **Error-tolerant**: Won't break agent workflows if formatting fails
- ✅ **Works with local or global Prettier**: Uses `npx` if available for local installations

## Setup

### Install Prettier

**Globally:**
```bash
npm install -g prettier
```

**Locally (recommended):**
```bash
npm install --save-dev prettier
```

### Configure Prettier (Optional)

Create a `.prettierrc` in your project root:

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

### Enable/Disable the Hook

The hook is enabled by default. To disable it, edit `.github/hooks/auto-prettier.json`:

```json
{
  "enabled": false
}
```

## File Structure

```
.github/hooks/
├── auto-prettier.json          # Hook configuration
└── auto-prettier/
    ├── format-file.sh          # Formatting script
    └── README.md               # This file
```

## Customization

### Skip Specific File Types

Edit `format-file.sh` and add extensions to the skip list:

```bash
case "$FILE_EXT" in
    jpg|jpeg|png|gif|svg|ico|pdf|lock|min.js)
        echo -e "${YELLOW}⏭️  Skipping: $FILE_PATH${NC}"
        exit 0
        ;;
esac
```

### Change Prettier Command

Modify the `PRETTIER_CMD` in `format-file.sh`:

```bash
# Example: use a specific config file
PRETTIER_CMD="prettier --config .prettierrc.custom"
```

## Troubleshooting

**Hook doesn't run:**
- Check that the hook JSON is valid
- Verify `format-file.sh` is executable: `chmod +x .github/hooks/auto-prettier/format-file.sh`

**Prettier errors:**
- Ensure Prettier is installed: `prettier --version`
- Check your `.prettierrc` configuration is valid
- Some files may not be supported by Prettier (e.g., binary files, custom formats)

**Too verbose:**
- Set `"silent": true` in `auto-prettier.json` to hide output
- Edit `format-file.sh` to reduce echo statements
