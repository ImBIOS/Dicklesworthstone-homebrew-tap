# Changelog

All notable changes to the **Dicklesworthstone Homebrew Tap** are documented here.

This is an auto-maintained Homebrew tap for the Dicklesworthstone tool stack. Formula version bumps are often automated via `repository_dispatch` from source repos or the 6-hour scheduled polling workflow. This changelog captures both formula additions and tap infrastructure changes.

Repository: <https://github.com/Dicklesworthstone/homebrew-tap>

---

## 2026-03-21

### cass formula v0.2.2 -- dispatch-payload checksum support

- Updated cass formula to v0.2.2 with verified SHA256 checksums.
- Auto-update workflow now accepts checksums inline via `repository_dispatch` payload (`client_payload.checksums`), eliminating the need for a second commit to fix SHA256 drift after auto-update.
- Modernized cass release asset naming convention (e.g., `cass-darwin-arm64.tar.gz`).
- Removed macOS Intel (`x86_64-apple-darwin`) build target from cass formula; Rosetta 2 covers Intel Macs from the ARM build.

Representative commits:
- [c86bbff](https://github.com/Dicklesworthstone/homebrew-tap/commit/c86bbffc89eaf730ba856cd916f84d15d1e53258) -- dispatch-payload checksum support, formula v0.2.2 checksums, modernized asset names
- [37f4275](https://github.com/Dicklesworthstone/homebrew-tap/commit/37f4275ff564f69d92bad323c9cdfcd9a4a363f5) -- auto-update cass to v0.2.2

---

## 2026-03-08 .. 2026-03-11

### cass formula v0.2.1, bv formula v0.15.0

- Updated cass formula to v0.2.1 with corrected checksums.
- Updated bv (Beads Viewer) formula to v0.15.0 via GoReleaser.

Representative commits:
- [338f0cb](https://github.com/Dicklesworthstone/homebrew-tap/commit/338f0cb04cfa66fd27279be3aa0d03820b4141d8) -- bv v0.15.0
- [643a4cd](https://github.com/Dicklesworthstone/homebrew-tap/commit/643a4cde2ccdca83f3ecc90b373cb210243d6918) -- auto-update cass to v0.2.1
- [a9ca0e9](https://github.com/Dicklesworthstone/homebrew-tap/commit/a9ca0e97c0936bb5f48f53145d8951d53fe563ea) -- correct cass v0.2.1 checksums

---

## 2026-03-07

### ntm cask v1.8.0

- Updated ntm (Named Tmux Manager) cask to v1.8.0 via GoReleaser.

Representative commit:
- [88480cb](https://github.com/Dicklesworthstone/homebrew-tap/commit/88480cb3b1a91ca4d88493f06019aef91d7baca9)

---

## 2026-03-02 .. 2026-03-06

### cass formula v0.2.0, br formula added (v0.1.20, then v0.1.21)

- **New formula: `br` (beads_rust)** -- agent-first issue tracker with SQLite + JSONL sync. Multi-arch support for macOS (Intel + ARM) and Linux (x86_64 + ARM64). Includes shell completions and an `init`-based test block.
- Updated br formula to v0.1.21 the same day.
- Updated cass formula to v0.2.0 with subsequent checksum correction.

Representative commits:
- [568506b](https://github.com/Dicklesworthstone/homebrew-tap/commit/568506bea0747b86dc12dab36c25df15eb6ef5e7) -- add br formula for v0.1.20
- [36a267d](https://github.com/Dicklesworthstone/homebrew-tap/commit/36a267de1ee3a7d3dc8ece21ea4ab2a2f9561c24) -- update br to v0.1.21
- [7b42bf1](https://github.com/Dicklesworthstone/homebrew-tap/commit/7b42bf1537779db54cdc96723ba9bfb65814b7a3) -- auto-update cass to v0.2.0
- [2b0e687](https://github.com/Dicklesworthstone/homebrew-tap/commit/2b0e687d3b940101b04c5c45c5c24d4e444dca42) -- fix cass v0.2.0 checksums

---

## 2026-02-21 .. 2026-02-23

### License update, tru formula v0.2.1

- License changed from MIT to **MIT with OpenAI/Anthropic Rider**.
- README updated to reflect new license.
- Added GitHub social preview image.
- Updated tru (TOON encoder/decoder) formula to v0.2.1 via auto-update.

Representative commits:
- [e105d05](https://github.com/Dicklesworthstone/homebrew-tap/commit/e105d05db2c498b4f2e80da7440524a397831bc3) -- update license to MIT with OpenAI/Anthropic Rider
- [adbefa8](https://github.com/Dicklesworthstone/homebrew-tap/commit/adbefa8003c80489a3395b46fd521b97c42e8fd1) -- README license references
- [0eb5108](https://github.com/Dicklesworthstone/homebrew-tap/commit/0eb5108fd90d39f733ec007f70530ece0b4042c1) -- auto-update tru to v0.2.1

---

## 2026-02-10 .. 2026-02-15

### dcg formula v0.4.0, tru formula v0.2.0, bv formula v0.14.4

- Updated dcg (Destructive Command Guard) formula to v0.4.0 via auto-update.
- Updated tru (TOON) formula to v0.2.0 via auto-update.
- Fixed bv formula that was out of sync at v0.14.4 (tap had fallen behind source releases).
- Fixed macOS compatibility issues across test scripts: replaced GNU-only `grep -oP` and `\s` patterns with POSIX-portable `sed` and `[[:space:]]`.
- Fixed cross-repo test path pointing to scoop-bucket.
- Fixed BRE alternation bugs and brew uninstall clean-check logic in E2E tests.

Representative commits:
- [0d6a8b8](https://github.com/Dicklesworthstone/homebrew-tap/commit/0d6a8b83dde7442068fd28e227a361a6ef1f4b2d) -- auto-update dcg to v0.4.0
- [f0e1698](https://github.com/Dicklesworthstone/homebrew-tap/commit/f0e16983d06ddb14c5d1069d174ac6f01b199102) -- auto-update tru to v0.2.0
- [119e138](https://github.com/Dicklesworthstone/homebrew-tap/commit/119e1388719f4cd65f714f6a7ef287c4f11a08dc) -- fix bv out-of-sync at v0.14.4
- [6bb24f9](https://github.com/Dicklesworthstone/homebrew-tap/commit/6bb24f9d5616c215815b5743811c76ef7a7ca7c4) -- POSIX [[:space:]] compat
- [8e6ae80](https://github.com/Dicklesworthstone/homebrew-tap/commit/8e6ae801adbfa23ca0904a5bc0fbca691152248b) -- replace grep -oP with sed for macOS

---

## 2026-02-09

### New formulas: dcg v0.3.0. E2E test suite for package distribution. Installation verification.

- **New formula: `dcg` (Destructive Command Guard) v0.3.0** -- safety rails for AI coding agents. macOS ARM and Linux x86_64 builds only at this version.
- Added dcg and tru to the auto-update scheduled workflow matrix.
- README updated: moved bv/caam/slb to "available" section, added dcg/tru.
- **New E2E test suite** (`scripts/e2e-test-suite.sh`) for the full package distribution pipeline -- validates Homebrew install/uninstall, Scoop manifests, and cross-repo consistency.
- **Installation lifecycle verification** (`scripts/verify-installation.sh`) -- checks install, upgrade, downgrade, and rollback paths.
- Added rollback and recovery documentation.
- Updated tru formula contents for the `tru -> toon` rename in the source binary.

Representative commits:
- [ca69cfe](https://github.com/Dicklesworthstone/homebrew-tap/commit/ca69cfefa0108daa5d86fe160b98d9093ec9e4f1) -- add dcg formula for v0.3.0
- [034ce35](https://github.com/Dicklesworthstone/homebrew-tap/commit/034ce350d8918110b83ae90704d6cd2b6ad0789f) -- E2E test suite for package distribution
- [a2a497c](https://github.com/Dicklesworthstone/homebrew-tap/commit/a2a497c3bdd2712f007d4558b6491b198e15ef62) -- installation verification scripts
- [347883e](https://github.com/Dicklesworthstone/homebrew-tap/commit/347883e594a77a077e9dd9dc83ee598cb0b8df8a) -- installation lifecycle verification script
- [14b2bab](https://github.com/Dicklesworthstone/homebrew-tap/commit/14b2bab8414bceb70f8ece37515a1fcc3a3f47f9) -- rollback and recovery docs

---

## 2026-02-08

### Unit test framework for update-formula.sh

- Added `scripts/test-helpers.sh` and `scripts/test-runner.sh` -- a lightweight shell-based unit test framework.
- Comprehensive unit tests for `update-formula.sh` (16 tests, 43 assertions) covering version replacement, checksum updates, and edge cases.

Representative commits:
- [c44fcfe](https://github.com/Dicklesworthstone/homebrew-tap/commit/c44fcfe1460e9f6a5254c2ae36c21c686fb287f6) -- add unit test framework
- [3dae2c2](https://github.com/Dicklesworthstone/homebrew-tap/commit/3dae2c211e20f94738cedd2ad22d48ab19c83f20) -- comprehensive unit tests for update-formula.sh

---

## 2026-02-02 .. 2026-02-05

### bv v0.14.1-v0.14.3, ntm cask v1.7.0, tru binary name fix, cass v0.1.64 checksum fix

- Rapid bv (Beads Viewer) releases: v0.14.1, v0.14.2, v0.14.3 in one day, all via GoReleaser.
- Updated ntm cask to v1.7.0 via GoReleaser.
- Auto-updated cass formula to v0.1.64, then corrected SHA256 hashes that drifted.
- Fixed `tru` formula binary name: briefly renamed to `toon` to match upstream, then **reverted back to `tru`** after deciding the binary should remain `tru` (to avoid coreutils `tr` conflict while keeping a short name).
- Bumped tru formula to v0.1.2 after the binary name stabilized.
- Fixed escaped quotes in ntm.rb caveats.

Representative commits:
- [4dd175b](https://github.com/Dicklesworthstone/homebrew-tap/commit/4dd175b3cfdceb6bf0d3750e28c2059e78d1a871) -- bv v0.14.3
- [3983d26](https://github.com/Dicklesworthstone/homebrew-tap/commit/3983d263e1a1225d0ca09706c24021e985d94cd7) -- fix cass v0.1.64 checksums
- [ba972fa](https://github.com/Dicklesworthstone/homebrew-tap/commit/ba972fa73a1ed4424ecee65dcbafc2275d94f28e) -- revert toon->tru binary name
- [bd5b81e](https://github.com/Dicklesworthstone/homebrew-tap/commit/bd5b81efec8c23381167d644ac71d0fe824f4e9a) -- tru bumped to v0.1.2

---

## 2026-01-27 .. 2026-01-29

### cass formula v0.1.63, asset name fix

- Auto-updated cass to v0.1.63.
- Fixed cass formula to match actual GitHub release asset names (naming convention had changed upstream).

Representative commits:
- [8a3ca28](https://github.com/Dicklesworthstone/homebrew-tap/commit/8a3ca280585160b1aeea869a6e31448d3ce27dd4) -- auto-update cass to v0.1.63
- [90eee7d](https://github.com/Dicklesworthstone/homebrew-tap/commit/90eee7d27b6845898f62da7504bf808112815a8e) -- fix cass formula asset names

---

## 2026-01-24

### New formula: tru (TOON). Deprecated: tr. cass v0.1.61. CI fix.

- **New formula: `tru` (TOON encoder/decoder)** -- Token-Optimized Object Notation, initially at v0.1.0, rapidly updated to v0.1.1, then switched to prebuilt release assets.
- **Deprecated formula: `tr`** -- the old name conflicted with coreutils `tr`. Added `disable!` directive pointing users to `tru`.
- Auto-updated cass to v0.1.61.
- Fixed auto-update workflow push failures (race condition when multiple matrix jobs push concurrently).

Representative commits:
- [bdafa45](https://github.com/Dicklesworthstone/homebrew-tap/commit/bdafa4578a35f94ec894772cb86efaac78e08729) -- add tru formula and deprecate tr
- [a57e7b4](https://github.com/Dicklesworthstone/homebrew-tap/commit/a57e7b4d8084fac39b92dc252b111883ceeb5a81) -- tru: switch to prebuilt release assets
- [c6d6fde](https://github.com/Dicklesworthstone/homebrew-tap/commit/c6d6fdea6d1af29e4483e55242f256d0ef718422) -- fix auto-update workflow push failures

---

## 2026-01-21

### MIT License added, caam formula v0.1.10

- Added `LICENSE` file (MIT).
- Updated caam (Coding Agent Account Manager) formula to v0.1.10 via GoReleaser.

Representative commits:
- [48427de](https://github.com/Dicklesworthstone/homebrew-tap/commit/48427de8b42cd7d99b0bb2f40193b97b651f98c0) -- add MIT License
- [63dfb6e](https://github.com/Dicklesworthstone/homebrew-tap/commit/63dfb6ed5abd0bdae50999009b19709592bca4e0) -- caam v0.1.10

---

## 2026-01-13 .. 2026-01-17

### Tap foundation: formulas, CI, E2E tests, update scripts, documentation

This date range represents the foundational buildout of the tap as a serious distribution channel.

#### Formulas added
- **`ru` (Repo Updater)** -- bash script formula, downloads single-file release from GitHub. Includes static bash/zsh/fish completions and depends on `git`, `gh`, and `gum`.
- **`cass` (Coding Agent Session Search)** -- multi-arch Rust binary (macOS ARM/Intel, Linux x86_64/ARM64). Shell completions via `generate_completions_from_executable`.
- **`xf` (X-Former)** -- multi-arch Rust binary for searching Twitter/X archives.
- **`cm` (CASS Memory System)** -- Bun-compiled binary for persistent AI agent memory.
- **`ubs` (Ultimate Bug Scanner)** -- bash script formula for code analysis.
- **`bv` (Beads Viewer) v0.13.0** -- GoReleaser-managed Go binary, graph-aware task management TUI.
- **`slb` (Simultaneous Launch Button) v0.2.0** -- GoReleaser-managed Go binary, two-person rule for dangerous commands.
- **`caam` (Coding Agent Account Manager) v0.1.2** -- GoReleaser-managed Go binary. Updated through v0.1.3 and v0.1.4 during the same period.

#### CI and testing
- `test-formulas.yml` workflow: Ruby syntax validation, `brew audit --strict --online`, full install/test/uninstall on macOS 13, macOS 14, and Ubuntu 22.04.
- Weekly scheduled test runs with platform summaries.
- `e2e-tests.yml` workflow for comprehensive end-to-end functional testing.
- `auto-update.yml` workflow: handles `repository_dispatch`, `workflow_dispatch`, and 6-hour scheduled polling. Matrix of 7 tools (ru, cass, xf, cm, ubs, dcg, tru). Retry-with-rebase on concurrent push conflicts.

#### Scripts
- `scripts/update-formula.sh` -- fetches checksums from GitHub releases and patches formula version/SHA256.
- `scripts/validate-formulas.sh` -- checks formula quality (required fields, Ruby syntax, optional `brew audit`).
- `scripts/e2e-test-suite.sh` -- full E2E install-test-uninstall cycle.
- `scripts/setup-hooks.sh` -- shell completions setup helper.

#### Documentation
- Comprehensive README with tool catalog, platform support matrix, troubleshooting guide, maintainer guide, release checklists per tool type (GoReleaser, Rust, Bun, Bash), required secrets documentation.

#### Formula quality fixes
- Resolved Rubocop style violations in bv and slb formulas.
- Fixed test blocks to use `bin/"name"` format.
- Added then removed explicit `version` attributes for ru and ubs (bash scripts that get version from URL).
- Fixed CI: formula names vs paths for `brew audit`, untap-before-re-tap, cleanup step ordering, name-based cask auditing.

Representative commits:
- [932e540](https://github.com/Dicklesworthstone/homebrew-tap/commit/932e540103b015640b9d34895c021c42098abcba) -- add Formula directory and comprehensive README
- [755b7c5](https://github.com/Dicklesworthstone/homebrew-tap/commit/755b7c5c1caee30fac5ace7b39d92cb31a9588ae) -- add ru formula
- [94e3645](https://github.com/Dicklesworthstone/homebrew-tap/commit/94e3645ee82ba2644282d2feebe1bc8c33160a8d) -- add cass and xf formulas
- [ba081f4](https://github.com/Dicklesworthstone/homebrew-tap/commit/ba081f4317f13121b196ab1ea6f8ee09cd685d04) -- add cm and ubs formulas
- [92534b3](https://github.com/Dicklesworthstone/homebrew-tap/commit/92534b34c05c7cbf91c10cd65d79ddbd67096b03) -- auto-update workflow
- [06c0a93](https://github.com/Dicklesworthstone/homebrew-tap/commit/06c0a93cbafbc06afa567c71efdebbda7d44a097) -- comprehensive README
- [eed3eb3](https://github.com/Dicklesworthstone/homebrew-tap/commit/eed3eb3d9cc44b55207b9ff69737f9897c483445) -- rewrite cass checksum update script
- [842230](https://github.com/Dicklesworthstone/homebrew-tap/commit/842230851d11ea1e4547b270eda2b6ad3bb02363) -- resolve Rubocop violations

---

## 2025-12-14 .. 2026-01-06

### ntm cask: initial addition and rapid iteration (v1.2.0 through v1.5.0)

The very first commit to this repository. GoReleaser from the ntm (Named Tmux Manager) source repo created the cask automatically.

- **ntm cask v1.2.0** -- initial cask (2025-12-14). macOS universal build, Linux x86_64/ARM64. Depends on `tmux`.
- **ntm v1.3.0** (2026-01-03)
- **ntm v1.4.0** (2026-01-04)
- **ntm v1.4.1** (2026-01-04)
- **ntm v1.5.0** (2026-01-06)
- Fixed Ruby syntax error in ntm caveats by switching to heredoc format.

Representative commits:
- [2be2201](https://github.com/Dicklesworthstone/homebrew-tap/commit/2be2201b14f59e80de89e245fec2d1b905307ff8) -- initial commit, ntm cask v1.2.0
- [95c8605](https://github.com/Dicklesworthstone/homebrew-tap/commit/95c86056903053672f442381843b8cc1a0da7059) -- fix ntm caveats heredoc syntax

---

## Current formula versions (as of 2026-03-21)

| Formula | Version | Type | Source |
|---------|---------|------|--------|
| br      | 0.1.21  | Rust binary (multi-arch) | [beads_rust](https://github.com/Dicklesworthstone/beads_rust) |
| bv      | 0.15.0  | GoReleaser (Go) | [beads_viewer](https://github.com/Dicklesworthstone/beads_viewer) |
| caam    | 0.1.10  | GoReleaser (Go) | [coding_agent_account_manager](https://github.com/Dicklesworthstone/coding_agent_account_manager) |
| cass    | 0.2.2   | Rust binary (multi-arch) | [coding_agent_session_search](https://github.com/Dicklesworthstone/coding_agent_session_search) |
| cm      | 0.2.3   | Bun binary (multi-arch) | [cass_memory_system](https://github.com/Dicklesworthstone/cass_memory_system) |
| dcg     | 0.4.0   | Rust binary (macOS ARM + Linux x86) | [destructive_command_guard](https://github.com/Dicklesworthstone/destructive_command_guard) |
| ntm     | 1.8.0   | GoReleaser cask (Go) | [ntm](https://github.com/Dicklesworthstone/ntm) |
| ru      | 1.2.1   | Bash script | [repo_updater](https://github.com/Dicklesworthstone/repo_updater) |
| slb     | 0.2.0   | GoReleaser (Go) | [simultaneous_launch_button](https://github.com/Dicklesworthstone/simultaneous_launch_button) |
| tr      | --      | **Deprecated** (renamed to tru) | [toon_rust](https://github.com/Dicklesworthstone/toon_rust) |
| tru     | 0.2.1   | Rust binary (multi-arch) | [toon_rust](https://github.com/Dicklesworthstone/toon_rust) |
| ubs     | latest  | Bash script | [ultimate_bug_scanner](https://github.com/Dicklesworthstone/ultimate_bug_scanner) |
| xf      | 0.2.0   | Rust binary (multi-arch) | [xf](https://github.com/Dicklesworthstone/xf) |
