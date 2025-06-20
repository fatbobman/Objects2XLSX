#!/bin/bash

# Test script for Git hooks and SwiftFormat integration

echo "🧪 Testing Git + SwiftFormat Integration"
echo "========================================"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check SwiftFormat installation
echo "1. Checking SwiftFormat installation..."
if command -v swiftformat &> /dev/null; then
    echo "✅ SwiftFormat found: $(swiftformat --version)"
else
    echo "❌ SwiftFormat not found. Install with: brew install swiftformat"
    exit 1
fi

# Check if .swiftformat config exists
echo ""
echo "2. Checking SwiftFormat configuration..."
if [ -f ".swiftformat" ]; then
    echo "✅ SwiftFormat configuration found"
    echo "   Config file: .swiftformat"
else
    echo "❌ SwiftFormat configuration not found"
    exit 1
fi

# Check git hooks
echo ""
echo "3. Checking Git hooks..."
if [ -f ".git/hooks/post-merge" ] && [ -x ".git/hooks/post-merge" ]; then
    echo "✅ Post-merge hook installed and executable"
else
    echo "❌ Post-merge hook missing or not executable"
fi

if [ -f ".git/hooks/pre-push" ] && [ -x ".git/hooks/pre-push" ]; then
    echo "✅ Pre-push hook installed and executable"
else
    echo "❌ Pre-push hook missing or not executable"
fi

# Check custom scripts
echo ""
echo "4. Checking custom scripts..."
if [ -f "scripts/git-pull-with-format.sh" ] && [ -x "scripts/git-pull-with-format.sh" ]; then
    echo "✅ Custom pull script found and executable"
else
    echo "❌ Custom pull script missing or not executable"
fi

# Check git alias
echo ""
echo "5. Checking Git alias..."
if git config --get alias.pullf > /dev/null; then
    echo "✅ Git alias 'pullf' configured"
    echo "   Command: $(git config --get alias.pullf)"
else
    echo "❌ Git alias 'pullf' not configured"
    echo "   Run: git config alias.pullf '!./scripts/git-pull-with-format.sh'"
fi

# Test SwiftFormat on a few files
echo ""
echo "6. Testing SwiftFormat on project files..."
FORMAT_NEEDED=false
for file in "Sources/Objects2XLSX/Sheet/Sheet.swift" "Sources/Objects2XLSX/Sheet/AnySheet.swift"; do
    if [ -f "$file" ]; then
        if ! swiftformat --lint "$file" &> /dev/null; then
            echo "⚠️  $file needs formatting"
            FORMAT_NEEDED=true
        else
            echo "✅ $file is properly formatted"
        fi
    else
        echo "❓ $file not found"
    fi
done

if [ "$FORMAT_NEEDED" = true ]; then
    echo ""
    echo "🔧 Some files need formatting. Run one of:"
    echo "   swiftformat Sources Tests"
    echo "   ./scripts/git-pull-with-format.sh"
    echo "   git pullf"
fi

echo ""
echo "🎉 Git + SwiftFormat integration test completed!"
echo ""
echo "Usage:"
echo "  git pullf                    # Pull with pre-formatting"
echo "  swiftformat Sources Tests    # Manual formatting"
echo "  swiftformat --lint Sources   # Check formatting (dry run)"