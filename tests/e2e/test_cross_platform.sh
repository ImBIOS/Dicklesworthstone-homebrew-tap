#!/usr/bin/env bash
# E2E Test: Cross-Platform Installation Matrix
# Verifies formulas have correct platform-specific configuration.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/test-helpers.sh"

PLATFORM="$(uname -sm)"

#==============================================================================
# Tests
#==============================================================================

test_formulas_have_platform_urls() {
    setup_test "formulas_have_platform_urls"

    for f in "$REPO_DIR"/Formula/*.rb; do
        [[ "$f" == *"TEMPLATE"* ]] && continue
        [[ "$f" == *".gitkeep"* ]] && continue

        local name
        name=$(basename "$f" .rb)

        # Check formula has platform-specific blocks
        if grep -qE 'on_macos|on_linux|on_arm|on_intel|Hardware::CPU' "$f" 2>/dev/null; then
            pass "Formula $name has platform-specific configuration"
        elif grep -qE 'url.*darwin\|url.*linux\|url.*arm64\|url.*x86_64\|url.*amd64' "$f" 2>/dev/null; then
            pass "Formula $name has platform-specific URLs"
        else
            log_test "WARN" "Formula $name may lack platform specificity"
        fi
    done

    teardown_test
}

test_verify_script_platform_detection() {
    setup_test "verify_script_platform_detection"

    local script="$REPO_DIR/scripts/verify-installation.sh"
    assert_file_exists "$script" "verify-installation.sh exists"

    # Verify script detects platform
    assert_file_contains "$script" "uname" "Script should detect platform via uname"

    teardown_test
}

test_ci_workflow_has_platform_matrix() {
    setup_test "ci_workflow_has_platform_matrix"

    local workflow="$REPO_DIR/.github/workflows/e2e-tests.yml"
    assert_file_exists "$workflow" "e2e-tests.yml exists"

    # Check for macOS ARM
    assert_file_contains "$workflow" "macos-14" "CI should test macOS ARM (macos-14)"

    # Check for macOS Intel
    if grep -q "macos-13" "$workflow" 2>/dev/null; then
        pass "CI tests macOS Intel (macos-13)"
    else
        log_test "WARN" "CI may not test macOS Intel"
    fi

    # Check for Linux
    assert_file_contains "$workflow" "ubuntu" "CI should test Linux"

    teardown_test
}

test_scoop_manifests_have_windows_urls() {
    setup_test "scoop_manifests_have_windows_urls"

    local scoop_dir="$REPO_DIR/../../scoop-bucket"
    if [[ ! -d "$scoop_dir" ]]; then
        log_test "INFO" "scoop-bucket not found alongside homebrew-tap"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
        teardown_test
        return 0
    fi

    for f in "$scoop_dir"/*.json; do
        [[ ! -f "$f" ]] && continue
        [[ "$(basename "$f")" == "LICENSE" ]] && continue

        local name
        name=$(basename "$f" .json)

        local url
        url=$(jq -r '.architecture."64bit".url // .url // empty' "$f" 2>/dev/null)

        if [[ -n "$url" ]]; then
            if [[ "$url" == *"windows"* ]] || [[ "$url" == *"msvc"* ]] || [[ "$url" == *"amd64"* ]]; then
                pass "Scoop manifest $name has Windows URL"
            else
                log_test "WARN" "Scoop manifest $name URL may not be Windows-specific: $url"
            fi
        else
            fail "Scoop manifest $name has no download URL"
        fi
    done

    teardown_test
}

test_formula_urls_reachable() {
    setup_test "formula_urls_reachable"

    # Test a sample of formula URLs (not all, to keep fast)
    local formulas=("ru" "cass" "bv")
    local tested=0

    for name in "${formulas[@]}"; do
        local formula="$REPO_DIR/Formula/${name}.rb"
        [[ ! -f "$formula" ]] && continue

        # Extract first URL from formula
        local url
        url=$(sed -n 's/.*url\s*"\([^"]*\)".*/\1/p' "$formula" 2>/dev/null | head -1)
        [[ -z "$url" ]] && continue

        local http_code
        http_code=$(curl -sL -o /dev/null -w '%{http_code}' --connect-timeout 10 --max-time 30 "$url" 2>/dev/null) || true

        if [[ "$http_code" == "200" ]] || [[ "$http_code" == "302" ]]; then
            pass "Formula $name URL reachable ($http_code)"
        else
            log_test "WARN" "Formula $name URL returned $http_code: $url"
        fi
        tested=$((tested + 1))
    done

    if [[ $tested -eq 0 ]]; then
        log_test "INFO" "No formula URLs tested"
        _TEST_SKIPPED=$((_TEST_SKIPPED + 1))
    fi

    teardown_test
}

test_current_platform_formulas() {
    setup_test "current_platform_formulas"

    log_test "INFO" "Testing on platform: $PLATFORM"

    # Count formulas that should work on current platform
    local compatible=0

    case "$PLATFORM" in
        *Darwin*arm*)
            log_test "INFO" "macOS ARM detected"
            for f in "$REPO_DIR"/Formula/*.rb; do
                [[ "$f" == *"TEMPLATE"* || "$f" == *".gitkeep"* ]] && continue
                if grep -qE 'darwin.*arm64\|on_macos' "$f" 2>/dev/null || ! grep -q 'on_linux' "$f" 2>/dev/null; then
                    compatible=$((compatible + 1))
                fi
            done
            ;;
        *Linux*x86_64*)
            log_test "INFO" "Linux x86_64 detected"
            for f in "$REPO_DIR"/Formula/*.rb; do
                [[ "$f" == *"TEMPLATE"* || "$f" == *".gitkeep"* ]] && continue
                if grep -qE 'linux.*x86_64\|linux.*amd64\|on_linux' "$f" 2>/dev/null || ! grep -q 'on_macos' "$f" 2>/dev/null; then
                    compatible=$((compatible + 1))
                fi
            done
            ;;
        *)
            log_test "INFO" "Platform: $PLATFORM"
            ;;
    esac

    if [[ $compatible -gt 0 ]]; then
        pass "$compatible formulas compatible with $PLATFORM"
    else
        log_test "INFO" "Could not determine platform compatibility"
    fi

    teardown_test
}

#==============================================================================
# Run
#==============================================================================

run_test test_formulas_have_platform_urls
run_test test_verify_script_platform_detection
run_test test_ci_workflow_has_platform_matrix
run_test test_scoop_manifests_have_windows_urls
run_test test_formula_urls_reachable
run_test test_current_platform_formulas

print_results
