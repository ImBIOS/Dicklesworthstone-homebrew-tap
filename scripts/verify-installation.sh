#!/usr/bin/env bash
# Installation lifecycle verifier for Homebrew tap tools.
# Tests: install → version check → smoke test → uninstall → clean check.
#
# Usage:
#   ./verify-installation.sh [--json] [--verbose] [--skip-uninstall] [TOOL...]
#   TOOLS: bv caam slb ru cass xf cm ubs dcg tru ntm tr
#   Omit TOOL args to test all formulas in Formula/*.rb.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

#==============================================================================
# Configuration
#==============================================================================

TAP_NAME="dicklesworthstone/tap"
JSON_MODE="${JSON_MODE:-false}"
VERBOSE="${VERBOSE:-false}"
SKIP_UNINSTALL="${SKIP_UNINSTALL:-false}"
LOG_DIR="${LOG_DIR:-/tmp/verify-install}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$LOG_DIR"

# Parse flags
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --json)       JSON_MODE="true"; shift ;;
        --verbose)    VERBOSE="true"; shift ;;
        --skip-uninstall) SKIP_UNINSTALL="true"; shift ;;
        -*)           echo "Unknown flag: $1" >&2; exit 4 ;;
        *)            POSITIONAL+=("$1"); shift ;;
    esac
done
set -- "${POSITIONAL[@]+"${POSITIONAL[@]}"}"

#==============================================================================
# Logging
#==============================================================================

_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

log() {
    local level="$1" msg="$2"
    shift 2
    local ts
    ts=$(_ts)

    if [[ "$JSON_MODE" == "true" ]]; then
        printf '{"timestamp":"%s","level":"%s","message":"%s"' "$ts" "$level" "$msg"
        while [[ $# -ge 2 ]]; do
            local key="$1" val="$2"
            # Escape double quotes in value
            val="${val//\"/\\\"}"
            printf ',"%s":"%s"' "$key" "$val"
            shift 2
        done
        printf '}\n'
    else
        printf "[%s] %-5s %s" "$ts" "$level" "$msg"
        while [[ $# -ge 2 ]]; do
            printf " %s=%s" "$1" "$2"
            shift 2
        done
        printf '\n'
    fi
}

debug() {
    [[ "$VERBOSE" == "true" ]] && log "DEBUG" "$@"
}

#==============================================================================
# Smoke tests per tool
#==============================================================================

# Returns 0 on success. Captures output into $SMOKE_OUTPUT.
smoke_test() {
    local tool="$1"
    case "$tool" in
        bv)   SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        caam)  SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        slb)   SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        ru)    SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        cass)  SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        xf)    SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        cm)    SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        ubs)   SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        dcg)   SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        tru)   SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        ntm)   SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        tr)    SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
        *)     SMOKE_OUTPUT=$("$tool" --help 2>&1) ;;
    esac
}

#==============================================================================
# Lifecycle verifier
#==============================================================================

TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0
declare -a RESULTS_ARRAY=()

verify_tool() {
    local tool="$1"
    local formula="${TAP_NAME}/${tool}"
    local start_time
    start_time=$(date +%s)
    local phases_passed=0
    local phases_total=0

    TOTAL=$((TOTAL + 1))
    log "INFO" "Starting verification" "tool" "$tool" "phase" "start"

    # Phase 1: Formula exists
    phases_total=$((phases_total + 1))
    log "INFO" "Checking formula" "tool" "$tool" "phase" "formula_check"
    if ! brew info "$formula" &>/dev/null; then
        log "ERROR" "Formula not found" "tool" "$tool" "error_code" "FORMULA_NOT_FOUND"
        FAILED=$((FAILED + 1))
        RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"formula_check\"}")
        return 1
    fi
    phases_passed=$((phases_passed + 1))
    debug "Formula found" "tool" "$tool"

    # Phase 2: Install
    phases_total=$((phases_total + 1))
    log "INFO" "Installing" "tool" "$tool" "phase" "install"
    local install_output install_exit=0
    install_output=$(brew install "$formula" 2>&1) || install_exit=$?

    if [[ $install_exit -ne 0 ]]; then
        log "ERROR" "Installation failed" "tool" "$tool" "exit_code" "$install_exit" \
            "output" "${install_output:0:500}"
        FAILED=$((FAILED + 1))
        RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"install\",\"exit_code\":$install_exit}")
        return 1
    fi
    phases_passed=$((phases_passed + 1))
    debug "Installed" "tool" "$tool"

    # Phase 3: Version check
    phases_total=$((phases_total + 1))
    log "INFO" "Checking version" "tool" "$tool" "phase" "version_check"
    local version_output version_exit=0
    version_output=$("$tool" --version 2>&1) || version_exit=$?

    if [[ $version_exit -ne 0 ]]; then
        # Some tools use different version flags; try alternatives
        version_exit=0
        version_output=$("$tool" version 2>&1) || version_exit=$?
    fi

    if [[ $version_exit -ne 0 ]]; then
        log "WARN" "Version command failed (non-fatal)" "tool" "$tool" "exit_code" "$version_exit"
    else
        local version=""
        version=$(echo "$version_output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        log "INFO" "Version OK" "tool" "$tool" "version" "${version:-unknown}" "phase" "version_check"
        phases_passed=$((phases_passed + 1))
    fi

    # Phase 4: Smoke test
    phases_total=$((phases_total + 1))
    log "INFO" "Running smoke test" "tool" "$tool" "phase" "smoke_test"
    local SMOKE_OUTPUT="" smoke_exit=0
    smoke_test "$tool" || smoke_exit=$?

    if [[ $smoke_exit -ne 0 ]]; then
        log "WARN" "Smoke test returned non-zero (non-fatal)" "tool" "$tool" "exit_code" "$smoke_exit"
    else
        log "INFO" "Smoke test passed" "tool" "$tool" "phase" "smoke_test"
        phases_passed=$((phases_passed + 1))
    fi

    # Phase 5: Uninstall (unless --skip-uninstall)
    if [[ "$SKIP_UNINSTALL" != "true" ]]; then
        phases_total=$((phases_total + 1))
        log "INFO" "Uninstalling" "tool" "$tool" "phase" "uninstall"
        local uninstall_output uninstall_exit=0
        uninstall_output=$(brew uninstall "$tool" 2>&1) || uninstall_exit=$?

        if [[ $uninstall_exit -ne 0 ]]; then
            log "ERROR" "Uninstall failed" "tool" "$tool" "exit_code" "$uninstall_exit"
            FAILED=$((FAILED + 1))
            RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"uninstall\"}")
            return 1
        fi
        phases_passed=$((phases_passed + 1))

        # Phase 6: Clean check
        phases_total=$((phases_total + 1))
        log "INFO" "Verifying clean removal" "tool" "$tool" "phase" "cleanup_check"
        if command -v "$tool" &>/dev/null; then
            log "ERROR" "Tool still in PATH after uninstall" "tool" "$tool" "phase" "cleanup_check"
            FAILED=$((FAILED + 1))
            RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"fail\",\"phase\":\"cleanup_check\"}")
            return 1
        fi
        phases_passed=$((phases_passed + 1))
    fi

    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    log "INFO" "Verification complete" "tool" "$tool" "result" "pass" \
        "phases" "${phases_passed}/${phases_total}" "duration_seconds" "$duration"
    PASSED=$((PASSED + 1))
    RESULTS_ARRAY+=("{\"tool\":\"$tool\",\"result\":\"pass\",\"phases_passed\":$phases_passed,\"phases_total\":$phases_total,\"duration_seconds\":$duration}")
    return 0
}

#==============================================================================
# Main
#==============================================================================

# Determine tool list
TOOLS=()
if [[ ${#POSITIONAL[@]} -gt 0 ]]; then
    TOOLS=("${POSITIONAL[@]}")
else
    # Discover from Formula directory
    shopt -s nullglob
    for f in "$REPO_DIR"/Formula/*.rb; do
        name=$(basename "$f" .rb)
        [[ "$name" == "TEMPLATE" ]] && continue
        TOOLS+=("$name")
    done
    shopt -u nullglob
fi

if [[ ${#TOOLS[@]} -eq 0 ]]; then
    log "ERROR" "No tools to verify"
    exit 4
fi

log "INFO" "Starting installation verification" "tool_count" "${#TOOLS[@]}" \
    "platform" "$(uname -sm)" "skip_uninstall" "$SKIP_UNINSTALL"

# Ensure tap is available
if ! brew tap | grep -q "$TAP_NAME" 2>/dev/null; then
    log "INFO" "Adding tap" "tap" "$TAP_NAME"
    brew tap "$TAP_NAME" 2>&1 || true
fi

for tool in "${TOOLS[@]}"; do
    verify_tool "$tool" || true
done

# Summary
log "INFO" "Suite complete" "total" "$TOTAL" "passed" "$PASSED" "failed" "$FAILED" "skipped" "$SKIPPED"

# Write JSON results file
{
    printf '{"generated_at":"%s","platform":"%s","total":%d,"passed":%d,"failed":%d,"skipped":%d,"tools":[%s]}\n' \
        "$(_ts)" "$(uname -sm)" "$TOTAL" "$PASSED" "$FAILED" "$SKIPPED" \
        "$(IFS=,; echo "${RESULTS_ARRAY[*]}")"
} > "$LOG_DIR/verify-results-$TIMESTAMP.json"

log "INFO" "Results written" "path" "$LOG_DIR/verify-results-$TIMESTAMP.json"

# GitHub Actions summary
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo "### Installation Verification Results"
        echo ""
        echo "| Tool | Result |"
        echo "|------|--------|"
        for entry in "${RESULTS_ARRAY[@]}"; do
            t=$(echo "$entry" | sed -n 's/.*"tool":"\([^"]*\)".*/\1/p')
            r=$(echo "$entry" | sed -n 's/.*"result":"\([^"]*\)".*/\1/p')
            if [[ "$r" == "pass" ]]; then
                echo "| $t | :white_check_mark: pass |"
            else
                echo "| $t | :x: fail |"
            fi
        done
        echo ""
        echo "**Total:** $TOTAL | **Passed:** $PASSED | **Failed:** $FAILED"
    } >> "$GITHUB_STEP_SUMMARY"
fi

[[ $FAILED -eq 0 ]]
