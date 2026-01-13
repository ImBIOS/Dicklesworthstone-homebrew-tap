# Dicklesworthstone Homebrew Tap

Homebrew formulas and casks for the Dicklesworthstone Stack - a collection of tools for AI coding agents and developer productivity.

## Installation

First, add this tap to your Homebrew:

```bash
brew tap dicklesworthstone/tap
```

Then install any tool:

```bash
brew install dicklesworthstone/tap/<tool-name>
```

## Available Packages

### Casks (GUI/TUI Applications)

| Package | Description | Install |
|---------|-------------|---------|
| **ntm** | Named Tmux Manager - Orchestrate AI coding agents in tmux sessions | `brew install --cask dicklesworthstone/tap/ntm` |

### Formulas (CLI Tools)

| Package | Description | Install |
|---------|-------------|---------|
| **bv** | Beads Viewer - Graph-aware task management TUI | `brew install dicklesworthstone/tap/bv` |
| **caam** | Coding Agent Account Manager - Switch between AI agent accounts | `brew install dicklesworthstone/tap/caam` |
| **slb** | Simultaneous Launch Button - Two-person rule for dangerous commands | `brew install dicklesworthstone/tap/slb` |
| **ru** | Repo Updater - Sync GitHub repositories to local projects directory | `brew install dicklesworthstone/tap/ru` |
| **cass** | Coding Agent Session Search - Unified agent history search | `brew install dicklesworthstone/tap/cass` |
| **xf** | X/Twitter data search tool | `brew install dicklesworthstone/tap/xf` |
| **cm** | Cass Memory System - Procedural memory for AI agents | `brew install dicklesworthstone/tap/cm` |
| **ubs** | Ultimate Bug Scanner - AI-friendly bug scanning with guardrails | `brew install dicklesworthstone/tap/ubs` |

> **Note**: Not all formulas are available yet. Check below for status.

## Package Status

| Package | Status | Auto-Update |
|---------|--------|-------------|
| ntm | Available | GoReleaser |
| bv | Coming Soon | GoReleaser |
| caam | Coming Soon | GoReleaser |
| slb | Coming Soon | GoReleaser |
| ru | Coming Soon | Manual |
| cass | Coming Soon | Manual |
| xf | Coming Soon | Manual |
| cm | Coming Soon | Manual |
| ubs | Coming Soon | Manual |

## Updating

To update all packages from this tap:

```bash
brew upgrade dicklesworthstone/tap/<tool-name>
```

Or update everything:

```bash
brew update && brew upgrade
```

## Troubleshooting

### Tap not found

If `brew tap dicklesworthstone/tap` fails:

```bash
# Check if tap exists
brew tap-info dicklesworthstone/tap

# Re-add the tap
brew untap dicklesworthstone/tap
brew tap dicklesworthstone/tap
```

### Package not installing

```bash
# Get detailed info
brew info dicklesworthstone/tap/<tool-name>

# Check for conflicts
brew doctor
```

### Checksum mismatch

This usually means a new release was published. Try:

```bash
brew update
brew reinstall dicklesworthstone/tap/<tool-name>
```

## Related Projects

- [ntm](https://github.com/Dicklesworthstone/ntm) - Named Tmux Manager
- [beads_viewer](https://github.com/Dicklesworthstone/beads_viewer) - Task management TUI
- [coding_agent_account_manager](https://github.com/Dicklesworthstone/coding_agent_account_manager) - Agent account switching
- [simultaneous_launch_button](https://github.com/Dicklesworthstone/simultaneous_launch_button) - Two-person rule
- [repo_updater](https://github.com/Dicklesworthstone/repo_updater) - Repository sync tool
- [coding_agent_session_search](https://github.com/Dicklesworthstone/coding_agent_session_search) - Session search
- [cass_memory_system](https://github.com/Dicklesworthstone/cass_memory_system) - Agent memory
- [ultimate_bug_scanner](https://github.com/Dicklesworthstone/ultimate_bug_scanner) - Bug scanner

## License

Each tool has its own license. Check the individual repositories for details.

## Contributing

This tap is auto-generated and maintained. For issues with specific tools, please file issues in their respective repositories.
