#!/usr/bin/env bash
# Test a single Homebrew formula locally with detailed logging
#
# Usage:
#   ./scripts/test-formula.sh <formula-name>
#   LOG_DIR=/tmp/my-logs ./scripts/test-formula.sh bv
#
# Example:
#   ./scripts/test-formula.sh ru        # Test the ru formula
#   ./scripts/test-formula.sh --all     # Test all formulas

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="${LOG_DIR:-/tmp/formula-tests}"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    local timestamp
    timestamp="$(date +%H:%M:%S)"
    echo -e "${BLUE}[$timestamp]${NC} $*"
    echo "[$timestamp] $*" >> "$LOG_FILE"
}

log_success() {
    local timestamp
    timestamp="$(date +%H:%M:%S)"
    echo -e "${BLUE}[$timestamp]${NC} ${GREEN}$*${NC}"
    echo "[$timestamp] SUCCESS: $*" >> "$LOG_FILE"
}

log_error() {
    local timestamp
    timestamp="$(date +%H:%M:%S)"
    echo -e "${BLUE}[$timestamp]${NC} ${RED}$*${NC}"
    echo "[$timestamp] ERROR: $*" >> "$LOG_FILE"
}

log_warn() {
    local timestamp
    timestamp="$(date +%H:%M:%S)"
    echo -e "${BLUE}[$timestamp]${NC} ${YELLOW}$*${NC}"
    echo "[$timestamp] WARNING: $*" >> "$LOG_FILE"
}

test_formula() {
    local formula="$1"
    local formula_path="$REPO_ROOT/Formula/${formula}.rb"

    if [[ ! -f "$formula_path" ]]; then
        echo "Formula not found: $formula_path"
        return 1
    fi

    LOG_FILE="$LOG_DIR/${formula}.log"
    mkdir -p "$LOG_DIR"
    : > "$LOG_FILE"  # Clear log file

    echo ""
    echo "========================================"
    log "=== Testing formula: $formula ==="
    echo "========================================"

    # System info
    log "Platform: $(uname -sm)"
    log "OS: $(sw_vers -productVersion 2>/dev/null || lsb_release -d 2>/dev/null | cut -f2 || uname -o)"
    log "Homebrew: $(brew --version | head -1)"
    log "Formula path: $formula_path"
    log "Log file: $LOG_FILE"
    echo ""

    # Step 1: Syntax check
    log "--- Step 1: Syntax check ---"
    if ruby -c "$formula_path" >> "$LOG_FILE" 2>&1; then
        log_success "Ruby syntax OK"
    else
        log_error "Ruby syntax error in $formula_path"
        return 1
    fi

    # Step 2: Audit
    log "--- Step 2: brew audit --strict ---"
    if brew audit --strict "$formula_path" >> "$LOG_FILE" 2>&1; then
        log_success "Audit passed"
    else
        log_error "Audit failed - check $LOG_FILE for details"
        return 1
    fi

    # Step 3: Install
    log "--- Step 3: brew install --verbose ---"
    if brew install --verbose "$formula_path" >> "$LOG_FILE" 2>&1; then
        log_success "Install succeeded"
    else
        log_error "Install failed - check $LOG_FILE for details"
        return 1
    fi

    # Step 4: Verify installation
    log "--- Step 4: Verify installation ---"
    local bin_path
    bin_path="$(brew --prefix)/bin/$formula"
    if [[ -x "$bin_path" ]]; then
        log_success "Binary exists: $bin_path"
    else
        log_warn "Binary not found at expected path: $bin_path"
    fi

    # Step 5: Version check
    log "--- Step 5: Version check ---"
    if "$formula" --version >> "$LOG_FILE" 2>&1; then
        log_success "Version: $("$formula" --version 2>&1 | head -1)"
    elif "$formula" version >> "$LOG_FILE" 2>&1; then
        log_success "Version: $("$formula" version 2>&1 | head -1)"
    else
        log_warn "No version command available"
    fi

    # Step 6: Smoke test (if defined in formula)
    log "--- Step 6: brew test ---"
    if brew test "$formula_path" >> "$LOG_FILE" 2>&1; then
        log_success "Smoke test passed"
    else
        log_warn "Smoke test failed or not defined (non-fatal)"
    fi

    # Step 7: Uninstall
    log "--- Step 7: brew uninstall ---"
    if brew uninstall "$formula" >> "$LOG_FILE" 2>&1; then
        log_success "Uninstall succeeded"
    else
        log_error "Uninstall failed"
        return 1
    fi

    echo ""
    log_success "=== All tests passed for $formula ==="
    log "Full log: $LOG_FILE"
    echo ""
    return 0
}

test_all_formulas() {
    local failed=0
    local passed=0
    local skipped=0

    shopt -s nullglob
    local formulas=("$REPO_ROOT"/Formula/*.rb)

    if [[ ${#formulas[@]} -eq 0 ]]; then
        echo "No formulas found in $REPO_ROOT/Formula/"
        return 0
    fi

    for formula_path in "${formulas[@]}"; do
        local name
        name=$(basename "$formula_path" .rb)

        # Skip .gitkeep
        [[ "$name" == ".gitkeep" ]] && continue

        if test_formula "$name"; then
            ((passed++))
        else
            ((failed++))
        fi
    done

    echo ""
    echo "========================================"
    echo "Summary: $passed passed, $failed failed, $skipped skipped"
    echo "========================================"

    return $failed
}

# Main
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 <formula-name>"
        echo "       $0 --all"
        echo ""
        echo "Test Homebrew formulas locally with detailed logging."
        echo ""
        echo "Options:"
        echo "  <formula-name>  Test a specific formula (e.g., 'ru', 'bv')"
        echo "  --all           Test all formulas in Formula/"
        echo "  --help, -h      Show this help message"
        echo ""
        echo "Environment variables:"
        echo "  LOG_DIR         Directory for log files (default: /tmp/formula-tests)"
        ;;
    --all)
        test_all_formulas
        ;;
    "")
        echo "Error: No formula specified"
        echo "Usage: $0 <formula-name>"
        exit 1
        ;;
    *)
        test_formula "$1"
        ;;
esac
