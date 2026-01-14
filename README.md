# Dicklesworthstone Homebrew Tap

[![Test Formulas](https://github.com/Dicklesworthstone/homebrew-tap/actions/workflows/test-formulas.yml/badge.svg)](https://github.com/Dicklesworthstone/homebrew-tap/actions/workflows/test-formulas.yml)
[![E2E Tests](https://github.com/Dicklesworthstone/homebrew-tap/actions/workflows/e2e-tests.yml/badge.svg)](https://github.com/Dicklesworthstone/homebrew-tap/actions/workflows/e2e-tests.yml)

Homebrew formulas for the **Dicklesworthstone Stack** - a collection of powerful tools designed for AI coding agents and developer productivity.

## Quick Start

```bash
# Add the tap
brew tap dicklesworthstone/tap

# Install a tool
brew install dicklesworthstone/tap/cass
```

## Available Tools

### Session Search & Memory

| Tool | Description | Install |
|------|-------------|---------|
| **[cass](https://github.com/Dicklesworthstone/coding_agent_session_search)** | Cross-agent session search - Index and search AI coding agent conversations from Claude Code, Cursor, Codex, and more | `brew install dicklesworthstone/tap/cass` |
| **[cm](https://github.com/Dicklesworthstone/cass_memory_system)** | CASS Memory System - Persistent vector-based procedural memory for AI agents | `brew install dicklesworthstone/tap/cm` |
| **[xf](https://github.com/Dicklesworthstone/xf)** | X-Former - Search and analyze your Twitter/X archive data locally | `brew install dicklesworthstone/tap/xf` |

### Repository & Code Management

| Tool | Description | Install |
|------|-------------|---------|
| **[ru](https://github.com/Dicklesworthstone/repo_updater)** | Repo Updater - Robust CLI for synchronizing GitHub repositories to local projects directory | `brew install dicklesworthstone/tap/ru` |
| **[ubs](https://github.com/Dicklesworthstone/ultimate_bug_scanner)** | Ultimate Bug Scanner - Comprehensive code analysis for bugs and security issues | `brew install dicklesworthstone/tap/ubs` |

### Coming Soon (via GoReleaser)

These tools will be automatically published when their GoReleaser configurations are set up:

| Tool | Description | Status |
|------|-------------|--------|
| **[ntm](https://github.com/Dicklesworthstone/ntm)** | Named Tmux Manager - Orchestrate AI coding agents in tmux sessions | Pending |
| **[bv](https://github.com/Dicklesworthstone/beads_viewer)** | Beads Viewer - Graph-aware task management TUI | Pending |
| **[caam](https://github.com/Dicklesworthstone/coding_agent_account_manager)** | Coding Agent Account Manager - Switch between AI agent accounts | Pending |
| **[slb](https://github.com/Dicklesworthstone/simultaneous_launch_button)** | Simultaneous Launch Button - Two-person rule for dangerous commands | Pending |

## Platform Support

| Tool | macOS Intel | macOS ARM | Linux x86 | Linux ARM |
|------|:-----------:|:---------:|:---------:|:---------:|
| cass | ✅ | ✅ | ✅ | ✅ |
| xf   | ✅ | ✅ | ✅ | - |
| cm   | ✅ | ✅ | ✅ | - |
| ru   | ✅ | ✅ | ✅ | ✅ |
| ubs  | ✅ | ✅ | ✅ | ✅ |

> **Note**: ru and ubs are Bash scripts that work on any Unix-like system.

## Tool Details

### cass - Coding Agent Session Search

Index and search your AI coding agent conversation histories across multiple tools:

```bash
# Check setup and indexing status
cass health

# Search across all sessions
cass search "authentication bug"

# For AI agents, use robot mode
cass search "error handling" --robot --limit 10

# JSON output for programmatic use
cass search "database" --json
```

**Supported agents**: Claude Code, Cursor, Codex CLI, Gemini CLI, ChatGPT, Aider, and more.

### cm - CASS Memory System

Persistent vector-based memory system that helps AI agents remember context across sessions:

```bash
# Check system status
cm status

# Store a memory
cm store "The user prefers tabs over spaces"

# Recall relevant memories
cm recall "code formatting preferences"
```

### xf - X-Former (Twitter Search)

Search and analyze your personal Twitter/X data archive locally:

```bash
# Setup: Download your Twitter data from Twitter settings, then:
xf --data-dir /path/to/twitter-archive

# Search your tweets
xf search "machine learning"

# Show archive statistics
xf stats

# Limit results
xf search "project" --limit 20
```

### ru - Repo Updater

Synchronize GitHub repositories to your local projects directory:

```bash
# Initialize configuration
ru init

# Sync all configured repositories
ru sync

# Check status of all repos
ru status

# Run diagnostics
ru doctor

# Review GitHub issues/PRs across repos
ru review --plan
```

**Requires**: `git`, `gh` (GitHub CLI) for private repos, optionally `gum` for beautiful TUI.

### ubs - Ultimate Bug Scanner

Comprehensive code analysis tool for finding bugs and security issues:

```bash
# Scan current directory
ubs .

# Scan with JSON output (for AI agents)
ubs --json ./src

# Show all options
ubs --help
```

**Supports**: Python, JavaScript, TypeScript, Rust, Go, and more.

## Updating Packages

```bash
# Update a specific tool
brew upgrade dicklesworthstone/tap/cass

# Update all tools from this tap
brew upgrade $(brew list --formula | grep dicklesworthstone)

# Update everything (including Homebrew itself)
brew update && brew upgrade
```

## How Auto-Updates Work

This tap uses multiple mechanisms to stay up-to-date:

### 1. Repository Dispatch (Fastest)
When a source repository publishes a new release, it can trigger an immediate update via GitHub's `repository_dispatch` API.

### 2. Scheduled Checks (Every 6 hours)
A GitHub Actions workflow checks all source repositories for new releases and automatically updates formulas.

### 3. Manual Updates
Maintainers can manually trigger formula updates via the GitHub Actions workflow_dispatch interface.

## Troubleshooting

### "Formula not found" after tapping

```bash
# Force refresh the tap
brew update --force
brew tap-info dicklesworthstone/tap
```

### Checksum/hash mismatch

This usually means a new release was published. Update and reinstall:

```bash
brew update
brew reinstall dicklesworthstone/tap/<tool-name>
```

### Installation fails with architecture error

Check if the tool supports your platform:

```bash
# Show formula info including supported platforms
brew info dicklesworthstone/tap/<tool-name>
```

### Tool not working after install

```bash
# Verify installation
which <tool-name>
<tool-name> --version

# Check for conflicts
brew doctor

# View installation logs
brew install --verbose dicklesworthstone/tap/<tool-name>
```

### Uninstalling

```bash
# Remove a specific tool
brew uninstall <tool-name>

# Remove the tap entirely
brew untap dicklesworthstone/tap
```

## For Maintainers

### Manual Formula Update

To manually update a formula when a new version is released:

```bash
cd /path/to/homebrew-tap
./scripts/update-formula.sh <tool> <version>

# Examples:
./scripts/update-formula.sh ru 1.2.3
./scripts/update-formula.sh cass 0.1.56
./scripts/update-formula.sh xf 0.2.1
```

The script will:
1. Fetch the new checksum(s) from GitHub releases
2. Update the version and sha256 in the formula
3. Show the git diff for review

### Validating Formulas

```bash
# Validate all formulas
./scripts/validate-formulas.sh

# Validate a specific formula
./scripts/validate-formulas.sh cass

# Full validation with brew audit (slower)
./scripts/validate-formulas.sh --ci
```

### Running E2E Tests Locally

```bash
# Test all installed tools
./scripts/e2e-test-suite.sh

# Test a specific tool
./scripts/e2e-test-suite.sh cass

# Verbose output
VERBOSE=1 ./scripts/e2e-test-suite.sh
```

### Writing New Formulas

Use the existing formulas as templates. Key requirements:

1. **desc**: Clear, concise description (10+ characters)
2. **homepage**: Link to source repository
3. **license**: Declare the license (usually MIT)
4. **Multi-arch support**: For binary releases, include `on_macos`/`on_linux` and `on_intel`/`on_arm` blocks
5. **test block**: At minimum, verify `--version` works

Example structure for multi-arch binary:

```ruby
class MyTool < Formula
  desc "Description of the tool"
  homepage "https://github.com/Dicklesworthstone/my_tool"
  version "1.0.0"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/.../my-tool-x86_64-apple-darwin.tar.gz"
      sha256 "..."
    end
    on_arm do
      url "https://github.com/.../my-tool-aarch64-apple-darwin.tar.gz"
      sha256 "..."
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/.../my-tool-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "..."
    end
  end

  def install
    bin.install "my-tool"
    # Optional: shell completions
    generate_completions_from_executable(bin/"my-tool", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/my-tool --version")
  end
end
```

### CI Pipeline

Every push to `Formula/` triggers:

| Stage | Description | Runners |
|-------|-------------|---------|
| **Validate** | Ruby syntax, required fields | ubuntu-latest |
| **Audit** | `brew audit --strict --online` | ubuntu-latest |
| **Install Test** | Full install/test/uninstall cycle | macOS-13, macOS-14, ubuntu-22.04 |

Weekly E2E tests run comprehensive functional tests on all installed tools.

## Directory Structure

```
homebrew-tap/
├── Formula/           # Homebrew formulas (.rb files)
│   ├── cass.rb
│   ├── cm.rb
│   ├── ru.rb
│   ├── ubs.rb
│   └── xf.rb
├── Casks/             # Homebrew casks (GUI apps)
├── scripts/
│   ├── update-formula.sh      # Update formula version/checksums
│   ├── validate-formulas.sh   # Validate formula quality
│   └── e2e-test-suite.sh      # End-to-end functional tests
└── .github/workflows/
    ├── test-formulas.yml      # CI: audit and install tests
    ├── e2e-tests.yml          # Weekly E2E functional tests
    └── auto-update.yml        # Automatic formula updates
```

## Related Resources

- **Scoop Bucket** (Windows): [Dicklesworthstone/scoop-bucket](https://github.com/Dicklesworthstone/scoop-bucket)
- **Source Repositories**: See individual tool links in the tables above

## License

Each tool has its own license. Check the individual repositories for details. This tap repository itself is MIT licensed.

## Contributing

This tap is primarily auto-maintained. For issues:

- **Tool bugs**: File issues in the respective tool's repository
- **Formula bugs**: File issues in this repository
- **Feature requests**: File issues in the respective tool's repository

We don't accept external PRs for formulas as they are auto-generated, but issue reports are welcome.
