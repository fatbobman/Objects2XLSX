# Git + SwiftFormat Integration

This directory contains scripts and hooks to integrate SwiftFormat with Git operations, ensuring consistent code formatting across the project.

## Setup

### Prerequisites

Install SwiftFormat:

```bash
brew install swiftformat
```

Or download from: <https://github.com/nicklockwood/SwiftFormat>

### Git Hooks

#### Post-Merge Hook

A `post-merge` hook has been installed that automatically runs SwiftFormat after successful pull/merge operations.

**Location**: `.git/hooks/post-merge`

**Behavior**:

- Runs SwiftFormat on `Sources/` and `Tests/` directories
- Shows which files were modified
- Does not automatically commit changes

#### Pre-Push Hook

A `pre-push` hook has been installed that automatically runs SwiftFormat before push operations.

**Location**: `.git/hooks/pre-push`

**Behavior**:

- Runs SwiftFormat on `Sources/` and `Tests/` directories before pushing
- If formatting changes are made, blocks the push and requires committing changes first
- Ensures only properly formatted code reaches the remote repository

#### Custom Pre-Pull Script

For more control, use the custom pre-pull script that runs SwiftFormat before pulling:

```bash
# Direct usage
./scripts/git-pull-with-format.sh

# With git pull arguments
./scripts/git-pull-with-format.sh origin main

# Using the git alias (recommended)
git pullf
git pullf origin main
```

**Features**:

- ✅ Checks for SwiftFormat installation
- ✅ Warns about uncommitted changes
- ✅ Runs SwiftFormat with project configuration
- ✅ Offers multiple options for handling formatting changes:
  1. Commit formatting changes before pull
  2. Stash changes, pull, then reapply
  3. Continue with uncommitted changes
  4. Abort operation

## SwiftFormat Configuration

The project uses a comprehensive SwiftFormat configuration defined in `.swiftformat` at the project root. Key settings include:

- **Indentation**: 4 spaces
- **Line width**: 200 characters
- **Import grouping**: Alphabetical
- **Brace style**: Same-line for closures
- **Documentation**: Before declarations
- **Trailing closures**: Enabled
- **Self removal**: Enabled

## Usage Examples

### Recommended Workflow

1. **Before making changes**:

   ```bash
   git pullf  # Pull with formatting
   ```

2. **Make your code changes**

3. **Before committing**:

   ```bash
   swiftformat Sources Tests  # Format your changes
   git add -A
   git commit -m "your commit message"
   ```

4. **Before pushing**:

   ```bash
   git pullf  # Pull latest changes with formatting
   git push
   ```

### Manual Formatting

Format all Swift files:

```bash
swiftformat Sources Tests
```

Format specific files:

```bash
swiftformat Sources/Objects2XLSX/Sheet/Sheet.swift
```

Check what would be formatted (dry run):

```bash
swiftformat --lint Sources Tests
```

## Integration with IDEs

### Xcode

1. Install SwiftFormat for Xcode extension
2. Enable the extension in System Preferences > Extensions
3. Use ⌘+Shift+F to format current file

### VS Code

1. Install the SwiftFormat extension
2. Configure to format on save in settings.json:

   ```json
   {
     "[swift]": {
       "editor.formatOnSave": true
     }
   }
   ```

## Troubleshooting

### SwiftFormat not found

```bash
# Install via Homebrew
brew install swiftformat

# Or install via Mint
mint install nicklockwood/SwiftFormat
```

### Permission denied

```bash
chmod +x scripts/git-pull-with-format.sh
chmod +x .git/hooks/post-merge
```

### Git alias not working

Re-run the alias setup:

```bash
git config alias.pullf '!./scripts/git-pull-with-format.sh'
```

### Hook not running

Ensure hooks are executable:

```bash
chmod +x .git/hooks/post-merge
```

## Customization

To modify SwiftFormat rules, edit the `.swiftformat` file in the project root. Changes will be automatically picked up by all scripts and hooks.

Common customizations:

- Change indentation: `--indent 2`
- Change line width: `--maxwidth 120`
- Disable specific rules: `--disable trailingCommas`
- Enable specific rules: `--enable isEmpty`
