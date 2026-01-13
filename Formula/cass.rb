# CASS (Coding Agent Session Search) - Homebrew formula
# Index and search AI coding agent conversation histories

class Cass < Formula
  desc "Cross-agent session search - index and search AI coding agent conversations"
  homepage "https://github.com/Dicklesworthstone/coding_agent_session_search"
  version "0.1.55"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/coding-agent-search-x86_64-apple-darwin.tar.xz"
      sha256 "c86441f8af59c02829f17d7609f368b3aeca832a4052bd803cb6c60826555e8e"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/coding-agent-search-aarch64-apple-darwin.tar.xz"
      sha256 "e9766e14cf7461d52eab8d441ef197f0f810499c891257abf5556cc9f581704b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/coding-agent-search-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "0f41d67cfe22e22d9cc43df7e34f83b81fbd3c675eeecaa12f86e958712e654b"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/coding-agent-search-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "6baa4b196de296bb90aee866868f0fea14e048cdaa45e2de4eb2c93a4862e4be"
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
