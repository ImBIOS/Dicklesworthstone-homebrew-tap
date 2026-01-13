#!/usr/bin/env bash
# Set up git pre-commit hooks for formula validation
#
# Usage:
#   ./scripts/setup-hooks.sh
#
# This installs a pre-commit hook that validates formulas before committing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Setting up git hooks for homebrew-tap..."

# Ensure .git/hooks exists
if [[ ! -d "$HOOKS_DIR" ]]; then
    echo "Error: .git/hooks directory not found. Are you in a git repository?"
    exit 1
fi

# Create pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'HOOK'
#!/usr/bin/env bash
# Pre-commit hook to validate Homebrew formulas
# Installed by: ./scripts/setup-hooks.sh

set -euo pipefail

# Get list of staged formula files
staged_formulas=$(git diff --cached --name-only --diff-filter=ACM | grep "^Formula/.*\.rb$" || true)

if [[ -z "$staged_formulas" ]]; then
    # No formula changes, skip validation
    exit 0
fi

echo "Validating staged formulas..."

# Validate each staged formula
for formula_path in $staged_formulas; do
    formula=$(basename "$formula_path" .rb)

    # Skip template
    [[ "$formula" == "TEMPLATE.rb" ]] && continue
    [[ "$formula_path" == *".example"* ]] && continue

    echo "  Checking $formula..."

    # Ruby syntax check
    if ! ruby -c "$formula_path" > /dev/null 2>&1; then
        echo "Error: Ruby syntax error in $formula_path"
        ruby -c "$formula_path" 2>&1
        exit 1
    fi

    # Check for required blocks
    if ! grep -q "desc " "$formula_path"; then
        echo "Error: Missing 'desc' in $formula_path"
        exit 1
    fi

    if ! grep -q "homepage " "$formula_path"; then
        echo "Error: Missing 'homepage' in $formula_path"
        exit 1
    fi

    if ! grep -q "test do" "$formula_path"; then
        echo "Warning: No test block in $formula_path"
    fi
done

echo "All staged formulas validated successfully!"
HOOK

chmod +x "$HOOKS_DIR/pre-commit"

echo -e "${GREEN}Pre-commit hook installed successfully!${NC}"
echo ""
echo "The hook will:"
echo "  - Validate Ruby syntax for staged formulas"
echo "  - Check for required 'desc' and 'homepage' fields"
echo "  - Warn if 'test do' block is missing"
echo ""
echo -e "${YELLOW}To skip the hook (not recommended):${NC}"
echo "  git commit --no-verify"
echo ""
echo "To uninstall:"
echo "  rm $HOOKS_DIR/pre-commit"
