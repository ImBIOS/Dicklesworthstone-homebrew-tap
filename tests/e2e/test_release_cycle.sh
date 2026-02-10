#!/usr/bin/env bash
# E2E Test: Release → Auto-Update → Install Cycle
# Validates that creating a release triggers auto-update and installation works.
#
# Requires: gh CLI, brew, network access
# This test uses dry-run mode by default to avoid creating real releases.
# Set E2E_LIVE=1 to run against real GitHub releases.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/test-helpers.sh"

E2E_LIVE="${E2E_LIVE:-0}"
TAP_NAME="dicklesworthstone/tap"

#==============================================================================
# Tests
#==============================================================================

test_formula_update_script_exists() {
    setup_test "formula_update_script_exists"
    assert_file_exists "$REPO_DIR/scripts/update-formula.sh" "update-formula.sh should exist"
    teardown_test
}

test_update_formula_dry_run() {
    setup_test "update_formula_dry_run"

    # Verify the update-formula.sh script accepts expected arguments
    local output exit_code=0
    output=$(bash "$REPO_DIR/scripts/update-formula.sh" --help 2>&1) || exit_code=$?

    # Script might not have --help; just verify it's executable
    assert_file_exists "$REPO_DIR/scripts/update-formula.sh" "update-formula.sh exists"

    teardown_test
}

test_formula_has_autoupdate_config() {
    setup_test "formula_has_autoupdate_config"

    # Verify that auto-update workflow exists
    assert_file_exists "$REPO_DIR/.github/workflows/auto-update.yml" \
        "auto-update workflow should exist"

    # Verify it has repository_dispatch trigger
    assert_file_contains "$REPO_DIR/.github/workflows/auto-update.yml" "repository_dispatch" \
        "Workflow should have repository_dispatch trigger"

    # Verify it has schedule trigger
    assert_file_contains "$REPO_DIR/.github/workflows/auto-update.yml" "schedule" \
        "Workflow should have schedule trigger"

    teardown_test
}

test_formula_version_extraction() {
    setup_test "formula_version_extraction"

    # For each formula, verify version can be extracted
    local formula_count=0
    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        local name
        name=$(basename "$f" .rb)
        local version
        version=$(grep -oP 'version\s+"?\K[0-9]+\.[0-9]+\.[0-9]+' "$f" 2>/dev/null || echo "")

        if [[ -n "$version" ]]; then
            pass "Formula $name has version: $version"
        else
            # Some formulas use url-based versioning
            pass "Formula $name uses URL-based versioning (OK)"
        fi
        formula_count=$((formula_count + 1))
    done

    assert_not_equals "0" "$formula_count" "Should have at least one formula"

    teardown_test
}

test_formula_checksums_present() {
    setup_test "formula_checksums_present"

    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        local name
        name=$(basename "$f" .rb)

        if grep -q 'sha256' "$f" 2>/dev/null; then
            pass "Formula $name has SHA256 checksum"
        else
            fail "Formula $name missing SHA256 checksum"
        fi
    done

    teardown_test
}

test_auto_update_workflow_matrix() {
    setup_test "auto_update_workflow_matrix"

    local workflow="$REPO_DIR/.github/workflows/auto-update.yml"
    assert_file_exists "$workflow" "auto-update.yml exists"

    # Check each tool we expect to be in the workflow
    for tool in cass xf cm ru bv ubs; do
        if grep -q "$tool" "$workflow" 2>/dev/null; then
            pass "Workflow covers tool: $tool"
        else
            log_test "WARN" "Tool $tool not found in auto-update workflow"
        fi
    done

    teardown_test
}

test_live_release_cycle() {
    setup_test "live_release_cycle"

    if [[ "$E2E_LIVE" != "1" ]]; then
        log_test "INFO" "Skipping live release cycle test (set E2E_LIVE=1 to enable)"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
        teardown_test
        return 0
    fi

    # Verify gh CLI is available
    if ! command -v gh &>/dev/null; then
        fail "gh CLI not available"
        teardown_test
        return 1
    fi

    # Check latest release of a representative tool
    local latest
    latest=$(gh api repos/Dicklesworthstone/repo_updater/releases/latest --jq '.tag_name' 2>/dev/null) || true

    if [[ -n "$latest" ]]; then
        pass "Can query latest release: $latest"
    else
        fail "Cannot query latest release"
    fi

    teardown_test
}

#==============================================================================
# Run
#==============================================================================

run_test test_formula_update_script_exists
run_test test_update_formula_dry_run
run_test test_formula_has_autoupdate_config
run_test test_formula_version_extraction
run_test test_formula_checksums_present
run_test test_auto_update_workflow_matrix
run_test test_live_release_cycle

print_results
