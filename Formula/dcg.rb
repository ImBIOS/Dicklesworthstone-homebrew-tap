# typed: false
# frozen_string_literal: true

class Dcg < Formula
  desc "Destructive Command Guard - Safety rails for AI coding agents"
  homepage "https://github.com/Dicklesworthstone/destructive_command_guard"
  version "0.4.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v0.3.0/dcg-aarch64-apple-darwin.tar.xz"
      sha256 "d153fb5497db00ca6e253f58da1fae18ffcbed8633f610349e36860a27eec296"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v0.3.0/dcg-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "0a82555f9b15c69e55b6eaed2d73055671e62b50b13f39c10612d8de01b71f4e"
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
