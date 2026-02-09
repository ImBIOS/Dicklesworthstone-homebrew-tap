#!/usr/bin/env bash
# Auto-update Homebrew formula for a specific tool
# Usage: ./update-formula.sh <tool> <version>
set -euo pipefail

TOOL="${1:-}"
VERSION="${2:-}"

if [[ -z "$TOOL" || -z "$VERSION" ]]; then
  echo "Usage: $0 <tool> <version>"
  echo "Example: $0 ru 1.2.2"
  exit 1
fi

# Strip 'v' prefix if present
VERSION="${VERSION#v}"

FORMULA_FILE="Formula/${TOOL}.rb"

if [[ ! -f "$FORMULA_FILE" ]]; then
  echo "Error: Formula file not found: $FORMULA_FILE"
  exit 1
fi

echo "Updating $TOOL to version $VERSION"

# Tool-specific update logic
case "$TOOL" in
  ru)
    # ru is a single bash script
    URL="https://github.com/Dicklesworthstone/repo_updater/releases/download/v${VERSION}/ru"
    echo "Fetching checksum for ru..."
    CHECKSUM=$(curl -sL "${URL}" | sha256sum | cut -d' ' -f1)

    # Update version
    sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"
    # Update checksum
    sed -i.bak "s/sha256 \"[a-f0-9]*\"/sha256 \"${CHECKSUM}\"/" "$FORMULA_FILE"
    ;;

  cass)
    # cass has multi-arch binaries (macOS Intel/ARM + Linux Intel/ARM)
    echo "Fetching checksums for cass..."

    MACOS_ARM=$(curl -sL "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v${VERSION}/coding-agent-search-aarch64-apple-darwin.tar.xz.sha256" | cut -d' ' -f1)
    MACOS_INTEL=$(curl -sL "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v${VERSION}/coding-agent-search-x86_64-apple-darwin.tar.xz.sha256" | cut -d' ' -f1)
    LINUX_ARM=$(curl -sL "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v${VERSION}/coding-agent-search-aarch64-unknown-linux-gnu.tar.xz.sha256" | cut -d' ' -f1)
    LINUX_INTEL=$(curl -sL "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v${VERSION}/coding-agent-search-x86_64-unknown-linux-gnu.tar.xz.sha256" | cut -d' ' -f1)

    echo "  macOS ARM: $MACOS_ARM"
    echo "  macOS Intel: $MACOS_INTEL"
    echo "  Linux ARM: $LINUX_ARM"
    echo "  Linux Intel: $LINUX_INTEL"

    # Update version
    sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"

    # Update checksums using Ruby-aware replacement (match by URL content to disambiguate blocks)
    ruby -i.bak -e '
      content = File.read(ARGV[0])
      # Replace macOS Intel checksum (url contains x86_64-apple-darwin)
      content.gsub!(/url[^\n]+x86_64-apple-darwin[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_INTEL"'\"")
      }
      # Replace macOS ARM checksum (url contains aarch64-apple-darwin)
      content.gsub!(/url[^\n]+aarch64-apple-darwin[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_ARM"'\"")
      }
      # Replace Linux Intel checksum (url contains x86_64-unknown-linux-gnu)
      content.gsub!(/url[^\n]+x86_64-unknown-linux-gnu[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$LINUX_INTEL"'\"")
      }
      # Replace Linux ARM checksum (url contains aarch64-unknown-linux-gnu)
      content.gsub!(/url[^\n]+aarch64-unknown-linux-gnu[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$LINUX_ARM"'\"")
      }
      File.write(ARGV[0], content)
    ' "$FORMULA_FILE"
    ;;

  xf)
    # xf has multi-arch binaries
    echo "Fetching checksums from xf release..."
    SUMS=$(curl -sL "https://github.com/Dicklesworthstone/xf/releases/download/v${VERSION}/SHA256SUMS")

    MACOS_ARM=$(echo "$SUMS" | grep "aarch64-apple-darwin" | cut -d' ' -f1)
    MACOS_INTEL=$(echo "$SUMS" | grep "x86_64-apple-darwin" | cut -d' ' -f1)
    LINUX_INTEL=$(echo "$SUMS" | grep "x86_64-unknown-linux-gnu" | cut -d' ' -f1)

    echo "  macOS ARM: $MACOS_ARM"
    echo "  macOS Intel: $MACOS_INTEL"
    echo "  Linux Intel: $LINUX_INTEL"

    # Update version
    sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"

    # Update checksums using Ruby-aware replacement
    # macOS Intel (on_macos + on_intel block)
    ruby -i.bak -e '
      content = File.read(ARGV[0])
      # Replace macOS Intel checksum (first sha256 in on_macos/on_intel)
      content.gsub!(/on_macos do\s+on_intel do\s+url[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_INTEL"'\"")
      }
      # Replace macOS ARM checksum (on_arm block inside on_macos)
      content.gsub!(/on_arm do\s+url[^\n]+darwin[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_ARM"'\"")
      }
      # Replace Linux Intel checksum
      content.gsub!(/on_linux do\s+on_intel do\s+url[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$LINUX_INTEL"'\"")
      }
      File.write(ARGV[0], content)
    ' "$FORMULA_FILE"
    ;;

  cm)
    # cm has multi-arch binaries
    echo "Fetching checksums for cm..."

    MACOS_ARM_CHECKSUM=$(curl -sL "https://github.com/Dicklesworthstone/cass_memory_system/releases/download/v${VERSION}/cass-memory-macos-arm64.sha256" | cut -d' ' -f1)
    MACOS_INTEL_CHECKSUM=$(curl -sL "https://github.com/Dicklesworthstone/cass_memory_system/releases/download/v${VERSION}/cass-memory-macos-x64.sha256" | cut -d' ' -f1)
    LINUX_CHECKSUM=$(curl -sL "https://github.com/Dicklesworthstone/cass_memory_system/releases/download/v${VERSION}/cass-memory-linux-x64.sha256" | cut -d' ' -f1)

    echo "  macOS ARM: $MACOS_ARM_CHECKSUM"
    echo "  macOS Intel: $MACOS_INTEL_CHECKSUM"
    echo "  Linux: $LINUX_CHECKSUM"

    # Update version
    sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"

    # Update checksums using Ruby-aware replacement
    ruby -i.bak -e '
      content = File.read(ARGV[0])
      # Replace macOS Intel checksum (on_macos/on_intel block)
      content.gsub!(/on_macos do\s+on_intel do\s+url[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_INTEL_CHECKSUM"'\"")
      }
      # Replace macOS ARM checksum (on_arm block inside on_macos)
      content.gsub!(/on_arm do\s+url[^\n]+arm64[^\n]*\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_ARM_CHECKSUM"'\"")
      }
      # Replace Linux Intel checksum
      content.gsub!(/on_linux do\s+on_intel do\s+url[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$LINUX_CHECKSUM"'\"")
      }
      File.write(ARGV[0], content)
    ' "$FORMULA_FILE"
    ;;

  ubs)
    # ubs is a bash script fetched from raw.githubusercontent.com
    URL="https://raw.githubusercontent.com/Dicklesworthstone/ultimate_bug_scanner/v${VERSION}/ubs"
    echo "Fetching checksum for ubs..."
    CHECKSUM=$(curl -sL "${URL}" | sha256sum | cut -d' ' -f1)

    # Update version
    sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"
    # Update checksum
    sed -i.bak "s/sha256 \"[a-f0-9]*\"/sha256 \"${CHECKSUM}\"/" "$FORMULA_FILE"
    ;;

  dcg)
    # dcg is a Rust binary with per-platform .sha256 files
    echo "Fetching checksums for dcg..."

    MACOS_ARM=$(curl -sL "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v${VERSION}/dcg-aarch64-apple-darwin.tar.xz.sha256" | cut -d' ' -f1)
    LINUX_INTEL=$(curl -sL "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v${VERSION}/dcg-x86_64-unknown-linux-gnu.tar.xz.sha256" | cut -d' ' -f1)

    echo "  macOS ARM: $MACOS_ARM"
    echo "  Linux Intel: $LINUX_INTEL"

    # Update version
    sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"

    # Update checksums using Ruby-aware replacement
    ruby -i.bak -e '
      content = File.read(ARGV[0])
      content.gsub!(/url[^\n]+aarch64-apple-darwin[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_ARM"'\"")
      }
      content.gsub!(/url[^\n]+x86_64-unknown-linux-gnu[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$LINUX_INTEL"'\"")
      }
      File.write(ARGV[0], content)
    ' "$FORMULA_FILE"
    ;;

  tru)
    # tru (toon_rust) has multi-arch binaries with per-platform .sha256 files
    echo "Fetching checksums for tru..."

    MACOS_INTEL=$(curl -sL "https://github.com/Dicklesworthstone/toon_rust/releases/download/v${VERSION}/toon-darwin-amd64.tar.xz.sha256" | cut -d' ' -f1)
    MACOS_ARM=$(curl -sL "https://github.com/Dicklesworthstone/toon_rust/releases/download/v${VERSION}/toon-darwin-arm64.tar.xz.sha256" | cut -d' ' -f1)
    LINUX_INTEL=$(curl -sL "https://github.com/Dicklesworthstone/toon_rust/releases/download/v${VERSION}/toon-linux-amd64.tar.xz.sha256" | cut -d' ' -f1)
    LINUX_ARM=$(curl -sL "https://github.com/Dicklesworthstone/toon_rust/releases/download/v${VERSION}/toon-linux-arm64.tar.xz.sha256" | cut -d' ' -f1)

    echo "  macOS Intel: $MACOS_INTEL"
    echo "  macOS ARM: $MACOS_ARM"
    echo "  Linux Intel: $LINUX_INTEL"
    echo "  Linux ARM: $LINUX_ARM"

    # Update version
    sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"

    # Update checksums using Ruby-aware replacement
    ruby -i.bak -e '
      content = File.read(ARGV[0])
      content.gsub!(/url[^\n]+darwin-amd64[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_INTEL"'\"")
      }
      content.gsub!(/url[^\n]+darwin-arm64[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$MACOS_ARM"'\"")
      }
      content.gsub!(/url[^\n]+linux-amd64[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$LINUX_INTEL"'\"")
      }
      content.gsub!(/url[^\n]+linux-arm64[^\n]+\n\s+sha256 "[a-f0-9]+"/) { |m|
        m.sub(/sha256 "[a-f0-9]+"/, "sha256 \"'"$LINUX_ARM"'\"")
      }
      File.write(ARGV[0], content)
    ' "$FORMULA_FILE"
    ;;

  *)
    echo "Error: Unknown tool: $TOOL"
    echo "Supported tools: ru, cass, xf, cm, ubs, dcg, tru"
    exit 1
    ;;
esac

# Clean up backup files
rm -f "$FORMULA_FILE.bak"

echo "Formula updated: $FORMULA_FILE"
echo ""
echo "Changes:"
git diff "$FORMULA_FILE" || true
