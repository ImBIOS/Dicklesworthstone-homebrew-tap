# CASS (Coding Agent Session Search) - Homebrew formula
# Index and search AI coding agent conversation histories

class Cass < Formula
  desc "Cross-agent session search - index and search AI coding agent conversations"
  homepage "https://github.com/Dicklesworthstone/coding_agent_session_search"
  version "0.5.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-darwin-arm64.tar.gz"
      sha256 "d032898c9fbc5626a36024d47150d5559e6f978f5ca43b8db3e87b661341c413"
    end
    # No Intel macOS build is published for cass v0.4.7.
    # Intel macOS users should use the upstream install script with --from-source.
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-linux-amd64.tar.gz"
      sha256 "7ca7f727f4a7dbabbbb8b8b5661c9c1c03f4889874acf48ac86341ae3e69c289"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-linux-arm64.tar.gz"
      sha256 "ae228c232ef47c0b052af14ee8125ea3355b0d63fef4349b5cecee226238eec6"
    end
  end

  def install
    bin.install "cass"

    # Generate shell completions using built-in support
    generate_completions_from_executable(bin/"cass", "completions")
  end

  def caveats
    <<~EOS
      cass indexes AI coding agent sessions from Claude Code, Codex, Cursor,
      Gemini, ChatGPT, and more.

      Quick start:
        cass health              # Check setup and indexing status
        cass search "error"      # Search across all sessions

      For AI agents, always use --robot or --json flags:
        cass search "query" --robot --limit 5
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cass --version")
    assert_match "health", shell_output("#{bin}/cass --help")
  end
end
