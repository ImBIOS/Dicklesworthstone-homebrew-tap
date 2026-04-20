# CASS (Coding Agent Session Search) - Homebrew formula
# Index and search AI coding agent conversation histories

class Cass < Formula
  desc "Cross-agent session search - index and search AI coding agent conversations"
  homepage "https://github.com/Dicklesworthstone/coding_agent_session_search"
  version "0.3.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-darwin-arm64.tar.gz"
      sha256 "c55b78397d0a5f8765f6c0d90fc717dfc5fe4262d84ee7fd96b722712d9dd1f4"
    end
    # No Intel macOS build currently available
    # Apple Silicon (arm64) binaries can run on Intel via Rosetta 2
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-linux-amd64.tar.gz"
      sha256 "829d385ef69249ef7aa636de0a6644335b8daaab4b4fd7bf3f4aeec823ad75c9"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-linux-arm64.tar.gz"
      sha256 "7b5448d720670b522e5487de34ae0f2cc7023fe7205527db9fed4abb600ddaf6"
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
