# typed: false
# frozen_string_literal: true

# br (beads_rust) - Homebrew formula
# Agent-first issue tracker with SQLite + JSONL sync

class Br < Formula
  desc "Agent-first issue tracker with SQLite + JSONL sync"
  homepage "https://github.com/Dicklesworthstone/beads_rust"
  version "0.2.10"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-#{version}-darwin_arm64.tar.gz"
      sha256 "00ff833d0cb1ef0f651c75a6de0a08bed970bc4e7ef1075230a9fcbadadda372"
    end
    on_intel do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-#{version}-darwin_amd64.tar.gz"
      sha256 "c76bacf98956416620385e74aa5e2d100ffa3d66a50b0eae65f895c902733a11"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-#{version}-linux_amd64.tar.gz"
      sha256 "f6388af90de58d1a98af720db061237147d964eff8fa52fdc8a50441f851f730"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-#{version}-linux_arm64.tar.gz"
      sha256 "11ed13cd0a5ed50042de5e3d946dba9844c97fcc862a820cfd9a120464bbd99d"
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
