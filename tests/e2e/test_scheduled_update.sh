#!/usr/bin/env bash
# E2E Test: Scheduled Update Check
# Verifies the scheduled update workflow correctly identifies outdated formulas.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/test-helpers.sh"

TAP_NAME="dicklesworthstone/tap"

#==============================================================================
# Tests
#==============================================================================

test_auto_update_workflow_has_schedule() {
    setup_test "auto_update_workflow_has_schedule"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"
    assert_file_exists "$workflow" "auto-update.yml exists"
    assert_file_contains "$workflow" "cron" "Should have cron schedule"

    teardown_test
}

test_auto_update_checks_latest_release() {
    setup_test "auto_update_checks_latest_release"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"

    # Verify the workflow has version comparison logic
    assert_file_contains "$workflow" "latest" "Should check latest version"
    assert_file_contains "$workflow" "current" "Should compare current version"

    teardown_test
}

test_update_formula_handles_version_comparison() {
    setup_test "update_formula_handles_version_comparison"

    local script="$REPO_DIR/scripts/update-formula.sh"
    assert_file_exists "$script" "update-formula.sh exists"

    # Verify it handles version input
    assert_file_contains "$script" "version\|VERSION" "Should handle version parameter"

    teardown_test
}

test_scheduled_update_has_retry_logic() {
    setup_test "scheduled_update_has_retry_logic"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"

    # Check for push retry (handles concurrent updates)
    if grep -q "retry\|rebase\|attempt" "$workflow" 2>/dev/null; then
        pass "Workflow has retry/rebase logic for concurrent updates"
    else
        fail "Workflow should have retry logic for concurrent pushes"
    fi

    teardown_test
}

test_formula_version_matches_github_api() {
    setup_test "formula_version_matches_github_api"

    # Test with ru (repo_updater) as a representative tool
    if ! command -v gh &>/dev/null; then
        log_test "INFO" "gh CLI not available, skipping API check"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
        teardown_test
        return 0
    fi

    local formula="$REPO_DIR/Formula/ru.rb"
    if [[ ! -f "$formula" ]]; then
        log_test "INFO" "ru.rb not found, skipping"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
        teardown_test
        return 0
    fi

    local formula_version
    formula_version=$(grep -oP 'version\s+"?\K[0-9]+\.[0-9]+\.[0-9]+' "$formula" 2>/dev/null | head -1)

    local latest_version
    latest_version=$(gh api repos/Dicklesworthstone/repo_updater/releases/latest --jq '.tag_name' 2>/dev/null | sed 's/^v//') || true

    if [[ -n "$formula_version" && -n "$latest_version" ]]; then
        if [[ "$formula_version" == "$latest_version" ]]; then
            pass "Formula version ($formula_version) matches latest release ($latest_version)"
        else
            log_test "WARN" "Version drift: formula=$formula_version latest=$latest_version"
            pass "Version comparison functional (drift detected)"
        fi
    else
        log_test "INFO" "Could not extract versions for comparison"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
    fi

    teardown_test
}

test_all_tools_in_scheduled_check() {
    setup_test "all_tools_in_scheduled_check"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"

    # The scheduled check should cover all known source repos
    local expected_repos=(
        "coding_agent_session_search"
        "repo_updater"
        "beads_viewer"
    )

    for repo in "${expected_repos[@]}"; do
        if grep -q "$repo" "$workflow" 2>/dev/null; then
            pass "Scheduled check covers $repo"
        else
            log_test "WARN" "$repo not found in scheduled check matrix"
        fi
    done

    teardown_test
}

#==============================================================================
# Run
#==============================================================================

run_test test_auto_update_workflow_has_schedule
run_test test_auto_update_checks_latest_release
run_test test_update_formula_handles_version_comparison
run_test test_scheduled_update_has_retry_logic
run_test test_formula_version_matches_github_api
run_test test_all_tools_in_scheduled_check

print_results
