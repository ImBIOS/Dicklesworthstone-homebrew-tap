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
    # cass has multi-arch binaries
    declare -A CHECKSUMS

    echo "Fetching checksums for cass..."
    for arch in "aarch64-apple-darwin" "x86_64-apple-darwin" "x86_64-unknown-linux-gnu" "aarch64-unknown-linux-gnu"; do
      URL="https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v${VERSION}/coding-agent-search-${arch}.tar.xz.sha256"
      CHECKSUMS[$arch]=$(curl -sL "$URL" | cut -d' ' -f1)
      echo "  $arch: ${CHECKSUMS[$arch]}"
    done

    # Update version
    sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"

    # Update checksums for each architecture
    # macOS ARM
    sed -i.bak "/on_arm do/,/end/{s/sha256 \"[a-f0-9]*\"/sha256 \"${CHECKSUMS[aarch64-apple-darwin]}\"/}" "$FORMULA_FILE"
    # macOS Intel
    sed -i.bak "/on_intel do/,/end/{s/sha256 \"[a-f0-9]*\"/sha256 \"${CHECKSUMS[x86_64-apple-darwin]}\"/}" "$FORMULA_FILE"
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

    # This is a simplified approach - more complex sed would be needed for multi-arch
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

  *)
    echo "Error: Unknown tool: $TOOL"
    echo "Supported tools: ru, cass, xf, cm, ubs"
    exit 1
    ;;
esac

# Clean up backup files
rm -f "$FORMULA_FILE.bak"

echo "Formula updated: $FORMULA_FILE"
echo ""
echo "Changes:"
git diff "$FORMULA_FILE" || true
