# typed: false
# frozen_string_literal: true

# br (beads_rust) - Homebrew formula
# Agent-first issue tracker with SQLite + JSONL sync

class Br < Formula
  desc "Agent-first issue tracker with SQLite + JSONL sync"
  homepage "https://github.com/Dicklesworthstone/beads_rust"
  version "0.1.21"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-v#{version}-darwin_arm64.tar.gz"
      sha256 "0e2b96b6d89fdf7d5a1b8ae2d3b0fa5c5d739ea598f49b46c93629a0cbb0bdc1"
    end
    on_intel do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-v#{version}-darwin_amd64.tar.gz"
      sha256 "d49d426147d6d7269fa3562178021c13dc2c006fdc417be0b08ac260be0453e6"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-v#{version}-linux_amd64.tar.gz"
      sha256 "10d1ac74ce8eab761fb72ff632fc019edad75dd4d49c867c4655f53684d18832"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-v#{version}-linux_arm64.tar.gz"
      sha256 "50ac4fdd829e63d2b36158fad038855b19e5f17394a5fd1a09f970842e23b761"
    end
  end

  def install
    bin.install "br"

    generate_completions_from_executable(bin/"br", "completions")
  end

  def caveats
    <<~EOS
      br is an agent-first issue tracker that stores issues in both
      SQLite (for speed) and JSONL (for git-friendliness).

      Quick start:
        br init                  # Initialize in current project
        br create "Fix the bug"  # Create an issue
        br list                  # List all issues
        br doctor                # Run diagnostics

      For AI agents, use --json flag:
        br list --json
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/br --version")
    system bin/"br", "init"
    assert_predicate testpath/".beads", :directory?
  end
end
