# typed: false
# frozen_string_literal: true

class Dcg < Formula
  desc "Destructive Command Guard - Safety rails for AI coding agents"
  homepage "https://github.com/Dicklesworthstone/destructive_command_guard"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v0.3.0/dcg-aarch64-apple-darwin.tar.xz"
      sha256 "33d334fef0bf9f3a940fd05410ae312e77abba07373b8b6dded29bb06edc6157"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v0.3.0/dcg-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "c9463c73efe3ae05fef9fe3699e2b634a8195f4c0523a737c7cbad8a85617d5f"
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
