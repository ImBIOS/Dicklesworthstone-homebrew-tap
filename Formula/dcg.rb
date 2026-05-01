# typed: false
# frozen_string_literal: true

class Dcg < Formula
  desc "Destructive Command Guard - Safety rails for AI coding agents"
  homepage "https://github.com/Dicklesworthstone/destructive_command_guard"
  version "0.4.11"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v0.3.0/dcg-aarch64-apple-darwin.tar.xz"
      sha256 "197266be8de3d2774eb338ebe10022216b8852f5a6cb9b9bc372fb4b278e72e9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v0.3.0/dcg-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "f842410c69a22232b0ad0e394f953734a4a04d8b95c6634b34ac8f3f36a53030"
    end
  end

  def install
    bin.install "dcg"
  end

  def caveats
    <<~EOS
      DCG (Destructive Command Guard) blocks dangerous commands from AI coding agents.

      Quick start:
        dcg test "rm -rf /"        # Test if a command would be blocked
        dcg explain "git push -f"  # See why a command is flagged
        dcg doctor                 # Verify installation

      To integrate with Claude Code, add to hooks:
        See: https://github.com/Dicklesworthstone/destructive_command_guard#integration
    EOS
  end

  test do
    system bin/"dcg", "--version"
  end
end
