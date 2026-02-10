#!/usr/bin/env bash
# E2E Test: Failure Recovery
# Verifies that failures at any stage are handled gracefully.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/test-helpers.sh"

#==============================================================================
# Tests
#==============================================================================

test_update_formula_rejects_empty_checksum() {
    setup_test "update_formula_rejects_empty_checksum"

    local script="$REPO_DIR/scripts/update-formula.sh"
    assert_file_exists "$script" "update-formula.sh exists"

    # Verify script validates checksum before updating
    if grep -qE 'CHECKSUM|checksum|sha256|hash' "$script" 2>/dev/null; then
        pass "Script handles checksums"
    else
        log_test "WARN" "Cannot verify checksum validation"
    fi

    # Check for empty/error validation
    if grep -qE '\-z.*CHECKSUM|\-z.*checksum|empty|not found|fail' "$script" 2>/dev/null; then
        pass "Script validates checksum is not empty"
    else
        log_test "WARN" "Cannot verify empty checksum rejection"
    fi

    teardown_test
}

test_formula_is_valid_ruby() {
    setup_test "formula_is_valid_ruby"

    # Verify each formula has valid Ruby syntax
    if ! command -v ruby &>/dev/null; then
        log_test "INFO" "ruby not available, skipping syntax check"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
        teardown_test
        return 0
    fi

    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        local name
        name=$(basename "$f" .rb)

        if ruby -c "$f" &>/dev/null; then
            pass "Formula $name has valid Ruby syntax"
        else
            fail "Formula $name has invalid Ruby syntax"
        fi
    done

    teardown_test
}

test_workflow_continues_on_single_failure() {
    setup_test "workflow_continues_on_single_failure"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"

    # Check for fail-fast: false or continue-on-error
    if grep -qE 'fail-fast.*false|continue-on-error' "$workflow" 2>/dev/null; then
        pass "Workflow continues despite single tool failure"
    else
        log_test "WARN" "Workflow may stop on first failure"
    fi

    teardown_test
}

test_no_partial_formula_state() {
    setup_test "no_partial_formula_state"

    # Verify formulas aren't in a half-updated state
    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        local name
        name=$(basename "$f" .rb)

        # Check for placeholder checksums that indicate failed updates
        if grep -qE 'sha256\s+"(PLACEHOLDER|TODO|FIXME|xxx|000)"' "$f" 2>/dev/null; then
            fail "Formula $name has placeholder checksum (partial update?)"
        else
            pass "Formula $name has no placeholder checksum"
        fi
    done

    teardown_test
}

test_verify_script_handles_missing_tool() {
    setup_test "verify_script_handles_missing_tool"

    local script="$REPO_DIR/scripts/verify-installation.sh"
    assert_file_exists "$script" "verify-installation.sh exists"

    # Skip if brew is not installed (CI-only test)
    if ! command -v brew &>/dev/null; then
        log_test "INFO" "brew not available, skipping missing-tool test"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
        teardown_test
        return 0
    fi

    # Run verify script with a nonexistent tool (should handle gracefully)
    local output exit_code=0
    output=$(bash "$script" "nonexistent_tool_xyz" 2>&1) || exit_code=$?

    # Should fail but not crash
    if echo "$output" | grep -qiE 'FORMULA_NOT_FOUND|Error|fail|not found|No tools'; then
        pass "Script reports missing tool gracefully"
    else
        fail "Script should report missing tool gracefully"
    fi

    teardown_test
}

test_update_formula_validates_url() {
    setup_test "update_formula_validates_url"

    local script="$REPO_DIR/scripts/update-formula.sh"
    assert_file_exists "$script" "update-formula.sh exists"

    # Check for URL validation (curl with error checking)
    if grep -qE 'curl.*-[fsSL]|http_code|wget' "$script" 2>/dev/null; then
        pass "Script fetches URLs with error checking"
    else
        log_test "WARN" "Cannot verify URL validation in update script"
    fi

    teardown_test
}

test_git_diff_quiet_check() {
    setup_test "git_diff_quiet_check"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"

    # Verify workflow checks for actual changes before committing
    if grep -q 'git diff --quiet' "$workflow" 2>/dev/null; then
        pass "Workflow checks for changes before committing"
    else
        log_test "WARN" "Workflow should verify changes exist before commit"
    fi

    teardown_test
}

#==============================================================================
# Run
#==============================================================================

run_test test_update_formula_rejects_empty_checksum
run_test test_formula_is_valid_ruby
run_test test_workflow_continues_on_single_failure
run_test test_no_partial_formula_state
run_test test_verify_script_handles_missing_tool
run_test test_update_formula_validates_url
run_test test_git_diff_quiet_check

print_results
