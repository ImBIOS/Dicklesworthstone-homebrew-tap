#!/usr/bin/env bash
# Unit tests for update-formula.sh argument handling and version parsing
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/test-helpers.sh"

#==============================================================================
# Tests: argument validation
#==============================================================================

test_missing_args_exits_nonzero() {
    setup_test "missing args exits nonzero"

    local output exit_code=0
    output=$(bash "$REPO_DIR/scripts/update-formula.sh" 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail with no arguments"
    assert_contains "$output" "Usage" "Should show usage message"
}

test_missing_version_exits_nonzero() {
    setup_test "missing version exits nonzero"

    local output exit_code=0
    output=$(bash "$REPO_DIR/scripts/update-formula.sh" ru 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail with no version"
    assert_contains "$output" "Usage" "Should show usage message"
}

test_unknown_tool_exits_nonzero() {
    setup_test "unknown tool exits nonzero"

    # Run from a temp dir so no formula file is found
    local output exit_code=0
    output=$(cd "$_TEST_DIR" && bash "$REPO_DIR/scripts/update-formula.sh" nonexistent 1.0.0 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail for unknown tool"
}

test_missing_formula_file_exits_nonzero() {
    setup_test "missing formula file exits nonzero"

    # Run from temp dir where Formula/ru.rb doesn't exist
    local output exit_code=0
    output=$(cd "$_TEST_DIR" && bash "$REPO_DIR/scripts/update-formula.sh" ru 1.0.0 2>&1) || exit_code=$?

    assert_not_equals "0" "$exit_code" "Should fail when formula file missing"
    assert_contains "$output" "not found" "Should mention file not found"
}

test_version_strip_v_prefix() {
    setup_test "version strips v prefix"

    # Create a minimal formula that the script will try to process
    mkdir -p "$_TEST_DIR/Formula"
    cat > "$_TEST_DIR/Formula/ru.rb" <<'FORMULA'
class Ru < Formula
  version "0.0.1"
  sha256 "abc123"
end
FORMULA

    # Mock curl to return a fake checksum
    curl() {
        echo "deadbeef01234567890abcdef01234567890abcdef01234567890abcdef0123456  -"
    }
    export -f curl

    # Mock sha256sum
    sha256sum() {
        echo "deadbeef01234567890abcdef01234567890abcdef01234567890abcdef0123456  -"
    }
    export -f sha256sum

    # Mock git diff
    git() { return 0; }
    export -f git

    local output exit_code=0
    output=$(cd "$_TEST_DIR" && bash "$REPO_DIR/scripts/update-formula.sh" ru v2.0.0 2>&1) || exit_code=$?

    # Check the formula was updated with version without 'v' prefix
    if [[ -f "$_TEST_DIR/Formula/ru.rb" ]]; then
        assert_file_contains "$_TEST_DIR/Formula/ru.rb" 'version "2.0.0"' "Version should be 2.0.0 (no v prefix)"
    else
        fail "Formula file should still exist after update"
    fi

    # Clean up exported functions
    unset -f curl sha256sum git
}

#==============================================================================
# Run all tests
#==============================================================================

run_test test_missing_args_exits_nonzero
run_test test_missing_version_exits_nonzero
run_test test_unknown_tool_exits_nonzero
run_test test_missing_formula_file_exits_nonzero
run_test test_version_strip_v_prefix

print_results
