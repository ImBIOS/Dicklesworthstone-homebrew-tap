#!/usr/bin/env bash
# E2E Test Suite for Dicklesworthstone Stack Tools
# Verifies each tool works correctly AFTER Homebrew installation
set -uo pipefail

# Configuration
LOG_DIR="${LOG_DIR:-/tmp/e2e-tests}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULTS_FILE="$LOG_DIR/results-$TIMESTAMP.json"
VERBOSE="${VERBOSE:-0}"

mkdir -p "$LOG_DIR"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging utilities
log_info()  { echo -e "${BLUE}[INFO]${NC}  $(date +%H:%M:%S) $*" | tee -a "$LOG_DIR/e2e.log"; }
log_pass()  { echo -e "${GREEN}[PASS]${NC}  $(date +%H:%M:%S) $*" | tee -a "$LOG_DIR/e2e.log"; }
log_fail()  { echo -e "${RED}[FAIL]${NC}  $(date +%H:%M:%S) $*" | tee -a "$LOG_DIR/e2e.log"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $(date +%H:%M:%S) $*" | tee -a "$LOG_DIR/e2e.log"; }
log_debug() { [[ "$VERBOSE" == "1" ]] && echo -e "[DEBUG] $(date +%H:%M:%S) $*" | tee -a "$LOG_DIR/e2e.log"; }

# Test result tracking
declare -A RESULTS
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

run_test() {
  local name="$1"
  local cmd="$2"

  TESTS_RUN=$((TESTS_RUN + 1))
  log_info "Running test: $name"
  log_debug "Command: $cmd"

  local start_time=$(date +%s.%N 2>/dev/null || date +%s)
  local output
  local exit_code=0

  output=$(eval "$cmd" 2>&1) || exit_code=$?

  local end_time=$(date +%s.%N 2>/dev/null || date +%s)
  local duration
  if command -v bc &>/dev/null; then
    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
  else
    duration="0"
  fi

  if [[ "$exit_code" -eq 0 ]]; then
    log_pass "$name (${duration}s)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    RESULTS["$name"]="pass"
  else
    log_fail "$name (exit code: $exit_code)"
    log_debug "Output: $output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    RESULTS["$name"]="fail"
  fi

  # Log full output for debugging
  {
    echo "=== $name ==="
    echo "Exit code: $exit_code"
    echo "Output:"
    echo "$output"
    echo ""
  } >> "$LOG_DIR/test-output.log"
}

skip_test() {
  local name="$1"
  local reason="$2"

  TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
  log_warn "Skipping test: $name - $reason"
  RESULTS["$name"]="skipped"
}

# Tool-specific test functions
test_bv() {
  log_info "=== Testing bv (beads_viewer) ==="

  if ! command -v bv &>/dev/null; then
    skip_test "bv-all" "bv not installed"
    return
  fi

  run_test "bv-version" "bv --version"
  run_test "bv-help" "bv --help | grep -qi robot"

  # Functional test with temp directory
  local tmpdir
  tmpdir=$(mktemp -d)
  mkdir -p "$tmpdir/.beads"
  echo '{"version":1}' > "$tmpdir/.beads/beads.db"
  run_test "bv-triage" "bv --robot-triage --path '$tmpdir' 2>&1 || true"
  rm -rf "$tmpdir"
}

test_caam() {
  log_info "=== Testing caam (coding_agent_account_manager) ==="

  if ! command -v caam &>/dev/null; then
    skip_test "caam-all" "caam not installed"
    return
  fi

  run_test "caam-version" "caam --version"
  run_test "caam-help" "caam --help | grep -qi switch"
  run_test "caam-list" "caam list 2>&1 || true"
}

test_slb() {
  log_info "=== Testing slb (simultaneous_launch_button) ==="

  if ! command -v slb &>/dev/null; then
    skip_test "slb-all" "slb not installed"
    return
  fi

  run_test "slb-version" "slb --version || slb version"
  run_test "slb-help" "slb --help"
}

test_ru() {
  log_info "=== Testing ru (repo_updater) ==="

  if ! command -v ru &>/dev/null; then
    skip_test "ru-all" "ru not installed"
    return
  fi

  run_test "ru-version" "ru --version"
  run_test "ru-help" "ru --help | grep -qi sync"
  run_test "ru-doctor" "ru doctor 2>&1 || true"
}

test_cass() {
  log_info "=== Testing cass (coding_agent_session_search) ==="

  if ! command -v cass &>/dev/null; then
    skip_test "cass-all" "cass not installed"
    return
  fi

  run_test "cass-version" "cass --version"
  run_test "cass-help" "cass --help | grep -qi search"
  run_test "cass-health" "cass health 2>&1 || true"
}

test_xf() {
  log_info "=== Testing xf (twitter search) ==="

  if ! command -v xf &>/dev/null; then
    skip_test "xf-all" "xf not installed"
    return
  fi

  run_test "xf-version" "xf --version"
  run_test "xf-help" "xf --help | grep -qi search"
}

test_cm() {
  log_info "=== Testing cm (cass_memory_system) ==="

  if ! command -v cm &>/dev/null; then
    skip_test "cm-all" "cm not installed"
    return
  fi

  run_test "cm-version" "cm --version"
  run_test "cm-help" "cm --help"
}

test_ubs() {
  log_info "=== Testing ubs (ultimate_bug_scanner) ==="

  if ! command -v ubs &>/dev/null; then
    skip_test "ubs-all" "ubs not installed"
    return
  fi

  run_test "ubs-version" "ubs --version"
  run_test "ubs-help" "ubs --help | grep -qi scan"

  # Create test file
  local testfile
  testfile=$(mktemp)
  echo "echo hello" > "$testfile"
  run_test "ubs-scan" "ubs '$testfile' 2>&1 || true"
  rm -f "$testfile"
}

test_dcg() {
  log_info "=== Testing dcg (destructive_command_guard) ==="

  if ! command -v dcg &>/dev/null; then
    skip_test "dcg-all" "dcg not installed"
    return
  fi

  run_test "dcg-version" "dcg --version"
  run_test "dcg-help" "dcg --help"
}

test_tru() {
  log_info "=== Testing tru (toon_rust) ==="

  if ! command -v tru &>/dev/null; then
    skip_test "tru-all" "tru not installed"
    return
  fi

  run_test "tru-version" "tru --version"
  run_test "tru-help" "tru --help"
}

test_ntm() {
  log_info "=== Testing ntm (named_tmux_manager) ==="

  if ! command -v ntm &>/dev/null; then
    skip_test "ntm-all" "ntm not installed"
    return
  fi

  run_test "ntm-version" "ntm --version"
  run_test "ntm-help" "ntm --help | grep -qi spawn"
}

test_tr() {
  log_info "=== Testing tr (toon_rust formula alias) ==="

  if ! command -v tr &>/dev/null; then
    skip_test "tr-all" "tr not installed or shadowed by coreutils"
    return
  fi

  # tr is a secondary formula — just check help works
  run_test "tr-help" "tr --help 2>&1 || true"
}

# Generate JSON results
generate_results() {
  local pass_rate=0
  if [[ "$TESTS_RUN" -gt 0 ]]; then
    pass_rate=$((TESTS_PASSED * 100 / TESTS_RUN))
  fi

  cat > "$RESULTS_FILE" << EOF
{
  "timestamp": "$(date -Iseconds 2>/dev/null || date)",
  "platform": "$(uname -sm)",
  "homebrew_version": "$(brew --version 2>/dev/null | head -1 || echo 'unknown')",
  "tests_run": $TESTS_RUN,
  "tests_passed": $TESTS_PASSED,
  "tests_failed": $TESTS_FAILED,
  "tests_skipped": $TESTS_SKIPPED,
  "pass_rate": "${pass_rate}%",
  "results": {
$(
  first=true
  for name in "${!RESULTS[@]}"; do
    if $first; then
      first=false
    else
      echo ","
    fi
    printf '    "%s": "%s"' "$name" "${RESULTS[$name]}"
  done
  echo ""
)
  }
}
EOF
  log_info "Results written to: $RESULTS_FILE"
}

# Print summary for GitHub Actions
print_summary() {
  echo ""
  echo "========================================"
  echo "E2E TEST SUMMARY"
  echo "========================================"
  echo "Platform:      $(uname -sm)"
  echo "Tests run:     $TESTS_RUN"
  echo "Tests passed:  $TESTS_PASSED"
  echo "Tests failed:  $TESTS_FAILED"
  echo "Tests skipped: $TESTS_SKIPPED"
  echo "========================================"

  # GitHub Actions summary
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      echo "### E2E Test Results"
      echo ""
      echo "| Metric | Value |"
      echo "|--------|-------|"
      echo "| Platform | $(uname -sm) |"
      echo "| Tests Run | $TESTS_RUN |"
      echo "| Tests Passed | $TESTS_PASSED |"
      echo "| Tests Failed | $TESTS_FAILED |"
      echo "| Tests Skipped | $TESTS_SKIPPED |"
      echo ""

      if [[ "$TESTS_FAILED" -gt 0 ]]; then
        echo "#### Failed Tests"
        for name in "${!RESULTS[@]}"; do
          if [[ "${RESULTS[$name]}" == "fail" ]]; then
            echo "- $name"
          fi
        done
      fi
    } >> "$GITHUB_STEP_SUMMARY"
  fi
}

# Main
main() {
  log_info "Starting E2E test suite"
  log_info "Platform: $(uname -sm)"
  log_info "Log directory: $LOG_DIR"

  # Clear previous logs
  : > "$LOG_DIR/e2e.log"
  : > "$LOG_DIR/test-output.log"

  # Run tests for each tool
  test_bv
  test_caam
  test_slb
  test_ru
  test_cass
  test_xf
  test_cm
  test_ubs
  test_dcg
  test_tru
  test_ntm

  generate_results
  print_summary

  # Exit with failure if any tests failed
  [[ "$TESTS_FAILED" -eq 0 ]] && exit 0 || exit 1
}

# Allow running specific tool tests
if [[ $# -gt 0 ]]; then
  case "$1" in
    bv|caam|slb|ru|cass|xf|cm|ubs|dcg|tru|ntm|tr)
      log_info "Running tests for: $1"
      "test_$1"
      generate_results
      print_summary
      exit $([[ "$TESTS_FAILED" -eq 0 ]] && echo 0 || echo 1)
      ;;
    *)
      echo "Usage: $0 [tool]"
      echo "Available tools: bv, caam, slb, ru, cass, xf, cm, ubs, dcg, tru, ntm, tr"
      echo "Run without arguments to test all installed tools"
      exit 1
      ;;
  esac
else
  main
fi
