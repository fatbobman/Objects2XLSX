#!/bin/bash

# Custom git pull script that runs SwiftFormat before pulling
# Usage: ./scripts/git-pull-with-format.sh [git pull arguments]

set -e  # Exit on any error

echo "🔧 Pre-pull SwiftFormat execution..."

# Check if swiftformat is available
if ! command -v swiftformat &> /dev/null; then
    echo "❌ Error: swiftformat not found. Please install it:"
    echo "  brew install swiftformat"
    echo "  or download from: https://github.com/nicklockwood/SwiftFormat"
    exit 1
fi

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "⚠️  Warning: You have uncommitted changes. SwiftFormat will run but may modify your working directory."
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Run SwiftFormat on Sources and Tests directories
echo "📝 Formatting Swift files with project configuration..."
if [ -d "Sources" ]; then
    swiftformat "Sources"
    echo "✅ Formatted Sources directory"
fi

if [ -d "Tests" ]; then
    swiftformat "Tests"
    echo "✅ Formatted Tests directory"
fi

# Check if SwiftFormat made any changes
if ! git diff --quiet; then
    echo ""
    echo "📋 SwiftFormat made changes to the following files:"
    git diff --name-only | sed 's/^/  - /'
    echo ""
    
    # Ask user what to do with the changes
    echo "Choose an action:"
    echo "1) Commit the formatting changes and then pull"
    echo "2) Stash the formatting changes, pull, then reapply"
    echo "3) Continue with pull (leave changes uncommitted)"
    echo "4) Abort"
    
    read -p "Enter your choice (1-4): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            echo "💾 Committing formatting changes..."
            git add -A
            git commit -m "style: Apply SwiftFormat before pull

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
            ;;
        2)
            echo "📦 Stashing formatting changes..."
            git stash push -m "SwiftFormat changes before pull"
            STASH_CREATED=true
            ;;
        3)
            echo "⚠️  Continuing with uncommitted formatting changes..."
            ;;
        4)
            echo "❌ Aborted."
            exit 1
            ;;
        *)
            echo "❌ Invalid choice. Aborted."
            exit 1
            ;;
    esac
else
    echo "✅ No formatting changes needed."
fi

# Execute git pull with any passed arguments
echo ""
echo "🔄 Executing git pull..."
git pull "$@"

# If we stashed changes, reapply them
if [ "${STASH_CREATED:-}" = "true" ]; then
    echo ""
    echo "📤 Reapplying stashed formatting changes..."
    git stash pop
    echo "✅ Formatting changes reapplied"
fi

echo ""
echo "🎉 Pull completed successfully with SwiftFormat integration!"