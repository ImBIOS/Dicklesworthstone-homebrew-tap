# CASS (Coding Agent Session Search) - Homebrew formula
# Index and search AI coding agent conversation histories

class Cass < Formula
  desc "Cross-agent session search - index and search AI coding agent conversations"
  homepage "https://github.com/Dicklesworthstone/coding_agent_session_search"
  version "0.4.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-darwin-arm64.tar.gz"
      sha256 "f409da9db762035a9fe70a9e72b1cdbb0b04d4351f5cd3afc8382ee61200fce3"
    end
    # No Intel macOS build currently available
    # Apple Silicon (arm64) binaries can run on Intel via Rosetta 2
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-linux-amd64.tar.gz"
      sha256 "770a63fb2b4e6ede2e61be7ee71dd13714ffa3dfe7dd64b3ed7a6709cff31ad3"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-linux-arm64.tar.gz"
      sha256 "e4d3e66f6e23c8aa5600b47de2e151fee4e3bb9cbe7600a1bbcd0827ef9cc8f6"
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
