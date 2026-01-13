# Shell Completions Strategy

This document outlines how shell completions are handled for each tool in the Dicklesworthstone Stack.

## Completion Support Matrix

| Tool | Has Completions? | Framework | Generation Method | Shells |
|------|------------------|-----------|-------------------|--------|
| bv | Yes | Cobra | `bv completion <shell>` | bash, zsh, fish |
| caam | Yes | Cobra | `caam completion <shell>` | bash, zsh, fish, powershell |
| slb | Yes | Cobra | `slb completion <shell>` | bash, zsh, fish |
| ntm | Yes | Cobra | `ntm completion <shell>` | bash, zsh, fish |
| cass | Yes | Clap | `cass completions <shell>` | bash, zsh, fish, powershell, elvish |
| xf | Yes | Clap | `xf completions <shell>` | bash, zsh, fish |
| cm | No | N/A | N/A | - |
| ru | No | N/A | Static (bundled) | bash, zsh, fish |
| ubs | No | N/A | N/A | - |

## Implementation by Category

### Cobra-based Go Tools (bv, caam, slb, ntm)

These tools use the [Cobra](https://github.com/spf13/cobra) CLI framework which provides built-in completion generation.

**Formula pattern:**
```ruby
def install
  bin.install "tool"
  generate_completions_from_executable(bin/"tool", "completion")
end
```

Homebrew's `generate_completions_from_executable` helper automatically:
- Runs the completion command for bash, zsh, and fish
- Installs to the correct completion directories

### Clap-based Rust Tools (cass, xf)

These tools use the [Clap](https://github.com/clap-rs/clap) CLI framework with completion generation.

**Formula pattern:**
```ruby
def install
  bin.install "tool"

  # Clap uses different subcommand name
  output = Utils.safe_popen_read("#{bin}/tool", "completions", "bash")
  (bash_completion/"tool").write output

  output = Utils.safe_popen_read("#{bin}/tool", "completions", "zsh")
  (zsh_completion/"_tool").write output

  output = Utils.safe_popen_read("#{bin}/tool", "completions", "fish")
  (fish_completion/"tool.fish").write output
end
```

### Tools with Static Completions (ru)

Some tools don't have built-in completion generation. For these, we bundle static completion scripts.

**Formula pattern:**
```ruby
def install
  bin.install "ru"

  # Install bundled static completions
  bash_completion.install "completions/ru.bash" => "ru"
  zsh_completion.install "completions/_ru"
  fish_completion.install "completions/ru.fish"
end
```

Static completions are stored in this directory:
- `completions/ru.bash` - Bash completion
- `completions/_ru` - Zsh completion (underscore prefix is convention)
- `completions/ru.fish` - Fish completion

### Tools Without Completions (cm, ubs)

Some tools don't have completion support:

- **cm** (cass-memory): TypeScript/Bun CLI, completion generation would need to be added upstream
- **ubs** (ultimate-bug-scanner): Bash script wrapper around multiple linters, complex subcommand structure

These are lower priority for completion support. If users request it, we can:
1. Add completion generation to the upstream tool
2. Create static completions here

## Completion Installation Paths

Homebrew installs completions to:

| Shell | Path |
|-------|------|
| Bash | `$(brew --prefix)/etc/bash_completion.d/` |
| Zsh | `$(brew --prefix)/share/zsh/site-functions/` |
| Fish | `$(brew --prefix)/share/fish/vendor_completions.d/` |

## Testing Completions

After installing a tool, verify completions work:

```bash
# Bash (restart shell or source completion)
source $(brew --prefix)/etc/bash_completion.d/tool
tool <TAB>

# Zsh (may need compinit)
compinit
tool <TAB>

# Fish (should work immediately)
tool <TAB>
```

## User Setup

Most users need to enable Homebrew's completions in their shell rc:

**Bash** (`~/.bashrc`):
```bash
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && \
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
```

**Zsh** (`~/.zshrc`):
```zsh
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit && compinit
fi
```

**Fish**: Completions should work automatically.

## Adding New Tools

When adding a new tool, check:

1. Does the tool have `--help | grep -i completion`?
2. Try `tool completion --help` or `tool completions --help`
3. If yes: Use `generate_completions_from_executable` or manual generation
4. If no: Create static completions or skip (document why)
