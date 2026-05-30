# CASS (Coding Agent Session Search) - Homebrew formula
# Index and search AI coding agent conversation histories

class Cass < Formula
  desc "Cross-agent session search - index and search AI coding agent conversations"
  homepage "https://github.com/Dicklesworthstone/coding_agent_session_search"
  version "0.6.9"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-darwin-arm64.tar.gz"
      sha256 "bbf0b5960201945656cb6a81c81198b7359b4a3a6ded52b36273f883c10c9383"
    end
    # No Intel macOS build is published for cass v0.4.7.
    # Intel macOS users should use the upstream install script with --from-source.
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-linux-amd64.tar.gz"
      sha256 "c1eae3357eeb1e507c5e7ae111fa3a5572fcae773c62b720ae694b81a10b8320"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/download/v#{version}/cass-linux-arm64.tar.gz"
      sha256 "6e941bfd95be219a0fd5154233a0d7a44bfd09858eb53ad3d82f2138b8db2200"
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
