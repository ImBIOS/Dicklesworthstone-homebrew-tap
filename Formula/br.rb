# br (beads_rust) - Homebrew formula
# Agent-first issue tracker with SQLite + JSONL sync

class Br < Formula
  desc "Agent-first issue tracker with SQLite + JSONL sync"
  homepage "https://github.com/Dicklesworthstone/beads_rust"
  version "0.1.20"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-v#{version}-darwin_arm64.tar.gz"
      sha256 "705a13ab7c972bff97440656633210ca2c88cd49c1094a6007a98983d73fbb1d"
    end
    on_intel do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-v#{version}-darwin_amd64.tar.gz"
      sha256 "b53f109e3f288d23d2918bc9dcf7fa9997351d79bfab6be54ca18bc41d504d58"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-v#{version}-linux_amd64.tar.gz"
      sha256 "aefc2ef6b16c7b275f6890636c110540c7bc081e203a1e8a706a376207d1f9dd"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/beads_rust/releases/download/v#{version}/br-v#{version}-linux_arm64.tar.gz"
      sha256 "20899316274b7ac40de477f3318a3d6391f7885c6cd1bec7ba10e828360207fb"
    end
  end

  def install
    bin.install "br"
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
