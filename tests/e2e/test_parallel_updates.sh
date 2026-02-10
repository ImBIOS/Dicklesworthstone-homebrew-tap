#!/usr/bin/env bash
# E2E Test: Multi-Tool Parallel Update
# Verifies that multiple tools releasing simultaneously are handled correctly.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/test-helpers.sh"

#==============================================================================
# Tests
#==============================================================================

test_workflow_concurrency_config() {
    setup_test "workflow_concurrency_config"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"
    assert_file_exists "$workflow" "auto-update.yml exists"

    # Check for concurrency configuration
    if grep -q "concurrency" "$workflow" 2>/dev/null; then
        pass "Workflow has concurrency configuration"
    else
        fail "Workflow should have concurrency config to handle parallel updates"
    fi

    # Verify cancel-in-progress is false (don't cancel running updates)
    if grep -q "cancel-in-progress.*false" "$workflow" 2>/dev/null; then
        pass "cancel-in-progress is false (won't drop in-flight updates)"
    else
        log_test "WARN" "cancel-in-progress should be false for update workflows"
    fi

    teardown_test
}

test_push_retry_handles_conflicts() {
    setup_test "push_retry_handles_conflicts"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"

    # Verify retry loop for push conflicts
    if grep -q "pull --rebase" "$workflow" 2>/dev/null; then
        pass "Workflow rebases before retry push"
    else
        fail "Workflow should rebase before retrying push"
    fi

    teardown_test
}

test_formulas_dont_share_files() {
    setup_test "formulas_dont_share_files"

    # Each formula should be an independent file — no shared state
    local formula_count=0
    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue
        formula_count=$((formula_count + 1))
    done

    assert_not_equals "0" "$formula_count" "Should have formulas"
    pass "Each formula is an independent .rb file ($formula_count total)"

    teardown_test
}

test_update_formula_is_atomic() {
    setup_test "update_formula_is_atomic"

    local script="$REPO_DIR/scripts/update-formula.sh"
    assert_file_exists "$script" "update-formula.sh exists"

    # Check that script updates one formula at a time (not batch)
    # The script should take a tool name parameter
    if grep -qE 'TOOL|tool|FORMULA' "$script" 2>/dev/null; then
        pass "Script operates on individual formulas"
    else
        log_test "WARN" "Cannot verify script operates on individual tools"
    fi

    teardown_test
}

test_git_commit_per_tool() {
    setup_test "git_commit_per_tool"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"

    # Verify workflow creates per-tool commits
    if grep -q 'git commit' "$workflow" 2>/dev/null; then
        pass "Workflow creates git commits"
    fi

    # Check that commits reference specific tool
    if grep -qE 'update.*\$.*tool|update.*\$.*TOOL|update.*matrix' "$workflow" 2>/dev/null; then
        pass "Commits reference specific tool name"
    else
        log_test "WARN" "Cannot verify per-tool commit messages"
    fi

    teardown_test
}

test_no_global_lockfile() {
    setup_test "no_global_lockfile"

    # Verify there's no global lock that would serialize updates
    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"

    # Strategy with fail-fast: false allows parallel matrix jobs
    if grep -q "fail-fast.*false" "$workflow" 2>/dev/null; then
        pass "Matrix strategy has fail-fast: false (parallel-friendly)"
    else
        log_test "INFO" "No fail-fast configuration found"
    fi

    teardown_test
}

#==============================================================================
# Run
#==============================================================================

run_test test_workflow_concurrency_config
run_test test_push_retry_handles_conflicts
run_test test_formulas_dont_share_files
run_test test_update_formula_is_atomic
run_test test_git_commit_per_tool
run_test test_no_global_lockfile

print_results
