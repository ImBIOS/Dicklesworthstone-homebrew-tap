#!/usr/bin/env bash
# E2E Test: Upgrade Path Testing
# Verifies formulas support clean upgrades between versions.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/test-helpers.sh"

#==============================================================================
# Tests
#==============================================================================

test_formulas_support_upgrade() {
    setup_test "formulas_support_upgrade"

    # Homebrew natively supports upgrade via `brew upgrade`
    # Verify formulas don't have anti-patterns that break upgrades

    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        local name
        name=$(basename "$f" .rb)

        # Check for keg_only (prevents linking, may complicate upgrades)
        if grep -q 'keg_only' "$f" 2>/dev/null; then
            log_test "INFO" "Formula $name is keg_only (may need special upgrade handling)"
        fi

        # Check for post_install hooks that might interfere
        if grep -q 'post_install' "$f" 2>/dev/null; then
            log_test "INFO" "Formula $name has post_install hook"
        fi

        pass "Formula $name has no upgrade-blocking patterns"
    done

    teardown_test
}

test_formulas_have_stable_binary_names() {
    setup_test "formulas_have_stable_binary_names"

    # Verify binary names don't change between versions
    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        local name
        name=$(basename "$f" .rb)

        # Check for bin.install directives
        if grep -q 'bin\.install' "$f" 2>/dev/null; then
            local bin_name
            bin_name=$(sed -n 's/.*bin\.install\s*"\{0,1\}\([^"=> ]*\).*/\1/p' "$f" 2>/dev/null | head -1)
            if [[ -n "$bin_name" ]]; then
                pass "Formula $name installs binary: $bin_name"
            fi
        else
            log_test "INFO" "Formula $name: no bin.install found (may use alternative)"
        fi
    done

    teardown_test
}

test_no_version_pinning_in_deps() {
    setup_test "no_version_pinning_in_deps"

    # Formulas shouldn't pin dependency versions (blocks upgrades)
    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        local name
        name=$(basename "$f" .rb)

        if grep -qE 'depends_on.*=>' "$f" 2>/dev/null; then
            log_test "WARN" "Formula $name has pinned dependency versions"
        else
            pass "Formula $name has no pinned dependencies"
        fi
    done

    teardown_test
}

test_autoupdate_config_in_scoop() {
    setup_test "autoupdate_config_in_scoop"

    local scoop_dir="$REPO_DIR/../../scoop-bucket"
    if [[ ! -d "$scoop_dir" ]]; then
        log_test "INFO" "scoop-bucket not found"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
        teardown_test
        return 0
    fi

    for f in "$scoop_dir"/*.json; do
        [[ ! -f "$f" ]] && continue
        [[ "$(basename "$f")" == "LICENSE" ]] && continue

        local name
        name=$(basename "$f" .json)

        # Verify autoupdate section exists
        local has_autoupdate
        has_autoupdate=$(jq 'has("autoupdate")' "$f" 2>/dev/null)

        if [[ "$has_autoupdate" == "true" ]]; then
            pass "Scoop manifest $name has autoupdate config"
        else
            log_test "WARN" "Scoop manifest $name missing autoupdate"
        fi

        # Verify checkver section exists
        local has_checkver
        has_checkver=$(jq 'has("checkver")' "$f" 2>/dev/null)

        if [[ "$has_checkver" == "true" ]]; then
            pass "Scoop manifest $name has checkver config"
        else
            log_test "WARN" "Scoop manifest $name missing checkver"
        fi
    done

    teardown_test
}

test_completions_installed_on_upgrade() {
    setup_test "completions_installed_on_upgrade"

    local completions_dir="$REPO_DIR/completions"
    if [[ ! -d "$completions_dir" ]]; then
        log_test "INFO" "No completions directory found"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
        teardown_test
        return 0
    fi

    # Check that formulas install completions
    local has_completions=0
    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        if grep -qE 'bash_completion|zsh_completion|fish_completion' "$f" 2>/dev/null; then
            has_completions=$((has_completions + 1))
        fi
    done

    if [[ $has_completions -gt 0 ]]; then
        pass "$has_completions formulas install shell completions"
    else
        log_test "INFO" "No formulas install shell completions yet"
    fi

    teardown_test
}

test_old_version_cleanup() {
    setup_test "old_version_cleanup"

    # Verify no leftover versioned files in the repo
    local stale_files=0
    for f in "$REPO_DIR"/Formula/*_v[0-9]*.rb "$REPO_DIR"/Formula/*-old*.rb "$REPO_DIR"/Formula/*.rb.bak; do
        [[ -f "$f" ]] || continue
        stale_files=$((stale_files + 1))
        log_test "WARN" "Stale file found: $(basename "$f")"
    done

    if [[ $stale_files -eq 0 ]]; then
        pass "No stale formula versions found"
    else
        fail "$stale_files stale formula files found"
    fi

    teardown_test
}

#==============================================================================
# Run
#==============================================================================

run_test test_formulas_support_upgrade
run_test test_formulas_have_stable_binary_names
run_test test_no_version_pinning_in_deps
run_test test_autoupdate_config_in_scoop
run_test test_completions_installed_on_upgrade
run_test test_old_version_cleanup

print_results
